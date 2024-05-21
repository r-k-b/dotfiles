#!/usr/bin/env bash

# makes a fake screen to share
# handy for sharing only part of 4K screens

# from https://askubuntu.com/a/1497547/340840

# tip: use `xdotool getmouselocation --shell` to find coordinates

# tip: use `xrandr --delmonitor screenshare` to remove it

# the bigger top-right quarter
xrandr --setmonitor screenshare 2270/1x1240/1+1570+0 none

