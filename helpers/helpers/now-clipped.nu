#!/usr/bin/env nu

~/helpers/now-rfc.nu | xsel -ib
notify-send $"time copied: (~/helpers/now-rfc.nu)" --expire-time=3000

