# like `dotnet clean`, but for /everything/.

find . -type d | grep 'bin$\|obj$' | xargs -I _ sh -c 'rm -rf _'

