#!/usr/bin/env nu

def main [
  --checkFlakes # run `nix flake check` on the branches
  --last: int = 3
  --fetch # pull the latest data from the remote BE repo.
] {
  cd ~/projects/phdsys-net

  if ($fetch) {
    git fetch --all --tags
  }

  let plain = git for-each-ref --sort=committerdate refs/remotes/ --format '%(objectname)፨%(refname:lstrip=3)፨%(objecttype)፨%(committerdate:iso-strict)'

  let parsed = $plain | lines | split column '፨' | rename hash ref type committerdate | update committerdate {|row| $row.committerdate | into datetime}

  let refined = $parsed | filter {|row|
    $row.ref != "integration"
  } | last $last

  if (not $checkFlakes) {
    return $refined
  } else {
    $refined | print
  }

  $refined | each {|row| doCheck $row}

  print "finished."
}

def doCheck [row] {
  print $"doing check for ($row.ref)"
  let flake = $"git+ssh://git@ssh.dev.azure.com/v3/HAMBS-AU/Sydney/PHDSys-net?ref=($row.ref)"

  try {
    NIXPKGS_ALLOW_INSECURE=1 nix flake check $flake --impure
  } catch {
    print $"❌ branch ($row.ref) did not pass the flake checks \(commit ($row.hash)\)"
  }
}

