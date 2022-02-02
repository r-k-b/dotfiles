#!/usr/bin/env bash

set -eou pipefail

if pacmd list-sources | grep -q "Remapped Q1U"; then
	echo "Remapping has already been done."
	exit 0;
fi

pacmd load-module module-remap-source \
	source_name=cru1_mono \
	master=alsa_input.usb-USB_Microphone_USB_Microphone-00.analog-stereo \
	channels=2 \
	channel_map=mono,mono

pacmd set-default-source cru1_mono

echo "Remapped microphone created."

