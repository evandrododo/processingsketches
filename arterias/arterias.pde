import g4p_controls.*;
 
Controles controles;


int brilhoKinect = 0;
float contrasteKinect = 1;
int anguloTilt = 0;
int quantidadeMassaPresenca = 1500;

int distanciaMin = 15;
int distanciaMax = 20;
int quantidadeMaxNos = 22;
int anguloVariacao = 90;
float velocidadeCriacao = 3;

PGraphics particulasFrame;
  
boolean debug = false;
boolean drawParticulasEnabled = false;

color corPrimaria = color(0,255,255);

KinectControl kinectControl;
Root r;

// Eventos
int tInicioBrisa, tDuracaoBrisa;
int qtdBrisasPassadas;

int tDuracaoMaximaBrisa = 15;
int tInicioRaizes = 2;
PVector posInicioRaiz = new PVector(960, 800);

public void settings() {
  fullScreen(P3D);
  controles = new Controles();
}

public void setup() {
  tInicioBrisa = millis();
  kinectControl = new KinectControl();
  kinectControl.setup(this);
  
  r = new Root(int(posInicioRaiz.x), int(posInicioRaiz.y), 0);
}

void startRaizes() {
  r.ativaRaiz();
}

void restartBrisa() {
  tInicioBrisa = millis();
  qtdBrisasPassadas++;
  println("Restart pela "+qtdBrisasPassadas+"ª vez");

  particulasFrame = createGraphics(width, height, P3D);
  r.restart(int(posInicioRaiz.x), int(posInicioRaiz.y));
}

public void update() {
  tDuracaoBrisa = millis() - tInicioBrisa;
  if (tDuracaoBrisa > tDuracaoMaximaBrisa*1000) {
    restartBrisa();
  }
  if( tDuracaoBrisa > tInicioRaizes*1000) {
    startRaizes();
  }
}

public void draw() {
  this.update();
  background(0);
  noStroke();
  // noLights();
  // popMatrix();
  // pointLight(255, 102, 0, 960, 800, 300);
  // translate(960, 800, 0);
  // sphere(200);  
  // pushMatrix();

  r.drawRaiz();
  if(drawParticulasEnabled) {
    particulasFrame.beginDraw();
    particulasFrame.fill(0, 0, 0, 10);
    particulasFrame.noStroke();
    particulasFrame.rect(0,0, width, height);
    particulasFrame.endDraw();
  }
  kinectControl.update();
}
