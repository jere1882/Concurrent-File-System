typedef struct _opened_files {
  uint  fid;
  char filename[FILENAME_SIZE];
  uint user_id;
  bool openers_here;
  bool rm_marked;
  queue * worker_queue;
  struct _opened_files * next;
} Opened_Files;
