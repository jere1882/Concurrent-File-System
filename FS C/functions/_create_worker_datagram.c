// Worker request datagram.
datagram * _worker_datagram
    (datagram * d, workerdata * wdata) {

  datagram * ds[WORKERS-1];
  int i = 0;
  for (i = 0; i < WORKERS-1; i++) {
    ds[i] = malloc(sizeof(datagram));
    ds[i].from = WORKER;
    ds[i].from_id = wdata->id;
    ds[i].respond_to = queues[wdata->id];
    ds[i].cmd = d->cmd;
  }
  return ds; }
