broadcast (Msg, #w{workers = Pids}) ->
  map (fun (Pid) ->
         Pid ! {worker, self(), Msg}
       end, Pids).
