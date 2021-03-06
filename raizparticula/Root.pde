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
    return 45;
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
    
    pontos.add(new Point(xNovoPonto, yNovoPonto));
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
    strokeWeight(2);
    colorMode(HSB, 255);
    for (int i = 0; i < pontos.size()-1; i++) {  
      stroke(i + 10*(profundidade+1), 255, 255);
      Point p = pontos.get(i);
      point(p.x, p.y);
    }
    stroke(255);
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

  void drawRaiz() { 
    this.update();
    this.drawLigacoes();
    // this.drawPontos();
    this.drawFilhas();
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
