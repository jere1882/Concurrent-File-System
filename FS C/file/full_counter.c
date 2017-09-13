bool full_counter (workerdata * wdata,
                   char * filename) {
  
  File * file = file_find (wdata, filename);
  return file->creation_counter >= 4; }
