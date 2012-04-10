public class Camera
{
  private Plane target;
  private PVector offset;
  
  public Camera(Plane target) {
    this.target = target;
    this.offset = new PVector(0, 0, 10.0f);
  }
  
  public Camera(Plane target, PVector offset) {
    this.target = target;
    this.offset = offset;
  }
  
  public void update() {
    
    if (target == null)
      return;
    
    // Camera offsets without transformations
    PVector pos = target.location;
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
    
    // Calculate camera location
    PVector player = PVector.add(pos, direction);
    PVector lookAt = pos;
    
    // Set global variables
    playerX = player.x;
    playerY = player.y;
    playerZ = player.z;
    
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
