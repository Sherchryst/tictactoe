enum Mark {
  x,
  o;

  Mark get opponent {
    return switch (this) {
      Mark.x => Mark.o,
      Mark.o => Mark.x,
    };
  }
}
