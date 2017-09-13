// Assumes that the file you want to remove
// exists.
void file_remove (workerdata * wdata,
                  char * filename) {
  
  assert (file_exists (wdata, filename));
  
  strcpy (auxdir, filedir);
  strcat (auxdir, filename);
  if (remove (auxdir) < 0)
    errno_abort ("Error deleting file!\n");
  
  // Search for the filename.
  File * prev = wdata->files;
  File * curr = prev->next;
  
  if (equal_strings (prev->filename,
                     filename)) {
    free (prev);
    wdata->files = curr;
    return ;
  } else {
    while (curr != NULL) {
      if (equal_strings (curr->filename,
                         filename)) {
        prev->next = curr->next;
        free (curr);
        return ; }
      
      prev = curr;
      curr = curr->next; } }

  assert (false); }
