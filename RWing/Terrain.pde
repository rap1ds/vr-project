import java.util.Vector;
import javax.media.opengl.GL;
import java.nio.FloatBuffer;
import java.nio.IntBuffer;
import com.sun.opengl.util.BufferUtil;
import com.sun.opengl.util.texture.*;

public class Terrain {
  
  // Different values to play around with that affect the fractal terrain generator behavior.
  // Final results also depend on constructor parameter groundSize.
  int size = 129; // Side length for the mesh (number of iterations). NOTE: must be 2^n + 1
  float bumpiness = 75.0;  // Initial height deviation bounds.
  float roughness = 0.95f;   // Factor by which to reduce bumpiness with each iteration (between 0 and 1).
  
  int groundSize;
  
  Texture tex;
  
  int[] vboID = new int[4];
  int numElements;

  public Terrain() {
    this(15000);
  }

  public Terrain(int groundSize) {
    this.groundSize = groundSize;
    
    try {
      // Load texture
      this.tex = TextureIO.newTexture(new File(dataPath("ground2.jpg")), true);
      
      // Set wrap for texture coordinates
      this.tex.setTexParameteri(GL.GL_TEXTURE_WRAP_S, GL.GL_REPEAT);
      this.tex.setTexParameteri(GL.GL_TEXTURE_WRAP_T, GL.GL_REPEAT);
      
    } catch (IOException e) {
      println("Texture file not found.");
    }
    

    
    createAndFillVBO();
  }

  private void createAndFillVBO() {
    
    // Guesstimate for nice-looking texture resolution
    float texScale = this.groundSize / 100.0f;
    
    // Build vertex and texture coordinate data
    Vector<PVector> vData = new Vector<PVector>();
    Vector<PVector> nData = new Vector<PVector>();
    Vector<PVector> tData = new Vector<PVector>();
    Vector<Integer> iData = new Vector<Integer>();
    
    //buildFlatData(texScale, vData, nData,tData, iData);
    buildFractalData(this.size, texScale, vData, nData, tData, iData);
    
    // Save our data length
    numElements = iData.size();
    
    PGraphicsOpenGL pgl = (PGraphicsOpenGL)g;
    GL gl = pgl.gl;
    
    pgl.beginGL();
    
    // Generate VBOs
    gl.glGenBuffers(4, vboID, 0);
    
    // Bind and upload data for vertex coordinates
    gl.glBindBuffer(GL.GL_ARRAY_BUFFER, vboID[0]);
    gl.glBufferData(GL.GL_ARRAY_BUFFER, vData.size() * 3 * BufferUtil.SIZEOF_FLOAT, toFloatBuffer(vData, 3), GL.GL_STATIC_DRAW);
    
    // Bind and upload data for normals
    gl.glBindBuffer(GL.GL_ARRAY_BUFFER, vboID[1]);
    gl.glBufferData(GL.GL_ARRAY_BUFFER, nData.size() * 3 * BufferUtil.SIZEOF_FLOAT, toFloatBuffer(nData, 3), GL.GL_STATIC_DRAW);
    
    // Bind and upload data for texture coordinates
    gl.glBindBuffer(GL.GL_ARRAY_BUFFER, vboID[2]);
    gl.glBufferData(GL.GL_ARRAY_BUFFER, tData.size() * 2 * BufferUtil.SIZEOF_FLOAT, toFloatBuffer(tData, 2), GL.GL_STATIC_DRAW);
    
    // Bind element array
    gl.glBindBuffer(GL.GL_ELEMENT_ARRAY_BUFFER, vboID[3]);
    gl.glBufferData(GL.GL_ELEMENT_ARRAY_BUFFER, iData.size() * BufferUtil.SIZEOF_INT, toIntBuffer(iData), GL.GL_STATIC_DRAW);
    
    // Unbind buffer
    gl.glBindBuffer(GL.GL_ARRAY_BUFFER, 0);
    
    pgl.endGL();
  }
  
  public void draw() {
    
    pushMatrix();
    
    // Transformation (note: just ignore translation, we probably always want to be in the origin)
    translate(0, ruis.getStaticFloorY(), 0);
    scale(groundSize, 1, groundSize);
    
    PGraphicsOpenGL pgl = (PGraphicsOpenGL)g;
    GL gl = pgl.gl;
    
    pgl.beginGL();
    
    gl.glColor4f(1, 1, 1, 1);
    
    // TODO: lighting doesn't really seem to work correctly..
    /*gl.glEnable(GL.GL_LIGHTING);
    gl.glEnable(GL.GL_LIGHT1);
    gl.glTexEnvi(GL.GL_TEXTURE_ENV, GL.GL_TEXTURE_ENV_MODE, GL.GL_MODULATE);*/
    
    // Bind and enable our texture
    if(tex != null) {
      tex.bind();
      tex.enable();
    }
    
    // Enable vertex array and texture coordinate client states
    gl.glEnableClientState(GL.GL_VERTEX_ARRAY);
    gl.glEnableClientState(GL.GL_NORMAL_ARRAY);
    gl.glEnableClientState(GL.GL_TEXTURE_COORD_ARRAY);
    
    // Bind our vertex data buffer and set vertex pointer
    gl.glBindBuffer(GL.GL_ARRAY_BUFFER, vboID[0]);
    gl.glVertexPointer(3, GL.GL_FLOAT, 0, 0);
    
    // Bind our normal buffer and set normal pointer
    gl.glBindBuffer(GL.GL_ARRAY_BUFFER, vboID[1]);
    gl.glNormalPointer(GL.GL_FLOAT, 0, 0);
    
    // Bind our texture coordinate buffer and set texcoord pointer
    gl.glBindBuffer(GL.GL_ARRAY_BUFFER, vboID[2]);
    gl.glTexCoordPointer(2, GL.GL_FLOAT, 0, 0);
    
    // Bind index buffer
    gl.glBindBuffer(GL.GL_ELEMENT_ARRAY_BUFFER, vboID[3]);
    
    // Draw quad primitives
    gl.glDrawElements(GL.GL_TRIANGLES, numElements, GL.GL_UNSIGNED_INT, 0);
    
    // Unbind buffers
    gl.glBindBuffer(GL.GL_ARRAY_BUFFER, 0);

    // Disable our client states
    gl.glDisableClientState(GL.GL_TEXTURE_COORD_ARRAY);
    gl.glDisableClientState(GL.GL_NORMAL_ARRAY);
    gl.glDisableClientState(GL.GL_VERTEX_ARRAY);
    
    if(tex != null) {
      tex.disable();
    }
    
    /*gl.glTexEnvi(GL.GL_TEXTURE_ENV, GL.GL_TEXTURE_ENV_MODE, GL.GL_MODULATE);
    gl.glDisable(GL.GL_LIGHT0);
    gl.glDisable(GL.GL_LIGHTING);*/
    
    pgl.endGL();

    popMatrix();
  }
  
  private void buildFlatData(float texScale, Vector<PVector> vData, Vector<PVector> nData, Vector<PVector> tData, Vector<Integer> iData)
  {
    vData.addElement(new PVector(-1, 0, 1));
    nData.addElement(new PVector(0, 1, 0));
    tData.addElement(new PVector(0, 0));
    
    vData.addElement(new PVector(1, 0, 1));
    nData.addElement(new PVector(0, 1, 0));
    tData.addElement(new PVector(texScale, 0));
    
    vData.addElement(new PVector(1, 0, -1));
    nData.addElement(new PVector(0, 1, 0));
    tData.addElement(new PVector(texScale, texScale));
    
    vData.addElement(new PVector(-1, 0, -1));
    nData.addElement(new PVector(0, 1, 0));
    tData.addElement(new PVector(0, texScale));
    
    iData.addAll(Arrays.asList(new Integer[] { 0,1,2, 0,2,3 }));
  }
  
  private void buildFractalData(int size, float texScale, Vector<PVector> vData, Vector<PVector> nData, Vector<PVector> tData, Vector<Integer> iData)
  {
    vData.clear();
    nData.clear();
    tData.clear();
    iData.clear();
    
    float dx = 1.0f/size;
    float dz = 1.0f/size;
    
    // intialize data
    float data[] = new float[size*size];
    
    for (int i = 0; i < size; i++)
      for (int j = 0; j < size; j++)
        data[j*size+i] = 0.0f;
        
    // random offset bounds
    float h = this.bumpiness;
    float f = this.roughness;

    // Generate height values by Square Diamond algorithm (based on Daniel Beard's implementation)
    for (int sideLength = size-1; sideLength >= 2; sideLength /= 2, h *= f)	{
    
      int halfSide = sideLength/2;
      
      //generate new square values
      for (int x = 0; x < size-1; x += sideLength) {
        for (int y = 0; y < size-1; y += sideLength) {
        
          // Calculate average of 4 corners
          float avg = (data[y*size + x] +
            data[y*size + x+sideLength]	+
            data[(y+sideLength)*size + x] +
            data[(y+sideLength)*size + x+sideLength]) / 4;
          
          // Set center location as average + random offset
          float offset = random(-h, h);
          data[(y+halfSide)*size + x+halfSide] = avg + offset;
        }
      }
      
      // Generate the diamond values
      for (int x = 0; x < size-1; x += halfSide) {
        for (int y = (x+halfSide) % sideLength; y < size-1; y += sideLength) {

          // Calculate average for diamond
          float avg = (data[y*size + (x-halfSide+size) % size] +
            data[y*size + (x+halfSide) % size] +
            data[((y+halfSide) % size)*size + x] +
            data[((y-halfSide+size) % size)*size + x]) / 4;

          // random offset for average value
          float offset = random(-h, h);
          float value = avg + offset;

          // Set value for diamond center
          data[y*size + x] = value;

          // Wrap around
          if (x == 0)
            data[y*size + size-1] = value;
          if (y == 0)
            data[(size-1)*size + x] = value;
        }
      }
    }
    
    // Generate vertices and indices based on height map
    for (int j = 0; j < size; j++)
    {
      for (int i = 0; i < size; i++)
      {
        // calculate vertex coordinates
        float x = i*dx-0.5f;
        float z = j*dz-0.5f;
        float y = data[j*size + i];

        PVector position = new PVector(x, y, z);
        PVector normal = new PVector(0, 1, 0);
        PVector texCoord = new PVector(x * texScale, z * texScale);

        if (i < size-1 && j < size-1)
        {
          // Calculate normal
          PVector v1 = new PVector(x, y, z);
          PVector v2 = new PVector(i*dx, data[(j+1)*size + i], (j+1)*dz);
          PVector v3 = new PVector((i+1)*dx, data[j*size + (i+1)], j*dz);

          normal = PVector.sub(v2, v1).cross(PVector.sub(v3, v1));
          normal.normalize();

          // set indices for CCW winding order
          iData.addElement(j*size + i);
          iData.addElement((j+1)*size + i);
          iData.addElement(j*size + (i+1));

          iData.addElement(j*size + (i+1));
          iData.addElement((j+1)*size + i);
          iData.addElement((j+1)*size + (i+1));
        }

        vData.addElement(position);
        tData.addElement(texCoord);
        nData.addElement(normal);
      }
    }
  }
}

FloatBuffer toFloatBuffer(Vector<PVector> data, int n)
{
  FloatBuffer a  = BufferUtil.newFloatBuffer(data.size() * n);
 
  for (int i = 0; i < data.size(); i++)
  {
    PVector v = data.elementAt(i);
    if(n >= 1) a.put(v.x);
    if(n >= 2) a.put(v.y);
    if(n >= 3) a.put(v.z);
    //if(n >= 4) a.put(v.w); // PVEctor only contains 3 elements
  }
  a.rewind();
  return a;
}

IntBuffer toIntBuffer(Vector<Integer> data)
{
  IntBuffer a = BufferUtil.newIntBuffer(data.size());
  
  for (int i = 0; i < data.size(); i++)
  {
    a.put(data.elementAt(i));
  }
  a.rewind();
  return a;
}
