# FAQ AI Search — Context for Claude Code

## Project Summary

Mullan Lighting FAQ app. Already built and working:
- ~200 FAQ entries stored in MySQL
- CRUD admin interface (add/edit/delete FAQs)
- Sales team view with category, tag, and keyword filtering

**Next feature:** AI search. Sales team types a natural language question. System finds the matching FAQs and returns a grounded natural language answer. Must not hallucinate — answers must come only from the database.

---

## Approach: Standard Vector RAG

Full implementation notes in `implementation-notes.md` in this directory.

Summary of the approach:
1. Generate a vector embedding for each FAQ (question + answer combined)
2. Store embeddings in the database alongside the FAQ data
3. At query time: embed the user's question, find top-5 most similar FAQs by cosine similarity
4. Send only those 5 FAQs to Claude with a strict system prompt
5. Return Claude's grounded answer to the user

This is ~8x cheaper per query than sending all 200 FAQs to the LLM.

---

## Before starting — read the existing codebase

Read the existing FAQ project before writing any code:
- Understand the current database schema (especially the `faqs` table)
- Find the existing FAQ controller(s) — create/update hooks need to be added there
- Find the existing FAQ view — the AI ask UI goes here
- Match existing code style exactly

---

## API Keys

The app needs an OpenAI API key for embeddings (`text-embedding-3-small`).

- Store as an environment variable: `OPENAI_API_KEY`
- Or in whatever `.env` / config pattern the project already uses
- **Never commit the key to git**

The app also needs a Claude (Anthropic) API key for answer generation.

- Store as: `ANTHROPIC_API_KEY`
- Same rules — never commit

---

## MySQL Version

Run `SELECT VERSION();` first. This determines which embedding storage approach to use:
- MySQL 9.0+: use native `VECTOR(1536)` column type
- MySQL < 9.0: use `JSON` column, compute cosine similarity in PHP

Both approaches are documented in `implementation-notes.md`.

---

## Constraints

- Follow PSR-12 and match existing codebase style
- Prepared statements always — never interpolate user input into SQL
- No business logic in templates
- Type hints on all method signatures
- Keep methods short — one responsibility per function
