void file_write (workerdata * wdata,
                 command cmd) {
  assert (cmd.name == WRT);
  
  FILE * fp = file_open (wdata, cmd);
  fwrite (cmd.text, 1, cmd.size, fp);
  fclose (fp); }
