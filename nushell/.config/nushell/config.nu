# config.nu
#
# Installed by:
# version = "0.116.1"
#
# This file is used to override default Nushell settings, define
# (or import) custom commands, or run any other startup tasks.
# See https://www.nushell.sh/book/configuration.html
#
# Nushell sets "sensible defaults" for most configuration settings,
# so your `config.nu` only needs to override these defaults if desired.
#
# See also:
# https://github.com/nushell/nushell/blob/0.116.1/crates/nu-config/default_files/doc_config.nu#
#
# You can open this file in your default editor using:
#     config nu
#
# You can also pretty-print and page through the documentation for configuration
# options using:
#     config nu --doc | nu-highlight | less -R

$env.config.show_banner = "short"

$env.history.path = "~/.config/nushell/history.txt"

$env.PATH ++= [ '~/helpers' ]

# To load from a custom file you can use:
# source ($nu.default-config-dir | path join 'custom.nu')

$env.EDITOR = "vim"

$env.MANWIDTH = "100"

zoxide init nushell --cmd=j | save -f ~/.zoxide.nu

#from https://github.com/nushell/nushell/issues/1616#issuecomment-1386714173
$env.config.keybindings ++= [
    {
        name: history_menu_fzf
        modifier: control
        keycode: char_r
        mode: [emacs, vi_normal, vi_insert]
        event: {
            send: executehostcommand
            cmd: "commandline edit --replace (
                history
                   | each { |it| $it.command }
                   | reverse
                   | uniq
                   | str join (char -i 0)
                   | fzf --scheme=history --read0 --layout=reverse --height=40% -q (commandline)
                   | decode utf-8
                   | str trim
            )"
        }
    }
]

source /home/rkb/.config/broot/launcher/nushell/broot-init

source ~/.zoxide.nu

# adds the ssh-agent socket env var to every shell.
# don't forget to add `AddKeysToAgent yes` to your `~/.ssh/config`.
source ~/helpers/ssh-add-nushell.nu

module rerun {
    # Watch the output of a command. Similar to watch(1) but with a closure.
    # based on https://github.com/emk/nushell-commands/blob/main/rerun.nu
    export def main [
        closure: closure                  # The closure run on each iteration.
        --interval (-n): duration = 2sec  # The interval between iterations.
    ] {
        loop {
            clear
            do $closure
            sleep $interval
        }
    }
}
use rerun *

module ssht {
    # SSH straight into the tmux session.
    export def main [hostname: string] {
        if ($hostname | is-empty) {
            error make {msg: $"usage: ssht <hostname>"}
        }
    ssh $hostname -t sh -c "'tmux a || tmux'"
    }
}
use ssht *


use '/home/rkb/.config/broot/launcher/nushell/broot-init' *


def gpr-pweb [
  branchToReview: string
  reviewNumber?: int
] {
  let wtFolder = "/home/rkb/projects/pweb_worktrees"
  let reviewBranch = match $reviewNumber {
    null => $branchToReview
    _ => $"rkb/review/($branchToReview)/($reviewNumber)"
  }
  cd ~/projects/pweb
  git branch $reviewBranch $"origin/($branchToReview)"
  git branch --unset-upstream $reviewBranch
  #git worktree add $"($wtFolder)/($reviewBranch)" $reviewBranch
  git clone "/home/rkb/projects/pweb" -b $reviewBranch $"($wtFolder)/($reviewBranch)"
  cp -r "/home/rkb/projects/pweb/.idea" $"($wtFolder)/($reviewBranch)/"
  direnv exec ~/projects/pweb npm --prefix $"($wtFolder)/($reviewBranch)/admin" install
  cd $"($wtFolder)/($reviewBranch)"
  git remote remove origin
  git remote add origin git@github.com:Pacific-Health-Dynamics/PHDSys-webapp.git
  echo "Opening intellij..."
  print "Opening intellij ..."
  intellij-idea $"($wtFolder)/($reviewBranch)"
  echo "gpr-pweb done."
}

def gpr-pnet [
  branchToReview: string
  reviewNumber?: int
] {
  let wtFolder = "/home/rkb/projects/pnet_worktrees"
  let reviewBranch = match $reviewNumber {
    null => $branchToReview
    _ => $"rkb/review/($branchToReview)/($reviewNumber)"
  }
  cd ~/projects/pnet
  git branch $reviewBranch $"origin/($branchToReview)"
  git branch --unset-upstream $reviewBranch
  git clone "/home/rkb/projects/pnet" -b $reviewBranch $"($wtFolder)/($reviewBranch)"
  cp -r "/home/rkb/projects/pnet/.idea" $"($wtFolder)/($reviewBranch)/"
  cp "/home/rkb/projects/pnet/All.slnx" $"($wtFolder)/($reviewBranch)/"

  cd $"($wtFolder)/($reviewBranch)"
  git remote remove origin
  git remote add origin git@ssh.dev.azure.com:v3/HAMBS-AU/Sydney/PHDSys-net
  echo "Opening intellij..."
  print "Opening intellij ..."
  rider $"($wtFolder)/($reviewBranch)/All.slnx"
  echo "gpr-net done."
}

# ets, but defaulting to nice RFC3339 format
def --wrapped etsr [...rest] {
  ets -c -f '[%FT%T%z]' ...$rest
}

###

def create_left_prompt [] {
    let dir = match (do --ignore-errors { $env.PWD | path relative-to $nu.home-path }) {
        null => $env.PWD
        '' => '~'
        $relative_pwd => ([~ $relative_pwd] | path join)
        }

    let path_color = (if (is-admin) { ansi red_bold } else { ansi green_bold })
    let separator_color = (if (is-admin) { ansi light_red_bold } else { ansi light_green_bold })
    let path_segment = $"($path_color)($dir)(ansi reset)"

    # remind me when a long-running command finishes
    # (I probably switched away to look at something else)
    if (($env.CMD_DURATION_MS | into int) > 5_000 and (which espeak-ng | is-not-empty)) {
        let said = $"that took ($env.CMD_DURATION_MS | into int | into duration --unit ms), exit code ($env.LAST_EXIT_CODE)"
        sh -c $"espeak-ng '($said)' -s 300 -p 80 -a 50 &"
    }

    $path_segment | str replace --all (char path_sep) $"($separator_color)(char path_sep)($path_color)"
}

def create_right_prompt [] {
    # create a right prompt in magenta with green separators and am/pm underlined
    let time_segment = ([
        (ansi reset)
        (ansi magenta)
        (printf "%'d" (date now | format date '%s'))
        " "
        (date now | format date '%+')
    ] | str join | str replace --regex --all "([/:])" $"(ansi green)${1}(ansi magenta)" |
        str replace --regex --all "([AP]M)" $"(ansi magenta_underline)${1}")

    let last_exit_code = if ($env.LAST_EXIT_CODE != 0) {([
        (ansi rb)
        ($env.LAST_EXIT_CODE)
    ] | str join)
    } else { "" }

    ([$last_exit_code, (char space), $time_segment] | str join)
}

# Use nushell functions to define your right and left prompt
$env.PROMPT_COMMAND = {|| create_left_prompt }
# FIXME: This default is not implemented in rust code as of 2023-09-08.
$env.PROMPT_COMMAND_RIGHT = {|| create_right_prompt }

###

# based on https://www.nushell.sh/cookbook/direnv.html#configuring-direnv-in-nushell
use std/config *

# Initialize the PWD hook as an empty list if it doesn't exist
$env.config.hooks.env_change.PWD = $env.config.hooks.env_change.PWD? | default []

$env.config.hooks.env_change.PWD ++= [{||
  if (which direnv | is-empty) {
    # If direnv isn't installed, do nothing
    return
  }

  direnv export json | from json | default {} | update cells --columns [ PATH ] {
    # If direnv changes the PATH, it will become a string and we need to re-convert it to a list
    do (env-conversions).path.from_string $in
  } | load-env
}]

###
