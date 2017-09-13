from_rworker(W, Worker, Resp) ->
  io:format("[Worker ~p] Received from rWorker "
    ++ "~p~n", [self(), Resp]),
  
  case Resp of
  
  {{cre, Filename}, Err} ->
    Cmd = {cre, Filename},
    track_handler (Cmd, W) !
      {self(), "FILE EXISTS"},
    worker (untrack (Cmd, W));
  {cre, Filename} ->
    Cmd = {cre, Filename},
    case tracked(Cmd, W) of
      true ->
        case fully_tracked(Cmd, W) of
          true -> track_handler (Cmd, W) !
                    {self(), "OK"},
                  NW = untrack (Cmd, W),
                  worker(NW#w{
                    files=add_file(Filename, NW) });
          false -> worker (
                     inc_tracking (Cmd, W))
        end;
      false ->
        worker(W)
    end;
  

  {lsd, Handler, FilesList} ->
    Obj = {lsd, Handler},
    case tracked(Obj, W) of
      true ->
	      NewList = track_info (Obj, W) ++ FilesList,          % Todos los archivos hasta el momento
	      case fully_tracked (Obj, W) of
	        true -> 
	          FinalList = list_files(W) ++ NewList  ++ " ",    % Le agrega los locales
	          Handler ! {self(), FinalList},
	          worker (untrack (Obj, W));
  	      false -> 
	      	  NW = track_info (Obj, W, NewList),              
        		worker (inc_tracking (Obj, NW))
     		end;
      false ->  io:format("(LSD) ERROR~n"),
      					worker(W)   % Nunca debería pasar.
    end;
  
  {opn, Status, Obj} ->
    case tracked (Obj, W) of
    true ->
      case Status of
      already_opened ->
        Handler = track_handler (Obj, W),
        respond (Handler, "ALREADY OPENED"),
        worker (untrack (Obj, W));
      not_found ->
        case fully_tracked (Obj, W) of
        true ->
          Handler = track_handler (Obj, W),
          respond (Handler, "FILE NOT FOUND"),
          worker (untrack (Obj, W));
        false ->
          worker (inc_tracking (Obj, W))
        end;
      Fid ->
        Handler = track_handler (Obj, W),
        respond (Handler, "OK FID " ++
          integer_to_list (Fid)),
        NW = untrack (Obj, W),
        worker (open (Obj,[{fid, [Fid]}, {worker, Worker}], NW))
      end;
    false ->
      worker (W)
    end;
  
  {rea, Text, Handler} ->
    respond (Handler, Text++"\0"),
    worker (W);
  

  {rm,Filename,Status} ->
    Cmd = {rm,Filename},
    case (tracked(Cmd,W)) of
      false ->
        worker(W);
      true  ->  % el comando está aún trackeado
        Handler = track_handler (Cmd, W),
        case Status of
          file_in_use    -> 
            respond(Handler,"MARKED. FILE WILL BE REMOVED."),          
            worker(untrack(Cmd,W));
          file_deleted   -> 
            respond(Handler,"OK."),
            worker(untrack(Cmd,W));
          file_not_found -> 
            case fully_tracked(Cmd,W) of
              true ->
                respond(Handler,"FILE NOT FOUND"),
                worker(untrack(Cmd,W));
              false ->
                worker(inc_tracking(Cmd,W))
            end
        end
    end;


  {clo, Fid, Handler, Status } ->
  	Obj = {clo,Fid},
  	case tracked (Obj, W) of
  	  true -> 
  	  	case Status of 
  	  	  ok -> 
		    respond (Handler, "OK"),
		    worker (untrack({clo,Fid},Handler,W));
		  err ->  % nunca debería suceder...
		    respond (Handler, "FILE NOT FOUND"),
		    worker (untrack({clo,Fid},Handler,W))
		end;
	  false -> 
	  	worker(W)
	  end;


  _ -> throw(from_rworker)
  end.


