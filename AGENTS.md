# AiLang Package Registry Agents

This repository is the curated package registry for AiLang.

## Rules

- Keep package records in `packages/*.toml`.
- Do not vendor package source in this repository.
- Package versions must resolve to immutable git commits.
- Tags may be used for readability, but every version entry must include the
  exact commit.
- Prefer one package record per pull request unless multiple package updates
  are intentionally related.
- IMPORTANT: Until a major or minor release is officially released, all
  contracts, APIs, schemas, interfaces, and architectural decisions are
  considered negotiable and may change freely. Do not add backward
  compatibility layers, legacy adapters, or dual-path support unless explicitly
  requested. When changing direction, replace the old implementation completely
  and update the codebase consistently to the new contract. Patch releases are
  for bug fixes only.

## Verification

```bash
find packages -name '*.toml' -print
```
