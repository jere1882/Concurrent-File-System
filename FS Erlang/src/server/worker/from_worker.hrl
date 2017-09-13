from_worker (W, WPid, Msg) ->
  io:format("[Worker ~p] Received from worker "
    ++ "~p~n", [self(), Msg]),
  
  case Msg of
  
  {cre, Filename} ->
    BiggerId = self() > WPid,
    I_win    = tracked (Msg, W) and not BiggerId,
    case file_exists (Msg, W) or I_win of
      true ->
        WPid ! {rworker, self(), {Msg, error}};
      false ->
        WPid ! {rworker, self(), Msg}
    end,
    case tracked (Msg, W) and BiggerId of
      true -> worker (untrack (Msg, W));
      false -> worker (W)
    end;
  
  {lsd, Handler} ->
    Res = {lsd, Handler, list_files (W)},
    wanswer (Res, WPid),
    worker (W);
  
  {opn, Filename, Handler} ->
    case opened ({opened, Filename}, W) of
    true ->
      Res = {opn, already_opened, Msg},
      NW  = W;
    false ->
      case file_exists ({opn, Filename}, W) of
      true ->  % si el archivo lo tiene este worker, lo trackea como opened
        Fid = file_fid (Filename, W),  
        Res = {opn, Fid, Msg},
        NW  = open (Msg, [{fid, [Fid]}], W);
      false ->
        Res = {opn, not_found, Msg},   % sin  manda not found.
        NW = W
      end
    end,
    wanswer (Res, WPid),
    worker (NW);
  
  {wrt, Fid, Size, Text} ->
    file_write (Msg, W),  
    worker (W);
  
  {rea, Fid, Size, Handler} ->
    Res = {rea, file_read (Msg, W), Handler},
    wanswer (Res, WPid),
    worker (W);

  {{rm,Filename},Handler} ->
    Obj = {opened,Filename},
    case file_exists({rm,Filename}, W) of 
      true  ->          %el archivo que se quiere borrar está acá 
        case opened(Obj,W) of
          true ->       %el archivo está abierto. No puede ser borrado.
            wanswer({rm,Filename,file_in_use},WPid),
			NW=mark_del(Filename,W),
            worker(NW);
          false ->      % el archivo no está abierto, puede ser borrado -> lo borra
            wanswer({rm,Filename,file_deleted},WPid),
            worker(file_delete(Filename,W))
        end;
      false ->
        wanswer({rm,Filename,file_not_found},WPid),
        worker(W)
    end;


  {clo, Fid, Handler} -> 
  	case i_opened (Fid, Handler, W) of
  	    true ->
  	      Filename = opened_filename (Fid, Handler, W),
  	      Obj  = {opened, Filename},
  	      wanswer ({clo, Fid, Handler,ok}, WPid),	
  	      Info = track_info (Obj, W),      % Obtengo el diccionario con info
          case dict:fetch(rm_marked,Info) of
	    	[false] ->                     % El archivo no estaba marcado para ser borrado
				NW = untrack(Obj,Handler,W);     % Cierro el archivo
			[true]  ->                     % El archivo estaba marcado. Lo borra.
				NNW = file_delete(Filename,W),   % Borra el archivo y lo cierra.
				NW  = untrack(Obj,Handler,NNW)
		  end;
  	    false ->
  	      NW = W,
  	      wanswer ({clo, Fid, Handler,err}, WPid)
    end,
    worker (NW);


  {bye,Handler} ->                        % hay que cerrar todos los archivos q tenga abiertos
    worker(close_all_files(W,Handler));   % borra todos los registros de archivos abiertos acá.
                                          % si alguno estaba marcado para ser borrado, lo borra.




    _ -> throw(worker_from_handler)
    end.

