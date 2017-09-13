void track_enlist (workerdata * wdata, command cmd, char * list) {
  assert (cmd.name == LSD);
  Tracker * tr = wdata->lsd_tracker;
  for (; tr != NULL; tr = tr->next)
    if (compare_tracker (tr, cmd))
      strcat (tr->list, list);
}
