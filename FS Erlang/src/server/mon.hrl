% Worker state.
-record(w, { workers = [],       % :: [Pid].  Los pids de los otros 4 workers.
             files   = [],       % :: [File].  File es, a su vez, otro record con dos campos: nombre (string) y fileid (int) (ver worker_utils\files)
             tracked = [] }).    % :: [Track]. Lista de records Track. (ver worker_utils\tracking)



mon() ->
  
  % Initialize workers.
  WPids = lists:map(
    fun(_) ->
      spawn_link (?MODULE, init_worker, [self()])
    end,
    lists:seq(1, 5)),
  
  % Send to each worker its init info.
  lists:map(
    fun(WPid) ->
      OtherPids = lists:delete(WPid, WPids),
      WPid ! {self(),
              [#w{workers=OtherPids}]}
    end,
    WPids),

  % Initialize the FID service.
  Fider = spawn_link (?MODULE, fider, [1]),
  register(fider_srv, Fider),
  
  % Listen for a new connection.
  {ok, ListenSocket} = gen_tcp:listen(
    8000, [{active,    true},
           {reuseaddr, true}]),
  wait_connect (WPids, ListenSocket, 1).


% ABOUT gen_tcp:listen/2
% The gen_tcp module provides functions for communicating with sockets using the TCP/IP protocol.
% listen(Port, Options) -> {ok, ListenSocket} | {error, Reason}
% Sets up a socket to listen on the port Port on the local host.
% The following options are available:
%{active, true | false | once | N}
% If the value is true, which is the default, everything received from the socket will be sent as 
% messages to the receiving process. If the value is false (passive mode), the process must explicitly 
% receive incoming data by calling gen_tcp:recv/2,3, gen_udp:recv/2,3 or gen_sctp:recv/1,2 (depending 
%on the type of socket).
% {reuseaddr, Boolean}
% Allows or disallows local reuse of port numbers. By default, reuse is disallowed.


