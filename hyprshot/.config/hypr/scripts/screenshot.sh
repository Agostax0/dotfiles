#!/bin/bash
PROMPT="Screenshot"
SEPARATOR="|"
OPTIONS="Region${SEPARATOR}Monitor${SEPARATOR}Window${SEPARATOR}Active Monitor${SEPARATOR}Active Window"

chosen=$(echo "$OPTIONS" | rofi -sep $SEPARATOR -dmenu -p $PROMPT)

case $chosen in
"Active Monitor")
  hyprshot -m active -m output
  ;;
"Region")
  hyprshot -m region
  ;;
"Monitor")
  hyprshot -m output
  ;;
"Window")
  hyprshot -m window
  ;;
"Active Window")
  hyprshot -m active -m window
  ;;
*)
  echo "err"
  ;;
esac
