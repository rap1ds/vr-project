public class EnemyPlane extends PhysicalObject {

  V3dsScene model;
  float x;
  float y;
  float z;
  float hitAreaSize = 15;

  float speed = 0; 
  float speedDown = 0;
  
  boolean destroyed = false;
  float rotation = 0;

  public EnemyPlane(PApplet applet, String filename) {
    super(0, 0, 0, 0, 0, 0, 0);

    x = random(500, 2000);
    y = random(-500, -100);
    z = random(-6000, 0);

    model = new V3dsScene(applet, filename);
  }

  public void startEngine() {
    speed = 0.25;
  }

  public void draw() {

    if(y > 200) {
      // No not draw anymore, destroyed.
      return;
    }
    
    pushMatrix();

    // TODO: this is because the model has a different base than processing
    translate(x, y, z);
    rotateX(rotation);
    scale(1, -1, 1);

    model.draw();

    popMatrix();    
  }
  
  public void update() {
    if (!destroyed) {
      z -= speed;
    } else {
      if(rotation < (HALF_PI)) {
        rotation += 0.01;
      }
      
      speed += 0.01;
      speedDown += 0.03;
      
      y += speedDown;
      z -= speed;
    }
  }
  
  public PVector getCenter() {
    return new PVector(x, y - 5, z -5);
  }
  
  public PVector getNormal() {
    PVector center = this.getCenter();
    return new PVector(center.x - 100, center.y, center.z);
  }
  
  public void destroy() {
    if(!this.destroyed) {
      this.destroyed = true;
      timer.decreaseTime(2500);
    }
  }

  public boolean intersects(PVector l0, PVector l1) {
    
    PVector p0 = this.getCenter();
    PVector n = getNormal();
    PVector l = new PVector();
    PVector.sub(l1, l0, l);

    PVector p0subl0 = new PVector();
    PVector.sub(p0, l0, p0subl0);

    float d = p0subl0.dot(n) / l.dot(n);

    PVector intersectionPoint = new PVector();
    PVector.mult(l, d, intersectionPoint);
    intersectionPoint.add(l0);

    float dist = intersectionPoint.dist(this.getCenter());

    if (dist < this.hitAreaSize) {
      return true;
    } 
    else {
      return false;
    }
  }
}

