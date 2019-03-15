import g4p_controls.*;

import processing.sound.*;
import gohai.glvideo.*;

Controles controles;


int brilhoKinect = -135;
float contrasteKinect = 5.0;
int anguloTilt = 0;
int quantidadeMassaPresenca = 1500;

int distanciaMin = 7;
int distanciaMax = 8;
int quantidadeMaxNos = 75;
int anguloVariacao = 80;
float velocidadeCriacao = 4;

PGraphics particulasFrame;
PGraphics raizesFrame;
  
boolean debug = false;
boolean drawParticulasEnabled = true;

boolean isStandby = true;

color corPrimaria = color(0,255,255);
color corTemporaria = color(0,0,0);
color corSilhueta = color(0,0,0);
color corParticulas = color(0,0,0);
color corRaizes = color(0,0,0);

KinectControl kinectControl;
Root r, r2, r3;

// Eventos
int tInicioBrisa, tDuracaoBrisa;
int tInicioStandby, tDuracaoStandby;
int qtdBrisasPassadas;

int tDuracaoMaximaBrisa = 193;
int tDuracaoMinimaStandby = 3;
int tInicioRaizes;
int tInicioArterias = 98;
PVector posInicioRaiz = new PVector(500, 100);

PImage luzplanta;
GLMovie arterias;
SoundFile trilha;

public void settings() {
  fullScreen(P3D);
  controles = new Controles();
}

public void setup() {
  frameRate(12);
  noCursor();
  tInicioBrisa = millis();
  tInicioRaizes = 20;
  kinectControl = new KinectControl();
  kinectControl.setup(this);
  
  particulasFrame = createGraphics(width, height, P3D);
  raizesFrame = createGraphics(width, height, P3D);
  r = new Root(int(posInicioRaiz.x), int(posInicioRaiz.y), 0, 1);
  r2 = new Root(int(posInicioRaiz.x-20), int(posInicioRaiz.y), 0, 2);
  r3 = new Root(int(posInicioRaiz.x), int(posInicioRaiz.y), 0, 3);

  startStandby();

  luzplanta = loadImage("luz.png");
  
  arterias = new GLMovie(this, "arterias.mp4");
  trilha = new SoundFile(this, "trilha.aiff");
  corTemporaria = corPrimaria;

}

void startRaizes() {
  r.ativaRaiz();
  r2.ativaRaiz();
  r3.ativaRaiz();
}

void restartBrisa() {
  //arterias.stop();
  trilha.stop();
  tInicioBrisa = millis();
  tDuracaoBrisa = 0;
  qtdBrisasPassadas++;
  // println("Restart pela "+qtdBrisasPassadas+"ª vez");

  corSilhueta = color(0,0,0,0);
  corParticulas = color(0,0,0,0);
  corRaizes = color(0,0,0,0);
  corTemporaria = corPrimaria;
  kinectControl.fbo = createGraphics(640, 480, P2D); 
  particulasFrame = createGraphics(width, height, P3D);
  raizesFrame = createGraphics(width, height, P3D);
  r.restart(int(posInicioRaiz.x), int(posInicioRaiz.y));
  r2.restart(int(posInicioRaiz.x), int(posInicioRaiz.y));
  r3.restart(int(posInicioRaiz.x), int(posInicioRaiz.y));
  arterias.play();
  trilha.play();
}

public void pulsaPreto() {
  corSilhueta = lerpColor(corSilhueta, color(0,0,0,0), 0.2);
  corRaizes = lerpColor(corSilhueta, color(0,0,0,0), 0.2);
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
    //startRaizes();
    r.ativaRaiz();
  }
  if( tDuracaoBrisa > tInicioRaizes*1000 + 4000) {
    r2.ativaRaiz();
  }
  if( tDuracaoBrisa > tInicioRaizes*1000 + 7000) {
    r3.ativaRaiz();
  }

  if(tDuracaoBrisa > 100 && tDuracaoBrisa < tInicioRaizes*1000 ) {
    corSilhueta = lerpColor(corSilhueta, corTemporaria, 0.005);
  } else if (tDuracaoBrisa > tInicioRaizes*1000 && tDuracaoBrisa < tInicioRaizes*1000 + 5000) {
    corSilhueta = lerpColor(corSilhueta, corTemporaria, 0.1);
    corRaizes = lerpColor(corRaizes, corTemporaria, 0.01);
  } else if (tDuracaoBrisa > tInicioRaizes*1000+5000 && tDuracaoBrisa < tInicioRaizes*1000 + 7000) {
    corRaizes = lerpColor(corRaizes, corTemporaria, 0.1);
  }

  // Pulsa essas raizes pras minhas veias
  if( tDuracaoBrisa < tInicioArterias*1000 + 7000) {
    if( tDuracaoBrisa > tInicioArterias*1000 && tDuracaoBrisa < tInicioArterias*1000 + 500) {
      pulsaPreto();
      corTemporaria = color(0,0,0);
    }
    if( tDuracaoBrisa > tInicioArterias*1000 + 500  && tDuracaoBrisa < tInicioArterias*1000 + 1500 ) {
      corSilhueta = lerpColor(corSilhueta, color(255,0,0), 0.4);
      corRaizes = lerpColor(corSilhueta, color(0,255,255), 0.4);
    }
    if( tDuracaoBrisa > tInicioArterias*1000 + 1500  && tDuracaoBrisa < tInicioArterias*1000 + 2000 ) {
      pulsaPreto();
    }
    if( tDuracaoBrisa > tInicioArterias*1000 + 2000  && tDuracaoBrisa < tInicioArterias*1000 + 3000 ) {
      corSilhueta = lerpColor(corSilhueta, color(255,0,0), 0.4);
      corRaizes = lerpColor(corSilhueta, color(255,0,0), 0.4);
    }
    if( tDuracaoBrisa > tInicioArterias*1000 + 3000  && tDuracaoBrisa < tInicioArterias*1000 + 3500 ) {
      pulsaPreto();
    }
    if( tDuracaoBrisa > tInicioArterias*1000 + 3500 && tDuracaoBrisa < tInicioArterias*1000 + 4500 ) {
      corSilhueta = lerpColor( corSilhueta, color(255,0,0), 0.4);
      corRaizes = lerpColor( corRaizes, color(255,0,0), 0.4);
    }
    if( tDuracaoBrisa > tInicioArterias*1000 + 4500 && tDuracaoBrisa < tInicioArterias*1000 + 5000 ) {
      pulsaPreto();
    }
    if( tDuracaoBrisa > tInicioArterias*1000 + 5500 && tDuracaoBrisa < tInicioArterias*1000 + 7000 ) {
      corSilhueta = lerpColor( corSilhueta, color(255,0,0), 0.4);
      corRaizes = lerpColor( corRaizes, color(255,0,0), 0.4);
    }
  }
  if( tDuracaoBrisa > tInicioArterias*1000 + 7000 && tDuracaoBrisa < tInicioArterias*1000 + 8000 ) {
    corSilhueta = lerpColor( corSilhueta, corPrimaria, 0.4);
    corRaizes = lerpColor( corRaizes, corPrimaria, 0.4);
    corTemporaria = corPrimaria;
  }
  

  // Fim da brisa com fade out
  if( tDuracaoBrisa > tDuracaoMaximaBrisa*1000 - 20000) {
    corTemporaria = lerpColor( corTemporaria, color(0,0,0,0), 0.1);
    // println("CorTemporaria:"+corTemporaria);
    corRaizes = corTemporaria;
    corSilhueta = corTemporaria;
  }
  if( tDuracaoBrisa > tDuracaoMaximaBrisa*1000 - 2000) {
    corTemporaria = lerpColor( corTemporaria, color(0,0,0,0), 0.5);
    corRaizes = corTemporaria;
    corSilhueta = corTemporaria;
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
    tint(corRaizes);
    image(raizesFrame, 0, 0);
    noTint();
    blendMode(BLEND);
  }
  if (debug) {
    text("tDuracao:"+tDuracaoBrisa,width-190, 80);
  }
}

void startStandby() {
  // println("Inicio standby");
  isStandby = true;
  tInicioStandby = millis();
  tDuracaoStandby = 0;
  tDuracaoBrisa = 0;
  tInicioFade = 0;
  iAlphaStandby = 0;
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
