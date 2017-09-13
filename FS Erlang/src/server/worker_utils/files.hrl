% Define funcionalidades para manipular archivos de nuestro FS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
-record(file, {filename    = "",
               fid         = 0 }).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% add_file   String -> W -> [file]
add_file(Filename, W) ->
  add_file_aux(Filename, W#w.files).

%  add_file_aux :: String -> [file] -> [file]  

%  Crea el archivo vacío en la carpeta storage.
%  Pide al fider (proceso que spawneamos al principio) que le pase un id de archivo nuevo (fresco).
%  el fider es común para todos los workers. entonces estamos seguros de que el id será único para todos los workers.
%  Agrega entonces, a Files, el nuevo nombre de archivo con su ID correspondiente.
%  obs: 

% write_file(Filename, Bytes) -> ok | {error, Reason}
% Writes the contents of the iodata term Bytes to the file Filename. The file is created if it does not exist. If it 
% exists, the previous contents are overwritten. Returns ok, or {error, Reason}.


add_file_aux(Filename, Files) ->
  file:write_file ("storage/"++Filename, ""),  % crea el archivo vacío.
  fider_srv ! self(),
  FreshFid = receive FreshFid -> FreshFid end,
  Files ++ [#file{filename=Filename,
                  fid=FreshFid}].
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%get_files :: W -> [file]
%extrae la lista de file de un W

get_files(W) ->
  W#w.files.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%file_exists :: Cmd -> W -> Bool
%se fija si un archivo existe en W.
file_exists({cre, Filename}, W) ->
  file_exists_aux({filename, Filename},
                  W#w.files);
file_exists({opn, Filename}, W) ->
  file_exists_aux({filename, Filename},
                  W#w.files);
file_exists({wrt, Fid, _, _}, W) ->
  file_exists_aux({fid, Fid},
                  W#w.files);
file_exists({rea, Fid, _}, W) ->
  file_exists_aux({fid, Fid},
                  W#w.files);
file_exists({clo,Fid},W) ->
  file_exists_aux({fid,Fid}, 
                  W#w.files);
file_exists({rea, Fid, _, _}, W) ->
  file_exists_aux({fid, Fid},
                  W#w.files);
file_exists({rm,Filename},W) -> 
  file_exists_aux({filename, Filename},
                  W#w.files).

file_exists_aux({filename, Filename},  % recorre todos los archivos de W y se fija si alguno tiene el mismo nombre
                Files) ->
  any( fun(File) ->
         File#file.filename == Filename
       end,
       Files);
file_exists_aux({fid, Fid}, Files) ->  % recorre todos los archivos de W y se fija si alguno tiene ese id.
  any( fun(File) ->
         File#file.fid == Fid
       end,
       Files).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% file_write :: Cmd -> W -> ok | {error, Reason}

file_write (Cmd = {wrt, Fid, Size, Text}, W) ->
  assert (file_exists (Cmd, W)),
  Filename = filename (Fid, W),
  RealText = take (Text, Size),
  file:write_file ("storage/"++Filename,
    RealText, [append]).

% file_read :: Cmd -> W -> String.
file_read ({rea, Fid, Size, _}, W) ->
  file_read ({rea, Fid, Size}, W);
file_read (Cmd = {rea, Fid, Size}, W) ->
  assert (file_exists (Cmd, W)),
  Filename = filename (Fid, W),
  {ok, Binary} =
    file:read_file ("storage/"++Filename),  % where Binary is a binary data object that contains the contents of Filename
  take (binary_to_list (Binary), Size).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% pasan de ID a nombre(string) y viceversa
filename (Fid, W) ->
  Files = get_files (W),
  File = nth(1,
      filter( fun(File) ->
                File#file.fid == Fid
              end, Files)),
  File#file.filename.

file_fid(Filename, W) ->
  Files = get_files(W),
  File = nth(1,
      filter( fun(File) ->
                File#file.filename == Filename
              end, Files)),
  File#file.fid.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% list_files : W -> string
% devuelve todos los nombres de los archivos existentes separados por espacios en un solo string.
list_files(W) ->
  list_files_aux(W#w.files).
list_files_aux(Files) ->
  foldl(
    fun(File, List) ->
      List ++ " " ++ File#file.filename
    end, "", Files).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% file_delete : W -> Filename -> W

file_delete(Filename, W = #w{ files = Files }) ->
  W#w{files =
    filter (fun (#file{filename = F}) ->
              F /= Filename
            end, Files)
  }.