#!/data/data/com.termux/files/usr/bin/bash

pkill -f "termux-x11" 2>/dev/null

pulseaudio --start \
  --load="module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1" \
  --exit-idle-time=-1

export XDG_RUNTIME_DIR="$TMPDIR"

termux-x11 :0 -ac -disable-dri3 >"$HOME/termux-x11.log" 2>&1 &

sleep 3

am start \
  --user 0 \
  -n com.termux.x11/com.termux.x11.MainActivity \
  >/dev/null 2>&1

sleep 1

proot-distro login \
  --user rehan \
  archlinuxarm \
  --shared-tmp \
  -- \
  env \
  DISPLAY=:0 \
  PULSE_SERVER=127.0.0.1 \
  dbus-run-session -- i3
