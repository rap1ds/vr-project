public class Camera
{
  private Plane target;
  private PVector offset;
  
  private PVector location = new PVector();
  private PVector velocity = new PVector();
  
  private float stiffness = 1800.0f;
  private float damping = 600.0f;
  private float mass = 50.0f;
  
  public Camera(Plane target) {
    this(target, new PVector(0, 0, 10.0f));
  }
  
  public Camera(Plane target, PVector offset) {
    this.target = target;
    this.offset = offset;
    
    if(offset != null)
      this.location.set(offset);
  }
  
  public void update() {
    
    if (target == null || offset == null)
      return;
    
    // Camera offsets without transformations
    PVector targetLocation = target.location;
    PVector direction = offset;
    PVector up = new PVector(0, 1, 0);
    
    PMatrix3D transform = target.transform;    
    if (transform != null) {
      
      // Transform normals with transpose of the inverse of the transformation matrix
      if (transform.invert()) {
        transform.transpose();
        
        direction = transformNormal(transform, offset);
        up = transformNormal(transform, up);
      }
    }
    
    PVector lookAt = targetLocation;
    
    // Calculate camera location
    PVector desiredLocation = PVector.add(targetLocation, direction);
    
    // calculate spring force
    PVector displacement = PVector.sub(location, desiredLocation);
    PVector force = PVector.sub(PVector.mult(displacement, -stiffness), PVector.mult(velocity, damping));
    
    // TODO: this shouldn't be hard-coded for 60 fps
    float elapsed = 0.016f;
        
    // Calculate acceleration and velocity based on force and update location
    PVector acceleration = PVector.div(force, mass);
    velocity.add(PVector.mult(acceleration, elapsed));
    location.add(PVector.mult(velocity, elapsed));
    
    // Set global variables
    playerX = location.x;
    playerY = location.y;
    playerZ = location.z;
    
    lookAtX = lookAt.x;
    lookAtY = lookAt.y;
    lookAtZ = lookAt.z;
    
    upX = up.x;
    upY = up.y;
    upZ = up.z;
  }
  
  public void setTarget(Plane target) {
    this.target = target;
  } 
}
