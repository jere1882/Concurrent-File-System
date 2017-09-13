// le envia a todos los workers el datagram
void broadcast (workerdata * wdata,  datagram * datagrams) {
  int i  = 0;
  int id = 0;
  for (i = 0; i < 4; i++, id++) { //porque no WORKERS
    if (wdata->id == id) id++;
    
    enqueue (wsdata[id].myqueue,
             datagrams + i);
  }
}
