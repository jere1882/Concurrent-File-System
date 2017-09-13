typedef struct sockaddr * sad;

typedef struct _conn {
  int           s_descriptor;
  struct sockaddr_in address;
} conn;

conn * start_conn () {
  conn * c = malloc(sizeof(conn));

  // Creating the socket
  c->s_descriptor = socket (
    /* int domain */ PF_INET,
    /* int type */ SOCK_STREAM,
    /* int protocol */ 0);
  if (c->s_descriptor < 0)
    errno_abort ("Socket Error");

  // To avoid error, address already in use.
  if (setsockopt (c->s_descriptor, SOL_SOCKET, SO_REUSEADDR, &(int){ 1 }, sizeof (int)) < 0)
    exit(0);

  // Defining the connection address
  c->address.sin_family      = AF_INET;
  c->address.sin_port        = htons(PORT);
  c->address.sin_addr.s_addr = INADDR_ANY;

  // Tell the socket which ip:port we want to listen
  if (bind (c->s_descriptor,
            (sad)&(c->address),
            sizeof c->address) < 0)
    errno_abort ("Binding error");

  // Do more stuff related to connection
  if (listen (c->s_descriptor, 100) < 0)
    errno_abort ("Listening error");

  return c;
}

void close_conn (conn * conexion) {
  close (conexion->s_descriptor);
  free  (conexion); 
}

void print_reply (int socket) {
  char buff[BUFF_SIZE];
  recvfrom (socket, buff, BUFF_SIZE, 0, NULL, NULL); // The recvfrom() and recvmsg() calls are used to receive messages from a socket, 
                                                    // and may be used to receive data on a socket whether or not it is connection-oriented. 
  printf ("%s\n", buff);
  return ; }

void communicate (int sock, char * req) {
  // Write req to server.
  int err = write (sock, req, strlen(req));
  if (err < 0) errno_abort ("Write Error");

  // Read response.
  char buff[BUFF_SIZE];
  recvfrom (sock, buff, BUFF_SIZE, 0, NULL, NULL);
  printf("%s\n", buff); }
