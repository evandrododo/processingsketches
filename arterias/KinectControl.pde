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

    ArrayList<Contour> contornos;
    PImage kinectDepth, videoFrame;


    public void setup(arterias parent) {
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
        image(fbo, 0, 0, 1440, 1080);

        if(debug) {
            // Desenha imagem de profundidade
            image(kinectDepth, 0, height - 480, 320, 240);
        }
    }

    void setupSensor(arterias parent) {
        kinect = new Kinect(parent);
        kinect.initDepth();
        kinect.enableMirror(true);
        kinect.initVideo();
        kinect.setTilt(anguloKinect);
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

    void movieEvent(Movie movie) {  
        movie.read();
    }
    
}
