public static class Quaternion {
  
  public float scalar;
  public PVector vector;
  
  private Quaternion(float scalar, PVector vector) {
    this.scalar = scalar;
    this.vector = vector;
  }
  
  private Quaternion(float scalar, float x, float y, float z) {
    this(scalar, new PVector(x, y, z));
  }
  
  public static Quaternion createIdentity() {
    return new Quaternion(1, new PVector(0, 0, 0));
  }
  
  public static Quaternion createFromAxisAngle(PVector axis, float angle) {
    axis.normalize();
    float _scalar = cos(angle / 2);
    PVector _vector = PVector.mult(axis, sin(angle / 2));
    return new Quaternion(_scalar, _vector);
  }
  
  /**
  * Quaternion multiplication.
  */
  public Quaternion mult(Quaternion q) {
    float _scalar = scalar * q.scalar - vector.dot(q.vector);
    PVector vector1 = PVector.mult(q.vector, scalar);
    PVector vector2 = PVector.mult(vector, q.scalar);
    PVector vector3 = vector.cross(q.vector);
    PVector _vector = PVector.add(PVector.add(vector1, vector2), vector3);
    return new Quaternion(_scalar, _vector);
  }
  
  public Quaternion getConjugate() {
    return new Quaternion(scalar, PVector.mult(vector, -1));
  }
  
  /**
  * This method conjugates (i.e. rotates) the input vector using this quaternion and the formula
  * v' = qvq*, where
  * v is the input vector
  * v' is the rotated vector
  * q is the quaternion
  * q* is the conjugate of the quaternion
  * The input vector is wrapped inside a quaternion in order to perform quaternion multiplication.
  */
  public PVector rotateVector(PVector _vector) {
    Quaternion wrappedVector = new Quaternion(0, _vector);
    return mult(wrappedVector.mult(getConjugate())).vector;
  }
  
  /**
  * Calculates the Euler angles that correspond to a rotation that this quaternion represents.
  */
  public PVector getAsEulerAngles() {
    PVector result = new PVector(0, 0, 0);
    float w = scalar, x = vector.x, y = vector.y, z = vector.z;
    result.x = atan2(2*(w*x + y*z), 1 - 2*(x*x + y*y));
    result.y = asin(2*(w*y - z*x));
    result.z = atan2(2*(w*z + x*y), 1 - 2*(y*y + z*z));
    return result;
  }
  
  public String toString() {
    return scalar + " + (" + vector.x + ", " + vector.y + ", " + vector.z + ")";
  }
}
