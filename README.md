# AiLang Package Registry

This repository is the curated package registry for AiLang.

The registry does not host package source. Each package record points to a git
repository, package root, and approved immutable versions.

## Status

This is the public curated registry used by `ailang package restore`.
Registry records are intentionally small and point at immutable source commits.

This repository uses `main` as its public default branch. Registry changes are
curated through pull requests and become visible to package restore after they
land on `main`.

Public roadmap:

- https://ailang.codes/docs/roadmap.html

Package records may declare item types:

- `library`: importable AiLang source.
- `tool`: executable command or project tool.
- `template`: project, file, or agent template content.
- `target`: build/publish/run target metadata, runner recipes, and host tool requirements.

A single package may contain multiple types. For example, AiVectra can expose
libraries, tools, and templates from one package. AiOS target packages can
expose target metadata, package-owned tools, and starter templates from one
package.

## Layout

```text
packages/
  <package-name>.toml
```

Validate registry metadata with the AiLang package tooling from an installed
SDK:

```bash
./scripts/validate-registry.sh
ailang package list
```

## Package Record

```toml
schema = "ailang.package.v1"
name = "example"
repo = "https://github.com/AiLangCore/example.git"
packageRoot = "."
license = "MIT"
types = ["library"]

[versions."0.0.1-alpha.1"]
ref = "v0.0.1-alpha.1"
commit = "exact-git-commit"
```

Target package records use the same shape:

```toml
schema = "ailang.package.v1"
name = "target-aios-service"
repo = "https://github.com/AiLangCore/ailang-core-packages.git"
packageRoot = "packages/target-aios-service"
license = "MIT"
types = ["target", "tool", "template"]
defaultVersion = "0.0.1-alpha.1"
```

## Rules

- One package per TOML file.
- Package files use lowercase names with hyphens when needed.
- Versions must resolve to immutable git commits.
- Tags may be used as readable refs, but the exact commit is required.
- Registry changes should be made by pull request.
- `defaultVersion`, when present, must point at an existing version table.
- `types` must match the source package contents.
- `repo` must point to an AiLangCore GitHub repository.
- `commit` values must be exact 40-character lowercase git SHAs.
- Target packages must declare stable target ids and any external tools required
  for `build`, `publish`, `run`, `test`, `doctor`, or device workflows.

## Publishing Workflow

Package publishing is currently a curated pull-request workflow:

1. Release or tag the package source repository.
2. Resolve that ref to the exact git commit.
3. Add or update `packages/<package-name>.toml`.
4. Include the readable `ref` and immutable `commit`.
5. Validate restore/build/run with an example project before requesting review.

Example validation:

```bash
ailang package restore examples/package-demo
ailang package list examples/package-demo
ailang build examples/package-demo
ailang run examples/package-demo
```

Do not point registry entries at moving branches without recording the exact
commit that users should restore.

Package source for official optional libraries lives in
[AiLangCore/ailang-core-packages](https://github.com/AiLangCore/ailang-core-packages).
