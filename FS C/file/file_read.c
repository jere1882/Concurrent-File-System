void file_read (workerdata * wdata,
    command cmd, char * text) {
  assert (cmd.name == REA);
  
  FILE * fp = file_open (wdata, cmd);
  fgets (text, cmd.size + 1, fp);
  fclose (fp); }
