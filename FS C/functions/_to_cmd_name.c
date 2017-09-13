cmd_name to_cmd_name (char * name) {
  if (strncmp ("CON", name, 3) == 0)
    return CON;
  if (strncmp ("LSD", name, 3) == 0)
    return LSD;
  if (strncmp ("RM", name, 2)  == 0)
    return RM;
  if (strncmp ("CRE", name, 3) == 0)
    return CRE;
  if (strncmp ("OPN", name, 3) == 0)
    return OPN;
  if (strncmp ("WRT", name, 3) == 0)
    return WRT;
  if (strncmp ("REA", name, 3) == 0)
    return REA;
  if (strncmp ("CLO", name, 3) == 0)
    return CLO;

  return BYE;
}
