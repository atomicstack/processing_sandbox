// https://gist.github.com/beesandbombs/19aa9175a770799272d2aca1d2f3ebb5

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
int numFrames = 450;        
float shutterAngle = .6;

boolean recording = false;

void setup() {
  size(800, 800, P3D);
  smooth(8);
  result = new int[width*height][3];
  rectMode(CENTER);
  fill(32);
  noStroke();
}

float x, y, z, tt;
int N = 12;
float qq, rot;
int nx = 12;


float r, th;
void vert(float th_, float r_) {
  r = 100*pow(1.7, r_ + 3*th_/PI);
  th = th_;
  strokeWeight(0.5+.012*r);
  vertex(r*cos(th), r*sin(th));
}

void lin(float x1, float y1, float x2, float y2) {

  for (int i=0; i<N; i++) {
    qq = i/float(N-1);
    vert(lerp(x1, x2, qq), lerp(y1, y2, qq));
  }
}

void diamond(float th_, float r_) {
  beginShape();
  lin(th_, .5 + r_, th_+PI/nx, 1 + r_);
  lin(th_+PI/nx, 1 + r_, th_+TWO_PI/nx, .5 + r_);
  lin(th_+TWO_PI/nx, .5 + r_, th_+PI/nx, r_);
  lin(th_+PI/nx, r_, th_, .5+r_);
  endShape(CLOSE);
}


color blu = #0054B9;
boolean flip;

void draw_() {
  flip = t >= .5;
  t = (2*t)%1;
  background(flip?250:blu);
  fill(flip?blu:250);
  push();
  translate(width/2, height/2);
  if ( t <= .5) {
    tt = ease(2*t, 5);
    for (int a=-16; a<6; a++) {
      for (int i=0; i<nx; i++) {
        rot = TWO_PI*i/nx + PI*(a%2 == 0 ? -tt : tt)/nx;
        diamond(rot, a);
      }
    }
  } else {
    tt = ease(2*t-1, 5);
    for (int a=-16; a<6; a++) {
      for (int i=0; i<nx; i++) {
        rot = TWO_PI*(i+.5)/nx;
        diamond(rot, a + (i%2 == 0?.5*tt:-.5*tt));
      }
    }
  }
  pop();
}
