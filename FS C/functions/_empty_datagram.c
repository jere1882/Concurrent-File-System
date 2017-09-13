datagram * _empty_datagram () {
  datagram * d = malloc (sizeof(datagram));
  return d; }

datagram * text_datagram (char * str) {
  datagram * d = malloc (sizeof(datagram));
  d->message   = (void *) text (str);
  return d; }
