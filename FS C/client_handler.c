#include "functions/invalid_cmdname.c"

void * client_handler (void * arg) {
  user_data * user = (user_data *)arg;
  
  datagram * request;
  char       response[BUFF_SIZE];
  
  printf ("[handler %d] Initialized\n",
          user->id);
  
  // Start listening for user command.
  while (1) {
    // saved in user->linea.
    if (_read (user) == 0) {
      printf ("[handler %d] User ended the"
              " connection\n", user->id);
      break; }
    
    printf ("[handler %d] User say: `%s`\n",
            user->id, user->linea);
    
    if (invalid_cmdname (user->linea)) {
      strcpy (response, "UNRECOGNIZED CMD");
    } else {
      // Ask to the worker
      request = handlers_datagram (user);
      printf ("[handler %d] Wait for an "
              "answer\n", user->id);
      enqueue (user->worker_queue, request);
      
      // Wait for an answer
      strcpy (response,
              (char *)dequeue (user->queue));
    }
    // Log & answer to client.
    printf ("[handler %d] Answer: `%s`\n",
      user->id, response);
    _write (user->socket, response);
  }
  
  return NULL; }
