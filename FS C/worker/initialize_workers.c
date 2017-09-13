void initialize_workers () {
  int i, j;

  // Initialize wdata array.
  for (i = 0; i < 5; i++) {
    wsdata[i].id = i;
    wsdata[i].myqueue = queues[i];
    for (j = 0; j < 5; ++j)
      wsdata[i].queues[j] = queues[j];
    pthread_create (&wsdata[i].thread, NULL,
                    worker, &wsdata[i].id);
    wsdata[i].files        = NULL;
    wsdata[i].cre_tracker  = NULL;
    wsdata[i].opn_tracker  = NULL;
    wsdata[i].opened_files = NULL; } }
