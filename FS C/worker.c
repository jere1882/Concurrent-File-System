#include "worker/from_handler.c"
#include "worker/from_worker.c"
#include "worker/from_rworker.c"

void * worker (void * id) {
  int wid          = *(int *)id;
  workerdata wdata = wsdata[wid];

  printf ("[worker %d] Initialized.\n", wid);
  
  // Wait for a datagram.
  while (1) {
    datagram * d = (datagram *)
      dequeue (wdata.myqueue);
    
    if (d->from == HANDLER)
      from_handler (&wdata, d);
    else if (d->from == WORKER)
      from_worker  (&wdata, d);
    else //d->from == RWORKER
      from_rworker (&wdata, d);
  }
  
  return NULL; }
