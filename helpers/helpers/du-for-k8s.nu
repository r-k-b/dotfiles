#!/usr/bin/env nu

let x1 = kubectl get pods -n review-apps -o json -l app=nbc-writer-azops

print "x1:"
print ($x1 | jq . --sort-keys)

let x2 = kubectl get --raw /api/v1/nodes/($x1 | jq '.items[] | .spec.nodeName' -r)/proxy/stats/summary

print "x2:"
print ($x2 | jq . --sort-keys)

let x3 = $x2 | jq '.pods | map({podName: .podRef.name, usedBytes: .containers[].rootfs.usedBytes})'

let x4 = $x3 | from json | sort-by usedBytes | update usedBytes {|pod| $pod.usedBytes | into filesize }

print $x4
