# Claude Code — Full Stack Developer Context

## Skill Library

This repo contains skills and setup instructions for Claude Code. Clone and install on any machine:

```bash
git clone https://github.com/dillonmccaffrey/dev-skills ~/dev-skills
bash ~/dev-skills/install.sh
```

After installing, read `SKILLS-CATALOG.md` to decide which Tier 2 skills apply to the current project.

---

## Role

Full Stack Developer. Work includes:
- Building and maintaining web applications and internal business tools
- PHP backend development (vanilla PHP and/or frameworks as the project requires)
- Frontend development (HTML, CSS, JavaScript — vanilla or framework-based)
- Database design and querying (MySQL/PostgreSQL)
- REST API design and consumption
- Deployment and maintenance of production systems

---

## PHP Conventions

Follow PSR-12. Match existing codebase style above everything else.

- **Type hints** on all method signatures
- **Prepared statements always** — never string interpolation in SQL queries
- **Early returns** over nested else blocks
- **`match` expressions** instead of nested ternaries
- **Short methods** — one responsibility per function/method
- **No business logic in templates** — templates display data only
- Read existing code before proposing new patterns

---

## JavaScript / Frontend Conventions

- Vanilla JS preferred unless the project already uses a framework
- If a framework is in use, follow its existing patterns — do not mix
- CSS: match existing methodology (BEM, utility classes, or plain CSS — follow what's there)
- Accessibility: semantic HTML, `alt` attributes, keyboard navigability on interactive elements

---

## Database

- MySQL preferred; follow the schema conventions already in place
- Write readable queries — alias columns where names would be ambiguous
- Index foreign keys; avoid `SELECT *` in production queries
- Migrations should be reversible where possible

---

## General Approach

- Understand the existing codebase before making suggestions
- Follow the patterns already in use — consistency beats novelty
- Ask before introducing new dependencies
- Security hook is active — it will flag SQL injection and XSS risks as you edit
- Use `/feature-dev` for any feature that requires understanding existing architecture first
- Use `/commit-push-pr` for all feature work

---

## Skills Available on This Machine

| Skill | Trigger |
|-------|---------|
| `/commit` | Stage and commit |
| `/commit-push-pr` | Commit + push + open PR |
| `/clean_gone` | Remove merged local branches |
| `/php-simplifier` | Post-edit PHP cleanup |
| `/feature-dev` | Structured feature development |
| `/code-review` | Review a PR with multi-agent analysis |
| `/session-report` | Weekly token usage report |
| Security guidance | Auto — fires on every file edit |
