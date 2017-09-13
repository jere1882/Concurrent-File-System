// Creates a datagram given a worker & cmd.
datagram * datagram_template(workerdata * wdata, command cmd, entity from) {
  datagram * d  = malloc (sizeof(datagram));
  d->from       = from;
  d->from_id    = wdata->id;
  d->respond_to = wdata->myqueue;
  d->cmd        = cmd;
  return d; }
