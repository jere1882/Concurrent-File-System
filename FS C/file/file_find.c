// Assumes that the file you want to find
// exists.
File * file_find (workerdata * wdata,
                  char * filename) {
  
  assert (file_exists (wdata, filename));
  
  // Search for the filename.
  File * file = wdata->files;
  for (; file != NULL; file = file->next)
    if (equal_strings (file->filename,
                       filename))
      return file;
  
  assert (false);
  return NULL; }
