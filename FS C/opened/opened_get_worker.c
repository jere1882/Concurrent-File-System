queue * opened_get_worker (workerdata * wdata,
                           command cmd) {
  
  Opened_Files * of = wdata->opened_files;
  for (; of != NULL; of = of->next) {
    switch (cmd.name) {
      case CLO: case REA: case WRT:
        if (of->fid == cmd.fid)
          return of->worker_queue;
      break;
      case RM:
        if (equal_strings (of->filename,
                           cmd.file))
          return of->worker_queue;
      break;
      default: assert (false); break; } }
  
  assert (false);
  return NULL; }
