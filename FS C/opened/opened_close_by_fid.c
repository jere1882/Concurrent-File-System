void opened_close_by_fid (workerdata * wdata,
                          int fid) {
  // search file by fid. remove it.
  Opened_Files * prev = wdata->opened_files;
  Opened_Files * curr = prev->next;
  
  if (prev->fid == fid) {
    if (prev->rm_marked)
      file_remove (wdata, prev->filename);
    free (prev);
    wdata->opened_files = curr;
    return ;
  } else {
    while (curr != NULL) {
      if (curr->fid == fid) {
        prev->next = curr->next;
        if (curr->rm_marked)
          file_remove (wdata, curr->filename);
        free (curr);
        return; }
      
      prev = curr;
      curr = curr->next; } }

  assert (false); }
