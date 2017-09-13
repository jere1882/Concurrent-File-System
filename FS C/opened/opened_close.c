void opened_close (workerdata * wdata,
                   command cmd) {
  // search file by fid. remove it.
  Opened_Files * prev = wdata->opened_files;
  Opened_Files * curr = prev->next;
  
  if (prev->fid == cmd.fid) {
    if (prev->rm_marked)
      file_remove (wdata, prev->filename);
    free (prev);
    wdata->opened_files = curr;
    return ;
  } else {
    while (curr != NULL) {
      if (curr->fid == cmd.fid) {
        prev->next = curr->next;
        if (curr->rm_marked)
          file_remove (wdata, curr->filename);
        free (curr);
        return; }
      
      prev = curr;
      curr = curr->next; } }

  assert (false); }
