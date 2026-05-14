# Workflow Principles

Distilled from a working session on 2026-05-13 (provenance in `JOURNAL.md`). Focus: reducing churn and rework when developing with Claude Code, especially on internal tools and rebuilds.

This is a stable reference doc.

---

## Working context

These principles emerged from solo development of internal business tools — mostly rebuilds, not greenfield. The relevant constraints:

- **Most work is rebuilds.** Existing tools document intent. Don't re-do full product discovery — only the delta needs validating.
- **Internal tools, not consumer products.** "Finished" matters more than "polished." Aesthetic perfection is not the bar.
- **Solo developer.** No team review process to fall back on. The discipline lives in personal workflow.
- **Stack:** PHP + Alpine + Tailwind/DaisyUI. The frontend design system is being grown organically across multiple tools.
- **Common failure mode 1: under-specification.** Default-mode is vague prompts and refactor-after. The cost is invisible in the moment but compounds.
- **Common failure mode 2: perfectionism mid-task.** Quality-itches on small details break flow. They need to be journaled, not acted on.

---

## The core insight

Code is a thinking medium. You often don't fully know what you want until you see a draft. Pre-AI you wrote the bad first version yourself and rewrote it; the job hasn't changed, but the cost of producing the bad first version dropped to nearly zero. **The correct workflow is more drafts, faster — not fewer drafts, slower.**

The trap is treating each Claude generation as a commitment. Treat each as a *draft you might throw away*, and the churn stops feeling like failure.

---

## Three tiers of decision

Every task contains three types of decision. Under-specification = letting Tier 1 and Tier 2 leak down to Claude.

| Tier | Decisions | Owner |
|------|-----------|-------|
| 1 — Direction | What we're building, why, what shape, what it should NOT do | Human only |
| 2 — Fit | How it slots into existing system, abstractions, what to reuse | Human, with Claude consultation (Claude has grep; you have judgment) |
| 3 — Implementation | Naming, exact syntax, control flow, equivalent expressions | Claude |

Mistakes: over-specifying Tier 3 (exhausting, produces stilted code) or under-specifying Tier 1 (refactor churn).

---

## Minimum viable spec

Before sending any non-trivial prompt, ask whether you can complete this single line:

> **Build X, structured as Y, using existing pattern Z, and explicitly not Q.**

If you can't, you don't know what you want yet — and neither will Claude. Two outcomes:

- Can't write Y or Z because you haven't looked at the code → use an **exploration prompt** (research, don't implement).
- Can't write X cleanly because the problem is fuzzy → that's a **spike** — timeboxed, throwaway exploration. Name it as a spike rather than letting it pretend to be the real work.

Treating exploration, spike, and build prompts as the same thing is the root of most churn. They have different inputs, different outputs, different review standards.

---

## Port + redesign — separate the two jobs

Rebuilding an existing tool in a new stack is **two** jobs:

1. **Port** — same behavior, different stack. Mechanical, well-suited to Claude.
2. **Redesign** — changes to what the tool does. Requires human judgment.

Mixing them makes every diff ambiguous: was a change *"I expressed it this way in PHP"* or *"we decided to do it this way now"*? Review becomes impossible. The fix:

**Per page (or per module):**
1. **Pass A — port faithfully.** Same behavior, same structure. No improvements, no consolidation, no *"while you're in there."* Binary success criterion (behavior parity). Skim, don't deep-review.
2. **Pass B — apply written redesign bullets.** Now the redesign is the *only* thing being decided in that prompt.

Cheaper alternative if you don't want two passes: write a 3-bullet diff against the original *before* prompting (*what stays, what changes, what's removed/added*). Only works if the diff exists before the prompt — if you find yourself writing "see what works," you're not ready.

---

## Scoping questions

Three question sets depending on context — **greenfield**, **rebuild**, or **new feature on existing tool**. The full questions, probing rules, and exit criteria live in the `/scope-feature` skill at `custom-skills/scope-feature/SKILL.md` — that file is the single source of truth, so the questions don't drift between two places.

Run `/scope-feature` at the start of any non-trivial work. The skill asks one question at a time, caps probing at two follow-ups per question to avoid interrogation, and ends by drafting 2–3 candidate min-viable-spec lines for you to pick from.

**Key principle for rebuilds: inheritance is safe by default.** The existing tool documents intent for everything that stays the same. Only the delta needs validating — a much smaller list of things to ever bother users about than re-doing full discovery.

---

## Triage: fix now vs. journal

Mid-task improvements come in two flavors:

- **Shape-changing** (data model wrong, abstraction at wrong level, file structure wrong) → stop and fix. The longer you build on bad shape, the more expensive the unwind.
- **Quality-improving** (naming, ergonomics, polish, *"could be cleaner"*) → journal it, finish the slice.

Most people over-fix quality stuff mid-flow (because it itches) and under-fix shape stuff (because it feels like backtracking). The discipline is asking *"shape or quality?"* before acting on the itch.

---

## Capturing decisions

Format matters far less than the discipline of writing things down. For a single project, default to a markdown file in the repo (`redesign-notes.md`, `scope.md`). Reasons:

- Lives next to the code (won't drift, easy to find).
- Versioned with git (free history).
- No external dependency, no setup.
- Cheapest possible to write — friction is the enemy of any documentation practice.

The structured pattern worth knowing the name of: **ADRs (Architecture Decision Records)** — one doc per decision with three sections: *context, decision, consequences*. Use the formal template only if working with a team that needs the structure. For solo work, plain bullets suffice.

For *layout* decisions, **sketch, don't prose** — Excalidraw, tldraw, or paper. Trying to describe UI layout in words is fighting the medium.

Heavier tools (Notion, Obsidian, Linear) only when scope outgrows one project and you genuinely need cross-project search.

---

## Design system: build, don't design

The drift you get trying to *"design a system first"* then fit components to it is predictable. The path that works:

1. Pick the **one** internal tool that's most representative — the one you'd be least embarrassed to show.
2. Build *that one tool* to the standard you want. Don't worry about reusability yet. Tailwind + DaisyUI, but override consistently — most "modernizing" DaisyUI is just CSS variable overrides (colors, border radius, spacing scale) plus a small number of `@apply` component classes. **Theme, don't replace.**
3. Once that one tool feels right, *then* extract — only patterns you can point at in actual use. No speculative components.
4. For the next tool, copy from the first. Notice what doesn't carry cleanly. Those are the real system needs.
5. By tool 3 or 4, the design system emerges, grounded in real use.

**Don't retrofit old tools just to nitpick.** Use the **boy scout rule**: when you're already in an old tool for another reason (bug fix, new feature, complaint), bring it up to current standard. For internal tools, **finished beats consistent** — a shipped slightly-inconsistent tool is far more valuable than a polished one nobody can use yet.

The design system is the asset; uniformity of *old* tools is not.

### Variant: extract from an existing reference tool

The build-one-tool-first rule has an inverted form. If a tool already exists at the standard you want (e.g. Kaizen for Mullan internal apps), the "one tool built to standard" is *already done* — the next move is to **extract tokens (colour, radius, spacing, shadow) from it as the foundation for new tools**, without copying its component CSS. New tools build their own components on those tokens. Same principle, different starting point: the system still emerges from one real instance, just an existing one.

---

## How Claude operates — useful things to know

- **No memory between sessions** except for explicit memory files. Every new conversation starts cold.
- **Context window is finite.** Long sessions lose recall of their own start. Compact at ~60% (set `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE=60`), not 95%.
- **Cannot tell when it doesn't know.** Produces plausible-but-wrong code with the same confidence as correct code. Review is non-optional.
- **Plans look complete but contain unstated assumptions.** Both you and Claude fill gaps with priors. Surface gaps explicitly with concrete questions.
- **Grounded > vibes.** Works much better given files to read, tests to run, examples to mimic than working from abstract descriptions.

---

## Working rules at a glance

1. Write a one-line minimum-viable spec before any non-trivial prompt. If you can't, name it as exploration or a spike.
2. Use `/scope-feature` at the start of any feature work to force the spec onto paper.
3. For rebuilds: port faithfully first, then apply written redesign bullets. Don't mix the two jobs.
4. Triage mid-task improvements: shape-changing → fix now; quality-improving → journal.
5. Capture decisions in a markdown file next to the code. Don't shop for tools.
6. Build one tool to standard, then extract. Don't design systems in the abstract.
7. For internal tools: finished beats consistent. Retrofit old tools only on the boy scout rule.
8. Treat each Claude generation as a draft, not a deliverable.

---

The source conversation that produced this document is preserved in `JOURNAL.md`. Provenance only — not load-bearing.
