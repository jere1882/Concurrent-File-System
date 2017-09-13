#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <unistd.h>
#include <string.h>

/* TCP/IP related headers: */
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>

#include "headers/constants.h"
#include "headers/errors.h"
#include "headers/connections.h"
#include "functions/equal_strings.c"

typedef char lilString[BUFF_SIZE];
typedef char string[BUFF_SIZE];

void get_line (char * line) {
  if (fgets (line, BUFF_SIZE, stdin) == NULL)
    err_abort(1, "Error reading line");
  // Remove \n char at the end.
  line[strlen(line)-1] = '\0'; }

int client_connect (lilString ip) {
  static bool client_connected = false;
  static int  conn;

  if (client_connected) return conn;

  struct sockaddr_in servaddr;

  conn = socket (AF_INET, SOCK_STREAM, 0);
  if (conn < 0) errno_abort ("Socket Error");
  memset (&servaddr, 0, sizeof(servaddr));
  servaddr.sin_family      = AF_INET;
  inet_aton (ip, &servaddr.sin_addr);
  servaddr.sin_port        = htons(PORT);
  if (connect (conn, (sad)&servaddr,
               sizeof(servaddr)) < 0)
    errno_abort ("Socket Error");
  client_connected = true;

  return conn; }

int main (int argc, char *argv[]) {
  lilString line;
  int socket = -1;

  while (1) {
    printf ("> ");
    get_line (line);
    
    if (equal_strings (line, "CON") &&
        socket < 0) {
      socket = client_connect ("127.0.0.1");
      print_reply (socket); }
    else if (equal_strings (line, "BYE")) {
      communicate (socket, line);
      exit(0);
    } else 
      communicate (socket, line);
  }
  
  return 0;
}
