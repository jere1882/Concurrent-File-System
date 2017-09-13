char filedir[1024] = "storage/";
char auxdir[1024];

typedef struct _File {
  int  fid;
  char filename[FILENAME_SIZE];
  struct _File * next;
  
  int opened_by;
  int opened_in; // worker id.
  
  int creation_counter;
  int open_counter;
  int remove_counter;
} File;
