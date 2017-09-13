% argumentos

% PPid : pid del padre (mon) que es único (no hay varios mon, hay uno solo)
% WPid : pid del worker que le tocó
% socket que fue preparado en mon, para el puerto 8000
% usario ID en nuestro sistema.


handler(PPid, WPid, ListenSocket, UID) ->
  {ok, Socket} = gen_tcp:accept(ListenSocket), 
  PPid ! {self(), ok}, % Unblock wait_connect
  io:format("[User ~p] Started a connection, "
    ++ "assigned worker ~p~n", [UID, WPid]),
  handler(UID, WPid, Socket).

% ABOUT ACCEPT
  % accept(ListenSocket) -> {ok, Socket} | {error, Reason}
  % Accepts an incoming connection request on a listen socket. Socket must be a socket returned from listen/2. 
  % Returns {ok, Socket} if a connection is established, or {error, closed}

% Proceso que gestiona la interacción del FS con un único usuario UID.

handler(UID, WPid, Socket) ->

  % recibimos las solicitudes del cliente (cadena de caracteres)
  receive
    {tcp, _, RawMsg} ->
      Msg = remove_newline(RawMsg), 
      io:format("[User ~p] Sent: `~s`~n",
        [UID, Msg]),
      case get_cmd(Msg) of  % analizamos su estructura (parseamos)
        
        {cmd, {con}} ->
          gen_tcp:send(Socket, "ALREADY CON");
       

        {cmd, Cmd} ->
          io:format("[User ~p] Ask to worker ~p:"
            ++ " ~p~n", [UID, WPid, Cmd]),
          WPid ! {handler, self(), Cmd},                   % transmitimos la consulta al worker
          receive
            {WPid, NewMsg} ->                              % recibimos la respuesta
              io:format("[User ~p] Response: "
                ++ "~p~n", [UID, NewMsg]),
              gen_tcp:send(Socket, NewMsg),                % respondemos al socket
              case Cmd of
                {bye} -> io:format("[User ~p] Exiting..~n", [UID]),
                         exit(normal);
                _     -> handler(UID, WPid, Socket)
              end;
            _ ->
              throw(handler_wait_reponse)
          end;
        _ ->
          
      end,
      handler(UID, WPid, Socket);

    {tcp_closed, Port} ->
      io:format("[User ~p] Exiting..~n", [UID]),
      exit(normal);
    _ ->
      throw(handler_receive)
  end.



% get_cmd parsea la cadena y retorna uno de los siguientes comandos:

% {con}
% {lsd}
% {bye}
% {rm, Filename}
% {cre, Filename}
% {opn, Filename}
% {clo, Fid}
% {rea, Fid, Size}
% {wrt, Fid, Size, Text}


get_cmd ("CON") ->
  {cmd, {con}};
get_cmd ("LSD") ->
  {cmd, {lsd}};
get_cmd ("BYE") ->
  {cmd, {bye}};
get_cmd ("RM " ++ Filename) ->
  io:format("~s~n", [Filename]),
  case re:run(Filename, "^([a-z]|[A-Z]|[0-9])+$") of
    {match, _} ->
      {cmd, {rm, Filename}};
    _ ->
      err
  end;
get_cmd ("CRE " ++ Filename) ->
  case re:run(Filename, "^([a-z]|[A-Z]|[0-9])+$") of
    {match, _} ->
      {cmd, {cre, Filename}};
    _ ->
      err
  end;
get_cmd ("OPN " ++ Filename) ->
  case re:run(Filename, "^([a-z]|[A-Z]|[0-9])+$") of
    {match, _} ->
      {cmd, {opn, Filename}};
    _ ->
      err
  end;

get_cmd("CLO " ++ Data) ->
  case re:run(Data, "^FD +([1-9][0-9]*)$") of
    {match, [_, Fid]} ->
      {cmd, {clo, from_tuple(Data, Fid)}};
    _ ->
      err
  end;

get_cmd("REA " ++ Data) ->
  case re:run(Data, "^FD +([1-9][0-9]*) +SIZE +([1-9][0-9]*)$") of
    {match, [_, Fid, Size]} ->
      {cmd, {rea, from_tuple(Data, Fid), from_tuple(Data, Size)}};
    _ ->
      err
  end;
get_cmd("WRT " ++ Data) ->
  case re:run(Data, "^FD +([1-9][0-9]*) +SIZE +([1-9][0-9]*) +") of
    {match, [{_, From}, Fid, Size]} ->
      RealSize = from_tuple(Data, Size),
      {cmd, {wrt, from_tuple(Data, Fid), RealSize, lists:sublist(Data, From+1, RealSize)}};
    _ ->
      err
  end;
get_cmd(_) ->
  err.

dispatch_from_handler(WPid, Cmd) ->
  throw(dispatch_from_handler).

remove_newline([]) ->
  [];
remove_newline([$\n|[]]) ->
  [];
remove_newline([X|[]]) ->
  [X];
remove_newline([X|XS]) ->
  [X| remove_newline(XS)].

from_tuple(String, {From, Length}) ->
  list_to_integer(
    lists:sublist(String, From+1, Length)).
