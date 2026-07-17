#!/usr/bin/env nu

def main [rev: string] {

  let tmpdir = mktemp -d
  print $"tmpdir is ($tmpdir)"
  mkdir $"($tmpdir)/toPreload"
  let getName = timeit --output { kubectl -n review-apps get pods -o custom-columns=:.metadata.name --no-headers | grep worker | collect }
  let getNameTime = $getName.time
  let workerPodName = $getName.output
  print $"workerPodName is ($workerPodName)"

  let copy1Time = timeit { nix copy              --from ssh-ng://rkb@strator --to $"file://($tmpdir)/toPreload" $"git+ssh://git@github.com/Pacific-Health-Dynamics/PHDSys-webapp.git?rev=($rev)#artifactZip" }
  let copy2Time = timeit { nix copy --derivation --from ssh-ng://rkb@strator --to $"file://($tmpdir)/toPreload" $"git+ssh://git@github.com/Pacific-Health-Dynamics/PHDSys-webapp.git?rev=($rev)#artifactZip" }

  print "clearing the pod's upload destination..."
  let clearDestTime = timeit { kubectl exec -it $workerPodName -c review-apps-worker -n review-apps -- rm -rf /opt/app/bootstrappers/toPreload/* }

  print "uploading to the worker pod..."
  let uploadTime = kubectl -n review-apps cp $"($tmpdir)/toPreload" $"($workerPodName):/opt/app/bootstrappers"

  print "copying to the store from the temp dir..."
  let podCopyTime = timeit { kubectl exec -it $workerPodName -c review-apps-worker -n review-apps -- nix -v copy --all --from file:///opt/app/bootstrappers/toPreload --to file:///srv/review-apps/buildcache --no-check-sigs }

  print "done."

  [[step timing];
    ["get worker pod name" $getNameTime]
    ["copy 1" $copy1Time]
    ["copy 2 (with --derivation flag)" $copy2Time]
    ["clear pod dest" $clearDestTime]
    ["upload to pod" $uploadTime]
    ["install to pod's Nix Store" $podCopyTime]
  ] | table
}
