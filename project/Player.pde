class Player {
  Body body;
  float w = 50;
  float h = 50;
  PImage chicken1;

  Player(float x, float y) {
    // Add the box to the box2d world
    makeBody(new Vec2(x, y), w, h);
    chicken1=loadImage("chicken111.png");
  }

  void display() {
    // We look at each body and get its screen position
    Vec2 pos = box2d.getBodyPixelCoord(body);
    // Get its angle of rotation
    float a = body.getAngle();

    pushStyle();
    imageMode(CENTER);
    pushMatrix();
    translate(pos.x, pos.y);
    rotate(-a);
    image(chicken1, 0, 0);
    popMatrix();
    popStyle();
  }

  void jump() {
    Vec2 currentVelocity = body.getLinearVelocity();
    body.setLinearVelocity(new Vec2(currentVelocity.x, gravity/3*2));
    //body.setAngularVelocity(0);
  }

  // This function adds the rectangle to the box2d world
  void makeBody(Vec2 center, float w_, float h_) {

    CircleShape shape = new CircleShape();
    shape.m_p.set(box2d.scalarPixelsToWorld(10), 0);
    shape.m_radius = box2d.scalarPixelsToWorld(50);

    // Define a fixture
    FixtureDef fd = new FixtureDef();
    fd.shape = shape;
    // Parameters that affect physics
    fd.density = 1000;
    //fd.friction = 0.3;
    //fd.restitution = 0.5;

    // Define the body and make it from the shape
    BodyDef bd = new BodyDef();
    bd.type = BodyType.DYNAMIC;
    bd.position.set(box2d.coordPixelsToWorld(center));

    body = box2d.createBody(bd);
    body.createFixture(fd);
  }
}