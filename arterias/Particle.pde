
public class Particle {
  int tempoVidaMax = 5;
  PVector velocity;
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
    velocity = new PVector(x,y);
    return this;
  }

  public void update() {
    tVida = millis() - tCreate;
    PVector randForce = new PVector( random(-0.5, 0.5), random(-0.5, 0.5));
    force.add(randForce);
    velocity.add(force);
  }

  public void draw() {
    if(this.isDead())
      return;
    particulasFrame.strokeWeight(1);
    float iVida = map(tVida, 0, tempoVidaMax*1000, 255, 0);
    particulasFrame.stroke(0 , iVida, iVida);
    particulasFrame.point(velocity.x, velocity.y);
  }

  boolean isDead() {
    if (tVida > tempoVidaMax*1000) {
     return true;
    } else {
     return false;
    } 
  }
}
