% Answer from a worker to other worker.
wanswer (Msg, WPid) ->
  WPid ! {rworker, self(), Msg}.
