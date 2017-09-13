wait_connect(WPids, ListenSocket, UserCounter) ->
  Index = random:uniform(length(WPids)),
  HPid = spawn_link (?MODULE, handler,
           [self(), nth(Index, WPids),
            ListenSocket, UserCounter]),

  % wait_connect se invoca luego de inicializar los workers. Se encarga de asignar un handler
  % a cliente del FS.
  
  receive
    {HPid, ok} ->
      wait_connect (WPids, ListenSocket,
                    UserCounter + 1);
    _ -> throw(wait_connect)  % uses throw/1 as a way to push {error, Reason} tuples back to a top-level function
  end.

  % apenas el handler que está en espera recibe una conexión, desbloquea esta función mandando "ok",  y un
  % nuevo handler es spawneado para atender al siguiente cliente.
