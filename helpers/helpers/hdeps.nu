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
    git checkout -f .
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

    try {
        git commit -a -m "chore: bump npmDepsHashes [dependabot skip]"
    }

    echo $"Pushing to branch ($targetBranch)..."
    git push
    echo "Pushed."
    git checkout main
    git branch -d $targetBranch

    echo "Starting a Hippo reviewapp about it..."
    curl --request POST --header 'Accept: application/json' --header 'Content-Type: application/json' --data $"{
      "user" : "rkb",
      "bootstrap" : "hippo-frontend",
      "gitShaOrTag" : "($targetBranch)",
      "ticketLink" : "dependabot",
      "ticketNo" : "dependabot",
      "backend" : "yarp"
    }" 'https://review-apps.dev.hippo.hambs.io/api/v1/apps'

    # find problems early
    nix flake check --max-jobs 2 --log-format internal-json -v e+o>| nom --json
}
