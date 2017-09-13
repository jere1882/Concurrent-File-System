char * track_getlist (workerdata * wdata, command cmd) {
  assert (cmd.name == LSD);
  Tracker * tr = wdata->lsd_tracker;
  for (; tr != NULL; tr = tr->next)
    if (compare_tracker (tr, cmd))
      return tr->list;
  
  return NULL; }
