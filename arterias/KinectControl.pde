import org.openkinect.freenect.*;
import org.openkinect.processing.*;
import gab.opencv.*;

import processing.video.*;

public class KinectControl {
    final int FONTE_SENSOR = 1;
    final int FONTE_VIDEO = 2;
    Kinect kinect;
    int fonteKinect = FONTE_VIDEO;
    int anguloKinect = 0;
    Movie videodemo;
    OpenCV opencv;
    PGraphics fbo;
  
    // Depth data
    int[] depth;
    PVector centroMassa = new PVector(1,1);

    ArrayList<Contour> contornos;
    PImage kinectDepth, videoFrame;
    int tempoPresenca, tempoPresencaTemporaria, tempoInicioPresenca, tempoInicioPresencaTemporaria;


    public void setup(arterias parent) {
        tempoPresencaTemporaria = 0;
        tempoPresenca = 0;
        int kinectWidth = 640;
        int kinectHeight = 480;

        kinectDepth = createImage(kinectWidth, kinectHeight, RGB);
        
        fbo = parent.createGraphics(kinectWidth, kinectHeight, P2D);
       
        opencv = new OpenCV(parent, kinectWidth, kinectHeight);

        if( fonteKinect == FONTE_SENSOR ) {
            setupSensor(parent);
        }
        if( fonteKinect == FONTE_VIDEO ) {
            setupVideo(parent);
        }
    }

    void update() {
        if( fonteKinect == FONTE_SENSOR ) {
            updateSensor();
        }
        if( fonteKinect == FONTE_VIDEO ) {
            updateVideo();
        }

        opencv.brightness(brilhoKinect);
        opencv.contrast(contrasteKinect);
        kinectDepth = opencv.getSnapshot();

        // Desenha contornos
        updateContornos();
        blendMode(ADD);
        image(fbo, 0, 0, 1440, 1080);
        blendMode(BLEND);

        if(debug) {
            // Desenha imagem de profundidade
            image(kinectDepth, 0, height - 480, 320, 240);
            // kinect.setTilt(10);
        }
    }

    void setupSensor(arterias parent) {
        kinect = new Kinect(parent);
        kinect.initDepth();
        kinect.enableMirror(true);
        kinect.initVideo();
        kinect.setTilt(10);
    }

    void setupVideo(arterias parent) {
        videodemo = new Movie(parent, "videodemo.mp4");
        videodemo.loop();
    }

    void updateSensor() {
        kinectDepth = kinect.getDepthImage();
        opencv.loadImage(kinectDepth);

        if(debug) {
            // Desenha camera RGB original
            PImage img = kinect.getVideoImage();
            image(img, 0, height - kinect.height/2, kinect.width/2, kinect.height/2);
            
            // Desenha imagem de profundidade
            image(kinectDepth, 0, height - kinect.height, kinect.width/2, kinect.height/2);
        }
    }

    void updateVideo() {
        if (videodemo.available() == true) {
            videodemo.read();
        }
        if(videodemo.width > 0) {
            opencv.loadImage(videodemo);
        }
    }

    void updateContornos() {
        trackKinect();
        contornos = opencv.findContours();

        fbo.smooth(4);
        fbo.beginDraw();
        fbo.noStroke();
        fbo.fill(0,0,0,10);
        fbo.rect(0,0, fbo.width, fbo.height); //fade migué
        fbo.stroke(corPrimaria);
        fbo.strokeWeight(1);
        fbo.noFill();
        for (Contour contour : contornos) {
            fbo.beginShape();
            for (PVector point : contour.getPoints()) {
            fbo.vertex(point.x, point.y);
            }
            fbo.endShape();
        }

        if(debug) {
            fbo.strokeWeight(20);
            fbo.point(centroMassa.x, centroMassa.y);
        }
        fbo.endDraw();

    }

    void movieEvent(Movie movie) {  
        movie.read();
    }
    
  void trackKinect() {
    // Raw location
    PVector loc = new PVector(width/2, height/2);
    PVector centroPonderado = new PVector(width/2, height/2);

    kinectDepth.loadPixels();
    // Get the raw depth as array of integers
    depth = kinectDepth.pixels;

    // Being overly cautious here
    if (depth == null) return;

    float sumX = 0;
    float sumY = 0;
    float count = 0;

    for (int x = 0; x < kinectDepth.width; x+=5) {
      for (int y = 0; y < kinectDepth.height; y+=5) {
        
        int offset =  x + y*kinectDepth.width;
        // Grabbing the raw depth
        int rawDepth = int(brightness(depth[offset]));

        // Testing against threshold
        if (rawDepth > 0) {
          sumX += x*rawDepth;
          sumY += y*rawDepth;
          count+=rawDepth;
        }
      }
    }

    // As long as we found something
    if (count != 0) {
      loc = new PVector(sumX/count, sumY/count);
    }

    if(count < 100) {
        ausenciaTemporaria();
    }
    if(count > quantidadeMassaPresenca) {
        presencaTemporaria();
    }


    if(debug) {
        fill(0,0,0,70);
        noStroke();
        rect(width-200, 20, 190,80);
        fill(155,255,255);
        text("frameRate: "+frameRate,width-190, 40);
        text("presença temporaria:"+tempoPresencaTemporaria,width-190, 80);
    }

    // Interpolating the location, doing it arbitrarily for now
    centroMassa.x = lerp(centroMassa.x, loc.x, 0.01f);
    centroMassa.y = lerp(centroMassa.y, loc.y, 0.01f);
  }

    void ausenciaTemporaria() {
        tempoInicioPresencaTemporaria = 0;
    }

    void presencaTemporaria() {
        if(tempoInicioPresencaTemporaria == 0)
            tempoInicioPresencaTemporaria = millis();
        tempoPresencaTemporaria = millis() - tempoInicioPresencaTemporaria;
    }
}
