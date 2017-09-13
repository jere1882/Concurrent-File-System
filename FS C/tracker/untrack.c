void untrack (workerdata * wdata, command cmd) {
  
  assert (tracked (wdata, cmd));
  
  // Pick the proper tracker
  Tracker * prev;
  switch (cmd.name) {
  case CRE:
    prev = wdata->cre_tracker;
    break;
  case OPN:
    prev = wdata->opn_tracker;
    break;
  case LSD:
    prev = wdata->lsd_tracker;
    break;
  case RM:
    prev = wdata->rm_tracker;
    break;
  default: assert (false); break; }
  Tracker * curr = prev->next;
  
  if (compare_tracker (prev, cmd)) {
    free (prev);
    switch (cmd.name) {
    case CRE:
      wdata->cre_tracker = curr;
      break;
    case OPN:
      wdata->opn_tracker = curr;
      break;
    case LSD:
      wdata->lsd_tracker = curr;
      break;
    case RM:
      wdata->rm_tracker = curr;
      break;
    default: assert (false); break; }
    return ;
  } else {
    // untrack all
    while (curr != NULL) {
      if (compare_tracker (curr, cmd)) {
        prev->next = curr->next;
        free (curr);
        return ; }
      
      prev = curr;
      curr = curr->next; } }

  assert (false); }
