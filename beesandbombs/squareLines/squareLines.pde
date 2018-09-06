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

int samplesPerFrame = 8;
int numFrames = 120;        
float shutterAngle = .7;

boolean recording = false;

void setup() {
  size(800, 800, P3D);
  smooth(8);
  result = new int[width*height][3];
  rectMode(CENTER);
  stroke(250);
  strokeWeight(3);
}

float x, y, z, tt;
int N = 32;
float l = 30, L = 420;
float h, H = 30, qq;

void strip(float q) {
  for (int i=0; i<N; i++) {
    qq = i/float(N-1);
    h = sin(PI*qq)*H;
    y = map(i, 0, N-1, -L/2, L/2) + h*sin(TWO_PI*q - TWO_PI*qq);
    line(-l/2, y, l/2, y);
  }
}

void squa(){
  for (int i=0; i<12; i++) {
    push();
    translate(map(i, 0, 11, -L/2 + l/2 - 1, L/2 - l/2 + 1), 0);
    strip(t - i/12.0);
    pop();
  }
}

PImage f1, f2;

void draw_() {
  background(32); 
  push();
  translate(width/2, height/2);
  scale(1.2);
  
  squa();
  f1 = get();
  
  background(32);
  push();
  scale(1.006,1.003);
  squa();
  pop();
  f2 = get();
  
  background(32);
  push();
  scale(1.012,1.006);
  squa();
  pop();
  
  pop();
  
  loadPixels();
  f1.loadPixels();
  f2.loadPixels();
  
  for(int i=0; i<pixels.length; i++)
    pixels[i] = color(red(f1.pixels[i]),green(f2.pixels[i]),blue(pixels[i]));
  updatePixels();
}