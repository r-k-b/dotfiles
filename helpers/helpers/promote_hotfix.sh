#!/usr/bin/env bash

# use like: ./promote_hotfix.sh "hippoui-release.hippo.2023w12.1" "2023W12.1" e7750d6e065dcd8ab314846a0530556bdf423dd3
# (the first arg can be copied from the name of the feed in Azure Artifacts;
# it's derived from the name of the hotfix branch)

set -eou pipefail

workDir=$(realpath ~/Downloads/azclistuff)
echo "Working in $workDir"
cd "$workDir"

commitHash="$3"
releaseVersion="$2"
hotfixFeed="$1"

echo downloading commit hash: "$commitHash"

~/helpers/az-cli-docker-alias.sh artifacts universal download \
	--organization "https://pacifichealthdynamics.visualstudio.com/" \
	--project "e216e3e9-03bd-4591-b373-c229ed35d45d" \
	--scope project \
	--feed "phd-frontend" \
	--name "$hotfixFeed" \
	--version "0.0.0-commit-$commitHash"\
	--path /Downloads/


sanitizedReleaseVersion=$(printf '%s' "$releaseVersion" | tr '[:upper:]' '[:lower:]')

echo uploading to the main feed for WF Octo, as version: "$sanitizedReleaseVersion ($releaseVersion)"

~/helpers/az-cli-docker-alias.sh artifacts universal publish \
	--organization https://pacifichealthdynamics.visualstudio.com/ \
	--project 'PHDSys' \
	--scope 'project' \
	--feed 'phd-frontend' \
	--name "hippoui-main" \
	--version "0.0.0-commit-$commitHash" \
	--description "HIPPO frontend for release $releaseVersion, commit $commitHash" \
	--path "/Downloads/HippoUI.0.0.0-commit-$commitHash.zip"

echo renaming zip file

mv "HippoUI.0.0.0-commit-$commitHash.zip" \
   "HippoUI.0.0.0-release-$sanitizedReleaseVersion.zip"

echo uploading as version: "$sanitizedReleaseVersion ($releaseVersion)"

~/helpers/az-cli-docker-alias.sh artifacts universal publish \
	--organization https://pacifichealthdynamics.visualstudio.com/ \
	--project 'PHDSys' \
	--scope 'project' \
	--feed 'phd-frontend' \
	--name "hippoui-release" \
	--version "0.0.0-release-$sanitizedReleaseVersion" \
	--description "HIPPO frontend for release $releaseVersion, commit $commitHash" \
	--path "/Downloads/HippoUI.0.0.0-release-$sanitizedReleaseVersion.zip"

echo done.
