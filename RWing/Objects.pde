/* Interactive objects.
 Write your dynamic and interactive element classes here */

import javax.vecmath.Quat4f;
import javax.vecmath.Vector3f;

import processing.core.PApplet;
import processing.core.PVector;

import com.bulletphysics.collision.dispatch.CollisionFlags;
import com.bulletphysics.collision.dispatch.CollisionObject;
import com.bulletphysics.collision.shapes.BoxShape;
import com.bulletphysics.collision.shapes.CollisionShape;
import com.bulletphysics.collision.shapes.SphereShape;
import com.bulletphysics.dynamics.RigidBody;
import com.bulletphysics.dynamics.RigidBodyConstructionInfo;
import com.bulletphysics.linearmath.DefaultMotionState;
import com.bulletphysics.linearmath.Transform;

public class Ground extends PhysicalObject {

  PImage groundTexture;

  public Ground() {
    this(2000);
  }

  public Ground(int groundSize) {
    super(groundSize, 2, groundSize, 1, 0, ruis.getStaticFloorY(), 0, color(200), PhysicalObject.IMMATERIAL_OBJECT);

    this.groundTexture = loadImage("ground.jpg");
  }

  public void renderAtOrigin() {

    pushMatrix();
    scale(super.width, super.height, super.depth);
    beginShape(QUADS);

    texture(groundTexture);
    textureMode(NORMALIZED);

    // front
    normal(0, 0, 1);
    vertex(-1, 1, 1, 0, 1);
    vertex( 1, 1, 1, 1, 1);
    vertex( 1, -1, 1, 1, 0);
    vertex(-1, -1, 1, 0, 0);

    // back
    normal(0, 0, -1);
    vertex( 1, 1, -1, 0, 1);
    vertex(-1, 1, -1, 1, 1);
    vertex(-1, -1, -1, 1, 0);
    vertex( 1, -1, -1, 0, 0);

    // right
    normal(1, 0, 0);
    vertex( 1, 1, 1, 0, 1);
    vertex( 1, 1, -1, 1, 1);
    vertex( 1, -1, -1, 1, 0);
    vertex( 1, -1, 1, 0, 0);

    // left
    normal(-1, 0, 0);
    vertex(-1, 1, -1, 0, 1);
    vertex(-1, 1, 1, 1, 1);
    vertex(-1, -1, 1, 1, 0);
    vertex(-1, -1, -1, 0, 0);

    // bottom
    normal(0, -1, 0);
    vertex(-1, -1, 1, 0, 1);
    vertex( 1, -1, 1, 1, 1);
    vertex( 1, -1, -1, 1, 0);
    vertex(-1, -1, -1, 0, 0);

    // top
    normal(0, 1, 0);
    vertex(-1, 1, -1, 0, 1);
    vertex( 1, 1, -1, 1, 1);
    vertex( 1, 1, 1, 1, 0);
    vertex(-1, 1, 1, 0, 0);

    endShape();

    popMatrix();
  }
}

public class Sky extends PhysicalObject {

  PImage skyTexture;

  public Sky() {
    this(5000);
  }

  public Sky(int skySize) {
    super(skySize, skySize, skySize, 1, 0, ruis.getStaticFloorY() - skySize, 0, color(200), PhysicalObject.IMMATERIAL_OBJECT);
    skyTexture = loadImage("skybox_texture.jpg");
  }

  public void renderAtOrigin() {
    this.setLocation(camera.location.x, camera.location.y, camera.location.z);

    noLights();
    pushMatrix();
    scale(super.width, super.height, super.depth);
    beginShape(QUADS);

    texture(skyTexture);
    textureMode(NORMALIZED);

    // front
    vertex(-1, 1, 1, 1f/4f, 2f/3f);
    vertex( 1, 1, 1, 2f/4f, 2f/3f);
    vertex( 1, -1, 1, 2f/4f, 1f/3f);
    vertex(-1, -1, 1, 1f/4f, 1f/3f);

    // back
    vertex( 1, 1, -1, 3f/4f, 2f/3f);
    vertex(-1, 1, -1, 1, 2f/3f);
    vertex(-1, -1, -1, 1, 1f/3f);
    vertex( 1, -1, -1, 3f/4f, 1f/3f);

    // right
    vertex( 1, 1, 1, 2f/4f, 2f/3f);
    vertex( 1, 1, -1, 3f/4f, 2f/3f);
    vertex( 1, -1, -1, 3f/4f, 1f/3f);
    vertex( 1, -1, 1, 2f/4f, 1f/3f);

    // left
    vertex(-1, 1, -1, 0, 2f/3f);
    vertex(-1, 1, 1, 1f/4f, 2f/3f);
    vertex(-1, -1, 1, 1f/4f, 1f/3f);
    vertex(-1, -1, -1, 0, 1f/3f);

    // bottom
    vertex(-1, -1, 1, 1f/4f, 1f/3f);
    vertex( 1, -1, 1, 2f/4f, 1f/3f);
    vertex( 1, -1, -1, 2f/4f, 0);
    vertex(-1, -1, -1, 1f/4f, 0);

    // top
    vertex(-1, 1, -1, 1f/4f, 1);
    vertex( 1, 1, -1, 2f/4f, 1);
    vertex( 1, 1, 1, 2f/4f, 2f/3f);
    vertex(-1, 1, 1, 1f/4f, 2f/3f);

    endShape();

    popMatrix();
    lights();
  }
}

public class Plane extends PhysicalObject {

  V3dsScene model;
  PVector baseDirection, direction, location;
  PMatrix3D transform;
  Quaternion rotation;
  
  static final float SPEED_BOOST_DURATION = 7000f;
  static final int SPEED_BOOST_MULTIPLIER = 3;
  float speed, speedBoost;
  Timer speedBoostTimer = new Timer();
  
  float stiffness = 3000.0f;
  float damping = 1000.0f;
  float mass = 10.0f;
  
  PVector currentRot = new PVector(0, 0);
  PVector desiredRot = new PVector(0, 0);
  PVector rotVelocity = new PVector(0, 0);
  
  public Plane(PApplet applet, String filename) {
    super(0, 0, 0, 0, 0, 0, 0);
    model = new V3dsScene(applet, filename);
    baseDirection = new PVector(0, 0, 1);
    direction = new PVector(0, 0, 1);
    location = new PVector(0, 0, 0);
    transform = new PMatrix3D();
    rotation = Quaternion.createIdentity();
    speed = 1f;
    
    // Turn the plane 180
    Quaternion yaw = Quaternion.createFromAxisAngle(new PVector(0, 1, 0), PI);
    rotation = rotation.mult(yaw);
  }

  public void draw() {
    direction = rotation.rotateVector(baseDirection);
    
    PVector eulerAngles = rotation.getAsEulerAngles();
    
    transform.reset();
    transform.translate(location.x, location.y, location.z);
    transform.translate(0, -8, 0);    
    transform.rotateZ(eulerAngles.z);
    transform.rotateY(eulerAngles.y);
    transform.rotateX(eulerAngles.x);
    transform.translate(0, 8, 0);
    
    pushMatrix();
    
    applyMatrix(transform);
    
    // TODO: this is because the model has a different base than processing
    scale(1, -1, -1);
    
    model.draw();
    
    popMatrix();
    
    // Calculate the speed boost from passing a checkpoint (if any)
    float boost = 0f;
    if (speedBoost > 0) {
      boost = easeOut(speedBoostTimer.getTimeMillis(), speedBoost,
                      -speedBoost, SPEED_BOOST_DURATION);
      if (boost < 0) {
        speedBoost = 0;
        boost = 0;
      }
    }
    
    // update location
    location = PVector.add(location, PVector.mult(direction, speed + boost));
    println(boost);
    
    // Calculate "easing angle" with spring force
    
    // Apply +- PI to currentRot if it's closer to desiredRot that way, fixes bump at +-PI/2
    if (abs(currentRot.x + PI - desiredRot.x) < abs(currentRot.x - desiredRot.x)) {
      currentRot.x += PI;
    } else if (abs(currentRot.x - PI - desiredRot.x) < abs(currentRot.x - desiredRot.x)) {
      currentRot.x -= PI;
    }
  
    // Calculate displacement force
    PVector displacement = PVector.sub(currentRot, desiredRot);    
    PVector force = PVector.sub(PVector.mult(displacement, -stiffness), PVector.mult(rotVelocity, damping));
    
    // TODO: this shouldn't be hard-coded for 60 fps
    float elapsed = 0.016f;
        
    // Calculate acceleration and velocity based on force and update location
    PVector acceleration = PVector.div(force, mass);
    rotVelocity.add(PVector.mult(acceleration, elapsed));
    
    PVector applyRot = PVector.mult(rotVelocity, elapsed);
    currentRot.add(applyRot);
  
    Quaternion roll = Quaternion.createFromAxisAngle(new PVector(0, 0, 1), applyRot.x);
    Quaternion pitch = Quaternion.createFromAxisAngle(new PVector(1, 0, 0), applyRot.y);
    rotation = rotation.mult(roll.mult(pitch));
  }

  public void roll(float angle) {
    /*Quaternion roll = Quaternion.createFromAxisAngle(new PVector(0, 0, 1), angle);
    rotation = rotation.mult(roll);*/
    desiredRot.x += angle;
  }

  public void pitch(float angle) {
    /*Quaternion pitch = Quaternion.createFromAxisAngle(new PVector(1, 0, 0), angle);
    rotation = rotation.mult(pitch);*/
    desiredRot.y += angle;
  }
  
  public void setEuler(float rollAngle, float pitchAngle) {
    // TODO: tanne constraint...
    desiredRot.y += pitchAngle;
    desiredRot.x = rollAngle;
  }
  
  public PVector getLocation() {
    return this.location;
  }
  
  public void speedBoost() {
    speedBoost = SPEED_BOOST_MULTIPLIER * speed;
    speedBoostTimer.start();
  }
  
  /* Cubic easing function (for the speed boost).
  * Returns startValue at time = 0 and approaches startValue + change at time = duration
  */
  private float easeOut(float time, float startValue, float change, float duration) {
    time /= duration;
    time--;
    return change * (pow(time, 3) + 1) + startValue;
  }
}

public class Checkpoint extends PhysicalObject {

  float posX;
  float posY;
  float posZ;
  PMatrix3D rotationMatrix;
  int size, index;
  
  PVector normal;

  PVector[] testVectors;
  
  boolean debug;
  
  float prevPosX;
  float prevPosY;
  float prevPosZ;

  public Checkpoint(float posX, float posY, float posZ, int size, int index) {
    super(size, size, size, 1, posX, posY, posZ, color(200), PhysicalObject.IMMATERIAL_OBJECT);

    this.size = size;
    this.index = index;
    this.posX = posX;
    this.posY = posY;
    this.posZ = posZ;

    this.test();
    
    /*
    this.prevPosX = spherePosX;
    this.prevPosY = spherePosY;
    this.prevPosZ = spherePosZ;
    */

    this.updatePlanePos(plane.getLocation());
    
    debug = false;
  }
  
  public void setRotationMatrix(PMatrix3D rot) {
    this.rotationMatrix = rot;
  }
  
  private void updatePlanePos(PVector planePos) {
    this.prevPosX = planePos.x;
    this.prevPosY = planePos.y;
    this.prevPosZ = planePos.z;
  }

  public boolean isPassed() {
    
    PVector planePos = plane.getLocation();
    
    // Check if passed
    PVector p0 = new PVector(prevPosX, prevPosY, prevPosZ);
    PVector p1 = planePos;
    if(intersects(p0, p1) && index == raceLine.current) {
      raceLine.current++;
      plane.speedBoost();
      return true;
    }
    
    this.updatePlanePos(planePos);
    
    return false;
  }

  public void renderAtOrigin() {
    if (index > raceLine.current) {
      fill(0x44AA0000);
    } else if (index < raceLine.current || isPassed()) {
      fill(0x4400CC00);
    } else {
      fill(0x440000CC);
    }

    pushMatrix();
    scale(super.width, super.height, super.depth);

    pushMatrix();
    if(rotationMatrix != null) {
      applyMatrix(rotationMatrix);
    }

    float x, y, z, s, t, u, v;
    float nx, ny, nz;
    float aInner, aOuter;
    int idx = 0;

    float outerRad = 1;
    float innerRad = 0.1;
    int numc = 4;
    int numt = 10;

    beginShape(QUAD_STRIP);
    for (int i = 0; i < numc; i++) {
      for (int j = 0; j <= numt; j++) {
        t = j;
        v = t / (float)numt;
        aOuter = v * TWO_PI;
        float cOut = cos(aOuter);
        float sOut = sin(aOuter);
        for (int k = 1; k >= 0; k--) {
          s = (i + k);
          u = s / (float)numc;
          aInner = u * TWO_PI;
          float cIn = cos(aInner);
          float sIn = sin(aInner);

          x = (outerRad + innerRad * cIn) * cOut;
          y = (outerRad + innerRad * cIn) * sOut;
          z = innerRad * sIn;

          nx = cIn * cOut; 
          ny = cIn * sOut;
          nz = sIn;

          normal(nx, ny, nz);
          vertex(x, y, z);
        }
      }
    }
    endShape();
    
    popMatrix();

    popMatrix();
  }
  
  public void setNormal(PVector normal) {
    this.normal = normal;
  }
  
  public PVector getNormal() {
    return normal;
  }

  public PVector getCenter() {
    return this.getLocation();
  }

  /**
   * @param l0 Position at the time 0
   * @param l1 Position at the time 1
   */
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

    if (dist < this.size) {
      PVector nl0 = PVector.sub(p0, l0);
      PVector nl1 = PVector.sub(p0, l1);

      float angle0 = PVector.angleBetween(n, nl0);
      float angle1 = PVector.angleBetween(n, nl1);
      
      if(angle0 < HALF_PI && angle1 >= HALF_PI) {
        return true;
      }
      
      return false;
    } 
    else {
      return false;
    }
  }

  /**
   * Tests intersects method.
   *
   * Should be removed when verifyid that the intersects method works as expected
   */
  public void test() {
    PVector center = this.getLocation();

    PVector true1 = new PVector(center.x - 50, center.y - 20, center.z);
    PVector false1 = new PVector(center.x + 150, center.y, center.z);
    PVector false2 = new PVector(center.x - 150, center.y - 20, center.z);

    true1.mult(2);
    false1.mult(2);
    false2.mult(2);

    PVector origin = new PVector(0, 0, 0);

    this.testVectors = new PVector[3];
    this.testVectors[0] = true1;
    this.testVectors[1] = false1;
    this.testVectors[2] = false2;
  }

  /**
   * Get the location of PhysicalObject
   */
  public PVector getLocation()
  {
    // This should be removed
    Transform myTransform = new Transform();
    rigidBody.getMotionState().getWorldTransform(myTransform);

    // Set object location
    return new PVector(myTransform.origin.x, myTransform.origin.y, 
    myTransform.origin.z);
  }
}

public class RaceLine {

  int ctrlPointCount = 20;
  PVector[] ctrlPoints = new PVector[ctrlPointCount];
  
  int checkpointCount = 8, current = 0;
  Checkpoint[] checkpoints = new Checkpoint[checkpointCount];

  int playerCtrlPoint = 1;
  float playerT = 0f;

  float lookAtDistance = 0.005;
  int lookAtCtrlPoint = 1;
  float lookAtT = playerT + lookAtDistance;
  float flyingSpeed = 0.005;

  public void setup() {
    generateControlPoints();
    createCheckpoints();
  }

  public void generateControlPoints() {
    ctrlPoints[0] = new PVector(0, -100, 0);
    ctrlPoints[1] = new PVector(0, -100, -600);

    for (int i = 2; i < ctrlPointCount; i++) {
      PVector prev = ctrlPoints[i-1];

      float z = prev.z - 600;
      float x = random(-600, 600);
      float y = random(-600, 0);

      ctrlPoints[i] = new PVector(x, y, z);
    }
  }

  public void createCheckpoints() {
    for (int j = 1; j <= checkpointCount; j++) {
      PVector p = this.getPoint(j, 0.5);
      Checkpoint checkpoint = new Checkpoint(p.x, p.y, p.z, 100, j-1);
      checkpoint.setNormal(this.getDirection(j, 0.5));
      checkpoint.setRotationMatrix(this.getRotationMatrix(j, 0.5));
      checkpoints[j-1] = checkpoint;
      ruis.addObject(checkpoint);
    }
  }

  public void follow() {
    if (lookAtCtrlPoint < ctrlPointCount - 2) {
      PVector playerPos = this.getPoint(playerCtrlPoint, playerT);
      PVector lookAtPos = this.getPoint(lookAtCtrlPoint, lookAtT);

      camera.location.set(playerPos);
      camera.target.set(lookAtPos);
      
      pushMatrix();
      fill(color(255, 255, 255));
      translate(playerPos.x, playerPos.y, playerPos.z);
      popMatrix();
    }

    if (playerT >= 1) {
      playerT = 0;
      playerCtrlPoint++;
    }

    if (lookAtT >= 1) {
      lookAtT = 0;
      lookAtCtrlPoint++;
    }

    playerT += flyingSpeed;
    lookAtT += flyingSpeed;
  }

  public void draw() {

    // Follow the race line
    // this.follow();

    stroke(color(255, 0, 0));
    noFill();
    for (int i = 3; i < ctrlPointCount; i++) {
      PVector p0 = ctrlPoints[i-3];
      PVector p1 = ctrlPoints[i-2];
      PVector p2 = ctrlPoints[i-1];
      PVector p3 = ctrlPoints[i];
      curve(p0.x, p0.y, p0.z, p1.x, p1.y, p1.z, p2.x, p2.y, p2.z, p3.x, p3.y, p3.z);
    }
    noStroke();
  }

  /**
   * Gets point on the spline.
   *
   * Example: 
   *   
   *   The point in the middle of control points 3 and 4 (where control point is zero-based)
   *   controlPoint: 3
   *   t: 0.5
   *
   * @param controlPoint number of control point
   * @param t the value of t [0,1]
   */
  public PVector getPoint(int controlPoint, float t) {
    // Equation
    /*
        q(t) = 0.5 *((2 * P1) + // pTerm1
     	       (-P0 + P2) * t + // pTerm2
     (2*P0 - 5*P1 + 4*P2 - P3) * t^2 + // pTerm3
     (-P0 + 3*P1- 3*P2 + P3) * t^3) // pTerm4
     */
    PVector p0 = ctrlPoints[controlPoint - 1];
    PVector p1 = ctrlPoints[controlPoint];
    PVector p2 = ctrlPoints[controlPoint + 1];
    PVector p3 = ctrlPoints[controlPoint + 2];

    PVector pTerm1 = new PVector();
    PVector pTerm2 = new PVector();
    PVector pTerm3 = new PVector();
    PVector pTerm4 = new PVector();

    // Term1
    pTerm1.add(p1);
    pTerm1.mult(2);

    // Term2
    pTerm2.sub(p0);
    pTerm2.add(p2);
    pTerm2.mult(t);

    // Term3
    pTerm3.add(PVector.mult(p0, 2));
    pTerm3.add(PVector.mult(p1, -5));
    pTerm3.add(PVector.mult(p2, 4));
    pTerm3.add(PVector.mult(p3, -1));
    pTerm3.mult(t*t);

    // Term 4
    pTerm4.add(PVector.mult(p0, -1));
    pTerm4.add(PVector.mult(p1, 3));
    pTerm4.add(PVector.mult(p2, -3));
    pTerm4.add(PVector.mult(p3, 1));
    pTerm4.mult(t*t*t);

    // Sum
    PVector sum = new PVector();
    sum.add(pTerm1);
    sum.add(pTerm2);
    sum.add(pTerm3);
    sum.add(pTerm4);
    sum.mult(0.5f);

    return sum;
  }

  public PVector getDirection(int controlPoint, float t) {
    /* Equation:
     0.5 ( 3t^2 (-P0 + 3P1 - 3P2 + P3) // pTerm1
     + 2t (2P0 - 5P1 + 4P2 - P3) // pTerm2
     - P0 + P2 )
     */

    PVector p0 = ctrlPoints[controlPoint - 1];
    PVector p1 = ctrlPoints[controlPoint];
    PVector p2 = ctrlPoints[controlPoint + 1];
    PVector p3 = ctrlPoints[controlPoint + 2];    

    PVector pTerm1 = new PVector();
    PVector pTerm2 = new PVector();

    // Term 1
    pTerm1.add(PVector.mult(p0, -1));
    pTerm1.add(PVector.mult(p1, 3));
    pTerm1.add(PVector.mult(p2, -3));
    pTerm1.add(PVector.mult(p3, 1));
    pTerm1.mult(3f * t * t);

    // Term 2
    pTerm2.add(PVector.mult(p0, 2));
    pTerm2.add(PVector.mult(p1, -5));
    pTerm2.add(PVector.mult(p2, 4));
    pTerm2.add(PVector.mult(p3, -1));
    pTerm2.mult(2f * t);

    // Sum
    PVector sum = new PVector();
    sum.add(pTerm1);
    sum.add(pTerm2);
    sum.sub(p0);
    sum.add(p2);
    sum.mult(0.5f);

    return sum;
  }
  
  public PMatrix3D getRotationMatrix(int controlPoint, float t) {
      PVector F = this.getDirection(controlPoint, t);
      F.normalize();
      PVector U = new PVector(0, 1, 0);
      PVector R = PVector.cross(F, U, null);
      U = PVector.cross(R, F, null);

      PMatrix3D rot = new PMatrix3D(
      F.x, U.x, R.x, 0, 
      F.y, U.y, R.y, 0, 
      F.z, U.z, R.z, 0, 
      0, 0, 0, 1);
      
      rot.rotateY(HALF_PI);
      
      return rot;  
  }
}


