class Popcorn {
  Body body;
  float w = 50;
  float h = 50;

  String prefix = "popcorn";
  int numOfImages = 7;

  PImage image;
  boolean changed = false;

  Popcorn(float x, float y) {
    image = loadImage(prefix+"7.png");

    makeBody(new Vec2(x, y), w, h);
  }

  void change() {
    if (!changed) {
      String imageName = prefix+int(random(1, numOfImages))+".png";
      image = loadImage(imageName);
      changed = true;
    }
  }

  // This function removes the particle from the box2d world
  void killBody() {
    box2d.destroyBody(body);
  }

  // Is the particle ready for deletion?
  boolean done() {
    // Let's find the screen position of the particle
    Vec2 pos = box2d.getBodyPixelCoord(body);
    // Is it off the bottom of the screen?
    if (pos.y > height+w*h) {
      killBody();
      return true;
    }
    return false;
  }

  // Drawing the box
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
    image(image, 0, 0);
    popMatrix();
    popStyle();
  }

  // This function adds the rectangle to the box2d world
  void makeBody(Vec2 center, float w_, float h_) {

    CircleShape shape = new CircleShape();
    shape.m_p.set(0, 0);
    shape.m_radius = box2d.scalarPixelsToWorld(20);

    // Define a fixture
    FixtureDef fd = new FixtureDef();
    fd.shape = shape;
    // Parameters that affect physics
    fd.density = 1;
    fd.friction = 0.3;
    fd.restitution = 0.5;

    // Define the body and make it from the shape
    BodyDef bd = new BodyDef();
    bd.type = BodyType.DYNAMIC;
    bd.position.set(box2d.coordPixelsToWorld(center));

    body = box2d.createBody(bd);
    body.createFixture(fd);

    // Give it some initial random velocity
    body.setLinearVelocity(new Vec2(random(-5, 5), random(2, 5)));
    body.setAngularVelocity(random(-5, 5));

    body.setUserData(this);
  }
  
  void applyForce(Vec2 force) {
    Vec2 pos = body.getWorldCenter();
    body.applyForce(force, pos);
  }
}