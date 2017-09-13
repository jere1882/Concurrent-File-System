void track (workerdata * wdata, command cmd) {
  
  Tracker * tr = malloc (sizeof (Tracker));
  
  // Init default values
  int i; for (i = 0; i < FILENAME_SIZE; ++i)
    tr->filename[i] = 0;
  tr->list[0] = 0;
  tr->user_id = 0;
  tr->counter = 0;
  
  // Track tr->filename or tr->user_id.
  switch (cmd.name) {
  case CRE: case OPN: case RM:
    strcpy (tr->filename, cmd.file);
  break;
  case LSD:
    tr->user_id = cmd.user_id;
  break;
  default: assert (false); break; }
  
  // Save in the worker data
  switch (cmd.name) {
  case CRE:
    tr->next = wdata->cre_tracker;
    wdata->cre_tracker = tr;
    break;
  case OPN:
    tr->next = wdata->opn_tracker;
    wdata->opn_tracker = tr;
    break;
  case LSD:
    tr->next = wdata->lsd_tracker;
    wdata->lsd_tracker = tr;
    break;
  case RM:
    tr->next = wdata->rm_tracker;
    wdata->rm_tracker = tr;
    break;
  default: assert (false); break; }
}
