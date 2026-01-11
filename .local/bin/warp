#!/bin/bash

# functions
Notify() {
  notify-send "Cloudflare Warp" "$1" -a "warp-script"
}

Status() {
  warp-cli status | awk ' /Status/ { print tolower($3) } '
}

status=$(Status)
case $status in
"disconnected")
  warp-cli connect >/dev/null && Notify "Connecting..."
  for i in $(seq 1 25); do
    sleep 0.5
    status=$(Status) # update status
    [ "$status" = "connected" ] &&
      Notify "Connected Successfully" &&
      exit 0
  done
  warp-cli disconnect >/dev/null
  Notify "Failed To Connect. Time Out Reached"
  exit 1
  ;;
"connected")
  warp-cli disconnect >/dev/null && Notify "Disconnected Successfully"
  exit 0
  ;;

"unable")
  Notify "Network Error. Unable to Connect. "
  exit 2
  ;;

"connecting") exit 0 ;;

*)
  Notify "Unknown Error Occurred. Check Log." &&
    warp-cli status >>~/warp.log &&
    exit 3
  ;;
esac
