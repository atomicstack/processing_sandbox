// "corners" by dave

int[][] result;
float t, c;

float ease(float p) {
  return 3*p*p - 2*p*p*p;
}

float ease(float p, float g) {
  if (p < 0.5) 
    return 0.5 * pow(2*p, g);
  else
    return 1 - 0.5 * pow(2*(1 - p), g);
}

float mn = .5*sqrt(3), ia = atan(sqrt(.5));

void push() {
  pushMatrix();
  pushStyle();
}

void pop() {
  popStyle();
  popMatrix();
}

float c01(float g) {
  return constrain(g, 0, 1);
}

void draw() {

  if (!recording) {
    t = mouseX*1.0/width;
    c = mouseY*1.0/height;
    if (mousePressed)
      println(c);
    draw_();
  } else {
    for (int i=0; i<width*height; i++)
      for (int a=0; a<3; a++)
        result[i][a] = 0;

    c = 0;
    for (int sa=0; sa<samplesPerFrame; sa++) {
      t = map(frameCount-1 + sa*shutterAngle/samplesPerFrame, 0, numFrames, 0, 1);
      draw_();
      loadPixels();
      for (int i=0; i<pixels.length; i++) {
        result[i][0] += pixels[i] >> 16 & 0xff;
        result[i][1] += pixels[i] >> 8 & 0xff;
        result[i][2] += pixels[i] & 0xff;
      }
    }

    loadPixels();
    for (int i=0; i<pixels.length; i++)
      pixels[i] = 0xff << 24 | 
        int(result[i][0]*1.0/samplesPerFrame) << 16 | 
        int(result[i][1]*1.0/samplesPerFrame) << 8 | 
        int(result[i][2]*1.0/samplesPerFrame);
    updatePixels();

    saveFrame("f###.gif");
    if (frameCount==numFrames)
      exit();
  }
}

//////////////////////////////////////////////////////////////////////////////

int samplesPerFrame = 4;
int numFrames = 480;        
float shutterAngle = .6;

boolean recording = false;

void setup() {
  size(720, 720, P3D);
  pixelDensity(recording ? 1 : 2);
  smooth(8);
  result = new int[width*height][3];
  rectMode(CENTER);
  fill(32);
  noStroke();
}

float x, y, z, tt;
int N = 12;
float l = 50;
float dist = 10*l, rotation = 3*PI;
color BLACK = #201e1a, RED = #c82c09, BLUE = #0069bd, YELLOW = #f1bb00, BG = #eae3d6;
color c1 = RED, c2 = BLACK, c3 = BLUE;

void boxx() {
  for (int i=0; i<4; i++) {
    push();
    rotateY(HALF_PI*i);
    fill(c1);
    if (i%2 == 0)
      fill(c2);
    translate(0, 0, l/2);
    rect(0, 0, l, l);
    pop();
  }
  for (int i=0; i<4; i++) {
    push();
    rotateX(HALF_PI+PI*i);
    fill(c3);
    translate(0, 0, l/2);
    rect(0, 0, l, l);
    pop();
  }
}

void cornerPiece() {
  boxx();

  push();
  translate(-l, 0, 0);
  boxx();
  pop();

  push();
  translate(-2*l, 0, 0);
  boxx();
  pop();

  push();
  translate(0, l, 0);
  boxx();
  pop();

  push();
  translate(0, 2*l, 0);
  boxx();
  pop();
}

void draw_() {
  background(BG); 
  tt = 1-sq(1-t);

  push();
  translate(width/2, height/2);
  rotate(HALF_PI*t);
  scale(pow(2/3.0, t), pow(2/3.0, t), 1);
  for (int i=0; i<4; i++) {
    for (int j=0; j<4; j++) {
      push();
      translate(-l*1.5+l*i, -l*1.5+l*j, 0);
      boxx();
      pop();
    }
  }

  for (int i=0; i<4; i++) {
    c1 = RED;  
    c3 = BLUE;
    if (i%2 == 0) {
      c1 = YELLOW; 
      c3 = RED;
    }
    push();
    rotate(HALF_PI*i);
    translate(l*2.5 + lerp(dist, 0, tt), -l*2.5);
    translate(0, l);
    rotateY(lerp(rotation, 0, tt));
    translate(0, -l);
    cornerPiece();
    pop();
  }

  pop();
}
