# --- 1. CORE SHELL SETTINGS ---
bindkey -e                           # Use Emacs mode
echo -ne '\e[5 q'                    # Use blinking beam cursor
PROMPT='%F{green}%n@%m%f:%F{blue}%~%f$ '

# --- 2. CLIPBOARD HELPERS ---
unset zle_bracketed_paste
_clipboard_copy() {
  local selection_data="$1"
  if [[ "$OSTYPE" == "darwin"* ]]; then
    printf "%s" "$selection_data" | pbcopy
    return 0
  elif command -v xclip > /dev/null; then
    printf "%s" "$selection_data" | xclip -selection clipboard
    return 0
  elif command -v wl-copy > /dev/null; then
    printf "%s" "$selection_data" | wl-copy
    return 0
  fi
  return 1
}

_clipboard_paste() {
  if [[ "$OSTYPE" == "darwin"* ]]; then
    pbpaste
  elif command -v xclip > /dev/null; then
    xclip -selection clipboard -o
  elif command -v wl-paste > /dev/null; then
    wl-paste
  fi
}

# --- 3. SELECTION ENGINE & AUTO-DESELECT ---

widget::util-select() {
  (( ! REGION_ACTIVE )) && zle set-mark-command
  zle $1
}

widget::util-unselect() {
  # Forces selection to clear when moving without Shift
  REGION_ACTIVE=0
  zle $1
}

foreach w (backward-char forward-char backward-word forward-word beginning-of-line end-of-line) {
  eval "${w}-select() { widget::util-select $w }"
  eval "${w}-unselect() { widget::util-unselect $w }"
  zle -N "${w}-select"
  zle -N "${w}-unselect"
}

# --- 4. CLIPBOARD WIDGETS ---

copy-selection() {
  if (( REGION_ACTIVE )); then
    local low=$(( MARK < CURSOR ? MARK : CURSOR ))
    local high=$(( MARK > CURSOR ? MARK : CURSOR ))
    local selection=$BUFFER[$((low + 1)),$high]
    if _clipboard_copy "$selection"; then
      CUTBUFFER="$selection"
      printf '\a' # Success signal (Bell)
    else
      [[ "$OSTYPE" == "linux-gnu"* ]] && zle -M "Error: 'xclip' not installed."
    fi
    # Explicitly maintain the region active state
    REGION_ACTIVE=1
    zle -R
  fi
}
zle -N copy-selection

paste-selection() {
  local pasted="$(_clipboard_paste)"
  if [[ -n "$pasted" ]]; then
    if (( REGION_ACTIVE )); then
      local low=$(( MARK < CURSOR ? MARK : CURSOR ))
      local high=$(( MARK > CURSOR ? MARK : CURSOR ))
      # Delete the selection first
      BUFFER=$BUFFER[1,$low]$BUFFER[$((high + 1)),-1]
      # Then insert pasted text at the low position
      BUFFER=$BUFFER[1,$low]$pasted$BUFFER[$((low + 1)),-1]
      CURSOR=$(( low + ${#pasted} ))
      REGION_ACTIVE=0
    else
      # Standard paste at cursor
      LBUFFER+="$pasted"
    fi
  fi
  zle -R
}
zle -N paste-selection

# --- 5. SMART DELETE LOGIC ---

widget::util-delete-selection() {
  if (( REGION_ACTIVE )); then
    local low=$(( MARK < CURSOR ? MARK : CURSOR ))
    local high=$(( MARK > CURSOR ? MARK : CURSOR ))
    BUFFER=$BUFFER[1,$low]$BUFFER[$((high + 1)),-1]
    CURSOR=$low
    REGION_ACTIVE=0
  else
    zle $1
  fi
}
delete-selection-backspace() { widget::util-delete-selection backward-delete-char }
delete-selection-delete()    { widget::util-delete-selection delete-char }
zle -N delete-selection-backspace
zle -N delete-selection-delete

# --- 6. KEY BINDINGS ---

# Selection (Shift + Arrows)
bindkey "\e[1;2C"   forward-char-select
bindkey "\e[1;2D"   backward-char-select
bindkey "\e[1;6C"   forward-word-select
bindkey "\e[1;6D"   backward-word-select
bindkey "\e[1;2H"   beginning-of-line-select
bindkey "\e[1;2F"   end-of-line-select

# Deselection (Standard Arrows)
bindkey "\e[C"      forward-char-unselect
bindkey "\e[D"      backward-char-unselect
bindkey "\e[H"      beginning-of-line-unselect
bindkey "\e[F"      end-of-line-unselect
bindkey "\e[1;5C"   forward-word-unselect
bindkey "\e[1;5D"   backward-word-unselect

# Clipboard
bindkey "\e[99;6u"  copy-selection
bindkey "\e[86;5u"  paste-selection

# Deletion
bindkey "^?"        delete-selection-backspace
bindkey "\e[3~"     delete-selection-delete
bindkey "\e[127;5u" delete-selection-backspace

exit_fix() {
  exit
}
alias exit='exit_fix'

VSCODE_PERSONAL_ROOT=~/projects/vscode
if [[ "$OSTYPE" == "darwin"* ]]; then
  VSCODE_PERSONAL_BIN="$VSCODE_PERSONAL_ROOT/.build/electron/Code - OSS.app/Contents/MacOS/Code - OSS"
else
  VSCODE_PERSONAL_BIN="$VSCODE_PERSONAL_ROOT/.build/electron/code-oss"
fi

# This is an unpackaged dev build (no app.asar), so Electron needs the app
# location as its first positional arg to know what to load at all -- pass
# VSCODE_PERSONAL_ROOT itself (absolute, so relative paths in "$@" like
# "code ." still resolve against the caller's cwd, not this one). VS Code's
# own arg parser only strips that positional arg back out (instead of
# treating it as a folder to open alongside the real target) when
# VSCODE_DEV is set.
code_oss_personal() {
  VSCODE_DEV=1 NODE_ENV=development "$VSCODE_PERSONAL_BIN" "$VSCODE_PERSONAL_ROOT" --user-data-dir ~/.vscode-personal/user-data --extensions-dir ~/.vscode-personal/extensions --profile Personal --enable-proposed-api=local.bode-claude "$@"
}

code() {
  local target="$PWD"
  for arg in "$@"; do
    case "$arg" in
      -*) continue ;;
      *) target="$arg"; break ;;
    esac
  done

  # Resolve to an absolute path so relative "code ." or "code ../foo" match correctly
  if [[ -e "$target" ]]; then
    target="$(cd "$(dirname "$target")" && pwd)/$(basename "$target")"
  fi

  case "$target" in
    /Users/fred/centrica/*|/Users/fred/centrica|/home/fred/centrica/*|/home/fred/centrica)
      command code --user-data-dir ~/.vscode-work --extensions-dir ~/.vscode-work-ext --profile Work "$@"
      ;;
    /Users/fred/projects/*|/Users/fred/projects|/home/fred/projects/*|/home/fred/projects)
      code_oss_personal "$@"
      ;;
    *)
      command code "$@"
      ;;
  esac
}

code-work() {
  command code --user-data-dir ~/.vscode-work --extensions-dir ~/.vscode-work-ext --profile Work "$@"
}

code-personal() {
  code_oss_personal "$@"
}

PATH=$HOME/.pulumi/bin:$PATH
