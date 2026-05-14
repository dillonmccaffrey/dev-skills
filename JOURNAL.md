# Journal — workflow sessions

Source-conversation logs that produced the stable docs in this repo. Provenance only — not load-bearing. The distilled principles live in `WORKFLOW-PRINCIPLES.md`; this file exists so the origin of those principles is not lost.

---

## 2026-05-13 — workflow improvement session

Working session between Dillon and Claude. Output: `WORKFLOW-PRINCIPLES.md` + the `/scope-feature` skill. Topics covered in order:

1. **The one-shot-perfection trap** — replaced with the *more drafts, faster* frame.
2. **Three-tier decision model** — Tier 1 (direction) leaking down to Claude is the main churn cause.
3. **The "lazy brain" framing** — re-framed as a miscalibrated cost function (optimize for total task cost, not current prompt cost).
4. **Minimum viable spec format** — *"Build X, structured as Y, using pattern Z, not Q."*
5. **Concrete example: Streamlit → PHP/Alpine port** at Mullan Lighting. Diagnosed as port + redesign mixed.
6. **Discovery vs. construction** — when a redesign spec doesn't yet exist, the next step is writing it down, not prompting Claude.
7. **Architecture renamed to product/scoping** — software architecture (code structure) and product scoping (what to build) are different muscles. The user was describing the latter.
8. **Rebuild adaptation of the five questions** — most internal-tools work is rebuilds; inheritance is safe, only the delta needs validation.
9. **Tools for capturing decisions** — markdown file in repo > Notion/Obsidian. ADRs worth knowing the name of. Sketch don't prose for layout.
10. **Design system dead end** — diagnosed as building the system before having a concrete instance to extract from. Fix is build-one-tool-well-then-extract.
11. **Iteration paradox** — accept that old tools won't match new standards; boy scout rule only; finished beats consistent.
12. **Built `/scope-feature` skill** and the principles doc as portable artifacts.

The live working queue tracking ongoing threads lives at `~/docs/claude-workflow-queue.md` on the personal laptop.
