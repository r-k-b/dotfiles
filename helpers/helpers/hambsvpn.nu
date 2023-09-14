#!/usr/bin/env nu

try {
	(kwallet-query -r hambs kdewallet
		| jq .pw -r
		| (sudo openconnect
			--passwd-on-stdin
			--protocol=gp
			--user=hslrbe
			--os=win
			-v
			--authgroup="PHD-Gateway"
			--servercert pin-sha256:pKHeXiDpkOI2nwBpa2JaibywuDmbgJxalJkV+adLUwg=
			--dump-http-traffic
			# try excluding the range that Docker uses?
			#-s 'vpn-slice %%10.0.0.0/8 --no-ns-hosts'
			vpnportal.hambs.com.au
			)
	)
} catch {
	notify-send "vpn ded" --expire-time=0
}
