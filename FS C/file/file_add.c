void file_add (workerdata * wdata,
               File * file) {
  
  file->next   = wdata->files;
  wdata->files = file; }
