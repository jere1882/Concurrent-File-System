// Creates a datagram given an user 
datagram * handlers_datagram (user_data * user) {
  datagram * d  = malloc (sizeof(datagram));
  d->from       = HANDLER;
  d->from_id    = user->id;
  d->respond_to = user->queue;
  d->cmd        = _parse (user->linea, user);
  return d; }
