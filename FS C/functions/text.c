char * text (const char * t) {
  char * r = malloc (sizeof t);
  if (r == NULL) err_abort (3, "malloc");
  strcpy (r, t);
  return r; }
