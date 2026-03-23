📘 Creating `AGENTS.md` / `CLAUDE.md` for Projects

## Purpose

This document describes the process used to create and refine `AGENTS.md` (and `CLAUDE.md`) for any repository or project.

The goal is not to follow a rigid external convention, but to:

- **Codify real project standards**
- **Improve AI agent performance**
- **Align platform direction intentionally**
- **Avoid outdated or generic assumptions**
- **Make the process reusable across projects**

## 🎯 High-Level Principles

- **Start from reality, not theory**
  Extract conventions from the actual codebase.

- **Align with documented standards**
  Cross-check with official internal guidelines (e.g. Compass).

- **Align cross-platform where it makes sense**
  Reduce unnecessary divergence between iOS / Android templates.

- **Remove obsolete assumptions**
  Reflect current technical direction (e.g. no UIKit if we’ve moved on).

- **Optimize for agent behavior, not just readability**
  The document exists to improve output quality.

## 🧭 The Step-by-Step Flow

### Step 1 — Scan the Codebase

Use AI to analyze the repository or project and extract:

- **Architectural patterns**
- **Folder structure**
- **Naming conventions**
- **Testing setup**
- **Dependency management**
- **Build assumptions**
- **Implicit rules** (e.g. SwiftUI-only, modularization style)

**Prompt example**

> Analyze this repository and extract:
>
> - Architectural conventions
> - Folder structure standards
> - Testing conventions
> - Platform assumptions
> - Implicit coding rules
>
> The goal is to surface conventions that are already being followed — even if undocumented.

### Step 2 — Cross-Check with Internal Standards

Scan official documentation:

- **iOS Compass guidelines**
- **Engineering standards**
- **Security policies**
- **CI/CD requirements**

Identify:

- **Gaps** between codebase and documentation
- **Outdated practices**
- **Inconsistencies**

This ensures `AGENTS.md` reflects both:

- **Reality**
- **Intended standards**

### Step 3 — Cross-Platform Alignment

Review equivalent or sibling projects (e.g. Android app, backend service).

Look for:

- **Shared architectural philosophies**
- **Similar testing strategies**
- **Naming consistency**
- **Modularization approach**
- **Dependency management philosophy**

The goal is alignment where it makes sense, not forced symmetry.

**Benefits:**

- **Easier mental model** for engineers switching platforms
- **Consistent AI behavior** across repositories
- **Easier long-term maintenance**

### Step 4 — Consolidate & Refine

Aggregate everything into a structured base context.

Then:

- **Remove outdated assumptions** (e.g. UIKit if deprecated)
- **Remove legacy practices**
- **Clarify direction** (e.g. SwiftUI-first)
- **Ensure no contradictions**

This step turns raw extraction into intentional design.

### Step 5 — Optimize for Agent Performance

After drafting `AGENTS.md` / `CLAUDE.md`:

**Test it.**

Run typical AI tasks:

- **Generate a new feature**
- **Refactor a module**
- **Write tests**
- **Propose architecture changes**

Observe:

- **Is output generic?**
- **Is it platform-aware?**
- **Does it respect structure?**
- **Does it follow testing standards?**

Iterate until behavior improves.

This step is critical — documentation is validated by output quality.

## 🧠 Why Not Just Copy Public Examples?

Public `AGENTS.md` examples vary widely in quality and maturity.

Instead of copying:

- **We treat `AGENTS.md` as a system-level context definition.**
- **It should encode our internal standards.**
- **It should evolve with the project.**

There is currently no strict ecosystem convention for structure or role-setting. Flexibility is intentional.

## 🧩 Role-Setting (Optional but Contextual)

If the repository is platform-specific (e.g. iOS app, Android app, backend service):

A base-level role-setting may be used to prime:

- **Platform conventions**
- **Framework assumptions**
- **Tooling expectations**

However:

- **Specialized agents can override it.**
- **This is contextual, not mandatory.**
- **It should reflect repository scope.**

## 🔄 When to Update `AGENTS.md`

Update when:

- **Architecture changes**
- **Tooling changes**
- **Platform direction changes**
- **Testing strategy changes**
- **Major conventions evolve**

Treat it as living documentation.

## 🚀 How to Apply This Flow to Other Projects

For any repository or project:

- **AI-scan the codebase**
- **Extract conventions**
- **Cross-check with official docs**
- **Compare with sibling repositories or projects**
- **Consolidate intentionally**
- **Validate through AI behavior**
- **Iterate**

Do not start from a blank document.
Start from the system itself.

## ✅ Outcome

This process ensures:

- **AI agents operate with high context fidelity**
- **Internal standards are encoded explicitly**
- **Cross-platform alignment is intentional**
- **Documentation reflects current technical direction**
- **Teams do not reinvent the process**
