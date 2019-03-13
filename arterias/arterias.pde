import g4p_controls.*;
 
Controles controles;


int brilhoKinect = -130;
float contrasteKinect = 1.5;
int anguloTilt = 0;
int quantidadeMassaPresenca = 1500;

int distanciaMin = 7;
int distanciaMax = 8;
int quantidadeMaxNos = 72;
int anguloVariacao = 80;
float velocidadeCriacao = 4;

PGraphics particulasFrame;
  
boolean debug = false;
boolean drawParticulasEnabled = true;

boolean isStandby = true;

color corPrimaria = color(0,255,255);
color corTemporaria = color(0,0,0);

KinectControl kinectControl;
Root r, r2, r3;

// Eventos
int tInicioBrisa, tDuracaoBrisa;
int tInicioStandby, tDuracaoStandby;
int qtdBrisasPassadas;

int tDuracaoMaximaBrisa = 193;
int tDuracaoMinimaStandby = 2;
int tInicioRaizes = 20;
PVector posInicioRaiz = new PVector(500, 100);

PImage luzplanta;
Movie arterias;

public void settings() {
  size(1024,768,P3D);
  controles = new Controles();
}

public void setup() {
  tInicioBrisa = millis();
  kinectControl = new KinectControl();
  kinectControl.setup(this);
  
  particulasFrame = createGraphics(width, height, P3D);
  r = new Root(int(posInicioRaiz.x), int(posInicioRaiz.y), 0, 1);
  r2 = new Root(int(posInicioRaiz.x), int(posInicioRaiz.y), 0, 2);
  r3 = new Root(int(posInicioRaiz.x), int(posInicioRaiz.y), 0, 3);

  startStandby();

  luzplanta = loadImage("luz.png");
  
  arterias = new Movie(this, "arterias.mp4");
  corTemporaria = corPrimaria;
}

void startRaizes() {
  r.ativaRaiz();
  r2.ativaRaiz();
  r3.ativaRaiz();
}

void restartBrisa() {
  arterias.stop();
  tInicioBrisa = millis();
  tDuracaoBrisa = 0;
  qtdBrisasPassadas++;
  println("Restart pela "+qtdBrisasPassadas+"ª vez");

  particulasFrame = createGraphics(width, height, P3D);
  r.restart(int(posInicioRaiz.x), int(posInicioRaiz.y));
  r2.restart(int(posInicioRaiz.x), int(posInicioRaiz.y));
  r3.restart(int(posInicioRaiz.x), int(posInicioRaiz.y));
  arterias.play();
}

public void update() {
  if (!isStandby) {
    tDuracaoBrisa = millis() - tInicioBrisa;
  }
  if (tDuracaoBrisa > tDuracaoMaximaBrisa*1000) {
    startStandby();
    //restartBrisa();
  }
  if( tDuracaoBrisa > tInicioRaizes*1000) {
    startRaizes();
  }

  if( tDuracaoBrisa > tDuracaoMaximaBrisa*1000 - 20000) {
    corTemporaria = lerpColor( corTemporaria, color(0,0,0,0), 0.01);
  }
  
}

public void draw() {
  this.update();
  background(0);
  noStroke();

  if( isStandby ) {
    tint(0,0,0,100);
  }

  kinectControl.update();

  updateStandBy();
  if( isStandby ) {
    drawStandby();
    return;
  }

  noTint();
  r.drawRaiz();
  r2.drawRaiz();
  r3.drawRaiz();

  if(drawParticulasEnabled) {
    particulasFrame.beginDraw();
    particulasFrame.fill(0, 0, 0, (sin(radians(millis()/100))+1)*10 );
    particulasFrame.noStroke();
    particulasFrame.rect(0,0, width, height);
    particulasFrame.endDraw();

    blendMode(ADD);
    image(particulasFrame, 0, 0);
    blendMode(BLEND);
  }
}

void startStandby() {
  println("Inicio standby");
  isStandby = true;
  tInicioStandby = millis();
  tDuracaoStandby = 0;
  tDuracaoBrisa = 0;
  tInicioFade = 0;
  iAlphaStandby = 100;
}

int tempoFade = 2;
int tInicioFade, iAlphaStandby;

void updateStandBy(){
  if (isStandby) {
    tDuracaoStandby = millis() - tInicioStandby;
    // pulsa
    iAlphaStandby = int((sin(radians(millis()/10))+1)*50);

    if( tDuracaoStandby > tDuracaoMinimaStandby*1000 ) {
      if (kinectControl.tempoPresencaTemporaria > 10) {
        fadeOutStandby();
        if (millis() - tInicioFade > tempoFade*1000) {
          isStandby = false;
          restartBrisa();
        }
      }
    }
  }
}

void drawStandby() {
  desenhaLuz();
}

void fadeOutStandby() {
  if( tInicioFade == 0 ) {
    tInicioFade = millis();
  }
  int iAlpha = int(map(millis(), tInicioFade, tInicioFade+tempoFade*1000, 100, 0));
  if( iAlpha < iAlphaStandby) iAlphaStandby  = iAlpha;
}

void desenhaLuz() {
  noStroke();
  pushMatrix();
  colorMode(HSB,100);
  translate(posInicioRaiz.x - luzplanta.width/2, posInicioRaiz.y - luzplanta.height/3, 0);
  tint(50, 50, 100, iAlphaStandby);
  image(luzplanta, 0, 0);
  colorMode(RGB,255);
  popMatrix();
}

void movieEvent(Movie movie) {
  movie.read();  
}