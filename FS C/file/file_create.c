void file_create (workerdata * wdata,
                  char * filename) {
  
  File * file = file_init ();
  strcpy (file->filename, filename);
  
  pthread_mutex_lock (&files_ids_mutex);
    file->fid = files_ids;
    files_ids++;
  pthread_mutex_unlock (&files_ids_mutex);
  
  file->next = wdata->files;
  wdata->files = file;
  strcpy (auxdir, filedir);
  strcat (auxdir, filename);
  FILE * f;
  if ((f = fopen (auxdir, "w+")) == NULL)
    errno_abort ("Error opening file!\n");
  fclose (f); }
