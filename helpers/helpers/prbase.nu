#!/usr/bin/env nu

# Creates a git branch at the MRCA of `main` and the current branch.
# Made necessary because IntelliJ has poor support for reviewing AzOps PRs.
def main [
    targetBranch:string = "main" # the branch that the PR is targeting
] {
    let currentBranch = (git branch --show-current)
    print $"Creating a review/comparison branch, at the MRCA of (ansi green)($targetBranch)(ansi reset) and (ansi green)($currentBranch)(ansi reset)..."
    git fetch --all --tags
    let prBase = (git merge-base HEAD origin/main)
    git branch rkb/pr-review-base $prBase --force
    print $"Branch (ansi green)rkb/pr-review-base(ansi reset) is ready for comparison, at commit ($prBase)"
}
