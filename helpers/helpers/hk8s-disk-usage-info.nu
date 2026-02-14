#!/usr/bin/env nu

# keep an eye on how much disk we're using on the k8s nodes

def main [
] {
    let app = "nbc-writer-azops"
    print $"app: ($app)"
    let node = kubectl get pods -n review-apps -o json -l app=nbc-writer-azops | jq '.items[] | .spec.nodeName' -r
    print $"node: ($node)"
    let stats = kubectl get --raw /api/v1/nodes/($node)/proxy/stats/summary

    $stats | jq '.pods | map({podName: .podRef.name, usedBytes: .containers[].rootfs.usedBytes})' | from json | sort-by usedBytes | update usedBytes {|pod| $pod.usedBytes | into filesize }
}
