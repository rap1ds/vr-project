/* Interactive objects.
 Write your dynamic and interactive element classes here */

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
    rotateX(0.25f*PI);
    pushMatrix();
    translate( super.radius, 0, 0);
    box(0.2f*super.radius, 0.4f*super.radius, 0.4f*super.radius);
    popMatrix();
    pushMatrix();
    translate(-super.radius, 0, 0);
    box(0.2f*super.radius, 0.4f*super.radius, 0.4f*super.radius);
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
    zDisplace = -0.5f*physicalObject.depth;
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
    this.physicalObject.setRotation(
    RUIS.inverseRotation(viewManager.getRUIScamRotMat()));
  }

  public void render()
  {
    pushMatrix();
    // Push the switch graphics backwards in the screen coordinate system
    viewManager.inverseCameraRotation();
    translate(0, 0, zDisplace);
    viewManager.applyCameraRotation();

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

    pushMatrix();
    scale(super.width, super.height, super.depth);
    beginShape(QUADS);

    texture(skyTexture);
    textureMode(NORMALIZED);

    // front
    normal(0, 0, 1);
    vertex(-1, 1, 1, 1f/4f, 2f/3f);
    vertex( 1, 1, 1, 2f/4f, 2f/3f);
    vertex( 1, -1, 1, 2f/4f, 1f/3f);
    vertex(-1, -1, 1, 1f/4f, 1f/3f);

    // back
    normal(0, 0, -1);
    vertex( 1, 1, -1, 3f/4f, 2f/3f);
    vertex(-1, 1, -1, 1, 2f/3f);
    vertex(-1, -1, -1, 1, 1f/3f);
    vertex( 1, -1, -1, 3f/4f, 1f/3f);

    // right
    normal(1, 0, 0);
    vertex( 1, 1, 1, 2f/4f, 2f/3f);
    vertex( 1, 1, -1, 3f/4f, 2f/3f);
    vertex( 1, -1, -1, 3f/4f, 1f/3f);
    vertex( 1, -1, 1, 2f/4f, 1f/3f);

    // left
    normal(-1, 0, 0);
    vertex(-1, 1, -1, 0, 2f/3f);
    vertex(-1, 1, 1, 1f/4f, 2f/3f);
    vertex(-1, -1, 1, 1f/4f, 1f/3f);
    vertex(-1, -1, -1, 0, 1f/3f);

    // bottom
    normal(0, -1, 0);
    vertex(-1, -1, 1, 1f/4f, 1f/3f);
    vertex( 1, -1, 1, 2f/4f, 1f/3f);
    vertex( 1, -1, -1, 2f/4f, 0);
    vertex(-1, -1, -1, 1f/4f, 0);

    // top
    normal(0, 1, 0);
    vertex(-1, 1, -1, 1f/4f, 1);
    vertex( 1, 1, -1, 2f/4f, 1);
    vertex( 1, 1, 1, 2f/4f, 2f/3f);
    vertex(-1, 1, 1, 1f/4f, 2f/3f);

    endShape();

    popMatrix();
  }
}

public class Plane {
  
  public OBJModel model;
  
  public Plane(PApplet parent, String filename, String pathType, int drawMode) {
    this.model = new OBJModel(parent, filename, pathType, drawMode);
    this.model.translateToCenter();
  }
  
  public void draw() {
    this.model.draw();
  }
}

public class Checkpoint extends PhysicalObject {

  public Checkpoint(float posX, float posY, float posZ, int size) {
    super(size, size, size, 1, posX, posY, posZ, color(200), PhysicalObject.IMMATERIAL_OBJECT);
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
    int axis = 0;

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

          if (axis == 0) {
            x = (outerRad + innerRad * cIn) * cOut;
            y = (outerRad + innerRad * cIn) * sOut;
            z = innerRad * sIn;
          } 
          else if (axis == 1) {
            x = innerRad * sIn;
            y = (outerRad + innerRad * cIn) * sOut;
            z = (outerRad + innerRad * cIn) * cOut;
          } 
          else {
            x = (outerRad + innerRad * cIn) * cOut;
            y = innerRad * sIn;
            z = (outerRad + innerRad * cIn) * sOut;
          }     

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
}
