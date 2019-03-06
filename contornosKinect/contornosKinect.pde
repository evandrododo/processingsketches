import org.openkinect.freenect.*;
import org.openkinect.processing.*;
import gab.opencv.*;
import g4p_controls.*;

Controles controles;
Kinect kinect;
OpenCV opencv;

PGraphics fbo;

ArrayList<Contour> contornos;
PImage kinectDepth;

int brilhoKinect = 0;
float contrasteKinect = 1;

public void settings() {
  fullScreen(P3D);
  controles = new Controles();
  
}

public void setup() {
  kinect = new Kinect(this);
  kinect.initDepth();
  kinect.enableMirror(true);
  kinect.initVideo();
  kinect.setTilt(0);
  kinectDepth = createImage(kinect.width, kinect.height, RGB);
  
  opencv = new OpenCV(this, kinectDepth);
  fbo = createGraphics(kinect.width, kinect.height, P2D);
}

public void draw() {
  background(0);
  noStroke();
  // Kinect
  kinectDepth = kinect.getDepthImage();
  
  // Aplica efeitos dos controles
  opencv.loadImage(kinectDepth);
  opencv.brightness(brilhoKinect);
  opencv.contrast(contrasteKinect);
  kinectDepth = opencv.getSnapshot();
  

  // Desenha contornos do kinect
  updateContornos();
  image(fbo, 356, 0, 1440, 1080);

  // Desenha camera RGB original
  PImage img = kinect.getVideoImage();
  image(img, 0, height - kinect.height/2, kinect.width/2, kinect.height/2);
  
  // Desenha imagem de profundidade
  image(kinectDepth, 0, height - kinect.height, kinect.width/2, kinect.height/2);
}

void updateContornos() {
  contornos = opencv.findContours();

  fbo.smooth(4);
  fbo.beginDraw();
  fbo.noStroke();
  fbo.fill(0,0,0,10);
  fbo.rect(0,0, fbo.width, fbo.height); //fade migué
  fbo.stroke(0, 255, 255, 100);
  fbo.noFill();
  for (Contour contour : contornos) {
    fbo.beginShape();
    for (PVector point : contour.getPoints()) {
      fbo.vertex(point.x, point.y);
    }
    fbo.endShape();
  }
  fbo.endDraw();

}