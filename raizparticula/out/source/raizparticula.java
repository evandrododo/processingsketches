import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import g4p_controls.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class raizparticula extends PApplet {

Controles controles;
Root r;
int distanciaMin = 40;
int distanciaMax = 50;
int quantidadeMaxNos = 50;
int anguloVariacao = 90;
float velocidadeCriacao = 3;

public void settings() {
  size(1366, 1000, P3D);  
  controles = new Controles();
  smooth(8);
  //fullScreen();
}


public void setup() {
  frameRate(60);
  strokeJoin(ROUND);
  background(0);
  //fill(102);
  noFill();

  r = new Root(00, 100, 0);
}

public void draw() {
  // println(frameRate);
  translate(0, 0, 0);
  curveTightness(0);
  clear();

  stroke(255);
  strokeWeight(1);


  //Raiz r = raizes.get(0);
  r.drawRaiz();
  colorMode(RGB, 255);
  fill(255, 255, 255);
  text("frameRate:"+frameRate, 20, 20);
  
}

public void keyPressed() {
  if (key == 'R' || key == 'r') {
    r = new Root( 200, 200, 0);
  }
}


GSlider dMin, dMax, angVar, velCriacao;

  
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
    fill(0);
    dMin = new GSlider(this, 95, 0, 200, 100, 15);
    dMin.setLimits(distanciaMin, 0, 300);
    dMin.setShowValue(true);

    dMax = new GSlider(this, 95, 40, 200, 100, 15);
    dMax.setLimits(distanciaMax, 20, 500);
    dMax.setShowValue(true);

    angVar = new GSlider(this, 95, 80, 200, 100, 15);
    angVar.setLimits(anguloVariacao, 2, 360);
    angVar.setShowValue(true);

    velCriacao = new GSlider(this, 95, 120, 200, 100, 15);
    velCriacao.setLimits(velocidadeCriacao, 0.1f, 100);
    velCriacao.setShowValue(true);
  }

  public void draw() {
    clear();
    background(0);
    fill(255);
    text("dist. Mínima", 10, 55);
    text("dist. Máxima", 10, 95);
    text("ang Variação", 10, 135);
    text("vel. Criação", 10, 175);
  }
  
  public void handleSliderEvents(GValueControl slider, GEvent event) { 
    if (slider == dMin) {
      distanciaMin = slider.getValueI();
    }
    if (slider == dMax) {
      distanciaMax = slider.getValueI();
    }
    if (slider == angVar) {
      anguloVariacao = slider.getValueI();
    }
    if (slider == velCriacao) {
      velocidadeCriacao = slider.getValueF();
    }
  }

  
}
public class Point {
  int x, y, z;
  public Point(int x0, int y0) {
    x = x0;
    y = y0;
  }
  public Point(int x0, int y0, int z0) {
    x = x0;
    y = y0;
    z = z0;
  }
}
public class Root {
  ArrayList<Point> pontos = new ArrayList<Point>();
  ArrayList<Root> filhas = new ArrayList<Root>();
  int profundidade = 0;
  int tCriacao;

  // Cria Raiz a partir de um ponto x,y
  public Root(int xI, int yI, int p) {
    pontos.add(new Point(xI, yI));
    
    profundidade = p;
    tCriacao = millis();
  }

  public int getDirecaoRaiz(int indexPonto) {
    // Calcula angulo da direção dos ultimos pontos
    if (pontos.size() > 1 && pontos.size() > indexPonto+1 ) {
      Point ultimoPonto = pontos.get(indexPonto);
      Point penultimoPonto = pontos.get(indexPonto - 1);
      Point vetorForca = new Point(ultimoPonto.x - penultimoPonto.x, ultimoPonto.y - penultimoPonto.y);
      float tamanhoVetor = dist(0,0, vetorForca.x, vetorForca.y);
      float xNormalizado = vetorForca.x / tamanhoVetor;
      
      println("anguloVetor: "+acos(xNormalizado));
      int anguloVetor = PApplet.parseInt(degrees(acos(xNormalizado)));
      // Acerta quadrante (sin e cos são iguais para quadrantes opostos)
      if( vetorForca.y < 0 ) {
        anguloVetor = 360 - anguloVetor;
      }
      return anguloVetor;
    } 
    return 45;
  }

  public void addPonto() {
    int destinoX = mouseX;
    int destinoY = mouseY;

    int anguloUltimoVetor = getDirecaoRaiz(pontos.size()-1);

    float distanciaNovoPonto = random(distanciaMin, distanciaMax);
    float anguloNovoPonto = random(anguloVariacao/-2, anguloVariacao/2) + anguloUltimoVetor;

    if (anguloNovoPonto < 0) {
      anguloNovoPonto += 360;
    }

    int xCriacao = PApplet.parseInt(cos(radians(anguloNovoPonto)) * distanciaNovoPonto);
    int yCriacao = PApplet.parseInt(sin(radians(anguloNovoPonto)) * distanciaNovoPonto);

    Point ultimoPonto = pontos.get(pontos.size() - 1);

    int xNovoPonto = xCriacao + ultimoPonto.x;
    int yNovoPonto = yCriacao + ultimoPonto.y;
    
    pontos.add(new Point(xNovoPonto, yNovoPonto));
  }

  public void drawPontos() {
    strokeWeight(2);
    colorMode(HSB, 255);
    for (int i = 0; i < pontos.size()-1; i++) {  
      stroke(i + 10*(profundidade+1), 255, 255);
      Point p = pontos.get(i);
      point(p.x, p.y);
    }
    stroke(255);
  }

  public void update() {
    int qtdNos = pontos.size();

    if (qtdNos < quantidadeMaxNos &&  
        qtdNos < segundosDecorridos() * velocidadeCriacao ) {
      
      addPonto();
    }
    
    int qtdFilhas = filhas.size();
    if (qtdNos > 10 && qtdFilhas < qtdNos/10) {    
      addFilha();
    }
      
    
  }

  public float segundosDecorridos() {
    return PApplet.parseFloat(millis()-tCriacao)/1000;
  }

  public void drawLigacoes() {
    noFill();
    colorMode(RGB, 100);
    beginShape();
    strokeWeight(9-profundidade*2);
    Point p = pontos.get(0);

    stroke(255, 0, 0);
    vertex(p.x, p.y, 0);
    for (int i = 0; i < pontos.size()-1; i++) {
      p = pontos.get(i);
      stroke(255 - i*5, 0, 0);
      curveVertex(p.x, p.y, 0);
    }
    curveVertex(p.x, p.y, 0);

    endShape();
  }

  public void drawRaiz() { 
    this.update();
    this.drawLigacoes();
    // this.drawPontos();
    this.drawFilhas();
  }

  public void addFilha() {
    if (profundidade > 2) return;
    Point ultimoPonto = pontos.get(pontos.size() - 1);
    filhas.add(new Root(ultimoPonto.x, ultimoPonto.y,  profundidade+1));
  }

  public void drawFilhas() {
    for (int i = 0; i < filhas.size(); i++) {
      Root r = filhas.get(i);
      r.drawRaiz();
    }
  }
}
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "raizparticula" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
