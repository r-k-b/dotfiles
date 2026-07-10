#!/usr/bin/env nu
let tmpdir = mktemp -d
print $"tmpdir is ($tmpdir)"
mkdir $"($tmpdir)/toPreload"
let workerPodName = kubectl -n review-apps get pods -o custom-columns=:.metadata.name --no-headers | grep worker
print $"workerPodName is ($workerPodName)"

nix copy              --to $"file://($tmpdir)/toPreload" 'git+ssh://git@github.com/Pacific-Health-Dynamics/PHDSys-webapp.git?ref=main&rev=e70bda1c0cf04cc3cbf5e13467bb436e6d360540#artifactZip'
nix copy --derivation --to $"file://($tmpdir)/toPreload" 'git+ssh://git@github.com/Pacific-Health-Dynamics/PHDSys-webapp.git?ref=main&rev=e70bda1c0cf04cc3cbf5e13467bb436e6d360540#artifactZip'

print "uploading to the worker pod..."
kubectl -n review-apps cp $"($tmpdir)/toPreload" $"($workerPodName):/opt/app/bootstrappers"

print "copying to the store from the temp dir..."
kubectl exec -it $workerPodName -n review-apps -- rm -rf /opt/app/bootstrappers/toPreload/*
kubectl exec -it $workerPodName -n review-apps -- nix -v copy --all --from file:///opt/app/bootstrappers/toPreload

print "done."

