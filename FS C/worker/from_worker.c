void from_worker (workerdata * wdata, datagram * request) {
  
  command cmd = request->cmd;
  datagram * response =
    datagram_template (wdata, cmd, RWORKER);
  datagram * aux_res; // Used by RM.
  
  Opened_Files * ofs;
  
  char * filename;
  char text[BUFF_SIZE];
  
  int i = 0;
  for (; i < BUFF_SIZE; ++i) text[i] = 0;
  
  bool bigger_id;
  bool i_win; // Used by CRE cmd.
  
  printf ("[worker %d][from worker] "
    "`%s`\n", wdata->id, cmd.linea);
  
  switch (cmd.name) {
  
  case CRE:
  
  filename  = cmd.file;
  bigger_id = wdata->id > request->from_id;
  
  i_win     = tracked (wdata, cmd) && !bigger_id;
  if (file_exists (wdata, filename) || i_win)
    note (response, 0, "FILE EXISTS");
  else
    note (response, 1, "COOL");
  
  if (tracked (wdata, cmd) && bigger_id)
    untrack (wdata, cmd);
  break;
  
  case OPN:
  if (file_exists (wdata, cmd.file)) {
    if (is_opened (wdata, cmd))
      note (response, -1, "FILE ALREADY OPENED");
    else {
      printf ("[worker %d][from worker] "
        "-> {%d, 'OK FID d'}\n", wdata->id,  file_fid (wdata, cmd));
      opened_open (wdata, cmd, request, false);
      note (response, file_fid (wdata, cmd),
            "OK FID %d");
    }
  } else {
    printf ("[worker %d][from worker] "
      "-> {0, 0}\n", wdata->id);
    note (response, 0, ""); // file not found
  }
  break;
  
  case REA:
  file_read (wdata, cmd, text);
  note (response, 1, text);
  break;
  
  case WRT:
  file_write (wdata, cmd);
  note (response, 1, "OK");
  break;
  
  case CLO:
  opened_close (wdata, cmd);
  note (response, 1, "OK");
  break;
  
  case LSD:
  note (response, 1, file_list (wdata));
  break;
  
  case RM:
  if (file_exists (wdata, cmd.file) &&
                    ! is_opened (wdata, cmd)) {
    file_remove (wdata, cmd.file);
    printf ("[worker %d][from worker] "
      "{ 1, \"OK\" }\n", wdata->id);
    note (response, 1, "OK");
  } else if (file_exists (wdata, cmd.file) &&
             is_opened (wdata, cmd) &&
             openers_here (wdata, cmd)) {
    opened_mark_rm (wdata, cmd);
    note (response, 1, "OK, RM WHEN CLOSED");
  } else if ( !file_exists (wdata, cmd.file) &&
              is_opened (wdata, cmd)) {
    aux_res = datagram_template (wdata, cmd,
                                 RWORKER);
    note (aux_res, -1 , "");
    enqueue (opened_get_worker (wdata, cmd),
             aux_res);
    note (response, 1, "OK, RM WHEN CLOSED");
  } else {
    printf ("[worker %d][from worker] "
      "{ 0, \"FILE NOT FOUND\" }\n", wdata->id);
    note (response, 0, "FILE NOF FOUND");
  }
  break;
  
  case BYE:
  // Ninja looping over the data structure:
  ofs = wdata->opened_files;
  for (; ofs != NULL; ofs = ofs->next) {
    if (ofs->user_id == cmd.user_id) {
      opened_close_by_fid (wdata, ofs->fid);
    }
  }
  break;
  
  default: assert (false); break; }
  
  enqueue (request->respond_to, response);
  
  // todo: clean datagram.
}
