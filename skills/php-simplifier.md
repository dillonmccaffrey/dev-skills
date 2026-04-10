# php-simplifier

**Source:** Custom skill — built for PHP full-stack development  
**Tier:** 1 — install on every PHP project  
**Workflow:** Any PHP project (vanilla, WordPress, Magento, framework-based)  
**Install:** `~/.claude/skills/php-simplifier/SKILL.md` (via `install.sh`)

## What it does

Post-edit cleanup agent for PHP files. Reviews recently modified code and applies refinements without changing functionality:

- PSR-12 style (indentation, braces, spacing)
- Type hints on all method signatures
- `match` expressions instead of nested ternaries
- Early returns instead of nested else blocks
- Null coalescing (`??`, `?->`) over `isset` chains
- Short focused methods (~20 lines max)
- Prepared statements — never string interpolation in SQL queries

## Why it matters for PHP specifically

PHP has a long history of insecure and inconsistent patterns. A codebase can easily accumulate:
- `$_GET['id']` interpolated directly into queries (SQL injection)
- Nested ternaries 3 levels deep
- 100-line methods doing 5 different things
- No type hints anywhere

This skill catches all of that on every edit.

## Not framework-specific

Works with any PHP: vanilla scripts, WordPress plugins, Magento modules, or Laravel. If the project uses a framework, the skill follows the existing patterns — it doesn't impose new ones.

## Benchmark

- Before: manually review PHP for style/safety issues before committing
- After: single-pass cleanup catches injection risks, missing type hints, and readability issues automatically
- Zero back-and-forth for style questions

## Trigger

`/php-simplifier` — run after finishing any PHP class, function, or script.  
Or set a stronger `description` field to make it auto-trigger without being asked.
