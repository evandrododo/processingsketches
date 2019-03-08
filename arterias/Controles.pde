import g4p_controls.*;

GSlider brilho, contraste, tilt;
GButton restart, btnCorPrimaria;
GCheckbox debugMode, drawParticulasCheckbox;
  
PGraphics pgCor;

GSlider2D posInicioRaizSlider;

public class Controles extends PApplet {
  
  Controles() {
    super();
    PApplet.runSketch(new String[] {this.getClass().getSimpleName()}, this);
  }

  void settings() {
    size(700, 500, P2D);
  }

  void setup() {
    background(0);

    brilho = new GSlider(this, 75, 20, 200, 100, 15);
    brilho.setLimits(brilhoKinect, -555, 255);
    brilho.setShowValue(true);

    contraste = new GSlider(this, 75, 50, 200, 100, 15);
    contraste.setLimits(contrasteKinect, 0, 100);
    contraste.setShowValue(true);

    tilt = new GSlider(this, 75, 80, 200, 100, 15);
    tilt.setLimits(anguloTilt, -30, 30);
    tilt.setShowValue(true);

    restart = new GButton(this, 40, 20, 100, 30, "Reiniciar");
    debugMode = new GCheckbox(this, 200, 25, 100, 15, "Debug");
    drawParticulasCheckbox = new GCheckbox(this, 350, 55, 200, 15, "Desenhar Particulas");

    btnCorPrimaria = new GButton(this, 400, 20, 100, 30, "Selecionar Cor");

    GView view = new GView(this, 350, 26, 40, 20, JAVA2D);
    pgCor = view.getGraphics();
    pgCor.beginDraw();
    pgCor.background(corPrimaria);
    pgCor.endDraw();

    posInicioRaizSlider = new GSlider2D(this, 350, 300, 192, 108);
    posInicioRaizSlider.setLimitsX(posInicioRaiz.x, 0, 1920);
    posInicioRaizSlider.setLimitsY(posInicioRaiz.y, 0, 1080);
    posInicioRaizSlider.setEasing(8);
  }

  void draw() {
    clear();
    background(255);
  }

  public void handleButtonEvents(GButton button, GEvent event) {
    if(button == restart) {
      restartRoot();
    } else if (button == btnCorPrimaria)
      handleColorChooser();
  }

  void restartRoot() {
    r = new Root(width/2, 0, 0);
  }

  void handleSliderEvents(GValueControl slider, GEvent event) { 
    if (slider == brilho) {
      brilhoKinect = slider.getValueI();
    }
    if (slider == contraste) {
      contrasteKinect = slider.getValueF();
    }
    if (slider == tilt) {
      anguloTilt = slider.getValueI();
    }
  }

  void handleToggleControlEvents(GToggleControl checkbox, GEvent event) { 
    if (checkbox == debugMode) {
      debug = (event.toString() == "SELECTED");
    } else if (checkbox == drawParticulasCheckbox) {
      drawParticulasEnabled = (event.toString() == "SELECTED");
    }
  }

  // G4P code for colour chooser
  public void handleColorChooser() {
    corPrimaria = G4P.selectColor();
    pgCor.beginDraw();
    pgCor.background(corPrimaria);
    pgCor.endDraw();
  }

  public void handleSlider2DEvents(GSlider2D slider2d, GEvent event) {
    if (slider2d == posInicioRaizSlider) {
      posInicioRaiz.x = slider2d.getValueXI();
      posInicioRaiz.y = slider2d.getValueYI();
    }
  }
}
