#!/bin/bash
# This pomodoro timer was inspired by nirabyte's waybar-timer (https://github.com/nirabyte/waybar-timer/tree/main)
POMODORO_WORK=25 # Minutes
POMODORO_BREAK=5 # Minutes
POMODORO_REPEAT=3

POMODORO_WORK_SECONDS="$((POMODORO_WORK * 60))"
POMODORO_BREAK_SECONDS="$((POMODORO_BREAK * 60))"

POMODORO_WORK_STATE="Work"
POMODORO_BREAK_STATE="Break"

POMODORO_AUTO_BREAK=true
POMODORO_AUTO_WORK=true

ICON_DISABLED="󰔞 "
ICON_IDLE="󰔛"
ICON_RUNNING=""

POMODORO_REPEAT_ICON=""

STATE_FILE="/dev/shm/pomo_timer.json"
PIPE_FILE="/tmp/waybar_pomo_timer.fifo"

DISABLED="DISABLED"
IDLE="IDLE"
RUNNING="RUNNING"
PAUSED="PAUSED"

INACTIVITY_LIMIT=10

init_state() {
  printf -v NOW '%(%s)T' -1
  # STATE SEC_SET START_TIME PAUSE_REM LAST_ACT POMODORO_CURRENT_STATE POMODORO_CURRENT_NUMBER
  echo "$DISABLED|$POMODORO_WORK_SECONDS|0|0|$NOW|$POMODORO_WORK_STATE|0" >"$STATE_FILE"
}

read_state() {
  IFS='|' read -r STATE SEC_SET START_TIME PAUSE_REM LAST_ACT POMODORO_CURRENT_STATE POMODORO_CURRENT_NUMBER <"$STATE_FILE"
  # STATE => current state
  # SEC_SET => how many seconds must pass
  # START_TIME => when the countdown started
  # PAUSE_REM =>
  # LAST_ACT => time when an action was performed
  # POMODORO_CURRENT_STATE => current active pomodoro state, either: POMODORO_WORK_STATE or POMODORO_BREAK_STATE
  # POMODORO_CURRENT_NUMBER => current repetition of pomodoro, from 0 to POMODORO_REPEAT
}

write_state() {
  echo "$1|$2|$3|$4|$5|$6|$7" >"$STATE_FILE"
}

WS() {
  write_state "$1" "$2" "$3" "$4" "$5" "$6" "$7"
}

format_time() {
  local T=$1
  local HH=$((T / 3600))
  local MM=$(((T % 3600) / 60))
  local SS=$((T % 60))
  if [ "$HH" -gt 1 ]; then printf "%d:%02d:%02d" "$HH" "$MM" "$SS"; else printf "%02d:%02d" "$MM" "$SS"; fi
}

trigger_update() {
  if [ -p "$PIPE_FILE" ]; then
    echo "1" >"$PIPE_FILE" &
  fi
}

# Comands to script
if [ -n "$1" ]; then
  if [ ! -f "$STATE_FILE" ]; then
    init_state
  fi

  read_state

  # Builtin time fetch
  printf -v NOW '%(%s)T' -1

  case "$1" in
  "start")
    WS "$RUNNING" "$SEC_SET" "$NOW" "0" "$NOW" "$POMODORO_CURRENT_STATE" "0"
    trigger_update
    exit 0
    ;;
  "stop")
    WS "$IDLE" "$POMODORO_WORK_SECONDS" "0" "0" "$NOW" "$POMODORO_WORK_STATE" "0"
    trigger_update
    exit 0
    ;;
  "skip")
    if [ "$POMODORO_CURRENT_STATE" == "$POMODORO_WORK_STATE" ]; then
      notify-send "Skipping work"
      WS "$RUNNING" "$POMODORO_BREAK_SECONDS" "$NOW" "0" "$NOW" "$POMODORO_BREAK_STATE" "$POMODORO_CURRENT_NUMBER"
    elif [[ "$POMODORO_CURRENT_STATE" == "$POMODORO_BREAK_STATE" ]]; then
      NEW_POMODORO_NUMBER=$((POMODORO_CURRENT_NUMBER + 1))
      if [ "$NEW_POMODORO_NUMBER" -gt "$POMODORO_REPEAT" ]; then
        notify-send "No more POMODORO" &
        WS "$IDLE" "$POMODORO_WORK_SECONDS" "0" "0" "$NOW" "$POMODORO_WORK_STATE" "0"
      else
        notify-send "Skipping break"
        WS "$RUNNING" "$POMODORO_WORK_SECONDS" "$NOW" "0" "$NOW" "$POMODORO_WORK_STATE" "$NEW_POMODORO_NUMBER"
      fi
    else
      notify-send "invalid state"
      exit 1
    fi
    trigger_update
    exit 0
    ;;
  *)
    notify-send "wrong input"
    exit 1
    ;;

  esac

  trigger_update
  exit 0
fi

# Timer loop

if [ ! -f "$STATE_FILE" ]; then init_state; fi

if [ ! -p "$PIPE_FILE" ]; then mkfifo "$PIPE_FILE"; fi

exec 3<>"$PIPE_FILE"

while true; do
  read_state

  printf -v NOW '%(%s)T' -1

  TEXT=""
  ICON=""

  case "$STATE" in
  "$DISABLED")
    ICON="$ICON_DISABLED"
    printf '{"text": "%s 󱋱 %s 󱋱 %s%s"}\n' "$(format_time "$POMODORO_WORK_SECONDS")" "$(format_time "$POMODORO_BREAK_SECONDS")" "$POMODORO_REPEAT" "$POMODORO_REPEAT_ICON"

    read -n 1 _ <&3
    continue
    ;;
  "$RUNNING")
    ELAPSED=$((NOW - START_TIME))
    REM=$((SEC_SET - ELAPSED))
    if [ "$REM" -le 0 ]; then
      if [ "$POMODORO_CURRENT_STATE" == "$POMODORO_WORK_STATE" ]; then
        # A pomodoro work session has been completed, change to RUNNING if POMODORO_AUTO_BREAK is true
        notify-send "Work finished" &
        WS "$RUNNING" "$POMODORO_BREAK_SECONDS" "$NOW" "0" "$NOW" "$POMODORO_BREAK_STATE" "$POMODORO_CURRENT_NUMBER"
      elif [ "$POMODORO_CURRENT_STATE" == "$POMODORO_BREAK_STATE" ]; then
        # A pomodoro break session has been completed, change to RUNNING if POMODORO_AUTO_WORK is true
        NEW_POMODORO_NUMBER=$((POMODORO_CURRENT_NUMBER + 1))
        if [ "$NEW_POMODORO_NUMBER" -gt "$POMODORO_REPEAT" ]; then
          # The last pomodoro work session, it should notify and idle
          notify-send "No more POMODORO" &
          WS "$IDLE" "$POMODORO_WORK_SECONDS" "0" "0" "$NOW" "$POMODORO_WORK_STATE" "0"
        else
          notify-send "Break finished" &
          WS "$RUNNING" "$POMODORO_WORK_SECONDS" "$NOW" "0" "$NOW" "$POMODORO_WORK_STATE" "$NEW_POMODORO_NUMBER"
        fi
      else
        notify-send "unexpected pomodoro session state"
        exit 1
      fi
      trigger_update
      continue
    fi
    ICON="$ICON_RUNNING"
    TEXT="$(format_time $REM) $POMODORO_CURRENT_NUMBER/$POMODORO_REPEAT $POMODORO_REPEAT_ICON"
    ;;
  "$IDLE")
    ICON="$ICON_IDLE"
    TEXT="IDLE"

    if [ $((NOW - LAST_ACT)) -gt "$INACTIVITY_LIMIT" ]; then
      WS "$DISABLED" "0" "0" "0" "$NOW" "$POMODORO_WORK_STATE" "0"
      trigger_update
      continue
    fi
    ;;
  esac
  echo "{\"text\": \"$ICON $TEXT\"}"
  read -t 1 -n 1 _ <&3
done
