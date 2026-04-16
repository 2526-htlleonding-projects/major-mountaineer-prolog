# Copilot Instructions for `major-mountaineer-prolog`

## Game context from README

Major Mountaineer is a text adventure about a climber ("Major") progressing through mountain areas, centered on survival- and morality-flavored mechanics. The README frames two core thematic systems to preserve in future changes: an **apple juice dependency** (resource/pressure mechanic) and an **honor system** (good vs. harmful choices with consequences).

## Build, test, and lint commands

This repository does not define automated build, lint, or test scripts.

Use SWI-Prolog directly for execution and quick checks:

```bash
# Run the game loop entrypoint
swipl -q -s majorgame.pl -g start

# Run one focused behavior check ("single test" style)
swipl -q -s majorgame.pl -g "go(n),halt."
```

## High-level architecture

The project is a single-file text adventure built around mutable world state in Prolog:

- `majorgame.pl` is the game implementation and runtime entrypoint.
- `adventure_template.pl` is the baseline template the game is derived from; keep gameplay mechanics aligned with its structure when extending features.

Core runtime model in both files:

1. World state is tracked with dynamic predicates (`i_am_at/1`, `at/2`, `holding/1`).
2. Navigation is encoded as `path(CurrentRoom, Direction, NextRoom)` facts and executed via `go/1`.
3. Room rendering is split between `describe/1` (room narrative) and `notice_objects_at/1` (iterates visible objects).
4. Item interaction mutates state with `take/1` and `drop/1` through `retract/1` + `assert/1`.
5. `start/0` is the expected entrypoint and calls `instructions/0` then `look/0`.

## Key conventions in this codebase

- Keep mutable state predicates declared `dynamic` and initialized at file load with `retractall(...)` reset calls.
- Preserve the command pattern of a success clause with cut (`!`) followed by a fallback clause that prints user-facing failure text.
- Direction shortcuts (`n.`, `s.`, `e.`, `w.`) are thin wrappers over `go/1`; add any new movement aliases in the same style.
- Object listing uses the Prolog fail-driven loop pattern (`notice_objects_at/1` with trailing fallback clause). Keep this pattern for multi-item output.
- Command UX is intentionally interactive and text-first (`write/1`, `nl/0`), so new commands should follow the same console response style.
