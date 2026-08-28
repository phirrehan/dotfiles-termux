#!/usr/bin/env bash
#
# start_xfce.sh
#
# Start Arch Linux ARM XFCE through Termux:X11.
#
# Run this script from Termux.
# XFCE itself is installed inside the Arch Linux ARM proot container.
#

set -u

########################
#### Configuration #####
########################

ARCH_NAME="archlinuxarm"
DISPLAY_NUMBER=":0"

########################
#### Helpers ###########
########################

die() {
  echo
  echo "ERROR: $*"
  echo
  exit 1
}

########################
#### Checks ############
########################

command -v proot-distro >/dev/null 2>&1 ||
  die "proot-distro is not installed."

command -v termux-x11 >/dev/null 2>&1 ||
  die "termux-x11 is not installed."

command -v am >/dev/null 2>&1 ||
  die "Android 'am' command is not available."

########################
#### PulseAudio ########
########################

start_pulseaudio() {
  echo "==> Starting PulseAudio"

  if pulseaudio --check 2>/dev/null; then
    echo "    PulseAudio already running"
    return 0
  fi

  pulseaudio \
    --start \
    --load="module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1" \
    --exit-idle-time=-1

  sleep 1

  if pulseaudio --check 2>/dev/null; then
    echo "    PulseAudio started"
  else
    echo "    WARNING: PulseAudio did not report as running"
  fi
}

########################
#### Termux:X11 ########
########################

start_x11() {
  echo "==> Starting Termux:X11 server"

  # Check whether an X server is already listening on :0.
  if pgrep -f "termux-x11.*${DISPLAY_NUMBER}" >/dev/null 2>&1; then
    echo "    Termux:X11 server already running"
  else
    termux-x11 \
      "$DISPLAY_NUMBER" \
      -ac \
      -disable-dri3 &

    X11_PID=$!

    echo "    Termux:X11 PID: $X11_PID"

    # Give the X server time to initialise.
    sleep 2

    if ! kill -0 "$X11_PID" 2>/dev/null; then
      echo "    WARNING: Termux:X11 process exited"
    fi
  fi

  echo "==> Opening Termux:X11 Android activity"

  am start \
    --user 0 \
    -n com.termux.x11/com.termux.x11.MainActivity \
    >/dev/null 2>&1 ||
    echo "    WARNING: Could not open Termux:X11 activity"

  sleep 1
}

########################
#### XFCE ##############
########################

start_xfce() {
  echo "==> Starting XFCE inside Arch Linux ARM"

  proot-distro login "$ARCH_NAME" \
    --shared-tmp \
    -- \
    env \
    DISPLAY="$DISPLAY_NUMBER" \
    PULSE_SERVER="127.0.0.1" \
    GDK_BACKEND="x11" \
    QT_QPA_PLATFORM="xcb" \
    LIBGL_ALWAYS_SOFTWARE="1" \
    XDG_CURRENT_DESKTOP="XFCE" \
    XDG_SESSION_DESKTOP="xfce" \
    bash -lc '
            set -u

            ########################################
            # XDG runtime directory
            ########################################

            export XDG_RUNTIME_DIR="/tmp/runtime-$USER"

            mkdir -p "$XDG_RUNTIME_DIR"
            chmod 700 "$XDG_RUNTIME_DIR"

            ########################################
            # Basic X11 environment
            ########################################

            export DISPLAY=":0"

            ########################################
            # Disable XFCE compositing
            #
            # Termux:X11 already handles the display
            # and software rendering is preferable here.
            ########################################

            if command -v xfconf-query >/dev/null 2>&1; then
                xfconf-query \
                    -c xfwm4 \
                    -p /general/use_compositing \
                    -n \
                    -t bool \
                    -s false \
                    2>/dev/null || true
            fi

            ########################################
            # Remove stale XFCE processes
            ########################################

            pkill -u "$USER" xfce4-panel 2>/dev/null || true
            pkill -u "$USER" xfwm4 2>/dev/null || true
            pkill -u "$USER" xfsettingsd 2>/dev/null || true
            pkill -u "$USER" xfdesktop 2>/dev/null || true
            pkill -u "$USER" xfce4-session 2>/dev/null || true

            ########################################
            # Start a fresh D-Bus session and XFCE
            ########################################

            echo "==> Environment:"
            echo "    DISPLAY=$DISPLAY"
            echo "    XDG_RUNTIME_DIR=$XDG_RUNTIME_DIR"
            echo "    GDK_BACKEND=$GDK_BACKEND"
            echo "    QT_QPA_PLATFORM=$QT_QPA_PLATFORM"
            echo

            exec dbus-run-session -- xfce4-session
        '
}

########################
#### Main ##############
########################

echo
echo "========================================"
echo " Starting Arch XFCE"
echo "========================================"
echo

start_pulseaudio
start_x11
start_xfce
