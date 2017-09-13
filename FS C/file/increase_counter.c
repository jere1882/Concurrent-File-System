void increase_counter (workerdata * wdata,
                       char * filename) {
  
  File * file = file_find (wdata, filename);
  file->creation_counter++; }
