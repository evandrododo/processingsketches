import g4p_controls.*;
 
Controles controles;


int brilhoKinect = 0;
float contrasteKinect = 1;

int distanciaMin = 40;
int distanciaMax = 50;
int quantidadeMaxNos = 22;
int anguloVariacao = 90;
float velocidadeCriacao = 3;

PGraphics particulasFrame;
  
boolean debug = false;

KinectControl kinectControl;
Root r;

public void settings() {
  fullScreen(P3D);
  controles = new Controles();
}

public void setup() {
  kinectControl = new KinectControl();
  kinectControl.setup(this);
  
  r = new Root(00, 100, 0);
  particulasFrame = createGraphics(width, height, P3D);
}

public void draw() {
  background(0);
  noStroke();
  
  r.drawRaiz();
  blendMode(ADD);
  kinectControl.update();
}
