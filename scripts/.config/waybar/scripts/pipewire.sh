#!/bin/bash

set -e

# https://blog.dhampir.no/content/sleeping-without-a-subprocess-in-bash-and-how-to-sleep-forever
snore() {
  local IFS
  [[ -n "${_snore_fd:-}" ]] || exec {_snore_fd}<> <(:)
  read -r ${1:+-t "$1"} -u $_snore_fd || :
}

DELAY=0.2

INPUT=
case "$1" in
"output")
  INPUT="@DEFAULT_AUDIO_SINK@"
  VOLUME_ICONS=$OUTPUT_ICONS
  MUTED_ICON=$OUTPUT_MUTED_ICON
  ;;
"input")
  INPUT="@DEFAULT_AUDIO_SOURCE@"
  VOLUME_ICONS=$INPUT_ICONS
  MUTED_ICON=$INPUT_MUTED_ICON
  ;;
*)
  dunstify "wrong input for pipewire"
  exit 1
  ;;
esac

while snore $DELAY; do
  WP_OUTPUT=$(wpctl get-volume "$INPUT")

  if [[ "${WP_OUTPUT}" == *[MUTED]* ]]; then
    printf '{"text":"", "alt":"muted"}\n'
  else
    str=${WP_OUTPUT#*: }
    num=$(echo "$str * 100" | bc)
    VOLUME=${num%.*}

    if [[ "$VOLUME" =~ ^[0-9]+$ ]]; then
      ICON=""

      if ((VOLUME < 33)); then
        ICON="low"
      elif ((VOLUME > 66)); then
        ICON="high"
      else
        ICON="medium"
      fi

      printf '{"text":"%s", "alt":"%s"}\n' "$VOLUME%" "$ICON"
    else
      printf '{"text":"Error","alt":"invalid volume"}\n'
    fi
  fi
done

exit 0
