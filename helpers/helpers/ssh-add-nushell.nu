#!/usr/bin/env nu
# from https://www.nushell.sh/cookbook/ssh_agent.html
# use like `source ssh-add-nushell.nu`
do --env {
    let ssh_agent_file = (
        $nu.temp-path | path join $"ssh-agent-($env.USER? | default whoami).nuon"
    )

    if ($ssh_agent_file | path exists) {
        let ssh_agent_env = open ($ssh_agent_file)
        if ($"/proc/($ssh_agent_env.SSH_AGENT_PID)" | path exists) {
            print $"loading existing env from file: ($ssh_agent_file)"
            load-env $ssh_agent_env
            print $ssh_agent_env
            return
        } else {
            print $"no agent running; removing file: ($ssh_agent_file)"
            rm $ssh_agent_file
        }
    }

    let ssh_agent_env = ^ssh-agent -c
        | lines
        | first 2
        | parse "setenv {name} {value};"
        | transpose --header-row
        | into record
    load-env $ssh_agent_env
    $ssh_agent_env | save --force $ssh_agent_file
    print $"agent started; see file: ($ssh_agent_file)"
    print $ssh_agent_env
}

