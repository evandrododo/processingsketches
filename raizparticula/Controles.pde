import g4p_controls.*;

GSlider dMin, dMax, angVar, velCriacao;

  
public class Controles extends PApplet {
  
  Controles() {
    super();
    PApplet.runSketch(new String[] {this.getClass().getSimpleName()}, this);
  }

  void settings() {
    size(500, 200, P3D);
  }

  void setup() {
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
    velCriacao.setLimits(velocidadeCriacao, 0.1, 100);
    velCriacao.setShowValue(true);
  }

  void draw() {
    clear();
    background(0);
    fill(255);
    text("dist. Mínima", 10, 55);
    text("dist. Máxima", 10, 95);
    text("ang Variação", 10, 135);
    text("vel. Criação", 10, 175);
  }
  
  void handleSliderEvents(GValueControl slider, GEvent event) { 
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
