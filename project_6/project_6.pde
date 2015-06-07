// The Nature of Code
// Daniel Shiffman
// http://natureofcode.com

// Basic example of falling rectangles

import shiffman.box2d.*;
import org.jbox2d.collision.shapes.*;
import org.jbox2d.common.*;
import org.jbox2d.dynamics.*;
import org.jbox2d.dynamics.contacts.*;

// A reference to our box2d world
Box2DProcessing box2d;

float scroll = 0;

float gravity = 50;

// A list we'll use to track fixed objects
ArrayList<Boundary> boundaries;
// A list for all of our rectangles
ArrayList<Popcorn> boxes;

Player player;

PImage backgroundImage;

void setup() {
  size(1024, 748);
  backgroundImage = loadImage("Game-Theater.png");
  
  // Initialize box2d physics and create the world
  box2d = new Box2DProcessing(this);
  box2d.createWorld();
  // We are setting a custom gravity
  box2d.setGravity(0, -gravity);
  box2d.listenForCollisions();
  
  player = new Player(400, 100);

  // Create ArrayLists  
  boxes = new ArrayList<Popcorn>();
  boundaries = new ArrayList<Boundary>();

  // Add a bunch of fixed boundaries
  boundaries.add(new Boundary(width/2, 5, width, 10));
  boundaries.add(new Boundary(width/2, height-5, width, 10));
}

void draw() {
  background(255);

  image(backgroundImage, 0, 0);

  // We must always step through time!
  box2d.step();

  if (random(1) < 0.05) {
    Vec2 position = new Vec2(width/3*2, height/2);
    Vec2 playerPosition = box2d.getBodyPixelCoord(player.body);

    Vec2 delta = playerPosition.sub(position);
    delta = new Vec2(delta.x, -delta.y);

    // corrected
    float vx = -75;
    float wvx = box2d.scalarWorldToPixels(vx);
    float wg = box2d.scalarWorldToPixels(gravity);
    float t = abs((delta.x)/wvx);
    float vy = (delta.y-0.5*(-wg)*t*t)/t;

    delta.normalize();
    Vec2 nd = delta.mul(75);

    //createBox(position, nd);
    createBox(position.sub(new Vec2(0, 0)), new Vec2(vx, box2d.scalarPixelsToWorld(vy)));
  }

  player.display();

  // Display all the boundaries
  for (Boundary wall : boundaries) {
    wall.display();
  }

  // Display all the boxes
  for (Popcorn b : boxes) {
    b.display();
  }

  // Boxes that leave the screen, we delete them
  // (note they have to be deleted from both the box2d world and our list
  for (int i = boxes.size()-1; i >= 0; i--) {
    Popcorn b = boxes.get(i);
    if (b.done()) {
      boxes.remove(i);
    }
  }
}

void keyPressed() {
  if (key == ' ') {
    player.jump();
  }
}

void beginContact(Contact cp) {
  // Get both fixtures
  Fixture f1 = cp.getFixtureA();
  Fixture f2 = cp.getFixtureB();
  // Get both bodies
  Body b1 = f1.getBody();
  Body b2 = f2.getBody();

  // Get our objects that reference these bodies
  Object o1 = b1.getUserData();
  Object o2 = b2.getUserData();

  if (o1 == null || o2 == null) {
    return;
  }

  if (o1.getClass() == Popcorn.class && o2.getClass() == Popcorn.class) {
    Popcorn p1 = (Popcorn) o1;
    p1.change();
    Popcorn p2 = (Popcorn) o2;
    p2.change();
  }

}

// Objects stop touching each other
void endContact(Contact cp) {
}



void createBox(Vec2 position, Vec2 velocity) {
  Popcorn p = new Popcorn(position.x, position.y);
  boxes.add(p);
  p.body.setLinearVelocity(velocity);
}
//void createBox(Vec2 position, Vec2 velocity) {
//  Box p = new Box(position.x, position.y);
//  boxes.add(p);
//  p.body.setLinearVelocity(velocity);
//}