# FAQ AI Search — Implementation Notes

## Stack

- Vanilla PHP
- MySQL (check version: `SELECT VERSION();`)
- PDO for database access
- OpenAI API for embeddings (`text-embedding-3-small`)
- Anthropic API (Claude) for answer generation

---

## Step 1 — Database migration

### MySQL 9.0+ (preferred)
```sql
ALTER TABLE faqs ADD COLUMN embedding VECTOR(1536) NULL;
```

### MySQL < 9.0 (fallback)
```sql
ALTER TABLE faqs ADD COLUMN embedding JSON NULL;
```

Store as `migration_add_faq_embeddings.sql` and run it once.

---

## Step 2 — EmbeddingService

`src/Services/EmbeddingService.php`

```php
<?php

declare(strict_types=1);

class EmbeddingService
{
    private string $apiKey;
    private string $model = 'text-embedding-3-small';
    private int $dimensions = 1536;

    public function __construct(string $apiKey)
    {
        $this->apiKey = $apiKey;
    }

    public function embed(string $text): array
    {
        $payload = json_encode([
            'input' => $text,
            'model' => $this->model,
            'dimensions' => $this->dimensions,
        ]);

        $ch = curl_init('https://api.openai.com/v1/embeddings');
        curl_setopt_array($ch, [
            CURLOPT_RETURNTRANSFER => true,
            CURLOPT_POST => true,
            CURLOPT_POSTFIELDS => $payload,
            CURLOPT_HTTPHEADER => [
                'Content-Type: application/json',
                'Authorization: Bearer ' . $this->apiKey,
            ],
        ]);

        $response = curl_exec($ch);
        $status = curl_getinfo($ch, CURLINFO_HTTP_CODE);
        curl_close($ch);

        if ($status !== 200) {
            throw new RuntimeException('OpenAI embeddings API error: ' . $response);
        }

        $data = json_decode($response, true);
        return $data['data'][0]['embedding'];
    }
}
```

---

## Step 3 — FaqSearchService

`src/Services/FaqSearchService.php`

Handles similarity search. Supports both MySQL 9.0+ (native VECTOR) and older MySQL (PHP cosine similarity).

```php
<?php

declare(strict_types=1);

class FaqSearchService
{
    private PDO $pdo;
    private EmbeddingService $embedder;
    private bool $mysqlVectorSupport;

    public function __construct(PDO $pdo, EmbeddingService $embedder, bool $mysqlVectorSupport)
    {
        $this->pdo = $pdo;
        $this->embedder = $embedder;
        $this->mysqlVectorSupport = $mysqlVectorSupport;
    }

    /**
     * Find the top-K most relevant FAQs for a given question.
     * Returns array of ['id', 'question', 'answer'] rows.
     */
    public function findRelevant(string $question, int $limit = 5): array
    {
        $queryEmbedding = $this->embedder->embed($question);

        if ($this->mysqlVectorSupport) {
            return $this->searchWithVector($queryEmbedding, $limit);
        }

        return $this->searchWithPhp($queryEmbedding, $limit);
    }

    private function searchWithVector(array $queryEmbedding, int $limit): array
    {
        $vectorJson = json_encode($queryEmbedding);
        $stmt = $this->pdo->prepare(
            "SELECT id, question, answer
             FROM faqs
             ORDER BY DISTANCE(embedding, CAST(:vec AS VECTOR(1536)), 'cosine') ASC
             LIMIT :limit"
        );
        $stmt->bindValue(':vec', $vectorJson);
        $stmt->bindValue(':limit', $limit, PDO::PARAM_INT);
        $stmt->execute();
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    private function searchWithPhp(array $queryEmbedding, int $limit): array
    {
        $stmt = $this->pdo->query('SELECT id, question, answer, embedding FROM faqs WHERE embedding IS NOT NULL');
        $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

        $scored = [];
        foreach ($rows as $row) {
            $faqEmbedding = json_decode($row['embedding'], true);
            $scored[] = [
                'id'         => $row['id'],
                'question'   => $row['question'],
                'answer'     => $row['answer'],
                'similarity' => $this->cosineSimilarity($queryEmbedding, $faqEmbedding),
            ];
        }

        usort($scored, fn($a, $b) => $b['similarity'] <=> $a['similarity']);

        return array_slice(
            array_map(fn($r) => ['id' => $r['id'], 'question' => $r['question'], 'answer' => $r['answer']], $scored),
            0,
            $limit
        );
    }

    private function cosineSimilarity(array $a, array $b): float
    {
        $dot = 0.0;
        $normA = 0.0;
        $normB = 0.0;

        foreach ($a as $i => $val) {
            $dot   += $val * $b[$i];
            $normA += $val * $val;
            $normB += $b[$i] * $b[$i];
        }

        $denom = sqrt($normA) * sqrt($normB);
        return $denom > 0.0 ? $dot / $denom : 0.0;
    }
}
```

---

## Step 4 — One-time backfill script

`scripts/generate-embeddings.php`

Run once from CLI to embed all existing FAQs.

```php
<?php

declare(strict_types=1);

require_once __DIR__ . '/../config/database.php'; // adjust path to match project
require_once __DIR__ . '/../src/Services/EmbeddingService.php';

$apiKey = getenv('OPENAI_API_KEY') ?: trim(file_get_contents(__DIR__ . '/../.openai-key'));
$embedder = new EmbeddingService($apiKey);

$stmt = $pdo->query('SELECT id, question, answer FROM faqs WHERE embedding IS NULL');
$faqs = $stmt->fetchAll(PDO::FETCH_ASSOC);

echo 'Embedding ' . count($faqs) . " FAQs...\n";

$update = $pdo->prepare('UPDATE faqs SET embedding = :embedding WHERE id = :id');

foreach ($faqs as $faq) {
    $text = $faq['question'] . ' ' . $faq['answer'];
    $vector = $embedder->embed($text);

    $update->execute([
        ':embedding' => json_encode($vector),
        ':id'        => $faq['id'],
    ]);

    echo "  Embedded FAQ #{$faq['id']}\n";
    usleep(100000); // 100ms pause — stay within rate limits
}

echo "Done.\n";
```

Run: `php scripts/generate-embeddings.php`

---

## Step 5 — FaqAiController

`src/Controllers/FaqAiController.php`

Handles `POST /api/faq/ask`.

```php
<?php

declare(strict_types=1);

class FaqAiController
{
    private FaqSearchService $search;
    private string $anthropicKey;

    public function __construct(FaqSearchService $search, string $anthropicKey)
    {
        $this->search = $search;
        $this->anthropicKey = $anthropicKey;
    }

    public function ask(): void
    {
        header('Content-Type: application/json');

        $body = json_decode(file_get_contents('php://input'), true);
        $question = trim($body['question'] ?? '');

        if ($question === '') {
            http_response_code(400);
            echo json_encode(['error' => 'Question is required']);
            return;
        }

        $faqs = $this->search->findRelevant($question, limit: 5);

        if (empty($faqs)) {
            echo json_encode(['answer' => "I don't have information about that in our FAQ database."]);
            return;
        }

        $context = $this->buildContext($faqs);
        $answer = $this->generateAnswer($question, $context);

        echo json_encode(['answer' => $answer]);
    }

    private function buildContext(array $faqs): string
    {
        $parts = [];
        foreach ($faqs as $i => $faq) {
            $parts[] = 'FAQ ' . ($i + 1) . ":\nQ: {$faq['question']}\nA: {$faq['answer']}";
        }
        return implode("\n\n", $parts);
    }

    private function generateAnswer(string $question, string $context): string
    {
        $systemPrompt = 'You are a helpful FAQ assistant for Mullan Lighting. '
            . 'Answer the user\'s question using ONLY the FAQ entries provided. '
            . 'If the answer is not in the FAQs, say so explicitly. '
            . 'Never make up information or use knowledge outside the provided FAQs.';

        $userMessage = "Here are the relevant FAQs:\n\n{$context}\n\nQuestion: {$question}";

        $payload = json_encode([
            'model'      => 'claude-sonnet-4-6',
            'max_tokens' => 512,
            'system'     => $systemPrompt,
            'messages'   => [
                ['role' => 'user', 'content' => $userMessage],
            ],
        ]);

        $ch = curl_init('https://api.anthropic.com/v1/messages');
        curl_setopt_array($ch, [
            CURLOPT_RETURNTRANSFER => true,
            CURLOPT_POST => true,
            CURLOPT_POSTFIELDS => $payload,
            CURLOPT_HTTPHEADER => [
                'Content-Type: application/json',
                'x-api-key: ' . $this->anthropicKey,
                'anthropic-version: 2023-06-01',
            ],
        ]);

        $response = curl_exec($ch);
        $status = curl_getinfo($ch, CURLINFO_HTTP_CODE);
        curl_close($ch);

        if ($status !== 200) {
            throw new RuntimeException('Anthropic API error: ' . $response);
        }

        $data = json_decode($response, true);
        return $data['content'][0]['text'] ?? 'Unable to generate a response.';
    }
}
```

---

## Step 6 — Hook into existing FAQ create/update

In your existing FAQ controller, after every INSERT or UPDATE:

```php
// After saving FAQ to DB — re-embed so the new/updated entry is searchable
$text = $question . ' ' . $answer;
$vector = $embedder->embed($text);
$stmt = $pdo->prepare('UPDATE faqs SET embedding = :embedding WHERE id = :id');
$stmt->execute([':embedding' => json_encode($vector), ':id' => $id]);
```

---

## Step 7 — Frontend UI

Add to the existing sales team FAQ view. Match existing CSS class conventions.

```html
<div class="faq-ai-search">
    <input type="text" id="faq-question" placeholder="Ask a question..." />
    <button id="faq-ask-btn">Ask</button>
    <div id="faq-ai-answer" hidden></div>
</div>

<script>
document.getElementById('faq-ask-btn').addEventListener('click', async () => {
    const question = document.getElementById('faq-question').value.trim();
    if (!question) return;

    const answerEl = document.getElementById('faq-ai-answer');
    answerEl.hidden = false;
    answerEl.textContent = 'Searching...';

    const res = await fetch('/api/faq/ask', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ question }),
    });

    const data = await res.json();
    answerEl.textContent = data.answer ?? data.error ?? 'Something went wrong.';
});
</script>
```

---

## Routing

Wire `POST /api/faq/ask` to `FaqAiController::ask()` using whatever routing pattern the project already uses.

---

## Test cases

| Test | Expected |
|------|----------|
| Question matching a FAQ closely | Returns grounded answer from that FAQ |
| Same question phrased differently | Still finds the right FAQ (semantic match) |
| Question outside the FAQs | "I don't have information about that" — NOT a hallucinated answer |
| Empty question submitted | 400 error, no API call made |

---

## Cost estimates

| Operation | Cost |
|-----------|------|
| One-time backfill (200 FAQs) | ~$0.0004 |
| Per query — embedding (user question) | ~$0.000001 |
| Per query — Claude answer generation | ~$0.008-0.015 |
| Per query total | ~$0.008-0.016 |

At 500 queries/month: ~$4-8/month.

---

## Environment variables

```
OPENAI_API_KEY=sk-...
ANTHROPIC_API_KEY=sk-ant-...
```

Add to `.env` or whatever config pattern the project uses. Never commit either key.
