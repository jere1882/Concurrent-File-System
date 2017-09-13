void file_reserve (workerdata * wdata,
                   char * filename) {
  
  File * file = file_init ();
  strcpy (file->filename, filename);
  file->creation_counter = 0;
  file_add (wdata, file); }
