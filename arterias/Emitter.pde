public class Emitter extends Point {

  ArrayList<Particle> particles;
  int angle;
  int tempoInicio;

  public Emitter(int x0, int y0) {
    super(x0, y0);
    angle = 45;
    particles = new ArrayList<Particle>();
    tempoInicio = millis();
  }
  
  public Emitter setAngle(int a) {
    angle = a;
    return this;
  }

  public void update() {
    for (Particle p : particles) {
      p.update();
      if(p.isDead()) {
        p.rebirth(x, y)
          .setForce(new PVector(cos(radians(angle)) / 10, sin(radians(angle)) / 10));
      }
    }
    createParticle();
  }

  public float segundosDecorridos() {
    return (millis() - tempoInicio)/1000;
  }
  public void createParticle() {
    if(particles.size() < segundosDecorridos()) {
      PVector f = new PVector( cos(radians(angle)) / 10, sin(radians(angle)) / 10);
      particles.add(new Particle(x,y).setForce(f));
    }
  }

  public void drawParticles() {
    if( debug ) {
      strokeWeight(1);
      stroke(0,255,0);
      line(x,y, x + cos(radians(angle))*10, y + sin(radians(angle))*10);
    }

    for (Particle p : particles) {
      p.draw();
    }

  }

}
