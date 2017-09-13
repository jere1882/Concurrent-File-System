bool is_opened (workerdata * wdata, command cmd) {
  
  Opened_Files * op = wdata->opened_files;
  for (; op != NULL; op = op->next) {
    switch (cmd.name) {
    case OPN: case RM:
    if (equal_strings (op->filename, cmd.file))
      return true;
    break;
    case REA: case WRT: case CLO:
    if (op->fid == cmd.fid)
      return true;
    break;
    default: assert (false); break; }
  }
  return false; }
