#!/usr/bin/env bash
# -----------------------------------------------------------------------------
#   setup-resolve-mcp.sh
#   Wersja: 1.0
#
#   Skrypt instalacyjny (tylko macOS) podpinajacy DaVinci Resolve Studio
#   pod Claude Desktop przez MCP (Model Context Protocol).
#
#   Autor skryptu:    pan-pawel
#   Serwer MCP:       resolve-claude-mcp by barckley75
#                     https://github.com/barckley75/resolve-claude-mcp
#
# -----------------------------------------------------------------------------
#   CO ROBI
# -----------------------------------------------------------------------------
#   1. Sprawdza, ze to macOS, ze sa Xcode Command Line Tools i git.
#   2. Instaluje uv (Homebrew albo oficjalny instalator), jesli go nie ma,
#      i ustala jego ABSOLUTNA sciezke - Claude Desktop startuje z launchd
#      i nie widzi PATH z .zshrc / .bash_profile.
#   3. Klonuje resolve-claude-mcp (albo robi git pull, jesli juz jest)
#      i uruchamia "uv sync".
#   4. Sprawdza, czy DaVinci Resolve jest w domyslnej lokalizacji
#      (tylko ostrzezenie - Resolve mozna doinstalowac pozniej).
#   5. Robi backup claude_desktop_config.json i dopisuje do niego wpis
#      "resolve" NIE ruszajac innych serwerow MCP.
#   6. Przypomina, zeby zamknac Claude Desktop (Cmd+Q) i odpalic od nowa.
#
# -----------------------------------------------------------------------------
#   UZYCIE
# -----------------------------------------------------------------------------
#   bash setup-resolve-mcp.sh                       # klon do ~/resolve-claude-mcp
#   bash setup-resolve-mcp.sh ~/inny/katalog        # klon do wskazanego katalogu
#   RESOLVE_MCP_DIR=~/inny/katalog bash setup-resolve-mcp.sh
#   bash setup-resolve-mcp.sh --dry-run             # nic nie instaluje, nic nie
#                                                   # zapisuje, wypisuje gotowy
#                                                   # JSON na stdout
#
# -----------------------------------------------------------------------------
#   KONFIGURACJA
# -----------------------------------------------------------------------------
#   Wszystkie sciezki sa w bloku ponizej. Jesli masz Resolve zainstalowany
#   gdzie indziej niz /Applications, zmien RESOLVE_SCRIPT_LIB
#   i RESOLVE_SCRIPT_API.
#
# -----------------------------------------------------------------------------
#   OGRANICZENIA
# -----------------------------------------------------------------------------
#   - Tylko macOS. Na Windows sciezki sa inne (fusionscript.dll,
#     %APPDATA%\Claude\claude_desktop_config.json) - patrz README upstream.
#   - Wymagany DaVinci Resolve STUDIO 18+. Darmowa wersja ma okrojony
#     scripting i serwer MCP nie zadziala.
#   - Istniejacy wpis "resolve" w configu jest zastepowany (stary zostaje
#     w backupie *.bak-<data>).
#   - Skrypt musi dzialac pod bash 3.2 (taki jest w macOS) - bez tablic
#     asocjacyjnych, mapfile, ${var,,} itp.
# -----------------------------------------------------------------------------

# ----------------------------- KONFIGURACJA ----------------------------------
UPSTREAM_REPO="https://github.com/barckley75/resolve-claude-mcp.git"
DEFAULT_DIR="$HOME/resolve-claude-mcp"
CLAUDE_CONFIG_DIR="$HOME/Library/Application Support/Claude"
CLAUDE_CONFIG="$CLAUDE_CONFIG_DIR/claude_desktop_config.json"
RESOLVE_SCRIPT_LIB="/Applications/DaVinci Resolve/DaVinci Resolve.app/Contents/Libraries/Fusion/fusionscript.so"
RESOLVE_SCRIPT_API="/Library/Application Support/Blackmagic Design/DaVinci Resolve/Developer/Scripting"
RESOLVE_PYTHONPATH="$RESOLVE_SCRIPT_API/Modules/"
UV_FALLBACK_PATHS=("/opt/homebrew/bin/uv" "/usr/local/bin/uv" "$HOME/.local/bin/uv")
# -----------------------------------------------------------------------------

set -euo pipefail

DRY_RUN=0
TARGET_DIR=""
UV_BIN=""
BACKUP_PATH=""
PYTHON_CMD=()
RESOLVE_WARNINGS=()

# Wszystkie komunikaty ida na stderr, zeby w --dry-run na stdout byl
# wylacznie JSON (mozna zrobic: ... --dry-run | jq .).
log()  { printf '[resolve-mcp] %s\n' "$*" >&2; }
warn() { printf '[resolve-mcp] UWAGA: %s\n' "$*" >&2; }
die()  { printf '[resolve-mcp] BLAD: %s\n' "$*" >&2; exit 1; }

usage() {
  cat >&2 <<'USAGE'
Uzycie: bash setup-resolve-mcp.sh [--dry-run] [katalog_docelowy]

  katalog_docelowy   gdzie sklonowac resolve-claude-mcp
                     (domyslnie ~/resolve-claude-mcp, albo $RESOLVE_MCP_DIR)
  --dry-run          nic nie instaluje i nic nie zapisuje; wypisuje na stdout
                     JSON, ktory trafilby do claude_desktop_config.json
  -h, --help         ta pomoc
USAGE
}

parse_args() {
  local positional=""
  while [[ $# -gt 0 ]]; do
    case "${1:-}" in
      --dry-run) DRY_RUN=1 ;;
      -h|--help) usage; exit 0 ;;
      --*) usage; die "nieznana opcja: $1" ;;
      *)
        if [[ -n "$positional" ]]; then
          usage
          die "za duzo argumentow (oczekiwany najwyzej jeden katalog)"
        fi
        positional="$1"
        ;;
    esac
    shift
  done
  if [[ -n "$positional" ]]; then
    TARGET_DIR="$positional"
  elif [[ -n "${RESOLVE_MCP_DIR:-}" ]]; then
    TARGET_DIR="$RESOLVE_MCP_DIR"
  else
    TARGET_DIR="$DEFAULT_DIR"
  fi
  # Sciezka wzgledna zamieniona na absolutna - Claude Desktop nie wie,
  # w jakim katalogu odpaliles ten skrypt.
  case "$TARGET_DIR" in
    /*) ;;
    *) TARGET_DIR="$PWD/$TARGET_DIR" ;;
  esac
}

check_macos() {
  [[ "$(uname -s)" == "Darwin" ]] \
    || die "ten skrypt dziala tylko na macOS (wykryto: $(uname -s)). Na Windows sciezki sa inne - patrz README upstream."
}

# Na czystym Macu /usr/bin/git i /usr/bin/python3 ISTNIEJA jako shimy,
# wiec "command -v git" klamie: pierwsze prawdziwe wywolanie wyskakuje
# z okienkiem "Install Command Line Tools". xcode-select -p odpowiada cicho.
check_clt() {
  xcode-select -p >/dev/null 2>&1 \
    || die "brak Xcode Command Line Tools. Uruchom najpierw: xcode-select --install"
}

check_git() {
  git --version >/dev/null 2>&1 || die "git nie dziala mimo obecnosci Command Line Tools"
}

find_uv() {
  local candidate
  if candidate="$(command -v uv 2>/dev/null)" && [[ -n "$candidate" ]]; then
    UV_BIN="$candidate"
    return 0
  fi
  for candidate in "${UV_FALLBACK_PATHS[@]}"; do
    if [[ -x "$candidate" ]]; then
      UV_BIN="$candidate"
      return 0
    fi
  done
  return 1
}

find_brew() {
  local candidate
  if candidate="$(command -v brew 2>/dev/null)" && [[ -n "$candidate" ]]; then
    printf '%s\n' "$candidate"
    return 0
  fi
  for candidate in /opt/homebrew/bin/brew /usr/local/bin/brew; do
    if [[ -x "$candidate" ]]; then
      printf '%s\n' "$candidate"
      return 0
    fi
  done
  return 1
}

ensure_uv() {
  if find_uv; then
    log "uv: $UV_BIN"
    return 0
  fi
  if [[ "$DRY_RUN" -eq 1 ]]; then
    UV_BIN="/opt/homebrew/bin/uv"
    warn "uv nie jest zainstalowany; w dry-run uzywam placeholdera $UV_BIN"
    return 0
  fi
  local brew
  if brew="$(find_brew)"; then
    log "uv nie znaleziony - instaluje przez Homebrew: $brew install uv"
    "$brew" install uv
  else
    log "uv nie znaleziony, Homebrew tez nie - uzywam oficjalnego instalatora:"
    log "  curl -LsSf https://astral.sh/uv/install.sh | sh"
    curl -LsSf https://astral.sh/uv/install.sh | sh
  fi
  find_uv || die "uv nadal nie widoczny po instalacji. Otworz nowy terminal i odpal skrypt ponownie."
  log "uv: $UV_BIN"
}

clone_or_update() {
  if [[ "$DRY_RUN" -eq 1 ]]; then
    log "dry-run: pominalem klonowanie do $TARGET_DIR i uv sync"
    return 0
  fi
  if [[ -d "$TARGET_DIR/.git" ]]; then
    log "repo juz jest w $TARGET_DIR - robie git pull"
    git -C "$TARGET_DIR" pull --ff-only \
      || warn "git pull sie nie udal (lokalne zmiany?), jade dalej na tym, co jest"
  elif [[ -e "$TARGET_DIR" ]]; then
    die "$TARGET_DIR istnieje, ale nie jest repozytorium git. Wskaz inny katalog albo usun ten."
  else
    mkdir -p "$(dirname "$TARGET_DIR")"
    log "klonuje $UPSTREAM_REPO -> $TARGET_DIR"
    git clone "$UPSTREAM_REPO" "$TARGET_DIR"
  fi
  log "uv sync w $TARGET_DIR"
  "$UV_BIN" --directory "$TARGET_DIR" sync
}

check_resolve_paths() {
  if [[ ! -f "$RESOLVE_SCRIPT_LIB" ]]; then
    RESOLVE_WARNINGS+=("brak $RESOLVE_SCRIPT_LIB - DaVinci Resolve Studio nie jest w /Applications?")
  fi
  if [[ ! -d "$RESOLVE_SCRIPT_API" ]]; then
    RESOLVE_WARNINGS+=("brak $RESOLVE_SCRIPT_API - Resolve nie zainstalowal API skryptowego?")
  fi
  local w
  for w in "${RESOLVE_WARNINGS[@]+"${RESOLVE_WARNINGS[@]}"}"; do
    warn "$w"
  done
  if [[ "${#RESOLVE_WARNINGS[@]}" -gt 0 ]]; then
    warn "konfiguracja i tak zostanie zapisana; doinstaluj Resolve Studio i sprawdz sciezki w bloku KONFIGURACJA"
  fi
}

# Do scalenia JSON wystarczy python ze stdlib. Kolejnosc:
#   1. /usr/bin/python3 - jest zawsze po instalacji CLT (sprawdzone wyzej),
#      dziala w dry-run bez klona, nie zalezy od stanu venv,
#   2. python z venv projektu (po uv sync uv gwarantuje jakis CPython),
#   3. cokolwiek innego w PATH.
find_python() {
  if [[ -x /usr/bin/python3 ]]; then
    PYTHON_CMD=(/usr/bin/python3)
  elif [[ -n "$UV_BIN" && -x "$UV_BIN" && -d "$TARGET_DIR/.venv" ]]; then
    PYTHON_CMD=("$UV_BIN" run --directory "$TARGET_DIR" python)
  elif command -v python3 >/dev/null 2>&1; then
    PYTHON_CMD=("$(command -v python3)")
  else
    die "nie znalazlem zadnego python3 do scalenia konfiguracji"
  fi
}

write_config() {
  if [[ ! -d /Applications/Claude.app ]]; then
    warn "nie widze /Applications/Claude.app - Claude Desktop chyba nie jest zainstalowany; config i tak zapisze"
  fi
  if [[ "$DRY_RUN" -eq 0 ]]; then
    mkdir -p "$CLAUDE_CONFIG_DIR"
    if [[ ! -f "$CLAUDE_CONFIG" ]]; then
      log "tworze nowy $CLAUDE_CONFIG"
      printf '{\n  "mcpServers": {}\n}\n' > "$CLAUDE_CONFIG"
    else
      BACKUP_PATH="$CLAUDE_CONFIG.bak-$(date +%Y%m%d-%H%M%S)"
      cp -p "$CLAUDE_CONFIG" "$BACKUP_PATH"
      log "backup configu: $BACKUP_PATH"
    fi
  else
    log "dry-run: JSON ponizej NIE zostal zapisany do $CLAUDE_CONFIG"
  fi

  # Wszystkie wartosci ida przez argv, nie sa wklejane do zrodla pythona
  # (sciezki ze spacjami i cudzyslowami sa bezpieczne). Heredoc w cudzyslowie,
  # wiec shell nie rozwija niczego w tresci.
  "${PYTHON_CMD[@]}" - "$CLAUDE_CONFIG" "$UV_BIN" "$TARGET_DIR" \
    "$RESOLVE_SCRIPT_LIB" "$RESOLVE_SCRIPT_API" "$RESOLVE_PYTHONPATH" "$DRY_RUN" <<'PY'
# BEGIN-MERGE-PY
import json, os, sys, tempfile
cfg_path, uv_bin, target_dir, lib, api, pypath, dry = sys.argv[1:8]
data = {}
if os.path.exists(cfg_path) and os.path.getsize(cfg_path) > 0:
    with open(cfg_path, encoding="utf-8") as f:
        try:
            data = json.load(f)
        except json.JSONDecodeError as e:
            sys.exit(f"BLAD: {cfg_path} nie jest poprawnym JSON ({e}). Popraw plik recznie, nic nie zapisano.")
if not isinstance(data, dict):
    sys.exit("BLAD: konfiguracja nie jest obiektem JSON. Popraw plik recznie, nic nie zapisano.")
servers = data.setdefault("mcpServers", {})
if not isinstance(servers, dict):
    sys.exit("BLAD: pole mcpServers nie jest obiektem JSON. Popraw plik recznie, nic nie zapisano.")
servers["resolve"] = {
    "command": uv_bin,
    "args": ["--directory", target_dir, "run", "resolve-claude-mcp"],
    "env": {
        "RESOLVE_SCRIPT_LIB": lib,
        "RESOLVE_SCRIPT_API": api,
        "PYTHONPATH": pypath,
    },
}
out = json.dumps(data, indent=2, ensure_ascii=False) + "\n"
if dry == "1":
    sys.stdout.write(out)
else:
    fd, tmp = tempfile.mkstemp(prefix=".claude_desktop_config.", dir=os.path.dirname(cfg_path))
    with os.fdopen(fd, "w", encoding="utf-8") as f:
        f.write(out)
    os.replace(tmp, cfg_path)
# END-MERGE-PY
PY
}

print_summary() {
  log "------------------------------------------------------------"
  if [[ "$DRY_RUN" -eq 1 ]]; then
    log "DRY-RUN zakonczony. Nic nie zostalo zainstalowane ani zapisane."
  else
    log "Gotowe."
  fi
  log "uv:              $UV_BIN"
  log "resolve-mcp:     $TARGET_DIR"
  log "config Claude:   $CLAUDE_CONFIG"
  if [[ -n "$BACKUP_PATH" ]]; then
    log "backup configu:  $BACKUP_PATH"
  fi
  local w
  for w in "${RESOLVE_WARNINGS[@]+"${RESOLVE_WARNINGS[@]}"}"; do
    warn "$w"
  done
  log "------------------------------------------------------------"
  log "Co dalej:"
  log "  1. DaVinci Resolve: Preferences -> System -> General ->"
  log "     External scripting using = Local"
  log "  2. Zamknij CALKOWICIE Claude Desktop (Cmd+Q) i uruchom ponownie."
  log "  3. Resolve musi byc uruchomiony z otwartym projektem."
}

main() {
  parse_args "$@"
  check_macos
  check_clt
  check_git
  ensure_uv
  clone_or_update
  check_resolve_paths
  find_python
  write_config
  print_summary
}

main "$@"
