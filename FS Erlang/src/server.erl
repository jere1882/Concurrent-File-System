-module(server).
-export([start/0, start/1, wait_connect/3,
         mon/0, fider/1,
         init_worker/1, worker/1,
         handler/4]).

-import(lists, [nth/2, any/2, map/2, filter/2,
                foldl/3]).

-include("server/mon.hrl").

-include("server/worker/init_worker.hrl").
-include("server/worker/worker.hrl").
-include("server/worker/from_handler.hrl").
-include("server/worker/from_worker.hrl").
-include("server/worker/from_rworker.hrl").

-include("server/fider.hrl").
-include("server/worker_utils/files.hrl").
-include("server/worker_utils/tracking.hrl").
-include("server/worker_utils/opened.hrl").
-include("server/worker_utils/broadcast.hrl").
-include("server/worker_utils/respond.hrl").
-include("server/worker_utils/wanswer.hrl").

-include("server/wait_connect.hrl").
-include("server/handler.hrl").


% "server:start()"" arranca todo el server.
% Spawnea un proceso "mon", y lo linkea a otro proceso "start/1" que
% borra archivos cuando mon sale, y si la salida es anormal lo levanta
% nuevamente. Si la salida es ok, entonces termina todo.

start () ->
  process_flag (trap_exit, true),
  M = spawn_link (?MODULE, mon, []),
  start (M).

start (M) ->
  receive
    {'EXIT', M, normal} ->
      erase_files (),
      exit(normal);
    {'EXIT', M, Reason} ->
      erase_files (),
      io:format ("[start] <mon> died, starting"
        ++ " all over again~n"),
      start ();
    _ -> start (M)
  end.

erase_files () ->
  {ok, Files} = file:list_dir ("storage"),
  map (fun (File) ->
         if
           File /= ".gitignore" ->
             file:delete ("storage/"++File);
           true -> File
         end
       end, Files).

% Funciones Auxiliares 

assert (Bool) ->
  case Bool of
    true ->
      true;
    false ->
      throw (failed_assertion)
  end.

take ([XS], 0) ->
  [];
take ([X|XS], N) ->
  [X|take (XS, N-1)];
take ([], N) ->
  [].
