public class Root {
  
  ArrayList<Emitter> pontos = new ArrayList<Emitter>();
  ArrayList<Root> filhas = new ArrayList<Root>();
  int profundidade = 0;
  int tCriacao;
  boolean ativo = false;

  // Cria Raiz a partir de um ponto x,y
  public Root(int xI, int yI, int p) {
    pontos.add( new Emitter(xI, yI).setAngle(-45) );
    
    profundidade = p;
    tCriacao = millis();
    
    if(profundidade > 0) {
      ativaRaiz();
    }
    println("Raiz add em ["+xI+","+yI+"] P:"+profundidade);
  }

  public void restart(int xI, int yI) {
    pontos.clear();
    filhas.clear();
    pontos.add( new Emitter(xI, yI).setAngle(-45) );

    tCriacao = millis();
  }

  public void desativaRaiz() {
    ativo = false;
  }

  public void ativaRaiz() {
    ativo = true;
  }

  int getDirecaoRaiz(int indexPonto) {
    // Calcula angulo da direção dos ultimos pontos
    if (pontos.size() > 1 && pontos.size() > indexPonto ) {
      Emitter ultimoPonto = pontos.get(indexPonto);
      if(ultimoPonto.angle != 45) {
        return ultimoPonto.angle;
      }
      Point penultimoPonto = pontos.get(indexPonto - 1);
      Point vetorForca = new Point(ultimoPonto.x - penultimoPonto.x, ultimoPonto.y - penultimoPonto.y);
      float tamanhoVetor = dist(0,0, vetorForca.x, vetorForca.y);
      float xNormalizado = vetorForca.x / tamanhoVetor;
      
      int anguloVetor = int(degrees(acos(xNormalizado)));
      // Acerta quadrante (sin e cos são iguais para quadrantes opostos)
      if( vetorForca.y < 0 ) {
        anguloVetor = 360 - anguloVetor;
      }
      return anguloVetor;
    } 
    return int(random(0,360));
  }

  void addPonto() {
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
    

    float destinoX = int(kinectControl.centroMassa.x/640 * 1440);
    float destinoY = int(kinectControl.centroMassa.y/480 * 1080);

    float distanciaDestino = dist(xNovoPonto, yNovoPonto, destinoX, destinoY);
    PVector forcaAtracao = new PVector(destinoX - xNovoPonto, destinoY - yNovoPonto);
    forcaAtracao.div(distanciaDestino);
    forcaAtracao.mult(profundidade);

    xNovoPonto += forcaAtracao.x;
    yNovoPonto += forcaAtracao.y;
    
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
    if(drawParticulasEnabled) {
      particulasFrame.beginDraw();
      for(Emitter e : pontos) {
        e.update();
        e.drawParticles();
      }
      particulasFrame.endDraw();
      image(particulasFrame, 0, 0);
    }
  }

  void update() {
    if(ativo) {
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
  }

  float segundosDecorridos() {
    return float(millis()-tCriacao)/1000;
  }

  void drawLigacoes() {
    noFill();
    colorMode(RGB, 100);
    beginShape();
    int strokeW = 9-profundidade*2;
    strokeWeight(strokeW);
    stroke(1);
    Point p = pontos.get(0);

    stroke(corPrimaria);
    vertex(p.x, p.y, 0);
    for (int i = 0; i < pontos.size()-1; i++) {
      p = pontos.get(i);
      curveVertex(p.x, p.y, 0);
    }
    curveVertex(p.x, p.y, 0);

    endShape();
  }

  void drawRaiz() { 
    if(ativo) {
      this.update();
      this.drawFilhas();
      this.drawParticulas();
      this.drawLigacoes();
      if(debug) {
        this.drawPontos();
      }
    }
  }

  void addFilha() {
    if (profundidade > 4) return;
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
