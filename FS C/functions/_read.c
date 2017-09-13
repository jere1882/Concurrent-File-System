// Save in user->linea the message of the
// client.
int _read (user_data * user) {
  int i;
  for (i = 0; i < BUFF_SIZE; ++i)
    user->linea[i] = '\0';
  
  int err = read (user->socket, user->linea,
                  sizeof user->linea);
  if (err < 0 )
    errno_abort ("Read error");
  
  return err; }
