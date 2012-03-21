public Wand[]             wand;
public PSMoveWand[]     psmove;
public WiimoteWand[]   wiimote;
public SkeletonWand[]  skewand;
public RuisSkeleton[] skeleton;
public Wand wand0, wand1, wand2, wand3,  wand4,  wand5, 
            wand6, wand7, wand8, wand9, wand10, wand11;
public PSMoveWand    psmove0,  psmove1,  psmove2,  psmove3;
public WiimoteWand  wiimote0, wiimote1, wiimote2, wiimote3;
public SkeletonWand skewand0, skewand1, skewand2, skewand3;
public RuisSkeleton skeleton0, skeleton1, skeleton2, skeleton3;
public RuisSkeletonManager skeletonManager;

/**
 * Maps a point on a view plane into X location in world coordinate system. 
 * The HUDx and HUDy arguments are relative view HUD locations, and in most 
 * cases they should be between 0.0 and 1.0 (origin is at upper left corner 
 * of of the view. Argument viewID identifies the view
 */
public float screen2WorldX(float HUDx, float HUDy, int viewID)
{
  return viewManager.screen2WorldX(HUDx, HUDy, 0, viewID);
}

/**
 * Maps a point on a view plane into Y location in world coordinate system. 
 * The HUDx and HUDy arguments are relative view HUD locations, and in most 
 * cases they should be between 0.0 and 1.0 (origin is at upper left corner 
 * of of the view. Argument viewID identifies the view
 */
public float screen2WorldY(float HUDx, float HUDy, int viewID)
{
  return viewManager.screen2WorldY(HUDx, HUDy, 0, viewID);
}

/**
 * Maps a point on a view plane into Z location in world coordinate system. 
 * The HUDx and HUDy arguments are relative view HUD locations, and in most 
 * cases they should be between 0.0 and 1.0 (origin is at upper left corner 
 * of of the view. Argument viewID identifies the view
 */
public float screen2WorldZ(float HUDx, float HUDy, int viewID)
{
  return viewManager.screen2WorldZ(HUDx, HUDy, 0, viewID);
}

/**
 *  Use rcamera() function instead of camera(). This function behaves 
 *  seemingly identically to Processing's camera() function and accepts the
 *  same arguments. 
 */
public void ruisCamera(float camX, float camY, float camZ,
                    float lookAtX, float lookAtY, float lookAtZ,
                    float upX, float upY, float upZ            )
{
  viewManager.ruisCamera( camX, camY, camZ, lookAtX, lookAtY, lookAtZ, 
                          upX, upY, upZ                               );
}

/** 
 * Reset RUIS' rcamera, works like camera() function.
 */
public void ruisCamera()
{
  viewManager.ruisCamera();
}

/**
 *  Modify ruisCamera's X, Y, and Z coordinates but not its rotation 
 */
public void ruisCameraLocation(float x, float y, float z) 
{
  viewManager.ruisCameraLocation(x, y, z);
}

/**
 *  Modify RUIScamera's rotation but not its location 
 */
void ruisCameraRotation(float rotX, float rotY, float rotZ) 
{
  viewManager.ruisCameraRotation(rotX, rotY, rotZ);
}

/**
 * Apply a modelview transformation that negates the rotation of camera*()
 * functions and RUIScamRotX/Y/Z
 */
public void inverseCameraRotation()
{
  viewManager.inverseCameraRotation();
}

/**
 * Apply a modelview transformation that negates the translation and rotation
 * of camera*() functions and RUIScamRotX/Y/Z
 */
public void inverseCameraTransform()
{
  viewManager.inverseCameraTransform();
}

/**
 * Returns PVector that stores the rcamera's forward direction in world
 * coordinates.
 */
public PVector getCameraForward()
{
  return viewManager.getCameraForward();
}

/**
 * Returns PVector that stores the rcamera's right direction in world
 * coordinates.
 */
public PVector getCameraRight()
{
  return viewManager.getCameraRight();
}

/**
 * Returns PVector that stores the rcamera's up direction in world
 * coordinates.
 */
public PVector getCameraUp()
{
  return viewManager.getCameraUp();
}

 /**
 *   Creates global RUIS shortcuts that ease the programming.
 *   The RUIS, viewManager, or/and inputManager must all have public 
 *   modifier in front of them (i.e. public ViewManager viewManager;) for 
 *   this function to create the respective shortcuts.
 */
public void createShortcuts()
	{
	  Field fields[] = this.getClass().getFields();
  for(int i=0; i<fields.length; ++i)
  {
    if(fields[i] != null && fields[i].getType() != null)
	    {
	      if(fields[i].getType().getSimpleName().equals("InputManager"))
	      {
        // wand, psmove, skewand, and wiimote shortcuts
	        for(int j=0; j<fields.length; ++j)
	        {
	          if(fields[j] != null && fields[j].getType() != null)
	          {
	            String typeName = fields[j].getType().getSimpleName();
	            if(   typeName.equals("Wand[]")
	               || typeName.equals("PSMoveWand[]")
	               || typeName.equals("WiimoteWand[]")
	               || typeName.equals("SkeletonWand[]")
               || typeName.equals("Skeleton[]")
               || typeName.equals("RuisSkeletonManager"))
	            {
	              attemptSubstitution(fields[i], typeName);
	            }
	            else
	            {
              String fieldName = fields[j].getName();
	              for(int k=0; k<12; ++k)
	              {
	                if(fieldName.equals(("wand" +k)))
	                  attemptSubstitution(fields[i], "wand" + k);
	                else
	                if(k<4)
	                {
                    if(   fieldName.equals(("psmove"   + k))
                       || fieldName.equals(("skewand"  + k))
                       || fieldName.equals(("wiimote"  + k))
                       || fieldName.equals(("skeleton" + k)))
                    {
                      attemptSubstitution(fields[i], fieldName);
                    }
	                }
	              }
	            }
	          }
	        }
	      }
	      else if(fields[i].getType().getSimpleName().equals("ViewManager"))
	      {
	        
	      }
      else if(fields[i].getType().getSimpleName().equals("RUIS"))
      {
        for(int j=0; j<fields.length; ++j)
        {
          if(fields[j] != null && fields[j].getType() != null)
          {

          }
        }
        
      }
    }
  }
}

public void attemptSubstitution(Field field, String arglist)
{
  try 
  {
    Class cls = field.getType();
    Class partypes[] = new Class[1];
    partypes[0] = String.class;
    Method meth = cls.getMethod( "assignShortcuts", partypes);
    Object obj = null;
    try
    {
      obj = field.get(this);
      meth.invoke(cls.cast(obj), arglist);
    }
    catch (ClassCastException e1) 
    {
      System.err.println(e1);
    }
  }
  catch (Throwable e2) 
  {
     System.err.println(e2);
  }
}

