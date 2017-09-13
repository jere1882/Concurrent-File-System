// Change the message from a given datagram
void add_text (datagram * d, char * str) {
  d->message = (void *) text (str);
  return ; }
