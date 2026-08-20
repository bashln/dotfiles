#!/usr/bin/env sh

xinput list --name-only | while IFS= read -r device; do
	case "$device" in
	"Virtual core pointer" | "Virtual core XTEST pointer" | *Touchpad* | *touchpad* | *Keyboard* | *keyboard*)
		continue
		;;
	esac

	if xinput list-props "$device" | grep -q "libinput Accel Profile Enabled"; then
		xinput set-prop "$device" "libinput Accel Profile Enabled" 0 1 0
	fi

	if xinput list-props "$device" | grep -q "libinput Accel Speed"; then
		xinput --set-prop "$device" "libinput Accel Speed" -0.5
	fi
done
