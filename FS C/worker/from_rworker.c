void from_rworker (workerdata * wdata, datagram * request) {
  
  command cmd = request->cmd;
  char response[BUFF_SIZE];
  Note * note = (Note *)request->message;
  
  printf ("[worker %d][from rWorker] "
    "`%s`\n", wdata->id, cmd.linea);
  
  switch (cmd.name) {
  
  case CRE:
  
  if (tracked (wdata, cmd)) {
    increase_tracking (wdata, cmd);
    if (note->status) { // It's cool
      if (fully_tracked (wdata, cmd)) {
        untrack (wdata, cmd);
        file_create (wdata, cmd.file);
        strcpy (response, "OK");
        enqueue (cmd.user_queue, response); }
    } else {
      untrack (wdata, cmd);
      strcpy (response, "FILE_EXISTS");
      enqueue (cmd.user_queue, response); }
  }
  break;
  
  case OPN:
  if (tracked (wdata, cmd)) {
    increase_tracking (wdata, cmd);
    
    int fnf = fully_tracked (wdata, cmd) && note->status == 0;
    if (! (fnf || note->status != 0)) // -(( p and q ) or -q) = -(p or -q) = -p and q
                                      // -fully_tracked (wdata, cmd) && note->status == 0
      break;
    
    // File already opened.
    if (note->status == -1)
      strcpy (response, note->text);
    // File opened
    if (note->status > 0) {
      opened_open (wdata, cmd, request, true);
      sprintf (response, note->text,
               note->status); }
    // File not found
    if (fnf)
      strcpy (response, "FILE NOT FOUND");
    
    untrack (wdata, cmd);
    enqueue (cmd.user_queue, response);
  }
  break;
  
  case REA: case WRT:
  strcpy (response, note->text);
  enqueue (cmd.user_queue, response);
  break;
  
  case CLO:
  // Just drop the message.
  break;
  
  case LSD:
  if (tracked (wdata, cmd)) {
    increase_tracking (wdata, cmd);
    
    track_enlist (wdata, cmd, note->text);
    if (fully_tracked (wdata, cmd)) {
      track_enlist (wdata, cmd,
                    file_list (wdata));
      strcpy (response,
        track_getlist (wdata, cmd));
      enqueue (cmd.user_queue, response);
      untrack (wdata, cmd);
    }
  }
  break;
  
  case RM:
  if (note->status == -1) {
    opened_mark_rm (wdata, cmd);
    
  } else if (tracked (wdata, cmd)) {
    increase_tracking (wdata, cmd);
    
    if (note->status == 1) {
      untrack (wdata, cmd);
      strcpy (response, note->text);
      enqueue (cmd.user_queue, response);
      printf ("[worker %d][from rWorker] "
        "Answering FOUND\n", wdata->id);
    }
    
    if (note->status == 0 &&
                fully_tracked (wdata, cmd)) {
      
      untrack (wdata, cmd);
      strcpy (response, note->text);
      printf ("[worker %d][from rWorker] "
        "Answering NOTFOUND\n", wdata->id);
      enqueue (cmd.user_queue, response); }
  }
  break;
  
  case BYE:
  // Just drop the message.
  break;
  
  default: assert (false); break; }
  
  // todo: clean datagram.
}
