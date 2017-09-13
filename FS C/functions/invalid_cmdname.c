bool invalid_cmdname (char * name) {
  return (strncmp ("BYE", name, 3) != 0) &&
         (strncmp ("CRE", name, 3) != 0) &&
         (strncmp ("RM",  name, 2) != 0) &&
         (strncmp ("OPN", name, 3) != 0) &&
         (strncmp ("REA", name, 3) != 0) &&
         (strncmp ("WRT", name, 3) != 0) &&
         (strncmp ("LSD", name, 3) != 0) &&
         (strncmp ("CLO", name, 3) != 0); }
