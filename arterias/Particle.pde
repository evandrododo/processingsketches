
public class Particle {
  int tempoVidaMax = 5;
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
    PVector randForce = new PVector( random(-0.05, 0.05), random(-0.05, 0.05));
    force.add(randForce);
    position.add(force);

    PVector centroMassa = new PVector(kinectControl.centroMassa.x/640*1440, kinectControl.centroMassa.y/480*1080);
    PVector forcaPresenca = centroMassa;
    forcaPresenca.sub(position);
    //forcaPresenca.div(100);
    forcaPresenca.div((dist(position.x,position.y,centroMassa.x, centroMassa.y)));
    //position.add(forcaPresenca);
  }

  public void draw() {
    if(this.isDead())
      return;
    particulasFrame.strokeWeight(1);
    float iVida = map(tVida, 0, tempoVidaMax*1000, 100, 10);
    color corP = corPrimaria;
    colorMode(HSB, 100);
    particulasFrame.stroke(color(hue(corP), saturation(corP), iVida));
    particulasFrame.point(position.x, position.y);
  }

  boolean isDead() {
    if (tVida > tempoVidaMax*1000) {
     return true;
    } else {
     return false;
    } 
  }
}
