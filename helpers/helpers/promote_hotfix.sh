#!/usr/bin/env bash

set -eou pipefail

az() {
  echo "calling az with: " "$@"
  ~/helpers/az-cli-docker-alias.sh "$@"
}

hash az 2>/dev/null || {
  echo >&2 "I didn't find the 'az' command.  Do you have the azure-cli set up?";
  exit 1;
}

if [ $# -eq 0 ]
then
	# no arguments provided
	echo 'use like: ./promote_hotfix.sh "hippoui-release.hippo.2023w12.1" "2023W12.1" e7750d6e065dcd8ab314846a0530556bdf423dd3'
	echo ''
	echo 'Note: the first arg exactly matches the "name" property of the feed in Azure Artifacts.'
  echo "It's derived from the name of the hotfix branch."
	exit 0
fi

workDir=$(realpath ~/Downloads/azclistuff)
containerWorkDir="/Downloads"
echo "Working in $workDir, visible from the az-cli container as $containerWorkDir"
cd "$workDir"

commitHash="$3"
releaseVersion="$2"
hotfixFeed="$1"

echo downloading commit hash: "$commitHash"

az artifacts universal download \
	--organization "https://dev.azure.com/HAMBS-AU/" \
	--project "d2756ded-f26d-4358-8551-02a4c0f37d19" \
	--scope "project" \
	--feed "hippo-frontend" \
	--name "$hotfixFeed" \
	--version "0.0.0-commit-$commitHash" \
	--path "$containerWorkDir"


sanitizedReleaseVersion=$(printf '%s' "$releaseVersion" | tr '[:upper:]' '[:lower:]')

echo uploading to the main feed for WF Octo, as version: "$sanitizedReleaseVersion ($releaseVersion)"

az artifacts universal publish \
	--organization "https://dev.azure.com/HAMBS-AU/" \
	--project "d2756ded-f26d-4358-8551-02a4c0f37d19" \
	--scope "project" \
	--feed "hippo-frontend" \
	--name "hippoui-main" \
	--version "0.0.0-commit-$commitHash" \
	--description "HIPPO frontend for release $releaseVersion, commit $commitHash" \
	--path "$containerWorkDir/HippoUI.0.0.0-commit-$commitHash.zip"

echo renaming zip file

mv "HippoUI.0.0.0-commit-$commitHash.zip" \
   "HippoUI.0.0.0-release-$sanitizedReleaseVersion.zip"

echo uploading as version: "$sanitizedReleaseVersion ($releaseVersion)"

az artifacts universal publish \
	--organization "https://dev.azure.com/HAMBS-AU/" \
	--project "d2756ded-f26d-4358-8551-02a4c0f37d19" \
	--scope "project" \
	--feed "hippo-frontend" \
	--name "hippoui-release" \
	--version "0.0.0-release-$sanitizedReleaseVersion" \
	--description "HIPPO frontend for release $releaseVersion, commit $commitHash" \
	--path "$containerWorkDir/HippoUI.0.0.0-release-$sanitizedReleaseVersion.zip"

echo done.
