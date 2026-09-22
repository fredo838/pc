#!/bin/bash
# List each running VS Code main process as "<kind> - <user-data-dir>"

ps ax -o command= \
  | grep "Contents/MacOS/Code" \
  | grep -v "Helper" \
  | grep -v grep \
  | while IFS= read -r line; do
      case "$line" in
        *"/Code - OSS.app/"*)
          kind="self-built" ;;
        *"Visual Studio Code - Insiders.app"*)
          kind="insiders" ;;
        *"/Applications/Visual Studio Code.app/"*)
          kind="normal" ;;
        *)
          kind="unknown" ;;
      esac

      udd="$(printf '%s\n' "$line" | grep -oE -- '--user-data-dir[= ]([^ ]+)' | sed -E 's/--user-data-dir[= ]//')"

      if [ -z "$udd" ]; then
        case "$kind" in
          self-built) udd="$HOME/Library/Application Support/Code - OSS (default)" ;;
          insiders)   udd="$HOME/Library/Application Support/Code - Insiders (default)" ;;
          normal)     udd="$HOME/Library/Application Support/Code (default)" ;;
          *)          udd="(unknown)" ;;
        esac
      fi

      echo "$kind - $udd"
    done \
  | sort -u
