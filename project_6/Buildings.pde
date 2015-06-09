class Buildings {
  PVector location;
  float speed = 2;
  float speedC = 1;
  PImage p;


  Buildings(PVector loc, PImage bp) {
    location = loc;
    p = bp;
  }


  void display() {

    image(p, location.x, location.y, 102, 542);
  }

  void update() {
    location.x -=speed;
  }

}