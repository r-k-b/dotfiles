#!/usr/bin/env nu

(kwallet-query -r hambs kdewallet
    | jq .pw -r
    | (try {
        do --capture-errors {
            (sudo openconnect
                --passwd-on-stdin
                --protocol=gp
                --user=hslrbe
                --os=win -v
                #--authgroup="HAMBS-HO-Gateway"
                --authgroup="PHD-Gateway"
                --servercert pin-sha256:rrIwctsA+cNDdkg1VpwBsbSbx1SES7zcYt7NdIpSeMg=
                --dump-http-traffic vpnportal.hambs.com.au
                -s 'vpn-slice --verbose --dump --banner --no-ns-hosts --no-host-names 10.0.0.0/8 172.0.0.0/8 192.168.0.0/16 203.22.229.119/32'
            )
        }
    } catch {
        notify-send "vpn ded" --expire-time=0
    })
)
