import g4p_controls.*;

GSlider brilho, contraste;
  
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
    brilho = new GSlider(this, 55, 10, 200, 100, 15);

    brilho.setLimits(0, -255, 255);
    brilho.setShowValue(true);

    contraste = new GSlider(this, 55, 30, 200, 100, 15);
    contraste.setLimits(1, 0, 100);
    contraste.setShowValue(true);
  }

  void draw() {
    clear();
    background(255);
  }
  
  void handleSliderEvents(GValueControl slider, GEvent event) { 
    if (slider == brilho) {
      brilhoKinect = slider.getValueI();
    }
    if (slider == contraste) {
      contrasteKinect = contraste.getValueF();
    }
  }

  
}
