/* The application logic is here */

// Your global variables:
float playerX =  0;
float playerY =  0;
float playerZ =  0;
float lookAtX = 0;
float lookAtY = 0;
float lookAtZ = 0;
float playerYaw   = 0;
float playerPitch = 0;
float playerRoll  = 0;
float upX = 0;
float upY = 1;
float upZ = 0;

PVector incrementalMove = new PVector(0, 0, 0);

boolean useKeyboard = false;

Plane plane;
RaceLine raceLine;

Camera followCamera;

// This function is called only once in the setup() function
public void mySetup()
{
  viewManager.setDisplayGridDraw(false);

  playerX = viewManager.getHeadX();
  playerY = viewManager.getHeadY();
  playerZ = viewManager.getHeadZ();

  lookAtX = display[0].center.x;
  lookAtY = display[0].center.y;
  lookAtZ = display[0].center.z;

  // Add a selectable, green switch on the view HUD, which can be interacted
  // with, but is not affected by physics
  float switchLenght = 0.15*display[0].getHeight();

  PhysicalObject switchObj =
    new PhysicalObject(switchLenght, switchLenght, switchLenght,
  0 /* mass */, 0 /* locX */, 0 /* locY */,
  0 /* locZ */, color(0, 255, 55),
  PhysicalObject.IMMATERIAL_OBJECT         );

  float screenRelativeX = 0.1f;
  float screenRelativeY = 0.9f;
  // SelectableSwitch contains interaction behavior, see its definition in
  // MyObjects.pde
  SelectableSwitch selSwitch = new SelectableSwitch(switchObj,
  screenRelativeX,
  screenRelativeY );
  ruis.addObject(selSwitch);

  // Here are some different ways to access different wands (controllers)
  // Setting initial locations
  wiimote[0].x = display[0].center.x;   // also wiimote0
  wiimote[0].y = display[0].center.y + 0.2*display[0].getHeight();
  wiimote[0].z = display[0].center.z;
  //skewand[0] == skewand0
  // psmove[3] == psmove3  etc.
  if (wand2 != null)
  {
    wand2.x = display[0].center.x - 0.3*display[0].getWidth();
    wand2.y = display[0].center.y - 0.3*display[0].getHeight();
    wand2.z = display[0].center.z;
  }

  Ground ground = new Ground();
  ruis.addObject(ground);

  Sky sky = new Sky();
  ruis.addObject(sky);

  plane = new Plane(this, "biplane.3DS");
  
  raceLine = new RaceLine();
  raceLine.setup();

  followCamera = new Camera(plane, new PVector(0.0f, -25.0f, -300.0f));
}

// This function is called for each view in the draw() loop.
// Place only drawing function calls here, and NO interaction code!
public void myDraw(int viewID)
{
  // Insert your draw code here

  // In order to keep ruisCamera() view and/or keystone correction intact,

  // use only drawing and camera matrix altering functions like pushMatrix(),
  // translate(), rotateX/Y/Z(), scale(), applyMatrix(), box(), sphere() etc.
  // DO NOT use projection matrix altering functions like perspective(),
  // camera(), resetMatrix(), frustum(), beginCamera(), etc.

  // There are functions like ruisCamera() and others that change the
  // point of view in RUIS, but they have to be invoked in myInteraction()
  // function. See examples there.

  followCamera.update();

  // Lights
  lightSetup();

  ruis.drawWands(1.f);
  ruis.drawSelectables();
  ruis.drawPlainObjects();
  ruis.drawSelectionRanges(); // Only if selection button is pressed

  // Draw frames around the walls in world coordinates
  viewManager.drawWallFrames();

  plane.draw();
  raceLine.draw();

  // You can get world coordinates from any (x,y) point on the display
  // screen using screen2WorldX/Y/Z method. This is useful when drawing
  // HUD graphics.
  pushMatrix();
  float relativeScreenX = 0.1f;
  float relativeScreenY = 0.1f;
  int displayID = 0;
  translate(screen2WorldX(relativeScreenX, relativeScreenY, displayID),
  screen2WorldY(relativeScreenX, relativeScreenY, displayID),
  screen2WorldZ(relativeScreenX, relativeScreenY, displayID) );
  // The RUIScamera rotation needs to be negated so that the HUD
  // object keeps facing the viewport
  inverseCameraRotation();
  fill(255, 0, 255); // Magenta box
  float boxWidth = 0.1*display[0].getWidth();
  box(boxWidth, 0.2*boxWidth, 0.2*boxWidth);
  popMatrix();

  pushMatrix();

  // If you just want to draw graphics on the HUD that are not
  // represented as PhysicalOjects, then it's more simple
  // to negate both the rotation AND translation of RUIScamera
  // transformation and draw items where the display screens are
  inverseCameraTransform();

  // Draw a yellow box fixed in view HUD, near top right corner
  pushMatrix();
  translate(display[0].center.x + 0.4*display[0].getWidth(),
            display[0].center.y - 0.4*display[0].getHeight(),
            display[0].center.z                               );
  fill(255, 255, 0);
  box(0.2*boxWidth, boxWidth, 0.2*boxWidth);
  popMatrix();

  // Example: Draw a wireframe box in front and above of the wand0
  noFill();
  stroke(255);
  pushMatrix();
  translate(wand0.x,
  wand0.y - 3, // Translate above
  wand0.z - 3    ); // Translate in front
  wand0.applyRotation();
  box(2);
  popMatrix();

  popMatrix();

  relativeScreenX = 0.8f;
  relativeScreenY = 0.95f;

  // Two examples below demonstrate how Kinect data points can be manipulated
  pushMatrix();
  // Shrink the skeleton if Kinect is used (not just graphical scale, this
  // scales all data points of skeleton)
  skeleton0.setScale(0.3*display[0].getHeight()/200);
  // Draw all Kinect skeletons in their individual local coordinate systems
  skeletonManager.drawSkeletons(  RuisSkeleton.DRAW_BONES
    + RuisSkeleton.LOCAL_COORDINATES);


  // setScale of Skeleton affects both local and world coordinate systems,
  // so lets return the tracked skeleton to it's normal centimeter scale
  skeleton0.setScale(1.0f);
  // Draw all Kinect skeletons in their individual world coordinate systems
  skeletonManager.drawSkeletons(  RuisSkeleton.DRAW_BONES
    + RuisSkeleton.DRAW_DIRECTIONS
    + RuisSkeleton.DRAW_JOINTS
    );
  popMatrix();

  // Draws edge lines of all RigidBodies. Should only be used for
  // debugging physics, because this function uses slow drawing methods
  //ruis.drawRigidBodyEdges(RUIS.myWorld);

  stroke(color(255, 0, 0));
  line(wand[0].x, wand[0].y, wand[0].z, wand[2].x, wand[2].y, wand[2].z);
  noStroke();
}

// This function is called only once in the draw() loop
public void myInteraction()
{
  // Insert your interaction code here

  // Head-tracking increases immersion and is useful for understanding the scale
  // of virtual objects. When physical limits of virtual environment setup are
  // reached (no more room to walk etc.), ruisCamera() methods can be used
  // to navigate through the virtual space. Combining camera controls to wand
  // buttons is a common approach.

  // Use ruisCamera() method instead of camera(). ruisCamera() accepts the
  // same arguments and behaves seemingly identically to camera() function.
  // Example: \     Camera center      /  \    Point to look at    /  \  Up /
  ruisCamera( playerX, playerY, playerZ, lookAtX, lookAtY, lookAtZ, upX, upY, upZ);
  // In the above example the camera can get seemingly stuck in north and south
  // poles of the lookAt point. Use an interactive up vector to avoid that.

  // A simple first person point of view controlling scheme (uncomment to test)
  //setCameraLocation(playerX, playerY, playerZ); // wasd-keys
  //setCameraRotation(playerYaw, playerPitch, playerRoll); // z,x,c,v,b,n keys

  // This is how you can match camera rotation to wand's rotation
  //setCameraRotation(wand[0].yaw, wand[0].pitch, wand[0].roll);

  // Rotate the camera automatically around a circle path
  //float theta = millis()*0.0003f;
  //float radius = 2*display[0].getWidth();
  //ruisCamera(display[0].displayCenter.x + radius*sin(theta),
  //           display[0].displayCenter.y,
  //           display[0].displayCenter.z - radius*cos(theta),
  //           lookAtX, lookAtY, lookAtZ, 0, 1, 0                         );

if (true) {
  
  /*
   * This is a naive implementation which assumes that the user is standing face towards the screen
   * It's naive because we're doing x and y comparisons.
   */
  
  Wand leftWand = wand[2];
  Wand rightWand = wand[0];

  leftWand.x = 0;
  leftWand.y = 0;

  leftWand.z = rightWand.z;

  PVector wands = new PVector(rightWand.x, rightWand.y, rightWand.z);
  wands.sub(new PVector(leftWand.x, leftWand.y, leftWand.z));
  wands.normalize();

  PVector wandsWithoutY = new PVector(wands.x, 0, wands.z);
  wandsWithoutY.normalize();

  float angle = wands.dot(wandsWithoutY);
  angle = acos(angle);
  
  // "Yksikkoympyra" Parts I, II, III and IV (counter-clockwise)
  boolean partsIIIorIV = rightWand.y > leftWand.y;
  boolean partsIIorIII = rightWand.x < leftWand.x;
  if(partsIIIorIV) {
    if(partsIIorIII) {
      angle = PI + angle;
      // print("Part III, angle: " + angle);
    } else {
      angle = TWO_PI - angle;
      // print("Part IV, angle: " + angle);    
    }
    
  } else {
    if(partsIIorIII) {
      angle = PI - angle;
      // print("Part II, angle: " + angle);   
    } else {
      // print("Part I, angle: " + angle);
    }
  }
  
  /*
   * There's a discountinuity when moving from angle 1 degree to angle 359 degree. 
   * The plane is rotated 358 degrees, not 2 degrees. The following moves this discontinuity
   * between the parts II and III because it is very distractive if the discontinuity point is
   * between I and IV 
   */
  /*
  if(angle > PI) {
    angle -= TWO_PI;
  }
  */
  if(!useKeyboard)
    plane.setEuler(angle, wand[0].pitch);
  //println(angle + "    " + wand[0].pitch);
}

  // Control camera (player) location with aswd-keys or wand0
  incrementalMove.set(0, 0, 0);
  if ( wand[0].buttonO      || (keyPressed && key == 's' ))
    incrementalMove.sub(getCameraForward());
  if ( wand[0].buttonT      || (keyPressed && key == 'w' ))
    incrementalMove.add(getCameraForward());
  if ( wand[0].buttonSelect || (keyPressed && key == 'a' ))
    incrementalMove.sub(getCameraRight());
  if ( wand[0].buttonStart  || (keyPressed && key == 'd' ))
    incrementalMove.add(getCameraRight());
  if ( wand[0].buttonHome   || (keyPressed && key == 'q' ))
    incrementalMove.sub(getCameraUp());
  if ( wand[0].buttonMove   || (keyPressed && key == 'e' ))
    incrementalMove.add(getCameraUp());
  if (keyPressed && key == 'p')
    wand[0].pitch = 1.0f;

  float moveSpeed = 5;
  // playerX += moveSpeed*incrementalMove.x;
  // playerY += moveSpeed*incrementalMove.y;
  // playerZ += moveSpeed*incrementalMove.z;

  // If wand0 is a mouse, you can simulate the 3-axis rotation
  /*if (wand0 instanceof MouseWand)
    wand[0].simulateRotation(1.5f);
  */


  // Set the tiny skeleton to lower left corner of the display
  skeleton0.setLocalTranslateOffset(new PVector(-.2*display[0].getWidth(),
                                                .8*ruis.getStaticFloorY(), 0));
  // WorldTranslateOffset is not affected by LocalTranslateOffset
  skeleton0.setWorldTranslateOffset(new PVector(0, 0, 10));
}

// Keyboard user interface
public void keyPressed()
{
  // Location control for wand3 which is simulated with keyboard
  /*if (key == CODED && wand3 != null)
   {
   if (keyCode == LEFT ) wand3.x -= 0.6;
   if (keyCode == RIGHT) wand3.x += 0.6;
   if (keyCode == UP   ) wand3.y -= 0.6;
   if (keyCode == DOWN ) wand3.y += 0.6;
   }*/

  if (keyCode == LEFT ) plane.roll(0.05);
  if (keyCode == RIGHT) plane.roll(-0.05);
  if (keyCode == UP   ) plane.pitch(-0.05);
  if (keyCode == DOWN ) plane.pitch(0.05);


  // Rotational control for camera
  if (key=='z') playerYaw   -= 0.08;
  if (key=='x') playerYaw   += 0.08;
  if (key=='b') playerPitch += 0.08;
  if (key=='n') playerPitch -= 0.08;
  if (key=='c') playerRoll  -= 0.08;
  if (key=='v') playerRoll  += 0.08;

  if (key == 'j') lookAtX -= 30;
  if (key == 'l') lookAtX += 30;
  if (key == 'o') lookAtY -= 30;
  if (key == 'u') lookAtY += 30;
  if (key == 'i') lookAtZ -= 30;
  if (key == 'k') lookAtZ += 30;

  // Simulate head tracking with keyboard. Notice the view distortion.
  if (key == 'f') viewManager.incThreadedHeadX(-5);
  if (key == 'h') viewManager.incThreadedHeadX(5);
  if (key == 'y') viewManager.incThreadedHeadY(-5);
  if (key == 'r') viewManager.incThreadedHeadY(5);
  if (key == 't') viewManager.incThreadedHeadZ(-5);
  if (key == 'g') viewManager.incThreadedHeadZ(5);

  // Enter/leave keystone calibration mode, where surfaces can be warped &
  // moved
  if (key == 'K')
    viewManager.keystoneCalibrationModeSwitch();

  if (key == ' ')
  {
    if (viewManager.isCalibrating())
    {
      // Save current view's keystones and move on to calibrate next
      viewManager.saveKeystones();
      viewManager.keystoneCalibrationViewSwitch();
    }
  }
}

public void mouseDragged()
{
  viewManager.dragKeystone();
}

public void mouseReleased()
{
  viewManager.setKeystoneSelected(false);
}

public void lightSetup()
{
  noLights();
  pushMatrix();

  lightSpecular(255, 255, 255);

  // White point light near the point of view (ruisCamera)
  pointLight(255, 255, 255,
             getCameraLocation().x - 100*getCameraForward().x,
             getCameraLocation().y - 0.3*display[0].getHeight(),
             getCameraLocation().z - 100*getCameraForward().z    );
  lightSpecular(0, 0, 0);

  pointLight(110, 110, 110, // All gray
  -600, 0, -600); // Position
  pointLight(110, 110, 110, // All gray
  900, 1800, 0); // Position
  popMatrix();
}

// Below are all the SimpleOpenNI's callback methods
public void onNewUser(int userId)
{
  print("onNewUser - userId: " + userId);
  println(".  Start pose detection");

  // startPoseDetection() requires users to make an 'X' pose in order to get
  // detected, whereas requestCalibrationSkeleton() starts detecting the user
  // as soon as he enters Kinect's view
  //inputManager.ni.startPoseDetection("Psi",userId);
  inputManager.ni.requestCalibrationSkeleton(userId, true);
}

public void onLostUser(int userId)
{
  println("onLostUser - userId: " + userId);
}

public void onStartCalibration(int userId)
{
  println("onStartCalibration - userId: " + userId);
}

public void onEndCalibration(int userId, boolean successfull)
{
  if (successfull)
  {
    println("  User calibrated !!!");
    inputManager.ni.startTrackingSkeleton(userId);
  }
  else
  {
    inputManager.ni.startPoseDetection("Psi", userId);
  }
}

public void onStartPose(String pose, int userId)
{
  print("onStartdPose - userId: " + userId + ", pose: " + pose);
  println(".  Stop pose detection");

  inputManager.ni.stopPoseDetection(userId);
  inputManager.ni.requestCalibrationSkeleton(userId, true);
}

