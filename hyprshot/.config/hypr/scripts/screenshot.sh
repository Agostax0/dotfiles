#!/bin/bash
PROMPT="Screenshot"
SEPARATOR="|"
OPTIONS="Region${SEPARATOR}Monitor${SEPARATOR}Window${SEPARATOR}Active Monitor${SEPARATOR}Active Window"

chosen=$(echo "$OPTIONS" | rofi -sep $SEPARATOR -dmenu -p $PROMPT)

case $chosen in
"Active Monitor")
  hyprshot -s -m active -m output
  ;;
"Region")
  hyprshot -s -m region
  ;;
"Monitor")
  hyprshot -s -m output
  ;;
"Window")
  hyprshot -s -m window
  ;;
"Active Window")
  hyprshot -s -m active -m window
  ;;
*)
  echo "err"
  ;;
esac
