void note (datagram * dgram, int s, char * msg) {
  Note * n = malloc (sizeof (Note));
  n->status = s;
  strcpy (n->text, msg);
  dgram->message = n; }
