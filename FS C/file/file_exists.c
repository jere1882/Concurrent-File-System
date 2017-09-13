bool file_exists (workerdata * wdata,
                  char * filename) {
  
  File * file = wdata->files;
  for (; file != NULL; file = file->next)
    if (equal_strings (file->filename, filename))
      return true;
  return false; }
