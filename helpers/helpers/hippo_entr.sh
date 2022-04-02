set -eou pipefail

# For when elm-live won't start because the build is broken.

cd ~/projects/PHDSys-webapp/hippo

nix-shell ./shell.nix --run "ag -l '^module ' ../ | grep .elm | entr sh -c 'clear; elm make src/Main.elm --output=./tmp/elm.js'"

