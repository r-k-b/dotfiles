#!/usr/bin/env bash

# Have I forgotten to commit or push changes to the common repos?

set -e

check () {
	msg=" Checking ${1} ..."
	msgLen=${#msg}
	echo 
	for ((i=1; i<=((80-msgLen)); i++)); do
		printf '=%.0s' 1
	done;
	echo "$msg"
	git -C "$1" fetch
	git -C "$1" status
}

check /etc/nixos
check ~/dotfiles

