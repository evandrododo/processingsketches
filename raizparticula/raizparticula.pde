Controles controles;
Root r;
int distanciaMin = 40;
int distanciaMax = 50;
int quantidadeMaxNos = 50;
int anguloVariacao = 90;
float velocidadeCriacao = 3;

void settings() {
  size(1366, 1000, P3D);  
  controles = new Controles();
  smooth(8);
  //fullScreen();
}


void setup() {
  frameRate(60);
  strokeJoin(ROUND);
  background(0);
  //fill(102);
  noFill();

  r = new Root(00, 100, 0);
}

void draw() {
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

void keyPressed() {
  if (key == 'R' || key == 'r') {
    r = new Root( 200, 200, 0);
  }
}