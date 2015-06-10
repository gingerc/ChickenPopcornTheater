class Player {
  Body body;
  float w = 50;
  float h = 50;
  PImage chicken1;
  PImage superChicken;

  Boolean superState = false;

  Player(float x, float y) {
    // Add the player to the box2d world
    makeBody(new Vec2(x, y), w, h);
    chicken1=loadImage("chicken111.png");
    superChicken = loadImage("chickens-01.png");
  }

  void display() {
    // We look at each body and get its screen position
    Vec2 pos = box2d.getBodyPixelCoord(body);
    // Get its angle of rotation
    float a = body.getAngle();
    constrain(a, -30, 60);
    if (superState == false) {
      pushStyle();
      imageMode(CENTER);
      pushMatrix();
      translate(pos.x, pos.y);
      rotate(-a);
      image(chicken1, 0, 0);
      popMatrix();
      popStyle();
    } else if (superState == true) {
      pushStyle();
      imageMode(CENTER);
      pushMatrix();
      translate(pos.x, pos.y);
      image(superChicken, 0, 0,200,206);
      popMatrix();
      popStyle();
    }
  }

  void jump() {
    Vec2 currentVelocity = body.getLinearVelocity();
    body.setLinearVelocity(new Vec2(currentVelocity.x, gravity/3*2));
    
    superState = rms.analyze()>0.1;
  }

  void transform() {
    
  }



  // adds the chicken to the box2d world
  void makeBody(Vec2 center, float w_, float h_) {

    CircleShape shape = new CircleShape();
    shape.m_p.set(box2d.scalarPixelsToWorld(10), 0);
    shape.m_radius = box2d.scalarPixelsToWorld(50);

    // Define a fixture
    FixtureDef fd = new FixtureDef();
    fd.shape = shape;
    // Parameters that affect physics
    fd.density = 100;
    fd.friction = 0.3;
    fd.restitution = 0.5;

    // Define the body and make it from the shape
    BodyDef bd = new BodyDef();
    bd.type = BodyType.DYNAMIC;
    bd.position.set(box2d.coordPixelsToWorld(center));

    body = box2d.createBody(bd);
    body.createFixture(fd);
  }

  void applyForce(Vec2 force) {
    Vec2 pos = body.getWorldCenter();
    body.applyForce(force, pos);
  }
}