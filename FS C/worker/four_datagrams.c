datagram * four_datagrams (workerdata * wdata, command cmd) {
  
  datagram * dgs = malloc (sizeof (datagram) * 4);
  
  int i = 0; for (; i < 4; ++i) {
    (dgs+i)->from       = WORKER;
    (dgs+i)->from_id    = wdata->id;
    (dgs+i)->respond_to = wdata->myqueue;
    (dgs+i)->cmd        = cmd;
    (dgs+i)->message    = NULL; }
  
  return dgs; }
