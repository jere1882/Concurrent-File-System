#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <unistd.h>
#include <string.h>
#include <assert.h>

typedef char * string;

pthread_mutex_t files_ids_mutex;
int files_ids = 1;

/* TCP/IP related headers: */
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>

#include "headers/constants.h"
#include "headers/errors.h"
#include "file/file.h"
#include "headers/connections.h"
#include "headers/queue.h"
#include "headers/command.h"
#include "headers/user_data.h"
#include "tracker/tracker.h"
#include "opened/opened_files.h"
#include "worker/workerdata.h"
workerdata wsdata[5];
#include "headers/entity.h"
#include "datagram/datagram.h"
#include "headers/hash_table.h"
#include "note/note.h"

#include "functions/equal.c"
#include "functions/equal_strings.c"
#include "functions/_write.c"
#include "functions/_read.c"
#include "functions/text.c"
#include "functions/_empty_datagram.c"
#include "functions/_to_cmd_name.c"
  #include "functions/_parse.c"
#include "datagram/handlers_datagram.c"
#include "file/file_add.c"
#include "file/file_list.c"
#include "file/file_exists.c"
#include "file/file_init.c"
#include "file/filename_used.c"
#include "file/file_find.c"
#include "file/file_reserve.c"
#include "file/file_reserved.c"
#include "file/file_remove.c"
#include "file/file_create.c"
#include "file/increase_counter.c"
#include "file/full_counter.c"
#include "file/file_fid.c"
#include "file/file_open.c"
#include "file/file_write.c"
#include "file/file_read.c"

#include "tracker/compare_tracker.c"
#include "tracker/tracked.c"
#include "tracker/track_enlist.c"
#include "tracker/track_getlist.c"
#include "tracker/fully_tracked.c"
#include "tracker/increase_tracking.c"
#include "tracker/track.c"
// unpark uses parked
#include "tracker/untrack.c"

#include "opened/opened_open.c"
#include "opened/is_opened.c"
#include "opened/openers_here.c"
#include "opened/opened_close.c"
#include "opened/opened_close_by_fid.c"
#include "opened/opened_by_user.c"
#include "opened/opened_get_worker.c"
#include "opened/opened_get_worker_by_fid.c"
#include "opened/opened_mark_rm.c"

#include "client_handler.c"
#include "functions/dispatch.c"
#include "functions/initialize_queues.c"

#include "note/note.c"

#include "datagram/datagram_template.c"
#include "worker/broadcast.c"
#include "worker/four_datagrams.c"
#include "worker.c"
#include "worker/initialize_workers.c"
#include "functions/create_user.c"

int main (int argc, char *argv[]) {
  conn * c = start_conn ();
  
  srand (time (NULL)); // To get real random.
  initialize_queues ();
  
  initialize_workers ();
  printf ("[main] Server started.\n");
  
  while (1) { // Solo se cierra cuando user->socket < 0
    user_data * user = create_user ();
    
    printf ("[main] Waiting for a client.\n");
    user->socket = accept (c->s_descriptor, (sad)&(user->address), &user->socket_length);
    if (user->socket < 0)
      errno_abort ("Accept error");
    
    // Say 'OK ID x' to user and dispatch him.
    lilString line;
    sprintf (line, "OK ID %d", user->id);
    _write (user->socket, line);
    dispatch (user);
    
    printf ("[main] New guy from %s:%d, "
            "assigned ID %d and worker %d\n",
      inet_ntoa(user->address.sin_addr),
      ntohs(user->address.sin_port),
      user->id, 
      user->worker_id);
  }
  
  close_conn (c);
  
  return 0;
}
