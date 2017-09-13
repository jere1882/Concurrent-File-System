command _parse (char * line,
                user_data * user) {
  command cmd;
  
  strcpy (cmd.linea, line);
  
  char * token = strtok(line, " ");
  
  cmd.name = to_cmd_name (token);
  cmd.user_id = user->id;
  cmd.user_queue = user->queue;
  
  // Fill file and fid.
  switch (cmd.name) {
    case RM: case CRE: case OPN:
      strcpy (cmd.file, strtok (NULL, " "));
      // cmd.file = strtok (NULL, " ");
      break;
    case WRT: case REA: case CLO:
      strtok (NULL, " "); // Drop 'FD' string.
      cmd.fid = atoi (strtok (NULL, " "));
      break;
    default: break; // Avoid warning
  } switch (cmd.name) {
    case REA:
      strtok (NULL, " "); //Drop 'SIZE' string
      cmd.size = atoi (strtok (NULL, " "));
      break;
    case WRT:
      strtok (NULL, " "); //Drop 'SIZE' string
      cmd.size = atoi (strtok (NULL, " "));
      strcpy (cmd.text, strtok (NULL, "\0"));
      break;
    default: break; // Avoid warning
  }
  
  return cmd; }
