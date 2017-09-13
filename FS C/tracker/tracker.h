typedef struct _Tracker {
  char filename[FILENAME_SIZE];
  
  // Used by LSD.
  uint user_id;
  char list[BUFF_SIZE];
  
  int            counter; /* 0 ~ 4 */
  struct _Tracker * next;
} Tracker;
