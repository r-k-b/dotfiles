#!/usr/bin/env bash

# use like: ./promote.sh 2023W06 78d6d395aa3d773cca5a2641e5eb8b18160bca75

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
	echo "use like: ./promote.sh 2023W06 78d6d395aa3d773cca5a2641e5eb8b18160bca75"
	exit 0
fi

workDir=$(realpath ~/Downloads/azclistuff)
containerWorkDir="/Downloads"
echo "Working in $workDir, visible from the az-cli container as $containerWorkDir"
cd "$workDir"

commitHash="$2"
releaseVersion="$1"

echo downloading commit hash: "$commitHash"

az artifacts universal download \
	--organization "https://dev.azure.com/HAMBS-AU/" \
	--project "d2756ded-f26d-4358-8551-02a4c0f37d19" \
	--scope "project" \
	--feed "hippo-frontend" \
	--name "hippoui-main" \
	--version "0.0.0-commit-$commitHash" \
	--path "$containerWorkDir"

sanitizedReleaseVersion=$(printf '%s' "$1" | tr '[:upper:]' '[:lower:]')

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
	--description "HIPPO frontend for release $releaseVersion" \
	--path "$containerWorkDir/HippoUI.0.0.0-release-$sanitizedReleaseVersion.zip"

echo done.
