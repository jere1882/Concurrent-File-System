% Este archivo reune utilidades para manipular la apertura-cerrado de archivos en relacion a nuestro FS

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
open ({opn, Filename, Handler}, InfoList, W) ->
  open ({opn, Filename}, Handler, InfoList, W).
 
% open :: Cmd -> Handler -> [{key, [infos]}] -> W ->  W   

open ({opn, Filename}, Handler, InfoList, W) ->
  Info1 = dict:from_list (InfoList),                % This function converts the Key - Value list List to a dictionary.
  Info2 = dict:append (handler, Handler, Info1),    % This function appends a new Value to the current list of values associated with Key.
  Info3 = dict:append (rm_marked, false, Info2),    % Info3 = { (fid,[Fid]), (handler,HandlerPid), (rm_marked,false)}
  Obj = {opened, Filename},
  NW = track (Obj, Handler, W),
  track_info (Obj, NW, Info3).                      % Modifica W agregando un cmd opened, el diccionario y el handler asociados.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Cierra todos los archivos abiertos por ese handler y borra aquellos que estaban marcados para borrar

close_all_files(W = #w{files = Files, tracked = Tracks}, Handler) -> 
  io:format("close_all_files. Llegamos con estos files: ~p ~n",[Files]),
  NewTracks =  [ #track{obj=O, handler=H} ||  #track{obj=O, handler=H} <- Tracks , not(is_opened_obj(O)), H/=Handler], % los cierro
  ToRemove  =  [ get_name(O)  || T = #track{obj=O, handler=H} <- Tracks , is_marked(T), H == Handler],  % archivos que debo borrar 
  io:format("close_all_files. Tengo q borrar estos files de nombre: ~p ~n",[ToRemove]),
  NewFiles  =  [ F || F = #file{filename = FN} <- Files , not(lists:member( FN,ToRemove)) ],                             % los borro
  io:format("close_all_files. Nos vamos con estos files: ~p ~p ~n",[NewFiles,self()]),
  W#w{tracked =NewTracks, files = NewFiles }. 

is_opened_obj({opened,_}) -> true ; 
is_opened_obj(_)          -> false.


is_marked(#track{obj=O, info=Info}) ->  case is_opened_obj(O) of
                                          false -> false;
                                          true  -> lists:nth(1,dict:fetch(rm_marked,Info))
                                        end.

get_name({_,F}) -> F.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Se fija si está trackeado
opened (Obj, W) ->
  tracked (Obj, W).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% i_opened :: (filename,String) -> HandlerPid -> W -> Bool   CASO 1
% Se fija si el archivo de nombre String está abierto por HandlerPid en W. 


i_opened ({filename, Filename}, H, W) ->
  Obj = {opened, Filename},
  case tracked (Obj, W) of          % filename está abierto en W
  true ->
    track_handler (Obj, W) == H;     
  false ->
    false
  end;

% i_opened :: Int (fid) -> HandlerPid -> W -> Bool   CASO 2

% Se fija si el archivo con id Fid está abierto por ese handler en W.
i_opened (Fid, H, W) ->
  length (aux_opened (Fid, H, W)) > 0.

% recupera el string nombre asociado al archivo abierto Fid (por H) en W.
opened_filename (Fid, H, W) ->
  #track{obj = Obj} = nth (1, aux_opened (Fid, H, W)),
  {opened, Filename} = Obj,
  Filename.



% aux_opened :: Int -> HandlerPid -> W -> [Track]
% Fltra la listra tracked dejando aquellos track que en su info tienen únicamente ese fid y ese handler.

aux_opened (Fid, Handler, #w{tracked = Tracks}) ->
  filter (
    fun (#track{info = Info}) ->
      (dict:is_key (fid, Info)) and
        (dict:fetch (fid, Info) == [Fid]) and             % This function returns the value associated with Key in the dictionary Dict.
        (dict:is_key (handler, Info)) and
        (dict:fetch (handler, Info) == [Handler])
    end, Tracks).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% mark_del :: Filename -> Handler -> W -> W
% anoto que se quiere borrar el archivo apenas se cierre.

mark_del(Filename, W) -> 
  Cmd = {opened,Filename},
  Track = get_track(Cmd,W),
  %% ese track tiene la siguiente info
  %% Nombre del archivo abierto 
  %% Handler del usuario q lo tiene abierto
  %% Info diccionario
  %% Extraemos estos datos
  Info     = track_info (Cmd, W),                                              % current info
  NewInfo  = dict:store(rm_marked,[true],Info),                                % marcar para ser borrado (override)
  NewTrack = #track{obj = Cmd, handler=track_handler(Cmd,W), info = NewInfo},
  switch_tracks (Track, NewTrack, W).                                          % cambiamos los tracks.