#!/usr/bin/env bash

set -eou pipefail

if pacmd list-sources | grep -q "Remapped Q1U"; then
	echo "Remapping has already been done."
	exit 0;
fi

BASE_NAME="alsa_input.usb-USB_Microphone_USB_Microphone-00.iec958-stereo";

if pacmd list-sources | grep -q "name: <$BASE_NAME>"; then
	pacmd load-module module-remap-source \
		source_name=cru1_mono \
		master=$BASE_NAME \
		channels=2 \
		channel_map=mono,mono

	pacmd set-default-source cru1_mono

	pacmd set-source-volume cru1_mono 65536 # 100%, in case Zoom turned down the volume

	echo "Remapped microphone created."
	exit 0;
else
	echo "Base mic not found: $BASE_NAME"
	exit 1;
fi;

