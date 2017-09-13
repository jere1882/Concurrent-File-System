bool opened_by_user (workerdata * wdata,
                     command cmd) {
  
  Opened_Files * ofs = wdata->opened_files;
  for (; ofs != NULL; ofs = ofs->next)
    if (ofs->fid == cmd.fid)
      return ofs->user_id == cmd.user_id;
  return false; }
