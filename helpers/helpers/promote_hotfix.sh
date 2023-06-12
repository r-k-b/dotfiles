#!/usr/bin/env bash

set -eou pipefail

hash az 2>/dev/null || {
  echo >&2 "I didn't find the 'az' command.  Do you have the azure-cli set up?";
  exit 1;
}

if [ $# -eq 0 ]
then
	# no arguments provided
	echo 'use like: ./promote.sh "hippoui-release.hippo.2023w12.1" "2023W12.1" e7750d6e065dcd8ab314846a0530556bdf423dd3'
	echo ''
	echo 'Note: the first arg exactly matches the "name" property of the feed in Azure Artifacts.'
  echo "It's derived from the name of the hotfix branch."
	exit 0
fi

workDir=$(realpath ~/Downloads/azclistuff)
echo "Working in $workDir"
cd "$workDir"

commitHash="$3"
releaseVersion="$2"
hotfixFeed="$1"

echo downloading commit hash: "$commitHash"

az artifacts universal download \
	--organization "https://pacifichealthdynamics.visualstudio.com/" \
	--project "e216e3e9-03bd-4591-b373-c229ed35d45d" \
	--scope project \
	--feed "phd-frontend" \
	--name "$hotfixFeed" \
	--version "0.0.0-commit-$commitHash"\
	--path /tmp/


sanitizedReleaseVersion=$(printf '%s' "$releaseVersion" | tr '[:upper:]' '[:lower:]')

echo uploading to the main feed for WF Octo, as version: "$sanitizedReleaseVersion ($releaseVersion)"

az artifacts universal publish \
	--organization https://pacifichealthdynamics.visualstudio.com/ \
	--project 'PHDSys' \
	--scope 'project' \
	--feed 'phd-frontend' \
	--name "hippoui-main" \
	--version "0.0.0-commit-$commitHash" \
	--description "HIPPO frontend for release $releaseVersion, commit $commitHash" \
	--path "/tmp/HippoUI.0.0.0-commit-$commitHash.zip"

echo renaming zip file

mv "HippoUI.0.0.0-commit-$commitHash.zip" \
   "HippoUI.0.0.0-release-$sanitizedReleaseVersion.zip"

echo uploading as version: "$sanitizedReleaseVersion ($releaseVersion)"

az artifacts universal publish \
	--organization https://pacifichealthdynamics.visualstudio.com/ \
	--project 'PHDSys' \
	--scope 'project' \
	--feed 'phd-frontend' \
	--name "hippoui-release" \
	--version "0.0.0-release-$sanitizedReleaseVersion" \
	--description "HIPPO frontend for release $releaseVersion, commit $commitHash" \
	--path "/tmp/HippoUI.0.0.0-release-$sanitizedReleaseVersion.zip"

echo done.
