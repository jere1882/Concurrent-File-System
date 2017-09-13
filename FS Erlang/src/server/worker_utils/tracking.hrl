% Este archivo provee utilidades para gestionar el conjunto de tracks de un worker.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

-record(track, {obj     = "",   % :: [Cmd]
                handler = "",   % :: [Pid]
                counter = 0,    % :: Int , cantidad de respuestas afirmativas de workers a ese Cmd  
                info    = []}). % :: Dict (info del fid, handler y rm_marked booleano )


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% track :: Cmd -> Handler -> W -> W
% agrega a la lista de trackeados de W un nuevo elemento con obj=Cmd y handler=H.
% info y counter asumen lso valores por default.
track (O, H, W = #w{tracked = Tracks}) ->
  W#w{tracked =
      [#track{obj=O, handler=H} | Tracks]
  }.

% untrack :: Cmd -> W -> W 
% borra de la lista de trackeados aquellos cuyo comando sea Cmd.
untrack (Obj, W = #w{tracked = Tracks}) ->
  W#w{tracked =
    filter (fun (#track{obj = Object}) ->
              Obj /= Object
            end, Tracks)
  }.

untrack (Obj,Hand , W = #w{tracked = Tracks}) ->
  W#w{tracked =
    filter (fun (#track{obj = O, handler = H}) -> (Obj /= O) or (Hand /= H) end, Tracks)
  }.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% switch_tracks :: Track -> Track -> W -> W
% Te sobreescribe en W todos los tracks que tienen el Obj de OldTrack por todos el otro track.
switch_tracksMALA (OldTrack = #track{obj = Obj},
               NewTrack,
               W = #w{tracked = Tracks}) ->
 


  W#w{tracked =
  map (fun (Track = #track{obj = Obj}) ->   NewTrack;
           (T) ->  T
       end, Tracks)
  }.

% OBS:
% All variables that occur in the head of a fun are assumed to be "fresh" variables. 

switch_tracks (OldTrack = #track{obj = Obj},
               NewTrack,
               W = #w{tracked = Tracks}) ->

  W#w{tracked =
  map (fun (Track = #track{obj = O}) when O == Obj ->   NewTrack;
           (T) ->  T
       end, Tracks)
  }.

% MORALEJA: Si usan funciones anonimas, no hacer pattern matching en el header.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% tracked :: Cmd -> W -> Bool
% se fija si un comando está trackeado en W.
tracked (Obj, #w{tracked = Tracks}) ->
  any (fun (Track) ->
         Track#track.obj == Obj
       end, Tracks).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% get_track :: Cmd -> W -> Track
% Te devuelve UN track con el que coincida el comando

get_track (Obj, #w{tracked = Tracks}) ->
  nth (1,
      filter (fun (#track{obj = Object}) ->
                Obj == Object
              end, Tracks)).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Dado un Cmd, extraen el hander/counter/info asociado en W.

track_handler (Obj, W) ->
  #track{handler = H} = get_track (Obj, W),
  H.
track_counter (Obj, W) ->
  #track{counter = C} =
    get_track (Obj, W),
  C.
track_info (Obj, W) ->
  #track{info = Info} =
    get_track (Obj, W),
  Info.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Setters
% cambia el handler de Obj en tracked.
track_handler (Obj, W, NewHandler) ->
  OldTrack = get_track (Obj, W),
  NewTrack = OldTrack#track{handler =
                            NewHandler},
  switch_tracks (OldTrack, NewTrack, W).

track_counter (Obj, W, NewCounter) ->
  OldTrack = get_track (Obj, W),
  NewTrack = OldTrack#track{counter =
                            NewCounter},
  switch_tracks (OldTrack, NewTrack, W).

%track_info :: Cmd -> W -> Info -> W  
track_info (Obj, W, NewInfo) ->

  OldTrack = get_track (Obj, W),
  NewTrack = OldTrack#track{info = NewInfo},

  switch_tracks (OldTrack, NewTrack, W).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Incrementa en 1 el contador
inc_tracking (Obj, W) ->
  Counter = track_counter (Obj, W),
  track_counter (Obj, W, Counter + 1).
% Devuelve true si counter == 3
fully_tracked (Obj, W) ->
  track_counter (Obj, W) == 3.
