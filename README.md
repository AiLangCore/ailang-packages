# AiLang Package Registry

This repository is the curated package registry for AiLang.

The registry does not host package source. Each package record points to a git
repository, package root, and approved immutable versions.

Package records may declare item types:

- `library`: importable AiLang source.
- `tool`: executable command or project tool.
- `template`: project, file, or agent template content.

A single package may contain multiple types. For example, AiVectra can expose
libraries, tools, and templates from one package.

## Layout

```text
packages/
  <package-name>.toml
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

## Rules

- One package per TOML file.
- Package files use lowercase names with hyphens when needed.
- Versions must resolve to immutable git commits.
- Tags may be used as readable refs, but the exact commit is required.
- Registry changes should be made by pull request.
