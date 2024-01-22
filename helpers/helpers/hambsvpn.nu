#!/usr/bin/env nu

(kwallet-query -r hambs kdewallet
	| jq .pw -r
	| (try {
	    do --capture-errors {
		sudo openconnect --passwd-on-stdin --protocol=gp --user=hslrbe --os=win -v --authgroup="PHD-Gateway" --servercert pin-sha256:YEJA+GVUxvFwbq3IFcgvXraEs/LRNsfccLDS/mdHIUQ= --dump-http-traffic vpnportal.hambs.com.au
		# try excluding the range that Docker uses?
		#-s 'vpn-slice %%10.0.0.0/8 --no-ns-hosts'
	    }
	} catch {
		notify-send "vpn ded" --expire-time=0
	})
)
