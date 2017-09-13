File * file_init () {
  File * f     = malloc (sizeof (File));
  f->fid       = 0;
  int i; for (i = 0; i < FILENAME_SIZE; ++i)
    f->filename[i] = 0;
  f->opened_by        = 0;
  f->creation_counter = -1;
  f->open_counter     = -1;
  f->next             = NULL;
  return f; }
