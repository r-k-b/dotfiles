set -eou pipefail

# For when elm-live won't start because the build is broken.

cd ~/projects/PHDSys-webapp/hippo

nix develop ./. --command sh -c "ag -l '^module ' ../ | grep .elm | entr sh -c 'clear; elm make src/Admin.elm --output=./tmp/elm-admin.js'"

