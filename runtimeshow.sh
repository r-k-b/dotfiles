# https://jakemccrary.com/blog/2015/05/03/put-the-last-commands-run-time-in-your-bash-prompt/

function timer_start {
  timer=${timer:-$SECONDS}
}

function timer_stop {
  timer_show=$(($SECONDS - $timer))
  unset timer
}

trap 'timer_start' DEBUG

if [ "$PROMPT_COMMAND" == "" ]; then
  PROMPT_COMMAND="timer_stop"
else
  PROMPT_COMMAND="$PROMPT_COMMAND; timer_stop"
fi

#PS1='[last: ${timer_show}s][\w]$ '

