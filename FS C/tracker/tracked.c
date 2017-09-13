bool tracked (workerdata * wdata, command cmd) {
  
  Tracker * tr;
  switch (cmd.name) {
  case CRE:
    tr = wdata->cre_tracker;
    break;
  case OPN:
    tr = wdata->opn_tracker;
    break;
  case LSD:
    tr = wdata->lsd_tracker;
    break;
  case RM:
    tr = wdata->rm_tracker;
    break;
  default: assert (false); break; }
  
  for (; tr != NULL; tr = tr->next)
    if (compare_tracker (tr, cmd))
      return true;
  
  return false; }
