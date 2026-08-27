#!/usr/bin/env bash
#
# start_xfce.sh
#
# Start the Arch Linux XFCE desktop through Termux:X11.
#
# This script runs in Termux.
#
# It:
#   1. Starts PulseAudio
#   2. Starts Termux:X11
#   3. Opens the Termux:X11 Android activity
#   4. Enters Arch with --shared-tmp
#   5. Starts XFCE
#

set +e

########################
#### Configuration #####
########################

ARCH_NAME="archlinux"
DISPLAY_NUMBER=":0"

########################
#### PulseAudio ########
########################

start_pulseaudio() {
  if pulseaudio --check 2>/dev/null; then
    echo "    PulseAudio already running"
    return 0
  fi

  pulseaudio \
    --start \
    --load="module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1" \
    --exit-idle-time=-1
}

########################
#### Termux:X11 ########
########################

start_x11() {
  echo "==> Starting Termux:X11"

  termux-x11 \
    "$DISPLAY_NUMBER" \
    -ac \
    -disable-dri3 \
    >/dev/null 2>&1 &

  sleep 2

  echo "==> Opening Termux:X11"

  am start \
    --user 0 \
    -n com.termux.x11/com.termux.x11.MainActivity \
    >/dev/null 2>&1

  sleep 1
}

########################
#### XFCE ##############
########################

start_xfce() {
  echo "==> Starting XFCE"

  proot-distro login "$ARCH_NAME" \
    --shared-tmp \
    -- \
    env \
    DISPLAY="$DISPLAY_NUMBER" \
    PULSE_SERVER="127.0.0.1" \
    XDG_RUNTIME_DIR="/tmp" \
    LIBGL_ALWAYS_SOFTWARE="1" \
    bash -lc '
                dbus-run-session startxfce4
            '
}

########################
#### Main ##############
########################

echo
echo "========================================"
echo " Starting Arch XFCE"
echo "========================================"

start_pulseaudio

if ! command -v termux-x11 >/dev/null 2>&1; then
  echo
  echo "ERROR: termux-x11 is not installed."
  echo
  echo "Install it with:"
  echo
  echo "  pkg install x11-repo"
  echo "  pkg install termux-x11-nightly"
  exit 1
fi

start_x11

start_xfce
