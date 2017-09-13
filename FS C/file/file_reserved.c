bool file_reserved (workerdata * wdata,
                    char * filename) {
  // Search for the filename.
  File * file = wdata->files;
  for (; file != NULL; file = file->next)
    if (equal_strings (file->filename,
                       filename)
        && file->creation_counter >= 0 )
      return true;
  
  return false; }
