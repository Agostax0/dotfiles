#!/bin/bash

set -e

# https://blog.dhampir.no/content/sleeping-without-a-subprocess-in-bash-and-how-to-sleep-forever
snore() {
  local IFS
  [[ -n "${_snore_fd:-}" ]] || exec {_snore_fd}<> <(:)
  read -r ${1:+-t "$1"} -u $_snore_fd || :
}

DELAY=0.2

<<<<<<< HEAD
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
=======
while snore $DELAY; do
  WP_OUTPUT=$(wpctl get-volume @DEFAULT_AUDIO_SINK@)

  if [[ $WP_OUTPUT =~ ^Volume:[[:blank:]]([0-9]+)\.([0-9]{2})([[:blank:]].MUTED.)?$ ]]; then
    if [[ -n ${BASH_REMATCH[3]} ]]; then
      printf "MUTE\n"
    else
      VOLUME=$((10#${BASH_REMATCH[1]}${BASH_REMATCH[2]}))
      ICON=(
        ""
        ""
        ""
      )

      if [[ $VOLUME -gt 50 ]]; then
        printf "%s" "${ICON[0]} "
      elif [[ $VOLUME -gt 25 ]]; then
        printf "%s" "${ICON[1]} "
      elif [[ $VOLUME -ge 0 ]]; then
        printf "%s" "${ICON[2]} "
      fi

      printf "$VOLUME%%\n"
>>>>>>> cb03f49 (added audio control)
    fi
  fi
done

exit 0
