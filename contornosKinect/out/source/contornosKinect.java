import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import org.openkinect.freenect.*; 
import org.openkinect.processing.*; 
import gab.opencv.*; 
import g4p_controls.*; 
import g4p_controls.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class contornosKinect extends PApplet {






Controles controles;
Kinect kinect;
OpenCV opencv;

PGraphics fbo;
PGraphics fader;

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
  kinectDepth = createImage(kinect.width, kinect.height, RGB);
  
  opencv = new OpenCV(this, kinectDepth);
  fbo = createGraphics(kinect.width, kinect.height, P2D);
  fader = createGraphics(kinect.width, kinect.height, P2D);
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
  image(fbo, 356, 0, (width/16) * 12, (height/9) * 9);

  // Desenha camera RGB original
  PImage img = kinect.getVideoImage();
  image(img, 0, height - kinect.height/2, kinect.width/2, kinect.height/2);
  
  // Desenha imagem de profundidade
  image(kinectDepth, 0, height - kinect.height, kinect.width/2, kinect.height/2);
}

public void updateContornos() {
  contornos = opencv.findContours();

  fbo.beginDraw();
  fbo.smooth(4);
  fbo.noStroke();
  fbo.fill(0,0,0,10);
  fbo.rect(0,0, fbo.width, fbo.height);
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



GSlider brilho, contraste;
  
public class Controles extends PApplet {
  
  Controles() {
    super();
    PApplet.runSketch(new String[] {this.getClass().getSimpleName()}, this);
  }

  public void settings() {
    size(500, 200, P3D);
  }

  public void setup() {
    background(255);
    brilho = new GSlider(this, 55, 10, 200, 100, 15);

    brilho.setLimits(0, -255, 255);
    brilho.setShowValue(true);

    contraste = new GSlider(this, 55, 30, 200, 100, 15);
    contraste.setLimits(1, 0, 100);
    contraste.setShowValue(true);
  }

  public void draw() {
    clear();
    background(255);
  }
  
  public void handleSliderEvents(GValueControl slider, GEvent event) { 
    if (slider == brilho) {
      brilhoKinect = slider.getValueI();
    }
    if (slider == contraste) {
      contrasteKinect = contraste.getValueF();
    }
  }

  
}
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "contornosKinect" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
