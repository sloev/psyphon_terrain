import shapes3d.utils.*;
import shapes3d.animation.*;
import shapes3d.*;
import codeanticode.syphon.*;

SyphonServer server;

Terrain terrain;
float oldy=0;

int mode=1;
int mode2=1;

TerrainCam cam;
int camHoversAt = 80;

float terrainSize = 1000;
float horizon = 500;

long time;
float camSpeed=200;
int count;

float rots=0;
float rots2=0;

float nearDist = 450;
float farDist = 500; 
color fogColor = color(0, 0, 0);

PGraphics canvas;

float backgroundColor=0;

void setup() {
  size(160, 130, OPENGL);
  canvas = createGraphics(640, 480, OPENGL);
  //background(0);
  server = new SyphonServer(this, "Processing Syphon");

  terrain = new Terrain(this, 90, terrainSize, horizon);
  terrain.usePerlinNoiseMap(-60, 60, 0.15f, 0.15f);
  terrain.setTexture("terrain.jpg", 4);
  terrain.drawMode(Shape3D.TEXTURE);


  cam = new TerrainCam(this);
  cam.adjustToTerrain(terrain, Terrain.WRAP, camHoversAt);
  PVector bla=cam.eye();
  oldy=-bla.z;
  cam.camera();
  cam.speed(camSpeed);
  cam.forward.set(cam.lookDir());

  // Tell the terrain what camera to use
  terrain.cam = cam;

  time = millis();
}

void draw() {
  colorMode(HSB,100);
  backgroundColor+=0.01;
background((sin(backgroundColor)*50)+50,100,100);
colorMode(RGB,255);
  canvas.beginDraw();
  mode=2;
  mode2=1;
  if (mode==1) {
    fill(0, 0, 0, 5);
    rect(0, 0, 640, 480);
    noFill();
  }
  else if (mode==2) {
    canvas.background(0);
  }
  if (mode2>1) {
          mode2++;

    if (mode2>4) {
      mode2=2;
    }
    if (mode2==2) {

      screenBlend(DIFFERENCE);
    }
     if (mode2==3) {
      screenBlend(SUBTRACT);
    }
         if (mode2==4) {
      screenBlend(ADD);
    }
  }

  // Get elapsed time
  long t = millis() - time;
  time = millis();

  rots+=0.01;
  rots2+=0.001;
  float a=sin(rots)*0.01;
  float b=(sin(rots)*0.01+cos(rots2)*0.01-sin(rots2/3+rots/3)*0.01)/3;
  cam.rotateViewBy(b);
  cam.turnBy(b);

  // Calculate amount of movement based on velocity and time
  cam.move(t/1000.0f);
  // Adjust the cameras position so we are over the terrain
  // at the given height.
  cam.adjustToTerrain(terrain, Terrain.WRAP, camHoversAt);
  PVector dis=cam.eye();
  dis.y=oldy+0.01*(dis.y-oldy);
  oldy=dis.y;
  cam.eye(dis);
  // Set the camera view before drawing
  cam.camera();
  terrain.draw();
  canvas.endDraw();

  server.sendImage(canvas);
}

public PVector getRandomPosOnTerrain(Terrain t, float tsize, float height) {
  PVector p = new PVector(random(-tsize/2.1f, tsize/2.1f), 0, random(-tsize/2.1f, tsize/2.1f));
  p.y = t.getHeight(p.x, p.z) - height;
  return p;
}

/**
 * Get random direction for seekers.
 * @param speed
 */
public PVector getRandomVelocity(float speed) {
  PVector v = new PVector(random(-10000, 10000), 0, random(-10000, 10000));
  v.normalize();
  v.mult(speed);
  return v;
}


