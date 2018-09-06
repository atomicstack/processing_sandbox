// 'spirals' by dave

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
int numFrames = 300;        
float shutterAngle = .6;

boolean recording = false;

void setup() {
  size(850, 850, P3D);
  pixelDensity(recording ? 1 : 2);
  smooth(8);
  result = new int[width*height][3];
  rectMode(CENTER);
  stroke(32);
  strokeWeight(2.4);
  noFill();
}

float x, y, z, tt;
int N = 12, n = 60;
float tw, qq;
float xx, yy;
float l = 46, sp = 1.25*l;

void twistLine(float q) {
  beginShape();
  curveVertex(-l/2, -l/2);
  for (int i=0; i<n; i++) {
    qq = i/float(n-1);
    qq = ease(qq);
    x = lerp(-l/2, l/2, qq);
    y = lerp(-l/2, l/2, qq);
    tw = -q*10*ease(1-abs(2*qq-1),1.5);
    xx = x*cos(tw) + y*sin(tw);
    yy = y*cos(tw) - x*sin(tw);
    curveVertex(xx, yy);
  }
  curveVertex(l/2, l/2);
  endShape();
}

float X, Y;

void draw_() {
  background(250); 
  push();
  translate(width/2, height/2);
  for (int i=0; i<N; i++) {
    for (int j=0; j<N; j++) {
      X = (i-.5*(N-1))*sp;
      Y = (j-.5*(N-1))*sp;
      tt = map(cos(TWO_PI*t + atan2(X,Y) - dist(X,Y,0,0)*.01),1,-1,0,1);
      push();
      translate(X,Y); 
      if((i+j)%2 == 0)
        rotate(HALF_PI);
      twistLine(tt);
      pop();
    }
  }
  pop();
}