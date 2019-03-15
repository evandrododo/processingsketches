
public class Particle {
  int tempoVidaMax = 7;
  PVector position;
  PVector force = new PVector(0,0.1);

  int tCreate, tVida;

  Particle(int x, int y) {
    rebirth(x, y);
  }

  public Particle setForce(PVector f) {
    force = f;
    return this;
  }

  Particle rebirth(float x, float y) {
    tCreate = millis();
    position = new PVector(x,y);
    return this;
  }

public void update() {
    tVida = millis() - tCreate;
    PVector randForce = new PVector( random(-0.02, 0.02), random(-0.04, 0.04));
    force.add(randForce);
    position.add(force);

    PVector centroMassa = new PVector(kinectControl.centroMassa.x/640*1024, kinectControl.centroMassa.y/480*768);
    PVector forcaPresenca = centroMassa;
    forcaPresenca.sub(position);
    //forcaPresenca.div(100);
    forcaPresenca.div((dist(position.x,position.y,centroMassa.x, centroMassa.y)));
    position.add(forcaPresenca);
  }

  public void draw() {
    if(this.isDead())
      return;
    particulasFrame.strokeWeight(1);
    float iVida = map(tVida, 0, tempoVidaMax*1000, 100, 10);
    color corP = corTemporaria;
    colorMode(HSB, 100);
    particulasFrame.stroke(color(hue(corP), saturation(corP), iVida));
    particulasFrame.point(position.x, position.y);
    colorMode(RGB, 255);
  }

  boolean isDead() {
    if (tVida > tempoVidaMax*1000) {
     return true;
    } else {
     return false;
    } 
  }
}
