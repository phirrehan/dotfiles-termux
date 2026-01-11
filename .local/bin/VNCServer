#!/bin/bash

pkill pulseaudio
pkill termux-wake-lock

pulseaudio --start --exit-idle-time=-1
pacmd load-module module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1

proot-distro login archlinux --user rehan --shared-tmp -- bash -c "vncserver :1"
