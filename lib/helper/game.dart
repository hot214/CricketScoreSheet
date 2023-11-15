String overString(int over) {
  int aOver = (over / 6.0).floor();
  int bOver = over % 6;

  return '$aOver.$bOver';
}
