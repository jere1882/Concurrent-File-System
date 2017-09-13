% recibe el pid del proceso mon, su padre.
% recibe el mensaje de mon indicándole el pid de los otros workers
% encapsulado en un W, y llama a la func worker(W).
% Es decir, el da su estado inicial.

init_worker(Caller) ->
  io:format("[Worker ~p] Initialized.~n",
    [self()]),
  
  receive
    {Caller, WorkerArgs} ->
      apply (?MODULE, worker, WorkerArgs);
    _ ->
      throw (bad_worker_arg)
  end.
