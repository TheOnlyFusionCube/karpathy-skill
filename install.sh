#!/usr/bin/env bash
# andrej-karpathy — universal installer.
#
# One-line install:
#   curl -fsSL https://raw.githubusercontent.com/TheOnlyFusionCube/karpathy-skill/main/install.sh | bash
#   curl -fsSL .../install.sh | bash -s -- --all
#
# Local clone:
#   bash install.sh [--all|--claude|--codex|--gemini|--cursor|--opencode|--devin|--agents]
#   bash install.sh --uninstall
#
# Installs the andrej-karpathy skill (SKILL.md + references/) into each detected
# agent's skills directory, plus a /karpathy command where the tool supports one.
# Pure file copies — no daemons, no hooks, no dependencies.

set -euo pipefail

REPO="TheOnlyFusionCube/karpathy-skill"
BRANCH="${KARPATHY_REF:-main}"
SKILL_NAME="andrej-karpathy"

say()  { printf '%s\n' "$*"; }
ok()   { printf '  + %s\n' "$*"; }
skip() { printf '  - %s (not found, skipping)\n' "$*"; }
die()  { printf 'install.sh: %s\n' "$*" >&2; exit 1; }

usage() {
  cat <<'EOF'
andrej-karpathy installer

Usage: install.sh [targets] [--uninstall] [--list]

Targets (default: auto-detect installed agents):
  --agents    ~/.agents/skills                        (shared cross-tool skills dir)
  --claude    ~/.claude/skills + commands/ + agents/  (Claude Code)
  --codex     ~/.codex/skills                         (OpenAI Codex CLI)
  --gemini    ~/.gemini/skills + commands/            (Gemini CLI)
  --cursor    ~/.cursor/skills                        (Cursor)
  --opencode  ~/.config/opencode/skills + command/    (opencode)
  --devin     ~/.config/devin/skills                  (Devin CLI)
  --all       every target above

Other flags:
  --uninstall  remove installed copies
  --list       show what would install / what exists
  -h, --help   this message
EOF
}

# --- resolve source payload -------------------------------------------------
# Local clone: use ./skills etc. Curl|bash: fetch the repo tarball to a tmpdir.
SRC=""
TMPDIR_MINE=""
cleanup() { [ -n "$TMPDIR_MINE" ] && rm -rf "$TMPDIR_MINE" 2>/dev/null || true; }
trap cleanup EXIT

resolve_source() {
  if [ -f "${BASH_SOURCE[0]:-}" ] 2>/dev/null && [ -d "$(dirname "${BASH_SOURCE[0]}")/skills/$SKILL_NAME" ]; then
    SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  else
    local tmp tball
    tmp="$(mktemp -d)" || die "mktemp failed"
    TMPDIR_MINE="$tmp"
    tball="$tmp/repo.tar.gz"
    say "fetching $REPO@$BRANCH ..."
    curl -fsSL "https://codeload.github.com/$REPO/tar.gz/refs/heads/$BRANCH" -o "$tball" \
      || die "download failed (check KARPATHY_REF / network)"
    tar -xzf "$tball" -C "$tmp" || die "extract failed"
    SRC="$(cd "$tmp"/*/ && pwd)"
    [ -d "$SRC/skills/$SKILL_NAME" ] || die "payload missing skills/$SKILL_NAME"
  fi
}

copy_skill() { # $1 = dest skills dir
  mkdir -p "$1/$SKILL_NAME"
  cp -R "$SRC/skills/$SKILL_NAME/" "$1/$SKILL_NAME/"
  ok "skill -> $1/$SKILL_NAME"
}
copy_file() { # $1 = repo path, $2 = dest dir, $3 = label
  mkdir -p "$2"
  cp "$SRC/$1" "$2/"
  ok "$3 -> $2/$(basename "$1")"
}
remove_path() { [ -e "$1" ] && { rm -rf "$1"; ok "removed $1"; } || true; }

# --- arg parsing -------------------------------------------------------------
WANT_ALL=0 UNINSTALL=0 LIST=0
declare -a TARGETS=()
for arg in "$@"; do
  case "$arg" in
    --all) WANT_ALL=1 ;;
    --uninstall) UNINSTALL=1 ;;
    --list) LIST=1 ;;
    --claude|--codex|--gemini|--cursor|--opencode|--devin|--agents) TARGETS+=("${arg#--}") ;;
    -h|--help) usage; exit 0 ;;
    *) die "unknown flag: $arg (see --help)" ;;
  esac
done

detected() { # parent dir exists OR target explicitly requested
  [ "$WANT_ALL" = 1 ] && return 0
  [ "${#TARGETS[@]}" -gt 0 ] && { local t; for t in "${TARGETS[@]}"; do [ "$t" = "$1" ] && return 0; done; return 1; }
  [ -d "$2" ]
}

if [ "$LIST" = 1 ]; then
  say "install targets:"
  for pair in \
    "agents|$HOME/.agents/skills" \
    "claude|$HOME/.claude" \
    "codex|$HOME/.codex" \
    "gemini|$HOME/.gemini" \
    "cursor|$HOME/.cursor" \
    "opencode|$HOME/.config/opencode" \
    "devin|$HOME/.config/devin"; do
    name="${pair%%|*}"; dir="${pair#*|}"
    if [ -d "$dir" ]; then say "  + $name  ($dir exists)"; else say "  - $name  ($dir absent)"; fi
  done
  exit 0
fi

if [ "$UNINSTALL" = 1 ]; then
  say "uninstalling $SKILL_NAME:"
  remove_path "$HOME/.agents/skills/$SKILL_NAME"
  remove_path "$HOME/.claude/skills/$SKILL_NAME";  remove_path "$HOME/.claude/commands/karpathy.md";  remove_path "$HOME/.claude/agents/karpathy.md"
  remove_path "$HOME/.codex/skills/$SKILL_NAME"
  remove_path "$HOME/.gemini/skills/$SKILL_NAME";   remove_path "$HOME/.gemini/commands/karpathy.toml"
  remove_path "$HOME/.cursor/skills/$SKILL_NAME"
  remove_path "$HOME/.config/opencode/skills/$SKILL_NAME"; remove_path "$HOME/.config/opencode/command/karpathy.md"
  remove_path "$HOME/.config/devin/skills/$SKILL_NAME"
  exit 0
fi

resolve_source

INSTALLED=0
say "installing $SKILL_NAME:"

if detected agents "$HOME/.agents/skills"; then copy_skill "$HOME/.agents/skills"; INSTALLED=1
else skip "~/.agents/skills"; fi

if detected claude "$HOME/.claude"; then
  copy_skill "$HOME/.claude/skills"
  copy_file "commands/karpathy.md" "$HOME/.claude/commands" "command"
  copy_file "agents/karpathy.md"   "$HOME/.claude/agents"   "agent"
  INSTALLED=1
else skip "~/.claude"; fi

if detected codex "$HOME/.codex"; then copy_skill "$HOME/.codex/skills"; INSTALLED=1
else skip "~/.codex"; fi

if detected gemini "$HOME/.gemini"; then
  copy_skill "$HOME/.gemini/skills"
  copy_file "commands/karpathy.toml" "$HOME/.gemini/commands" "command"
  INSTALLED=1
else skip "~/.gemini"; fi

if detected cursor "$HOME/.cursor"; then copy_skill "$HOME/.cursor/skills"; INSTALLED=1
else skip "~/.cursor"; fi

if detected opencode "$HOME/.config/opencode"; then
  copy_skill "$HOME/.config/opencode/skills"
  copy_file "commands/karpathy.md" "$HOME/.config/opencode/command" "command"
  INSTALLED=1
else skip "~/.config/opencode"; fi

if detected devin "$HOME/.config/devin"; then copy_skill "$HOME/.config/devin/skills"; INSTALLED=1
else skip "~/.config/devin"; fi

[ "$INSTALLED" = 1 ] || die "no agent directories found. Re-run with explicit targets or --all."

cat <<'EOF'

done. Try it:
  /karpathy why won't my loss go down
  or just ask your agent "what would karpathy think about this eval"
EOF
