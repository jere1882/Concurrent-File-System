user_data * create_user () {
  user_data * user;
  void * buffer[QUEUE_SIZE];
  int id = rand() % 5;

  user = malloc (sizeof(user_data));
  user->queue = create_queue (buffer);
  user->socket_length = sizeof user->address;
  user->id            = users_ids;
  user->worker_id     = id;
  user->worker_queue  = queues[id];
  users_ids++;

  return user; }
