char * file_list (workerdata * wdata) {
  char * list = malloc (sizeof (char) * BUFF_SIZE);
  list[0] = '\0';
  char * space = " ";
  
  File * f = wdata->files;
  for (; f != NULL; f = f->next) {
    strcat (list, f->filename);
    strcat (list, space); }
  
  return list; }
