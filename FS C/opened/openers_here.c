bool openers_here (workerdata * wdata,
                   command cmd) {
  assert (cmd.name == RM);
  
  Opened_Files * of = wdata->opened_files;
  for (; of != NULL; of = of->next)
    if (equal_strings (of->filename, cmd.file))
      return of->openers_here;
  return false; }
