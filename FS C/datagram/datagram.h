typedef struct _datagram {
  entity  from;
  uint    from_id;
  queue * respond_to;
  command cmd;
  void *  message;
} datagram;
