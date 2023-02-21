set -eou pipefail

# For when elm-live won't start because the build is broken.

cd ~/projects/PHDSys-webapp/tcm

nix develop ../hippo --command sh -c "ag -l '^module ' ../ | grep .elm | entr sh -c 'clear; echo 'cleared'; elm make src/Main.elm --output=./tmp/elm.js'"

