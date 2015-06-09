class Building {
  PVector location;
  float speed = 2;
  float speedC = 1;
  PImage p;
  float buildingWidth = 102;

  Building(PVector loc, PImage bp) {
    location = loc;
    p = bp;
  }

  void display() {
    image(p, location.x, location.y, buildingWidth, 542);
  }

  void update() {
    location.x -=speed;
  }

}