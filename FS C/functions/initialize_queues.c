void  * buffer[5][QUEUE_SIZE];
queue * queues[5];

void initialize_queues () {
  int i;
  for (i = 0; i < 5; i++)
    queues[i] = create_queue (buffer[i]);
  return ; }
