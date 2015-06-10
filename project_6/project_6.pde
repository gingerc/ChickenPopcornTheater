import processing.sound.*; //<>// //<>//
AudioIn in;
Amplitude rms;

import shiffman.box2d.*;
import org.jbox2d.collision.shapes.*;
import org.jbox2d.common.*;
import org.jbox2d.dynamics.*;
import org.jbox2d.dynamics.contacts.*;

// A reference to our box2d world
Box2DProcessing box2d;

PFont A;
PImage start;
PImage howtoplay;
PImage end;
PImage theaterImage;
float scroll = 0;
int scene =0;
float lastStarted = 0;

float gravity = 80;

// A list we'll use to track fixed objects
ArrayList<Boundary> boundaries;
// A list for all of our popcorns
ArrayList<Popcorn> popcorns;
// for buildings and clouds
ArrayList<Building> buildings = new ArrayList<Building>();
// Assets
PImage[] buildingImages =new PImage[11];
PImage[] cloudImages= new PImage[2];
PImage[] wings=new PImage[18];
int frames;

Player player;
Vec2 startPosition =new Vec2(400, 300);

void setup() {
  size(1024, 748);

  A = createFont("HITCHCOCK.bmap", 60);
  textFont(A);

  //Audio Input
  in=new AudioIn(this, 0);
  in.start();
  rms=new Amplitude(this);
  rms.input(in);

  //load assets
  start=loadImage("screens-06.png");
  howtoplay=loadImage("screens-08.png");
  end=loadImage("screens-07.png");
  theaterImage = loadImage("Game-Theater-01.png");
  for (int i=0; i<11; i++) {
    String name="buildings-"+nf(i+1, 2)+".png";
    buildingImages[i]=loadImage(name);
  }
  cloudImages[0]=loadImage("clouds-12.png");
  cloudImages[1]=loadImage("clouds-13.png");
  for (int i=0; i<18; i++) {
    String name="wing-"+nf(i+1, 2)+".png";
    wings[i]=loadImage(name);
  }


  // Initialize box2d physics and create the world
  box2d = new Box2DProcessing(this);
  box2d.createWorld();
  // We are setting a custom gravity
  box2d.setGravity(0, -gravity);
  box2d.listenForCollisions();

  player = new Player(400, 200);

  // Create ArrayLists  
  popcorns = new ArrayList<Popcorn>();
  boundaries = new ArrayList<Boundary>();

  // Add a bunch of fixed boundaries
  boundaries.add(new Boundary(width/2, 5, width, 10));
  boundaries.add(new Boundary(width/2, height-5, width, 10));
}

void draw() {
  background(#7FC895);

  // We must always step through time!
  box2d.step();

  if (scene == 0) {
    image(start, 0, 0, 1024, 748);
    frames++;
    if (frames==18) {
      frames=0;
    }
    image(wings[frames], 30, 300, 220, 200);
  } else if (scene == 1) {
    image(howtoplay, 0, 0, 1024, 748);
  } else if (scene ==2) {
    noCursor();
    drawBuilding();
    drawClouds();
    image(theaterImage, 0, 0, 1024, 748);

    player.superState = rms.analyze()>0.01;
    if (player.superState) {
      for (Popcorn p : popcorns) {
        Vec2 wind = new Vec2(50000, 0);
        p.applyForce(wind);
      }
    }

    if (random(1) < 0.05) {
      Vec2 position = new Vec2(width/3*2, height/2);  //where popcorns come from
      Vec2 playerPosition = box2d.getBodyPixelCoord(player.body);
      Vec2 dis = playerPosition.sub(position);
      dis = new Vec2(dis.x, -dis.y);
      // corrected
      float vx = -75;
      float wvx = box2d.scalarWorldToPixels(vx);
      float wg = box2d.scalarWorldToPixels(gravity);
      float t = abs((dis.x)/wvx);
      float vy = (dis.y-0.5*(-wg)*t*t)/t;

      dis.normalize();
      createPopcorn(position.sub(new Vec2(0, 0)), new Vec2(vx, box2d.scalarPixelsToWorld(vy)));
    }

    Vec2 playerPosition = box2d.getBodyPixelCoord(player.body);
    if (playerPosition.x <-100 || playerPosition.y > 650) {
      scene = 3;
    }

    player.display();

    // Display all the boundaries
    for (Boundary wall : boundaries) {
      wall.display();
    }

    // Display all the popcorns
    for (Popcorn b : popcorns) {
      b.display();
    }

    // Delete off screen popcorns
    for (int i = popcorns.size()-1; i >= 0; i--) {
      Popcorn b = popcorns.get(i);
      if (b.done()) {
        popcorns.remove(i);
      }
    }
  } else if (scene == 3 ) {
    endScreen();
    frames++;
    if (frames==18) {
      frames=0;
    }
    image(wings[frames], 10, 300, 270, 230);
  }
}

void keyPressed() {
  if (key == ' ') {
    player.jump();
  }
}

void mouseClicked() {
  Boolean next = false;
  int lastScene = scene;
  if (scene == 0) {
    if (mouseX> 465 && mouseX <677 && mouseY >398 && mouseY < 501) {
      scene = 2;
      lastStarted = millis();
    }
    if (mouseX> 722 && mouseX <925 && mouseY >398 && mouseY < 501) {
      scene=1;
    }
  } else if (scene == 1) {
    if (mouseX> 856 && mouseX <996 && mouseY >29 && mouseY < 163) {
      scene = 2;
      lastStarted = millis();
    }
  } else if (scene == 2) {
  } else if (scene == 3) {
    next = (mouseX> 388 && mouseX <685 && mouseY >417 && mouseY < 521);
  }

  if (next == true) {
    scene ++;
    if (scene == 4) {
      scene = 2;
      lastStarted = millis();
      popcorns.removeAll(popcorns);
      buildings.removeAll(buildings);
    }
  }

  if (lastScene != scene && scene == 2) {
    player.body.setTransform(box2d.coordPixelsToWorld(startPosition), 0);
  }
}

int lastScore = 0;
void endScreen() {
  cursor();
  image(end, 0, 0, 1024, 748);
  // String score = String.format("%.1f", lastScore);
  //  fill(0);
  //  text(score, 490, 240);
}

void drawBuilding() {
  float distance = random(0, 100);
  float lastLocationRight = 0;
  if (!buildings.isEmpty()) {
    Building lastBuilding = buildings.get(buildings.size()-1);
    lastLocationRight = lastBuilding.location.x+lastBuilding.buildingWidth;
  }
  if (lastLocationRight+distance < width) {
    PVector location = new PVector (width, 80);
    buildings.add(new Building(location, buildingImages[(int(random(0, 11)))]));
  }
  ArrayList<Building> toBeRemoved = new ArrayList<Building>();
  for (Building b : buildings) {
    b.display();
    b.update();

    if (b.location.x <-100) {
      toBeRemoved.add(b);
    }
  }
  buildings.removeAll(toBeRemoved);
}

//Create Clouds
float x = 100;
void drawClouds() {
  float v=1;
  image(cloudImages[0], x, 100, 350, 300);
  image(cloudImages[1], x+500, 100, 400, 300);
  x=x-v;

  if (x<-800) {
    x=width;
  }
}

// Collision
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

void createPopcorn(Vec2 position, Vec2 velocity) {
  Popcorn p = new Popcorn(position.x, position.y);
  popcorns.add(p);
  p.body.setLinearVelocity(velocity);
}