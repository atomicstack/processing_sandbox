// skeleton lifted from "corners"
// https://gist.github.com/beesandbombs/8fe3fb78be30e6d4c363a6361fcdd280
// https://necessarydisorder.wordpress.com/2018/07/02/getting-started-with-making-processing-gifs-and-using-the-beesandbombs-template/

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

float x, y, z, tt;
float l = 75;
float dist = 10*l, rotation = 3*PI;
color BLACK = #201e1a, RED = #c82c09, BLUE = #0069bd, YELLOW = #f1bb00, BG = #eae3d6;
color c1 = RED, c2 = BLACK, c3 = BLUE;

int subdivisions = 10;
int color_matrix_size = subdivisions * subdivisions;
int border_width = 2;
int display_width = 720;
int display_height = 720;
// int N = subdivisions;

void setup() {
  size(720, 720, P3D);
  pixelDensity(recording ? 1 : 2);
  smooth(8);
  result = new int[width*height][3];
  rectMode(CORNER);
  fill(32);
  noStroke();
  int[] color_matrix = new int[color_matrix_size];
  for (int i=0; i < matrix_size; i++) {
    color_matrix[i] = random(255);
  }
}



void draw_() {
  background(BG); 
  tt = 1-sq(1-t);

  //fill(127);
  //rect(10, 10, 20, 20);

  //push();
  for(int i=0; i < subdivisions; i++){
    println("i == " + i);
    // easing = lerp(12,2,sqrt(i/float(N)));
    // l = map(i,0,N,maxL,0);
    fill(i%2 == 0 ? 32 : 250);
    //push();
    rect(c,c,l * t,l * t);
    translate(40, 40);
    //pop();
  }
  //pop();
}