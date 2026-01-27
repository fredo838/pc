# --- KEYBOARD SELECTION LOGIC ---

# Load the selection module
autoload -U select-word-style
select-word-style bash

# Custom function to start selection (setting the "mark") 
# and moving the cursor back by one word
select-backward-word() {
  if (( ! REGION_ACTIVE )); then
    zle set-mark-command
  fi
  zle backward-word
}

# Custom function to select forward
select-forward-word() {
  if (( ! REGION_ACTIVE )); then
    zle set-mark-command
  fi
  zle forward-word
}

# Define the widgets
zle -N select-backward-word
zle -N select-forward-word

# --- KEYBINDINGS ---
# Note: ^[[1;6D is the escape code for Ctrl+Shift+Left in GNOME Terminal
bindkey '^[[1;6D' select-backward-word
bindkey '^[[1;6C' select-forward-word

# Allow Backspace to delete the whole selection
bindkey '^?' backward-delete-char

# --- VISUALS ---
# This highlights the selected text so you can see what you're doing
zstyle ':zle:*' standout-style 'fg=black,bg=white'

# --- STANDARD PROMPT ---
PROMPT='%F{cyan}%n@%m%f:%F{yellow}%~%f$ '