#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
failed=0

fail() {
  echo "$1" >&2
  failed=1
}

extract_string() {
  local key="$1"
  local file="$2"
  sed -n "s/^${key} = \"\\(.*\\)\"$/\\1/p" "${file}" | head -n 1
}

check_record() {
  local file="$1"
  local base
  local name
  local repo
  local package_root
  local license
  local types
  local default_version
  local version_count

  base="$(basename "${file}" .toml)"
  name="$(extract_string name "${file}")"
  repo="$(extract_string repo "${file}")"
  package_root="$(extract_string packageRoot "${file}")"
  license="$(extract_string license "${file}")"
  default_version="$(extract_string defaultVersion "${file}")"
  types="$(sed -n 's/^types = \[\(.*\)\]$/\1/p' "${file}" | head -n 1)"
  version_count="$(rg -c '^\[versions\."' "${file}" || true)"

  if ! rg -q '^schema = "ailang\.package\.v1"$' "${file}"; then
    fail "missing registry schema: ${file}"
  fi
  if [[ -z "${name}" ]]; then
    fail "missing package name: ${file}"
  elif [[ "${name}" != "${base}" ]]; then
    fail "package filename/name mismatch: ${file} has name ${name}"
  fi
  if [[ ! "${name}" =~ ^[a-z][a-z0-9]*(-[a-z0-9]+)*$ ]]; then
    fail "invalid package name '${name}' in ${file}"
  fi
  if [[ -z "${repo}" ]]; then
    fail "missing repo: ${file}"
  elif [[ ! "${repo}" =~ ^https://github\.com/AiLangCore/[A-Za-z0-9._-]+\.git$ ]]; then
    fail "repo must be an AiLangCore git URL: ${file}"
  fi
  if [[ -z "${package_root}" ]]; then
    fail "missing packageRoot: ${file}"
  elif [[ "${package_root}" = /* || "${package_root}" == *..* ]]; then
    fail "packageRoot must be relative and cannot contain '..': ${file}"
  fi
  if [[ -z "${license}" ]]; then
    fail "missing license: ${file}"
  fi
  if [[ -z "${types}" ]]; then
    fail "missing types: ${file}"
  else
    while IFS= read -r type; do
      [[ -z "${type}" ]] && continue
      if [[ ! "${type}" =~ ^(library|tool|template|target)$ ]]; then
        fail "invalid package type '${type}' in ${file}"
      fi
    done < <(printf '%s\n' "${types}" | tr ',' '\n' | tr -d ' "')
  fi
  if [[ "${version_count}" -eq 0 ]]; then
    fail "missing versions: ${file}"
  fi
  if [[ -z "${default_version}" ]]; then
    fail "missing defaultVersion: ${file}"
  elif ! rg -q "^\\[versions\\.\"${default_version}\"\\]$" "${file}"; then
    fail "defaultVersion does not match a version table: ${file}"
  fi

  while IFS= read -r version; do
    local section
    local body
    local ref
    local commit
    section="[versions.\"${version}\"]"
    body="$(awk -v section="${section}" '
      $0 == section { in_section = 1; next }
      in_section && /^\[/ { exit }
      in_section { print }
    ' "${file}")"
    ref="$(printf '%s\n' "${body}" | sed -n 's/^ref = "\(.*\)"$/\1/p' | head -n 1)"
    commit="$(printf '%s\n' "${body}" | sed -n 's/^commit = "\(.*\)"$/\1/p' | head -n 1)"
    if [[ -z "${ref}" ]]; then
      fail "missing ref for ${name}@${version}"
    fi
    if [[ ! "${commit}" =~ ^[0-9a-f]{40}$ ]]; then
      fail "commit must be a 40-character lowercase SHA for ${name}@${version}"
    fi
  done < <(sed -n 's/^\[versions\."\([^"]*\)"\]$/\1/p' "${file}")
}

while IFS= read -r record; do
  check_record "${record}"
done < <(find "${ROOT_DIR}/packages" -name '*.toml' -print | sort)

if [[ "${failed}" -ne 0 ]]; then
  exit 1
fi

echo "registry validation: PASS"
