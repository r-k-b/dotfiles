#!/usr/bin/env bash

docker run -it \
    -v "${HOME}"/.azure:/root/.azure \
    -v "${HOME}"/.azure-devops:/root/.azure-devops \
    -v "${HOME}"/Downloads/azclistuff:/Downloads \
    -v ~/projects/PHDSys-webapp/hippo:/hippo \
    mcr.microsoft.com/azure-cli:2.53.0 \
    az "$@"

