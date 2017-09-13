void opened_open (workerdata * wdata, command cmd,
    datagram * received, bool openers_here) {
  
  Opened_Files * of = malloc (
                        sizeof (Opened_Files));
  bool file_owned =
    file_exists (wdata, cmd.file);
  
  of->fid = (file_owned) ?
    (file_find (wdata, cmd.file))->fid :
    ((Note *)received->message)->status;
  strcpy (of->filename, cmd.file);
  of->user_id = cmd.user_id;
  of->openers_here = openers_here;
  of->rm_marked = false;
  of->worker_queue = (file_owned) ? NULL :
    received->respond_to;
  
  of->next = wdata->opened_files;
  wdata->opened_files = of; }
