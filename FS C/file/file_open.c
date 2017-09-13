FILE * file_open (workerdata * wdata,
                  command cmd) {
  assert (file_exists (wdata, cmd.file));
  
  strcpy (auxdir, filedir);
  strcat (auxdir, cmd.file);
  FILE * f;
  switch (cmd.name) {
  case REA:
  if ((f = fopen (auxdir, "r")) == NULL)
    errno_abort ("Error opening file!\n");
  break;
  case WRT:
  if ((f = fopen (auxdir, "a")) == NULL)
    errno_abort ("Error opening file!\n");
  break;
  default: assert (false); break; }

  return f; }
