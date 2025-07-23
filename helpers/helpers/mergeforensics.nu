#!/usr/bin/env nu

# assuming we always run this on the pweb repo...?

def main [
    --mergecommit: string
  ] {
  cd ~/projects/pweb
  print $"setting up forensics on ($mergecommit)..."
  let parents = git rev-list --parents -n 1 $mergecommit | split row " " | skip 1
  print "parents:" $parents
  git -C ~/projects/mergeforensics-pweb reset --hard
  git -C ~/projects/mergeforensics-pweb fetch origin
  git -C ~/projects/mergeforensics-pweb checkout ($parents | first)
  let restParents = $parents | skip 1
  do -i {
    git -C ~/projects/mergeforensics-pweb merge ...$restParents
  }
  print "~/projects/mergeforensics-pweb ready for examination 🔍"
}
