void _write (int socket, char * line) {
  if (write (socket, line, BUFF_SIZE) < 0)
    errno_abort ("Write Error");
  return ; }
