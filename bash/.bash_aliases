alias copy='xsel -ib'

alias idea-hambs='nix-shell ~/projects/hambs/shell.nix --run "idea-ultimate ~/projects/hambs/" &> /dev/null &'

alias idea-hippo='nix-shell ~/projects/PHDSys-webapp/hippo/shell.nix --run "idea-ultimate ~/projects/PHDSys-webapp/" &> /dev/null &'

alias rider-phdnet='nix develop /home/rkb/projects/phdsys-net/ --command rider "" &> /dev/null &'

# use like `vim $(bo)`
# https://dystroy.org/broot/tricks/
alias bo="br --conf ~/.config/broot/select.toml"

