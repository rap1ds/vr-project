import java.util.Vector;
import javax.media.opengl.GL;
import java.nio.FloatBuffer;
import com.sun.opengl.util.BufferUtil;
import com.sun.opengl.util.texture.*;

class ms_vector2
{
 float x, y;
 
 // constructor
 ms_vector2()
 {
   this.x = 0;
   this.y = 0;
 }
 
 ms_vector2( float _x, float _y)
 {
   this.x = _x;
   this.y = _y;
 }
}
 
// buffer converters
FloatBuffer PVector_to_FloatBuffer( Vector<PVector> _vector )
{
 FloatBuffer a  = BufferUtil.newFloatBuffer( _vector.size() * 3 );      
 
 for( int i = 0; i < _vector.size(); i++ )
 {
   PVector v = (PVector) _vector.elementAt( i );
   a.put( v.x );
   a.put( v.y );
   a.put( v.z );
 }
 a.rewind();
 return a;
}

FloatBuffer PVector_to_FloatBuffer2( Vector<PVector> _vector )
{
 FloatBuffer a  = BufferUtil.newFloatBuffer( _vector.size() * 2 );      
 
 for( int i = 0; i < _vector.size(); i++ )
 {
   PVector v = (PVector) _vector.elementAt( i );
   a.put( v.x );
   a.put( v.y );
 }
 a.rewind();
 return a;
}
        
public class Terrain extends PhysicalObject {

  Texture tex;
  int size;
  
  PGraphicsOpenGL pgl;
  GL gl;
  
  int[] vboID = new int[2];
  int dataLength;

  public Terrain() {
    this(100);
  }

  public Terrain(int groundSize) {
    super(groundSize, 2, groundSize, 1, 0, ruis.getStaticFloorY(), 0, color(200), PhysicalObject.IMMATERIAL_OBJECT);

    this.size = groundSize;
    
    try {
      // Load texture
      this.tex = TextureIO.newTexture(new File(dataPath("ground2.jpg")), true);
      
      // Set wrap for texture coordinates
      this.tex.setTexParameteri(GL.GL_TEXTURE_WRAP_S, GL.GL_REPEAT);
      this.tex.setTexParameteri(GL.GL_TEXTURE_WRAP_T, GL.GL_REPEAT);
      
    } catch (IOException e) {
      println("Texture file not found.");
    }
    
    pgl = (PGraphicsOpenGL)g;
    gl = pgl.gl;
    
    createAndFillVBO();
  }

  private void createAndFillVBO() {
    
    // Guesstimate for nice-looking texture resolution
    float texScale = this.size / 100.0f;
    
    // Build vertex and texture coordinate data
    Vector<PVector> vertexData = new Vector<PVector>();
    Vector<PVector> texcoordData = new Vector<PVector>();
    
    vertexData.addElement(new PVector(-1, 0, 1));
    texcoordData.addElement(new PVector(0, 0));
    
    vertexData.addElement(new PVector(1, 0, 1));
    texcoordData.addElement(new PVector(texScale, 0));
    
    vertexData.addElement(new PVector(1, 0, -1));
    texcoordData.addElement(new PVector(texScale, texScale));
    
    vertexData.addElement(new PVector(-1, 0, -1));
    texcoordData.addElement(new PVector(0, texScale));
    
    // Save our data length
    dataLength = vertexData.size();
    
    pgl.beginGL();
    
    // Generate VBOs
    gl.glGenBuffers(2, vboID, 0);
    
    // Bind and upload data for vertex coordinates
    gl.glBindBuffer(GL.GL_ARRAY_BUFFER, vboID[0]);
    gl.glBufferData(GL.GL_ARRAY_BUFFER, dataLength * 3 * BufferUtil.SIZEOF_FLOAT, PVector_to_FloatBuffer(vertexData), GL.GL_STATIC_DRAW);
    
    // Bind and upload data for texture coordinates
    gl.glBindBuffer(GL.GL_ARRAY_BUFFER, vboID[1]);
    gl.glBufferData(GL.GL_ARRAY_BUFFER, dataLength * 2 * BufferUtil.SIZEOF_FLOAT, PVector_to_FloatBuffer2(texcoordData), GL.GL_STATIC_DRAW);
    
    // Unbind buffer
    gl.glBindBuffer(GL.GL_ARRAY_BUFFER, 0);
    
    pgl.endGL();
  }
  
  public void renderAtOrigin() {

    pushMatrix();
    
    // Transformation (note: just ignore translation, we probably always want to be in the origin)
    scale(super.width, super.height, super.depth);
    
    pgl.beginGL();
    
    // Bind and enable our texture
    if(tex != null) {
      tex.bind();
      tex.enable();
    }
    
    // Enable vertex array and texture coordinate client states
    gl.glEnableClientState(GL.GL_VERTEX_ARRAY);
    gl.glEnableClientState(GL.GL_TEXTURE_COORD_ARRAY);
    
    // Bind our vertex data buffer and set vertex pointer
    gl.glBindBuffer(GL.GL_ARRAY_BUFFER, vboID[0]);
    gl.glVertexPointer(3, GL.GL_FLOAT, 0, 0);
    
    // Bind our texture coordinate buffer and set texcoord pointer
    gl.glBindBuffer(GL.GL_ARRAY_BUFFER, vboID[1]);
    gl.glTexCoordPointer(2, GL.GL_FLOAT, 0, 0);
    
    // Draw quad primitives
    gl.glDrawArrays(GL.GL_QUADS, 0, dataLength);
    
    // Unbind buffers
    gl.glBindBuffer(GL.GL_ARRAY_BUFFER, 0);

    // Disable our client states
    gl.glDisableClientState(GL.GL_TEXTURE_COORD_ARRAY);    
    gl.glDisableClientState(GL.GL_VERTEX_ARRAY);
    
    if(tex != null) {
      tex.disable();
    }
    
    pgl.endGL();

    popMatrix();
  }
}
