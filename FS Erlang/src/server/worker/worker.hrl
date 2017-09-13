% luego de ser inicializado, un worker se comporta así:
% W es su estado. Recibe tres tipos de mensaje y acorde a quién lo envió, actúa en consecuencia con el from adecuado. 
% luego se volverá a llamar a worker en el nuevo W actualizado.


worker(W) ->
  receive
    {handler, Handler, Cmd} ->
      from_handler(W, Handler, Cmd);
    {worker, Worker, Cmd} ->
      from_worker(W, Worker, Cmd);
    {rworker, Worker, Resp} ->
      from_rworker(W, Worker, Resp);
    _ ->
      throw(bad_worker_arg1)
  end.
