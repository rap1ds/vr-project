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

float spherePosX = 0;
float spherePosY = 0;
float spherePosZ = 0;

/**
 * This is how you define a new kind of Physical object with its own physical
 * behavior and own graphics rendering method.
 */
public class ImmaterialSphere extends PhysicalObject
{
  ImmaterialSphere(float radius, float startX, 
  float startY, float startZ, int sphereColor)
  {
    // This object takes no part in the JBullet's physical simulation because
    // of the PhysicalObject.IMMATERIAL flag. The PhysicalObject constructor
    // with 7 arguments creates a sphere shape, whereas the constructor with 
    // 9 arguments creates a box shape
    super(radius, 1 /* mass */, startX, startY, startZ, 
    sphereColor, PhysicalObject.IMMATERIAL_OBJECT         );
  }

  // Redefine PhysicalObject's renderAtOrigin() method, which draws graphics
  // without any previous translations or rotations
  public void renderAtOrigin()
  {
    // Call PhysicalObject's default draw method
    super.renderAtOrigin();

    // Add some graphical details (2 white boxes around the sphere) 
    fill(color(255));
    noStroke();
    rotateX(0.25*PI);
    pushMatrix();
    translate( super.radius, 0, 0);
    box(0.2*super.radius, 0.4*super.radius, 0.4*super.radius);
    popMatrix();
    pushMatrix();
    translate(-super.radius, 0, 0);
    box(0.2*super.radius, 0.4*super.radius, 0.4*super.radius);
    popMatrix();
  }
}

public class SelectableSwitch extends SelectableObject
{    
  public boolean switchOn = true;
  public float screenRelativeX;
  public float screenRelativeY;
  public float zDisplace = 0;

  public SelectableSwitch(PhysicalObject ruisObject, float relX, float relY)
  {
    super(ruisObject);
    screenRelativeX = relX;
    screenRelativeY = relY;
  }

  // Executes once just after the object is selected (button pressed)
  public void initObjectSelection(int wandID)
  {
    zDisplace = -0.5*physicalObject.depth;
  }

  // Do nothing while switch is being selected
  public void whileObjectSelection(int wandID)
  {
  }

  // Executes once just after the selection button is released
  public void releaseObjectSelection(int wandID)
  {
    if (switchOn)
    {
      this.physicalObject.fillColor = color(30, 110, 80);
      ruis.setGlobalGravity(new PVector(0, 0, 0));
    }
    else
    {
      this.physicalObject.fillColor = color(0, 255, 55);
      ruis.setGlobalGravity(new PVector(0, 70, 0));
    }
    switchOn = !switchOn;
    zDisplace = 0;
  }

  // This is called for the switch on every draw() iteration
  // If you want to use Selectable objects as interactive 
  // Heads-Up-Display (HUD) buttons, menus, etc. that are fixed in 
  // the user view regardless of RUIScamera pose, then update the 
  // Selectable object's location in its updateObject() function 
  // with screen2WorldX/Y/Z. It returns the HUD object's X/Y/Z 
  // location in world coordinates, where selections are made. 
  public void updateObject()
  {
    super.updateObject();
    float locX = screen2WorldX(screenRelativeX, screenRelativeY, 0);
    float locY = screen2WorldY(screenRelativeX, screenRelativeY, 0);
    float locZ = screen2WorldZ(screenRelativeX, screenRelativeY, 0);
    this.physicalObject.setLocation(locX, locY, locZ);
    // Applying the inverse of ruisCamera's rotation matrix keeps the switch
    // facing towards the viewport even when ruisCamera is manipulated
    this.physicalObject.setRotation(inverseRotation(getCameraRotMat()));
  }

  public void render()
  {
    pushMatrix();

    // Push the switch graphics backwards in the screen coordinate system
    inverseCameraRotation();
    translate(0, 0, zDisplace);
    applyCameraRotation();

    super.render();
    popMatrix();
  }

  // SelectableSwitch inherits highlightWouldBeSelected() and getRigidBody()
  // from SelectableObject
}

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
    this(2000);
  }

  public Sky(int skySize) {
    super(skySize, skySize, skySize, 1, 0, ruis.getStaticFloorY() - skySize, 0, color(200), PhysicalObject.IMMATERIAL_OBJECT);
    skyTexture = loadImage("skybox_texture.jpg");
  }

  public void renderAtOrigin() {
    this.setLocation(playerX, playerY, playerZ);

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

  OBJModel model;
  PVector direction, location;
  float speed, roll = 0, pitch = 0, easing = 0.3;
  PMatrix3D transform;

  public Plane(PApplet parent, String filename, String pathType, int drawMode) {
    super(0, 0, 0, 0, 0, 0, 0);
    model = new OBJModel(parent, filename, pathType, drawMode);
    direction = new PVector(0, 0, 1);
    location = new PVector(0, 0, 0);
    transform = new PMatrix3D();
    speed = 0.5;
  }

  public void draw() {
    
    transform.reset();
    transform.translate(location.x, location.y, location.z);
    transform.translate(0, -8, 0);    
    transform.rotateZ(roll);
    transform.rotateX(pitch);
    transform.translate(0, 8, 0);
    
    pushMatrix();
//    translate(location.x, location.y, location.z);
//    translate(0, -8, 0);
//    rotateX(pitch);
//    rotateZ(roll);
//    translate(0, 8, 0);
    applyMatrix(transform);
    model.draw();
    popMatrix();
    
    // transform forward direction
    PVector forward = direction;
    
    PMatrix3D m = new PMatrix3D(transform);
    if (m.invert()) {
      m.transpose();
      forward = transformNormal(m, direction);
    }
    
    // update location
    location = PVector.add(location, PVector.mult(forward, speed));
  }

  public void roll(float angle) {
    roll += easing * (angle - roll);
  }

  public void pitch(float angle) {
    pitch += easing * (angle - pitch);
  }

  public void addRoll(float increment) {
    roll += increment;
  }

  public void addPitch(float increment) {
    pitch += increment;
  }
}

boolean isFirst = true;

public class Checkpoint extends PhysicalObject {

  float posX;
  float posY;
  float posZ;
  PMatrix3D rotationMatrix;
  int size;
  
  PVector normal;

  PVector[] testVectors; 
  
  boolean passed = false;
  
  boolean debug;
  
  float prevPlayerX;
  float prevPlayerY;
  float prevPlayerZ;

  public Checkpoint(float posX, float posY, float posZ, int size) {
    super(size, size, size, 1, posX, posY, posZ, color(200), PhysicalObject.IMMATERIAL_OBJECT);

    this.size = size;
    this.posX = posX;
    this.posY = posY;
    this.posZ = posZ;

    this.test();
    
    /*
    this.prevPlayerX = spherePosX;
    this.prevPlayerY = spherePosY;
    this.prevPlayerZ = spherePosZ;
    */

    this.prevPlayerX = playerX;
    this.prevPlayerY = playerY;
    this.prevPlayerZ = playerZ;
    
    debug = false;
    
    isFirst = false;
    
  }
  
  public void setRotationMatrix(PMatrix3D rot) {
    this.rotationMatrix = rot;
  }

  public boolean isPassed() {
    if(passed) {
      return true;
    }
    
    // Check if passed
    PVector p0 = new PVector(prevPlayerX, prevPlayerY, prevPlayerZ);
    // PVector p1 = new PVector(spherePosX, spherePosY, spherePosZ);
    PVector p1 = new PVector(playerX, playerY, playerZ);
    if(intersects(p0, p1)) {
      this.passed = true;
      return true;
    }
    
    // Update player pos
    /*
    prevPlayerX = spherePosX;
    prevPlayerY = spherePosY;
    prevPlayerZ = spherePosZ;
    */
    
    prevPlayerX = playerX;
    prevPlayerY = playerY;
    prevPlayerZ = playerZ;
    
    return false;
  }

  public void renderAtOrigin() {
    if(isPassed()) {
      fill(0x4400CC00);
    } else {
      fill(0x44FF0000);
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
    ctrlPoints[0] = new PVector(0, -100, -100);
    ctrlPoints[1] = new PVector(0, -100, 0);

    for (int i = 2; i < ctrlPointCount; i++) {
      PVector prev = ctrlPoints[i-1];

      float z = prev.z + 150;
      float x = random(-600, 600);
      float y = random(-600, 0);

      ctrlPoints[i] = new PVector(x, y, z);
    }
  }

  public void createCheckpoints() {
    for (int j = 1; j < 8; j++) {
      PVector p = this.getPoint(j, 0.5);
      Checkpoint checkpoint = new Checkpoint(p.x, p.y, p.z, 100);
      checkpoint.setNormal(this.getDirection(j, 0.5));
      checkpoint.setRotationMatrix(this.getRotationMatrix(j, 0.5));
      ruis.addObject(checkpoint);
    }
  }

  public void follow() {
    if (lookAtCtrlPoint < ctrlPointCount - 2) {
      PVector playerPos = this.getPoint(playerCtrlPoint, playerT);
      PVector lookAtPos = this.getPoint(lookAtCtrlPoint, lookAtT);
      // PVector spherePos = this.getPoint(playerCtrlPoint, playerT);

      playerX = playerPos.x;
      playerY = playerPos.y;
      playerZ = playerPos.z;

      lookAtX = lookAtPos.x;
      lookAtY = lookAtPos.y;
      lookAtZ = lookAtPos.z;
      
      pushMatrix();
      fill(color(255, 255, 255));
      translate(playerPos.x, playerPos.y, playerPos.z);
      // sphere(10);
      popMatrix();
      /*
      spherePosX = spherePos.x;
      spherePosY = spherePos.y;
      spherePosZ = spherePos.z;  
  */    
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

