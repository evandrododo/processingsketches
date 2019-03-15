public class Root {
  
  ArrayList<Emitter> pontos = new ArrayList<Emitter>();
  ArrayList<Root> filhas = new ArrayList<Root>();
  int profundidade = 0;
  int tCriacao;
  boolean ativo = false;
  int iRaiz = 0;

  // Cria Raiz a partir de um ponto x,y
  public Root(int xI, int yI, int p, int iR) {
    pontos.add( new Emitter(xI, yI).setAngle(-45) );
    iRaiz = iR;
    
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
    desativaRaiz();

    tCriacao = millis();
  }

  public void desativaRaiz() {
    ativo = false;
  }

  public void ativaRaiz() {
    if( ativo == false ){
      ativo = true;
      tCriacao = millis();
    }
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
    
    float destinoX = int(kinectControl.centroMassa.x/640 * 1024);
    float destinoY = int(kinectControl.centroMassa.y/480 * 768);
    if( profundidade == 0 && iRaiz == 1){
      destinoX = 1024;
      destinoY = 0;
    }
    if( profundidade == 0 && iRaiz == 2){
      destinoX = -200;
      destinoY = 0;
    }
    if( profundidade == 0 && iRaiz == 3){
      destinoY = -30;
      destinoX = width/2;
    }
    if( profundidade == 1 ) {
      if( iRaiz == 1){
        destinoX = 1200;
        destinoY = 900;
      }
      if( iRaiz == 2){
        destinoX = -100;
        destinoY = 900;
      }
      if( iRaiz == 3){
        destinoY = -400;
      }
    } 

    float distanciaDestino = dist(xNovoPonto, yNovoPonto, destinoX, destinoY);
    PVector forcaAtracao = new PVector(destinoX - xNovoPonto, destinoY - yNovoPonto);
    if( profundidade < 2 ){
      forcaAtracao.div(sqrt(distanciaDestino)*(2+profundidade));
      // forcaAtracao.mult();
    } else {
      forcaAtracao.div(distanciaDestino);
      forcaAtracao.mult(sqrt(sqrt(distanciaDestino)));
    }
    if(forcaAtracao.mag() > 20) forcaAtracao.setMag(20);

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
    colorMode(RGB, 255);
    stroke(255);
  }

  void drawParticulas() {
    if(drawParticulasEnabled) {
      particulasFrame.beginDraw();
      int limita = 0;
      for(Emitter e : pontos) {
        if(limita % 15 == 7 && limita < pontos.size()-1) {
          e.update();
          e.drawParticles();
        }
        limita++;
      }
      particulasFrame.endDraw();
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
      int frequenciaFilhas = 20*profundidade;
      int limiteMinimo = 30;
      if(profundidade == 0) {
        frequenciaFilhas = 20;
        limiteMinimo = 40;
      }

      if (qtdNos > limiteMinimo && qtdFilhas < qtdNos/frequenciaFilhas) {    
        addFilha();
      }
    }
  }

  float segundosDecorridos() {
    return float(millis()-tCriacao)/1000;
  }

  void drawLigacoes() {
    raizesFrame.smooth(8);
    raizesFrame.beginDraw();
    raizesFrame.noFill();
    raizesFrame.beginShape();
    int strokeW = 1;
    switch(profundidade) {
      case 0:
        strokeW = 7;
        break;
      case 1:
        strokeW = 5;
        break;
      case 2:
        strokeW = 3;
        break;
      case 3:
        strokeW = 2;
      default:
        strokeW = 1;

    }
    raizesFrame.strokeWeight(strokeW);
    Point p = pontos.get(0);

    // raizesFrame.stroke(corRaizes);
    raizesFrame.stroke(255,255,255);
    raizesFrame.vertex(p.x, p.y, 0);
    for (int i = 0; i < pontos.size()-1; i++) {
      p = pontos.get(i);
      raizesFrame.curveVertex(p.x, p.y, 0);
    }
    raizesFrame.curveVertex(p.x, p.y, 0);

    raizesFrame.endShape();
    raizesFrame.endDraw();
  }

  void drawRaiz() { 
    if(ativo) {
      this.update();
      this.drawFilhas();
      this.drawParticulas();
      if( pontos.size() < quantidadeMaxNos-1 ) {
        this.drawLigacoes();
      }
      if(debug) {
        this.drawPontos();
      }
    }
  }

  void addFilha() {
    if (profundidade > 7) return;
    Point ultimoPonto = pontos.get(pontos.size() - 1);
    filhas.add(new Root(ultimoPonto.x, ultimoPonto.y,  profundidade+1, iRaiz));
  }

  void drawFilhas() {
    for (int i = 0; i < filhas.size(); i++) {
      Root r = filhas.get(i);
      r.drawRaiz();
    }
  }
}
