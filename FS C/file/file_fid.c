// Assumes that the file you want to find
// exists.
int file_fid (workerdata * wdata, command cmd) {
  
  assert (file_exists (wdata, cmd.file));
  
  // Search for the filename.
  File * file = wdata->files;
  for (; file != NULL; file = file->next)
    if (equal_strings (file->filename, cmd.file))
      return file->fid;
  
  assert (false);
  return 0; }
