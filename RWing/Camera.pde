public class Camera
{
  PVector location = new PVector();
  PVector target = new PVector();
  PVector up = new PVector(0, 1, 0);
    
  private Plane followTarget;
  private PVector offset;  
  private PVector velocity = new PVector();
  
  private float stiffness = 1800.0f;
  private float damping = 600.0f;
  private float mass = 50.0f;
  
  public Camera(Plane target) {
    this(target, new PVector(0, 0, 10.0f));
  }
  
  public Camera(Plane followTarget, PVector offset) {
    this.followTarget = followTarget;
    this.offset = offset;
    
    if(offset != null)
      this.location.set(offset);
  }
  
  public void update() {
    
    if (followTarget == null || offset == null)
      return;
    
    // Camera offsets without transformations
    PVector targetLocation = followTarget.location;
    PVector direction = offset;
    
    PMatrix3D transform = followTarget.transform;
    if (transform != null) {
      
      // Transform normals with transpose of the inverse of the transformation matrix
      if (transform.invert()) {
        transform.transpose();
        
        direction = transformNormal(transform, offset);
        this.up = transformNormal(transform, new PVector(0, 1, 0));
      }
    }
    
    this.target.set(targetLocation);
    
    // Calculate camera location
    PVector desiredLocation = PVector.add(targetLocation, direction);
    
    // calculate spring force
    PVector displacement = PVector.sub(this.location, desiredLocation);
    PVector force = PVector.sub(PVector.mult(displacement, -stiffness), PVector.mult(velocity, damping));
    
    // TODO: this shouldn't be hard-coded for 60 fps
    float elapsed = 0.016f;
        
    // Calculate acceleration and velocity based on force and update location
    PVector acceleration = PVector.div(force, mass);
    velocity.add(PVector.mult(acceleration, elapsed));
    location.add(PVector.mult(velocity, elapsed));
  }
  
  public void setFollowTarget(Plane followTarget) {
    this.followTarget = followTarget;
  } 
}

