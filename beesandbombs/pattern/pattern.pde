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
int numFrames = 240;        
float shutterAngle = .6;

boolean recording = false;

void setup() {
  size(800, 600, P3D);
  pixelDensity(recording ? 1 : 2);
  smooth(8);
  result = new int[width*height][3];
  rectMode(CENTER);
  stroke(255);
  noFill();
  blendMode(EXCLUSION);
  strokeWeight(7.5);
}

float x, y, z, tt;
int N = 12;
float sp = 60, r;
float dd, am;

void vert(float x_, float y_) {
  dd = dist(x_, y_, 0, 0);
  am = map(dd, 0, 500, -6, 6);
  vertex(x_ + am*cos(2*TWO_PI*t), y_ + am*sin(2*TWO_PI*t));
}

int n = 60;

void draw_() {
  background(0); 
  push();
  translate(width/2, height/2);
  for (int i=-N; i<N; i++) {
    for (int j=-N; j<N; j++) {
      x = i*sp;
      y = j*mn*sp;
      if (j%2 != 0)
        x += .5*sp;
      r = map(sin(TWO_PI*t - 0.005*dist(x,y,0,0)), -1, 1, 0, 1);
      r = lerp(sp*0.65, sp*0.75, ease(r));
      beginShape();
      for (int a=0; a<n; a++)
        vert(x + r*cos(TWO_PI*a/n), y + r*sin(TWO_PI*a/n));
      endShape(CLOSE);
    }
  }
  pop();
}
