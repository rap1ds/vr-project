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
  
  public Plane(PApplet parent, String filename, String pathType, int drawMode) {
    super(0, 0, 0, 0, 0, 0, 0);
    model = new OBJModel(parent, filename, pathType, drawMode);
    direction = new PVector(0, 0, 1);
    location = new PVector(0, 0, 0);
    speed = 0.5;
  }
  
  public void draw() {
    location = PVector.add(location, PVector.mult(direction, speed));
    pushMatrix();
    translate(location.x, location.y, location.z);
    translate(0, -8, 0);
    rotateX(roll);
    rotateZ(pitch);
    translate(0, 8, 0);
    model.draw();
    popMatrix();
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

public class Checkpoint extends PhysicalObject {

  float posX;
  float posY;
  float posZ;
  int size;
  
  PVector[] testVectors; 

  public Checkpoint(float posX, float posY, float posZ, int size) {
    super(size, size, size, 1, posX, posY, posZ, color(200), PhysicalObject.IMMATERIAL_OBJECT);

    this.size = size;
    this.posX = posX;
    this.posY = posY;
    this.posZ = posZ;
    
    this.test();
  }

  public void renderAtOrigin() {
    fill(0x4400CC00);

    pushMatrix();
    scale(super.width, super.height, super.depth);

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
  }

  /**
   * This is naive because it doesn't take into account the rotation of the object.
   * Assumes the rotation is not changed from the default
   */
  public PVector getNaiveNormal() {
    PVector norm = new PVector(0, 0, this.size);
    norm.add(this.getLocation());
    return norm;
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
    PVector n = getNaiveNormal();
    PVector l = new PVector();
    PVector.sub(l1, l0, l);
    
    PVector p0subl0 = new PVector();
    PVector.sub(p0, l0, p0subl0);
    
    float d = p0subl0.dot(n) / l.dot(n);
    
    PVector intersectionPoint = new PVector();
    PVector.mult(l, d, intersectionPoint);
    intersectionPoint.add(l0);
    
    float dist = intersectionPoint.dist(this.getCenter());
    
    if(dist < this.size) {
      return true;
    } else {
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
    
    println("True1, intersects (should be true): " + this.intersects(origin, true1));
    println("False1, intersects (should be false): " + this.intersects(origin, false1));
    println("False2, intersects (should be false): " + this.intersects(origin, false2));
    
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
