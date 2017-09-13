int compare_tracker (Tracker * tr,
                     command cmd) {
  switch (cmd.name) {
  case CRE: case OPN: case RM:
    return equal_strings (tr->filename, cmd.file);
  break;
  case LSD:
    return tr->user_id == cmd.user_id;
  break;
  default: assert (false); break; }
}
