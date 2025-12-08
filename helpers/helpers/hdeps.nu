#!/usr/bin/env nu

# Updates the hashes of the npm dependencies, so that the Nix build can continue.
#
# todo: Switch the Nix build so it calculates the hashes from
# package.lock.json, and we no longer need this or update-npmDepsHashes
def main [
    targetBranch: string # the branch to commit to
] {
    cd ~/projects/hdeps-fe
    git clean -xf .
    git checkout .
    git reset --hard HEAD
    git fetch
    git checkout main
    try { git branch -D $targetBranch }
    git checkout $targetBranch
    git merge origin/main --no-edit

    # see if we can standardize the `"peer": true` weirdness
    nix develop . --command npm i --prefix admin
    nix develop . --command npm i --prefix hippo

    ./hippo/bin/update-npmDepsHashes
    git commit -a -m "chore: bump npmDepsHashes"
    echo $"Pushing to branch ($targetBranch)..."
    git push
    echo "Pushed."
    git checkout main
    git branch -d $targetBranch
}
