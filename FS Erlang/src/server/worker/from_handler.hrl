% Esta función recibe una consulta de un handler.
% Toma las primeras acciones que debe tomar un worker ante tal comando, eg, fijarse 
% Si con su información local es suficiente para responder la consulta ó 
% comunicarse con los otros workers para obtener los datos necesarios que requiera 
% esta consulta.

% Se utilizan intensivamente las funciones de tracking.hrl y files.hrl, básicamente 
% manipulan el estado de un worker (record W) al agregarle nuevos archivos, trackear
% nuevos comandos, fijarse si un archivo existe, borrar, etc.


from_handler (W, Handler, Cmd) ->
  io:format("[Worker ~p] Received ~p~n",
    [self(), Cmd]),
  
  case Cmd of
  {cre, Filename} ->
    case file_exists (Cmd, W) or        % ese nombre de archivo ya existe en este worker
             tracked (Cmd, W) of        % este comando ya esta trackeado
    true ->
      respond (Handler, "FILE EXISTS"), % Handler ! {self(), Msg}. Envío la respuesta al handler para que éste lo reenvíe 
                                        % al cliente.
      worker (W);                  
    false ->
      broadcast (Cmd, W),               % Reenvía la consulta a los workers compañeros (será atendida por la función from_worker) 
      worker (track (Cmd, Handler, W))  % agrega el comando como trackeado con el handler asociado
                                        % para poder terminar de resolver la consulta cuando los otros workers respondan al broadcast.
    end;
  

  {opn, Filename} ->
    case opened ({opened, Filename}, W) of 
    true ->  %  Alguien ya tiene abierto ese archivo
      respond (Handler, "ALREADY OPENED"),
      worker (W);
    false -> 
      case file_exists (Cmd, W) of     
        true ->  % SI EL ARCHIVO EXISTE EN ESTE WORKER y NADIE LO TIENE ABIERTO 
          Fid = file_fid (Filename, W),
          respond (Handler,
            "OK FID " ++ integer_to_list (Fid)),
          worker (
            open (Cmd, Handler,[{fid, [Fid]}], W));
        false ->
          Obj = {opn, Filename, Handler},
          broadcast (Obj, W),
          worker (track (Obj, Handler, W))
      end
    end;
  

% REGLAS PARA ARCHIVOS ABIERTOS
% El worker que atiende a un usuario sabe si (el usuario) tiene o no un archivo abierto
% SI hay trackeado un opened entonces se sabe que archivo tinene abierto y  en que worker
% Si es otro worker, entonces el otro worker también tiene trackeado un opened.
% Osea q en un worker ya se sabe todos los handlers q tenen abiertos archivos suyos
% Es clave la simplificación (del enunciado) que dice que un achivo puede tener un solo 
% handler q lo tiene abierto a al vez.

  {lsd} ->
    Msg = {lsd, Handler},
    broadcast (Msg, W),
    worker (track (Msg, Handler, W));

  {wrt, Fid, Size, Text} ->
    case i_opened (Fid, Handler, W) of
    true ->
      Filename = opened_filename (Fid, Handler, W),
      case file_exists (Cmd, W) of
        true ->
          file_write (Cmd, W);
        false ->                            % quiere escribir en un archivo que no está entre sus archivos
          Obj  = {opened, Filename},        % como está abierto por el usuario
          Info = track_info (Obj, W),       % saca la info
          WPid = dict:fetch (worker, Info), % se fija en que worker está guardado
          WPid ! {worker, self(), Cmd}      % le manda al q lo tiene "escribí"
      end,
      respond (Handler, "OK");
    false ->
      respond (Handler, "FILE NOT OPENED/OWNED")
    end,
    worker (W);


  {rea, Fid, Size} ->
    case i_opened (Fid, Handler, W) of
    true ->
      Filename =
        opened_filename (Fid, Handler, W),
      case file_exists (Cmd, W) of
      true ->
        respond (Handler, file_read (Cmd, W)); % Si no le agregamos ++"\0" el espacio, falla cuando le pido leer más size del q corresponde.
      false ->
        Obj  = {opened, Filename},
        Info = track_info (Obj, W),
        WPid = dict:fetch (worker, Info),
        WPid ! {worker, self(),
                  {rea, Fid, Size, Handler}}
      end;
    false ->
      respond (Handler, "FILE NOT OPENED/OWNED")
    end,
    worker (W);
  
  {rm,Filename} ->  
    Obj = {opened,Filename},
    case file_exists(Cmd, W) of 
      true  ->    %el archivo que quiero borrar está acá 
        case opened(Obj,W) of
          true -> %el archivo está abierto. No puede ser borrado.
                  %lo marcaré para ser borrado.
            NW = mark_del(Filename,W),
            respond(Handler,"MARKED. FILE WILL BE REMOVED."),
            worker(NW);
          false -> % el archivo no está abierto, puede ser borrado -> lo borro
            respond(Handler,"OK"),
            worker(file_delete(Filename,W))
        end;
      false ->
        broadcast({Cmd,Handler},W),
        worker(track(Cmd,Handler,W))
    end;


 % Obs. La diferencia entre i_opened y opened es q la primera si fija si esta abierto por un handler particular ("si tiene permiso")
 % y la segunda solo si alguien tiene abierto el archivo.
 % NOTAR que en clo usamos un untrack con el handler. Porque solo queremos cerrar los opened de un dado handler, no todos los opened!.

  {clo, Fid} ->
    case i_opened (Fid, Handler, W) of
      true ->
        Filename = opened_filename (Fid, Handler, W),
        Obj  = {opened, Filename},
        Info = track_info (Obj, W),     
        case file_exists (Cmd, W) of
          true ->                                         % El archivo está abierto y lo tengo yo!
            respond (Handler, "OK"),      

            case dict:fetch(rm_marked,Info) of
            	[false] ->                                % El archivo no estaba marcado para ser borrado
					NW = untrack(Obj,Handler,W);
				[true]  ->                                % El archivo estaba marcado. Lo borro.
					NNW = file_delete(Filename,W), 
					NW  = untrack(Obj,Handler,NNW)
			end;
          false ->                                        % El archivo está abierto y no lo tengo yo.
            WPid = dict:fetch (worker, Info),             % Me fijo quién lo tiene
            WPid ! {worker, self(),{clo, Fid, Handler}},  % Le mando que lo borre
            NNW  = untrack(Obj,Handler,W),                % Lo doy por borrado
            NW   = track(Cmd,Handler,NNW)
        end;
      false ->
        respond (Handler, "FILE NOT OPENED/OWNED"),  
        NW = W
    end,
    worker(NW);  




  {bye} ->                                % hay que cerrar todos los archivos q tenga abiertos ese handler
    broadcast({bye,Handler},W),           % les aviso a los demás que si este handler tiene algo abierto allá, lo cierren
    respond(Handler,"OK"),                % aviso al usuario que todo OK
    worker(close_all_files(W,Handler));   % borro todos los registros de archivos abiertos acá y borro los archivos marcados a ser borrados de entre esos.
  

  _ -> throw(worker_from_handler)
  
  end.















%%%%%%%%%%%% testing tools
	print_tracks(W = #w{tracked = T}) -> 
		io:format(" ~n~n ~p ~n ~n",[T]).