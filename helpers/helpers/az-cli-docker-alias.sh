#!/usr/bin/env bash

# for available versions, see:
# https://mcr.microsoft.com/v2/azure-cli/tags/list

podman run -it \
    -v "${HOME}"/.azure:/root/.azure \
    -v "${HOME}"/.azure-devops:/root/.azure-devops \
    -v "${HOME}"/Downloads/azclistuff:/Downloads \
    -v ~/projects/pweb/hippo:/hippo \
    mcr.microsoft.com/azure-cli:2.63.0 \
    az "$@"

