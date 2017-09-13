typedef struct _workerdata {
  int id;
  queue * myqueue;
  queue * queues[5];
  pthread_t thread;
  File * files;
  Tracker * cre_tracker;
  Tracker * opn_tracker;
  Tracker * lsd_tracker;
  Tracker * rm_tracker;
  Opened_Files * opened_files;
} workerdata;
