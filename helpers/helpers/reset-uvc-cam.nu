#!/usr/bin/env nu

print "Settings before:"
v4l2-ctl -d /dev/video3 --list-ctrls

v4l2-ctl -d /dev/video3 --set-ctrl=brightness=90
v4l2-ctl -d /dev/video3 --set-ctrl=contrast=30
v4l2-ctl -d /dev/video3 --set-ctrl=saturation=60

print "\nSettings after:"
v4l2-ctl -d /dev/video3 --list-ctrls

