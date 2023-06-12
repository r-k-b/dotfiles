#!/usr/bin/env bash

# The weekly version bump job in GitHub has a problem:
# https://github.com/Pacific-Health-Dynamics/PHDSys-webapp/blob/5ae55b3c062851f1e7f224f7c5f070249f168b97/.github/workflows/version_bump.yml
# Being an automated CI check, it doesn't trigger the other automatic CI
# checks, without which the PR is not allowed to merge.
# This script does the minimum necessary to get the mandatory CI checks to run.

set -e

cd ~/projects/bump
git fetch
git checkout bump_hippo_version
git commit --amend
git push --force
git checkout main
git branch -d bump_hippo_version
