typedef enum _cmd_name { 
  CON,
  LSD,
  RM, /* file */
  CRE, /* file */
  OPN, /* file */
  WRT, /* FD fid SIZE size text */
  REA, /* FD fid SIZE size */
  CLO, /* FD fid */
  BYE } cmd_name;

typedef struct _command {
  uint      user_id;
  cmd_name  name;
  lilString file;
  uint      fid;
  uint      size;
  lilString text;
  queue  *  user_queue;
  // For logging propuses:
  char      linea[BUFF_SIZE];
} command;
