queue * opened_get_worker_by_fid (
    workerdata * wdata, int fid) {
  
  Opened_Files * of = wdata->opened_files;
  for (; of != NULL; of = of->next)
    if (of->fid == fid)
      return of->worker_queue;
  
  assert (false);
  return NULL; }
