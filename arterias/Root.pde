public class Root {
  
  
  ArrayList<Emitter> pontos = new ArrayList<Emitter>();
  ArrayList<Root> filhas = new ArrayList<Root>();
  int profundidade = 0;
  int tCriacao;

  // Cria Raiz a partir de um ponto x,y
  public Root(int xI, int yI, int p) {
    pontos.add( new Emitter(xI, yI).setAngle(45) );
    
    profundidade = p;
    tCriacao = millis();
    
  }

  int getDirecaoRaiz(int indexPonto) {
    // Calcula angulo da direção dos ultimos pontos
    if (pontos.size() > 1 && pontos.size() > indexPonto+1 ) {
      Point ultimoPonto = pontos.get(indexPonto);
      Point penultimoPonto = pontos.get(indexPonto - 1);
      Point vetorForca = new Point(ultimoPonto.x - penultimoPonto.x, ultimoPonto.y - penultimoPonto.y);
      float tamanhoVetor = dist(0,0, vetorForca.x, vetorForca.y);
      float xNormalizado = vetorForca.x / tamanhoVetor;
      
      println("anguloVetor: "+acos(xNormalizado));
      int anguloVetor = int(degrees(acos(xNormalizado)));
      // Acerta quadrante (sin e cos são iguais para quadrantes opostos)
      if( vetorForca.y < 0 ) {
        anguloVetor = 360 - anguloVetor;
      }
      return anguloVetor;
    } 
    return 15;
  }

  void addPonto() {
    int destinoX = mouseX;
    int destinoY = mouseY;

    int anguloUltimoVetor = getDirecaoRaiz(pontos.size()-1);

    float distanciaNovoPonto = random(distanciaMin, distanciaMax);
    float anguloNovoPonto = random(anguloVariacao/-2, anguloVariacao/2) + anguloUltimoVetor;

    if (anguloNovoPonto < 0) {
      anguloNovoPonto += 360;
    }

    int xCriacao = int(cos(radians(anguloNovoPonto)) * distanciaNovoPonto);
    int yCriacao = int(sin(radians(anguloNovoPonto)) * distanciaNovoPonto);

    Point ultimoPonto = pontos.get(pontos.size() - 1);

    int xNovoPonto = xCriacao + ultimoPonto.x;
    int yNovoPonto = yCriacao + ultimoPonto.y;
    
    pontos.add(new Emitter(xNovoPonto, yNovoPonto).setAngle(int(anguloNovoPonto)));
  }

  void drawPontos() {
    strokeWeight(2);
    colorMode(HSB, 255);
    for (int i = 0; i < pontos.size()-1; i++) {  
      stroke(i + 10*(profundidade+1), 255, 255);
      Point p = pontos.get(i);
      point(p.x, p.y);
    }
    stroke(255);
  }

  void drawParticulas() {

    blendMode(BLEND);
    particulasFrame.beginDraw();
    particulasFrame.fill(0, 0, 0, 5);
    particulasFrame.noStroke();
    if(millis()%10 == 0) {
      particulasFrame.rect(0,0, width, height);
    }
    for(Emitter e : pontos) {
      e.update();
      e.drawParticles();
    }
    particulasFrame.endDraw();
    image(particulasFrame, 0, 0);
  }

  void update() {
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

  float segundosDecorridos() {
    return float(millis()-tCriacao)/1000;
  }

  void drawLigacoes() {
    noFill();
    colorMode(RGB, 100);
    beginShape();
    // strokeWeight(9-profundidade*2);
    stroke(1);
    Point p = pontos.get(0);

    stroke(0, 255, 255, 100);
    vertex(p.x, p.y, 0);
    for (int i = 0; i < pontos.size()-1; i++) {
      p = pontos.get(i);
      curveVertex(p.x, p.y, 0);
    }
    curveVertex(p.x, p.y, 0);

    endShape();
  }

  void drawRaiz() { 
    this.update();
    this.drawFilhas();
    this.drawParticulas();
    if(debug) {
      this.drawPontos();
    }
    this.drawLigacoes();
  }

  void addFilha() {
    if (profundidade > 2) return;
    Point ultimoPonto = pontos.get(pontos.size() - 1);
    filhas.add(new Root(ultimoPonto.x, ultimoPonto.y,  profundidade+1));
  }

  void drawFilhas() {
    for (int i = 0; i < filhas.size(); i++) {
      Root r = filhas.get(i);
      r.drawRaiz();
    }
  }
}
