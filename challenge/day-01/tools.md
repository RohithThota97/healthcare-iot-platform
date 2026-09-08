# Day 1 — Tools

No new services today. You only need what [SETUP.md](../SETUP.md) installed, plus a way to draw.

| Tool | Purpose | Config checkpoint / trap |
|---|---|---|
| Mermaid (built into GitHub Markdown) | Data-flow diagrams in `docs/` | Fence with ```mermaid; preview in the GitHub PR, not just your editor |
| draw.io / Excalidraw (optional) | Richer diagrams | Export **both** the editable source (`.drawio`/`.excalidraw`) and a `.png`/`.svg` into `docs/img/` so it's reviewable |
| ADR tooling (optional) | Numbering ADRs | `adr-tools` (`brew install adr-tools`) or just copy a template file — don't spend more than 10 min here |

### ADR template to drop in `docs/adr/`

```markdown
# NNNN. <short title of decision>
Date: YYYY-MM-DD
Status: accepted            # proposed | accepted | superseded by NNNN

## Context
<the forces at play, constraints, what we know and don't>

## Decision
<the choice, stated in one or two sentences>

## Alternatives considered
- <option>: <why rejected>
- <option>: <why rejected>

## Consequences
<what becomes easier, what becomes harder, what we now must live with>
```

### Trap

Don't let diagramming eat the day. A clear Mermaid `flowchart LR` beats a beautiful Figma board
you finish at midnight. Time-box C4 to 2 hours.
