#!/usr/bin/env bash
# dev-skills — New Machine Setup
# Installs Tier 1 skills. Run once on a new machine.
# After running, check SKILLS-CATALOG.md for Tier 2 options.

set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BASE="https://raw.githubusercontent.com/anthropics/claude-plugins-official/main/plugins"

echo "Installing dev-skills..."

# commit-commands
mkdir -p ~/.claude/commands
curl -sf "$BASE/commit-commands/commands/commit.md"          -o ~/.claude/commands/commit.md
curl -sf "$BASE/commit-commands/commands/commit-push-pr.md"  -o ~/.claude/commands/commit-push-pr.md
curl -sf "$BASE/commit-commands/commands/clean_gone.md"      -o ~/.claude/commands/clean_gone.md
echo "  [+] commit-commands (commit, commit-push-pr, clean_gone)"

# security-guidance hook
mkdir -p ~/.claude/hooks
curl -sf "$BASE/security-guidance/hooks/security_reminder_hook.py" \
  -o ~/.claude/hooks/security_reminder_hook.py

HOOK_CMD="python3 $HOME/.claude/hooks/security_reminder_hook.py"
SETTINGS="$HOME/.claude/settings.json"
[ -f "$SETTINGS" ] || echo '{"permissions":{"allow":[],"deny":[]}}' > "$SETTINGS"

python3 - <<EOF
import json, os
path = os.path.expanduser("~/.claude/settings.json")
with open(path) as f:
    s = json.load(f)
entry = {"matcher": "Edit|Write|MultiEdit", "hooks": [{"type": "command", "command": "$HOOK_CMD"}]}
s.setdefault("hooks", {}).setdefault("PreToolUse", [])
if not any(h.get("matcher") == "Edit|Write|MultiEdit" for h in s["hooks"]["PreToolUse"]):
    s["hooks"]["PreToolUse"].append(entry)
    with open(path, "w") as f:
        json.dump(s, f, indent=2)
EOF
echo "  [+] security-guidance hook (fires on every file edit)"

# session-report
mkdir -p ~/.claude/skills/session-report
SR="https://raw.githubusercontent.com/anthropics/claude-plugins-official/main/plugins/session-report/skills/session-report"
curl -sf "$SR/SKILL.md"              -o ~/.claude/skills/session-report/SKILL.md
curl -sf "$SR/analyze-sessions.mjs"  -o ~/.claude/skills/session-report/analyze-sessions.mjs
curl -sf "$SR/template.html"         -o ~/.claude/skills/session-report/template.html
echo "  [+] session-report (/session-report or /session-report 7d)"

# php-simplifier (custom — from this repo)
mkdir -p ~/.claude/skills/php-simplifier
cp "$SCRIPT_DIR/custom-skills/php-simplifier/SKILL.md" ~/.claude/skills/php-simplifier/SKILL.md
echo "  [+] php-simplifier (/php-simplifier)"

echo ""
echo "Done. Tier 1 installed."
echo ""
echo "Optional Tier 2 — install what fits the project:"
echo "  feature-dev   : curl -sf '$BASE/feature-dev/commands/feature-dev.md' -o ~/.claude/commands/feature-dev.md"
echo "  code-review   : curl -sf '$BASE/code-review/commands/code-review.md' -o ~/.claude/commands/code-review.md"
echo "  playwright    : add to .mcp.json: { \"playwright\": { \"command\": \"npx\", \"args\": [\"@playwright/mcp@latest\"] } }"
echo ""
echo "See SKILLS-CATALOG.md for full details and decision criteria."
