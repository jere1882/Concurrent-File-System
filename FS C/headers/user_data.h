static int users_ids = 1;

typedef struct _user_data {
  // User handler stuff:
  pthread_t thread;
  queue  *  queue;

  // Assigned at initialization:
  socklen_t socket_length;
  uint      id;
  uint      worker_id;
  queue  *  worker_queue;

  // Dynamically assigned:
  int       socket;
  struct sockaddr_in address;
  char      linea[BUFF_SIZE];
} user_data;
