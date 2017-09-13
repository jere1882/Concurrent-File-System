void from_handler (workerdata * wdata, datagram * received ) {
  
  command cmd = received->cmd;
  datagram * requests;
  datagram * request;
  
  Opened_Files * ofs;
  
  char response[BUFF_SIZE];
  int i = 0;
  for (; i < BUFF_SIZE; ++i) response[i] = 0;
  
  printf ("[worker %d][from handler] "
    "`%s`\n", wdata->id, cmd.linea);
  
  switch (cmd.name) {
  case CRE:
  if (file_exists (wdata, cmd.file) ||
      tracked (wdata, cmd)) {
    
    strcpy (response, "FILE EXISTS"); // response = "FILE EXISTS"
    enqueue (cmd.user_queue, response);
  } else {
    track (wdata, cmd);
    // Send CRE requests to workers.
    requests = four_datagrams (wdata, cmd);
    broadcast (wdata, requests); }
  break;
  
  case OPN:
  if (file_exists (wdata, cmd.file)) {
    if (is_opened (wdata, cmd)) {
      strcpy (response, "FILE ALREADY OPENED");
    } else {
      opened_open (wdata, cmd, received, true);
      sprintf (response, "OK FID %d", (file_find (wdata, cmd.file))->fid); 
    }
    enqueue (cmd.user_queue, response);
  } else {
    track (wdata, cmd);
    // Send OPN requests to workers.
    broadcast (wdata,
      four_datagrams (wdata, cmd));
  }
  break;
  
  case REA:
  if (is_opened (wdata, cmd)) {
    if (opened_by_user (wdata, cmd)) {
      if (file_exists (wdata, cmd.file)) {
        file_read (wdata, cmd, response);
      } else {
        request = datagram_template (
          wdata, cmd, WORKER);
        enqueue (opened_get_worker (
          wdata, cmd), request);
        break; }
    } else {
      strcpy (response, "ERROR, FILE OPENED"
        " BY OTHER USER"); }
  } else {
    strcpy (response, "ERROR, FILE NOT OPENED");
  }
  enqueue (cmd.user_queue, response);
  break;
  
  case WRT:
  if (is_opened (wdata, cmd)) {
    if (opened_by_user (wdata, cmd)) {
      if (file_exists (wdata, cmd.file)) {
        file_write (wdata, cmd);
        strcpy (response, "OK");
      } else {
        request = datagram_template (
          wdata, cmd, WORKER);
        enqueue (opened_get_worker (
          wdata, cmd), request);
        break; }
    } else {
      strcpy (response, "ERROR, FILE OPENED"
        " BY OTHER USER"); }
  } else {
    strcpy (response, "ERROR, FILE NOT OPENED");
  }
  enqueue (cmd.user_queue, response);
  break;

  case CLO:
  if (is_opened (wdata, cmd)) {
    if (opened_by_user (wdata, cmd)) {
      if (! file_exists (wdata, cmd.file)) {
        request = datagram_template (
          wdata, cmd, WORKER);
        enqueue (opened_get_worker (
          wdata, cmd), request); }
      opened_close (wdata, cmd);
      strcpy (response, "OK");
    } else {
      strcpy (response, "ERROR, FILE OPENED"
        " BY OTHER USER"); }
  } else {
    strcpy (response, "ERROR, FILE NOT OPENED");
  }
  enqueue (cmd.user_queue, response);
  break;
  
  case LSD:
  track (wdata, cmd);
  requests = four_datagrams (wdata, cmd);
  broadcast (wdata, requests);
  break;
  
  case RM:
  if (file_exists (wdata, cmd.file) &&
        !is_opened (wdata, cmd)) {
    file_remove (wdata, cmd.file);
    strcpy (response, "OK");
    enqueue (cmd.user_queue, response);
  } else if (file_exists (wdata, cmd.file) &&
             is_opened (wdata, cmd) &&
             openers_here (wdata, cmd)) {
    opened_mark_rm (wdata, cmd);
    strcpy (response, "OK, RM WHEN CLOSED");
    enqueue (cmd.user_queue, response);
  } else {
    printf ("[worker %d][from handler] "
      "Ask other workers for %s\n", wdata->id, cmd.file);
    track (wdata, cmd);
    requests = four_datagrams (wdata, cmd);
    broadcast (wdata, requests);
  }
  break;
  
  // Close all the user files and say OK.
  case BYE:
  // Ninja looping over the data structure:
  ofs = wdata->opened_files;
  for (; ofs != NULL; ofs = ofs->next) {
    if (ofs->user_id == cmd.user_id) {
      if (file_exists (wdata, ofs->filename)) {
        opened_close_by_fid (wdata, ofs->fid);
      } else {
        printf ("[worker %d][from handler] "
          "Send a BYE to the worker owner of"
          " the file <%s>\n", wdata->id,
          ofs->filename);
        request = datagram_template (
          wdata, cmd, WORKER);
        enqueue (opened_get_worker_by_fid (
                   wdata, ofs->fid),
                 request);
      }
    }
  }
  strcpy (response, "OK");
  enqueue (cmd.user_queue, response);
  break;
  
  default: assert (false); break; }

  // todo: clean datagram
}
