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

PVector incrementalMove = new PVector(0, 0, 0);

// This function is called only once in the setup() function
public void mySetup()
{ 
  viewManager.setDisplayGridDraw(false);

  playerX = viewManager.getHeadX();
  playerY = viewManager.getHeadY();
  playerZ = viewManager.getHeadZ();

  lookAtX = viewManager.display[0].displayCenter.x;
  lookAtY = viewManager.display[0].displayCenter.y;
  lookAtZ = viewManager.display[0].displayCenter.z;

  // Add a selectable, green switch on the view HUD, which can be interacted
  // with, but is not affected by physics
  float switchLenght = 0.15f*viewManager.display[0].getDisplayHeight();

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
  wiimote[0].x = viewManager.display[0].displayCenter.x;   // also wiimote0
  wiimote[0].y = viewManager.display[0].displayCenter.y;
  wiimote[0].z = viewManager.display[0].displayCenter.z;
  //skewand[0] == skewand0 etc.
  // psmove[3] == psmove3
  if (wand3 != null)
  {
    wand3.x = viewManager.display[0].displayCenter.x 
      - 0.3f*viewManager.display[0].getDisplayWidth();
    wand3.y = viewManager.display[0].displayCenter.y
      - 0.3f*viewManager.display[0].getDisplayHeight();
    wand3.z = viewManager.display[0].displayCenter.z;
  }
  
  Ground ground = new Ground();
  ruis.addObject(ground);
  
  Sky sky = new Sky();
  ruis.addObject(sky);
}

// This method is called for each view in the draw() loop.
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

  // Lights
  lightSetup();

  ruis.drawWands(1.f);
  ruis.drawSelectables();
  ruis.drawPlainObjects();
  ruis.drawSelectionRanges(); // Only if selection button is pressed

  // Draw frames around the walls in world coordinates
  viewManager.drawWallFrames();

  // Draw kinect skeletons if they are detected
  pushMatrix();
  skeletonManager.drawSkeletons(true, true, true);
  popMatrix();

  // Draw a yellow cross at the location where the camera points at
  pushMatrix();
  noStroke();
  translate(lookAtX, lookAtY, lookAtZ);
  fill(255, 255, 0);
  box(4);
  box(2, 10, 2);
  popMatrix();

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
  float boxWidth = 0.1f*viewManager.display[0].getDisplayWidth();
  box(boxWidth, 0.2f*boxWidth, 0.2f*boxWidth);
  popMatrix();

  pushMatrix();

  // If you just want to draw graphics on the HUD that are not
  // represented as PhysicalOjects, then it's more simple
  // to negate both the rotation AND translation of RUIScamera 
  // transformation and draw items where the display screens are
  inverseCameraTransform();

  // Draw a yellow box fixed in view HUD, near top right corner
  pushMatrix();
  translate(viewManager.display[0].displayCenter.x
    + 0.4f*viewManager.display[0].getDisplayWidth(), 
  viewManager.display[0].displayCenter.y
    - 0.4f*viewManager.display[0].getDisplayHeight(), 
  viewManager.display[0].displayCenter.z                );
  fill(255, 255, 0);
  box(0.2f*boxWidth, boxWidth, 0.2f*boxWidth);
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

  if (imageOverlay != null) {
    hint(DISABLE_DEPTH_TEST);
    imageMode(CENTER);
    image(imageOverlay, 0, 0);
  }

  relativeScreenX = 0.8f;
  relativeScreenY = 0.95f;

  // Draws edge lines of all RigidBodies. Should only be used for 
  // debugging physics, because this function uses slow drawing methods
  //ruis.drawRigidBodyEdges(RUIS.myWorld);
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
  ruisCamera( playerX, playerY, playerZ, lookAtX, lookAtY, lookAtZ, 0f, 1f, 0f);
  // In the above example the camera can get seemingly stuck in north and south
  // poles of the lookAt point. Use an interactive up vector to avoid that.

  // A simple first person point of view controlling scheme (uncomment to test)
  //ruisCameraLocation(playerX, playerY, playerZ); // wasd-keys
  //ruisCameraRotation(playerYaw, playerPitch, playerRoll); // z,x,c,v,b,n keys

  // This is how you can match camera rotation to wand's rotation
  //ruisCameraRotation(wand[0].yaw, wand[0].pitch, wand[0].roll); 

  // Rotate the camera automatically around a circle path
  //float theta = millis()*0.0003f; 
  //float radius = 2*viewManager.display[0].getDisplayWidth();
  //ruisCamera(viewManager.display[0].displayCenter.x + radius*sin(theta),
  //           viewManager.display[0].displayCenter.y, 
  //           viewManager.display[0].displayCenter.z - radius*cos(theta), 
  //           lookAtX, lookAtY, lookAtZ, 0, 1, 0                         ); 

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
    incrementalMove.add(viewManager.getCameraUp());

  float moveSpeed = 5;
  playerX += moveSpeed*incrementalMove.x;
  playerY += moveSpeed*incrementalMove.y;
  playerZ += moveSpeed*incrementalMove.z;

  // If wand0 is a mouse, you can simulate the 3-axis rotation
  if (wand0 instanceof MouseWand)
   wand[0].simulateRotation(1.5f);

  // Below lines affect only the Kinect tracked skeleton
  // Below makes skeleton0's location and rotation invariant of ruisCamera(),
  // and pushes the skeleton0 700 cm in front of the camera
  skeleton0.setWorldTranslationOffset(
  PVector.add(viewManager.getCameraLocation(), 
  PVector.mult(viewManager.getCameraForward(), 700)));
  PMatrix3D cameraRotation = new PMatrix3D();
  cameraRotation.rotateY( viewManager.getRUIScamRotX());
  cameraRotation.rotateX( viewManager.getRUIScamRotY());
  cameraRotation.rotateZ(-viewManager.getRUIScamRotZ());
  skeleton0.setWorldRotationOffset(cameraRotation);
}

// Keyboard user interface
public void keyPressed()
{ 
  // Location control for wand3 which is simulated with keyboard
  if (key == CODED && wand3 != null)
  {
    if (keyCode == LEFT ) wand3.x -= 0.6; 
    if (keyCode == RIGHT) wand3.x += 0.6;     
    if (keyCode == UP   ) wand3.y -= 0.6; 
    if (keyCode == DOWN ) wand3.y += 0.6;
  }

  // Rotational control for camera
  if (key=='z') playerYaw   -= 0.02;
  if (key=='x') playerYaw   += 0.02;
  if (key=='b') playerPitch += 0.02;
  if (key=='n') playerPitch -= 0.02;
  if (key=='c') playerRoll  -= 0.02;
  if (key=='v') playerRoll  += 0.02;

  if (key == 'j') lookAtX -= 5;
  if (key == 'l') lookAtX += 5;
  if (key == 'o') lookAtY -= 5;
  if (key == 'u') lookAtY += 5;
  if (key == 'i') lookAtZ -= 5;
  if (key == 'k') lookAtZ += 5;

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

public void mousePressed() {
  if (imageOverlay != null) imageOverlay = null;
}

public void lightSetup()
{
  noLights();
  pushMatrix();

  lightSpecular(255, 255, 255);

  // White point light near the ruisCamera location
  pointLight(255, 255, 255, 
  viewManager.getCameraLocation().x 
    - 100*viewManager.getCameraForward().x, 
  viewManager.getCameraLocation().y 
    - 0.3f*viewManager.display[0].getDisplayHeight(), 
  viewManager.getCameraLocation().z 
    - 100*viewManager.getCameraForward().z );
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

public void scaleImageOverlay() {
  double screenAspectRatio = viewManager.display[0].getDisplayWidth() /
          viewManager.display[0].getDisplayHeight();
  double imageAspectRatio = imageOverlay.width / imageOverlay.height;
  if (screenAspectRatio > imageAspectRatio) {
    imageOverlay.resize(0, (int)viewManager.display[0].getDisplayHeight());
  } else {
    imageOverlay.resize((int)viewManager.display[0].getDisplayWidth(), 0);
  }
}
