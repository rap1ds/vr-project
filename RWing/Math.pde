public static class Quaternion {
  
  public float scalar;
  public PVector vector;
  
  private Quaternion() {
    scalar = 0.0f;
    vector = new PVector(0, 0, 0);
  }
  
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
  
  static float i(float[] m, int r, int c) {
    return m[r*4 + c];
  }
  
  public void set(float x, float y, float z, float w) {
    this.vector.set(x, y, z);
    this.scalar = w;
  }
  
  public static Quaternion fromMatrix(PMatrix matrix) {
    Quaternion q = new Quaternion();
    
    float m[] = new float[16];
    matrix.get(m);
    
    float m00 = i(m, 0, 0);
    float m01 = i(m, 0, 1);
    float m02 = i(m, 0, 2);
    float m03 = i(m, 0, 3);
    
    float m10 = i(m, 1, 0);
    float m11 = i(m, 1, 1);
    float m12 = i(m, 1, 2);
    float m13 = i(m, 1, 3);
    
    float m20 = i(m, 2, 0);
    float m21 = i(m, 2, 1);
    float m22 = i(m, 2, 2);
    float m23 = i(m, 2, 3);
    
    float m30 = i(m, 3, 0);
    float m31 = i(m, 3, 1);
    float m32 = i(m, 3, 2);
    float m33 = i(m, 3, 3);
    
    float qw, qx, qy, qz;
    float tr = m00 + m11 + m22;
    if(tr > 0) {
      float S = sqrt(tr + 1.0) * 2;
      qw = 0.25 * S;
      qx = (m21 - m12) / S;
      qy = (m02 - m20) / S;
      qz = (m10 - m01) / S;
    } else if ((m00 > m11) && (m00 > m22)) {
      float S = sqrt(1.0 + m00 - m11 - m22) * 2;
      qw = (m21 - m12) / S;
      qx = 0.25 * S;
      qy = (m01 + m10) / S;
      qz = (m02 + m20) / S;
    } else if (m11 > m22) {
      float S = sqrt(1.0 + m11 - m00 - m22) * 2;
      qw = (m02 - m20) / S;
      qx = (m01 + m10) / S;
      qy = 0.25 * S;
      qz = (m12 + m21) / S;
    } else {
      float S = sqrt(1.0 + m22 - m00 - m11) * 2;
      qw = (m10 - m01) / S;
      qx = (m02 + m20) / S;
      qy = (m12 + m21) / S;
      qz = 0.25 * S;
    }
    
    q.vector = new PVector(qx, qy, qz);
    q.scalar = qw;
    
    return q;
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
