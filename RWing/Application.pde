/* The application logic is here */

boolean useKeyboard = true;

Minim minim;

Plane plane;
RaceLine raceLine;
Camera camera;
Timer timer;
Countdown countdown;

// This function is called only once in the setup() function
public void mySetup()
{
  viewManager.setDisplayGridDraw(false);
  
  minim = new Minim(this);

  ruis.addObject(new Terrain());
  ruis.addObject(new Sky());

  plane = new Plane(this, "biplane.3DS");

  raceLine = new RaceLine();
  raceLine.setup();

  camera = new Camera(plane, new PVector(0.0f, -25.0f, -300.0f));
  timer = new Timer();
  countdown = new Countdown();

  camera.location.set(viewManager.getHeadX(), viewManager.getHeadY(), viewManager.getHeadZ());
  camera.target.set(display[0].center.x, display[0].center.y, display[0].center.z);
}

// This function is called for each view in the draw() loop.
// Place only drawing function calls here, and NO interaction code!
public void myDraw(int viewID)
{ 
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

  pushMatrix();

  // If you just want to draw graphics on the HUD that are not
  // represented as PhysicalOjects, then it's more simple
  // to negate both the rotation AND translation of RUIScamera
  // transformation and draw items where the display screens are
  inverseCameraTransform();

  // Example: Draw a wireframe box in front and above of the wand0
  noFill();
  stroke(255);

  pushMatrix();
  translate(wand0.x, wand0.y, wand0.z - 1);
  wand0.applyRotation();
  box(2);
  popMatrix();

  if (wand2 != null) {
    pushMatrix();
    translate(wand2.x, wand2.y, wand2.z - 1);
    wand2.applyRotation();
    box(2);
    popMatrix();
  }

  popMatrix();

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

  stroke(color(255, 0, 0));
  line(wand[0].x, wand[0].y, wand[0].z, wand[2].x, wand[2].y, wand[2].z);
  noStroke();

  hint(DISABLE_DEPTH_TEST);
  viewManager.renderText(timer.formattedTime(), 0.1, 0.1, color(200, 255, 100), 2, viewID);
  viewManager.renderText(plane.getThrust(), 0.7, 0.05, color(200, 255, 100), 1.5, viewID);

  if (countdown.isDone() == false) {

    float relX;

    if (countdown.isStarted() == false) {
      relX = 0.28; // Ready to start?
    } 
    else if (countdown.isFinished() == false) {
      relX = 0.48; // 3, 2, 1
    } 
    else {
      relX = 0.45; // Go!
    }

    viewManager.renderText(countdown.getCountdown(), relX, 0.5, color(200, 255, 100), 2, viewID);
  }

  if (countdown.isFinishedOnce()) {
    timer.start();
    plane.startEngine();
  }

  hint(ENABLE_DEPTH_TEST);
}

// This function is called only once in the draw() loop
public void myInteraction()
{
  // Head-tracking increases immersion and is useful for understanding the scale
  // of virtual objects. When physical limits of virtual environment setup are
  // reached (no more room to walk etc.), ruisCamera() methods can be used
  // to navigate through the virtual space. Combining camera controls to wand
  // buttons is a common approach.

  camera.update();

  ruisCamera(camera.location.x, camera.location.y, camera.location.z, 
  camera.target.x, camera.target.y, camera.target.z, 
  camera.up.x, camera.up.y, camera.up.z);

  Wand leftWand = wand[0];
  Wand rightWand = wand[2];

  // uncomment for mouse dev testing
  /*
  leftWand.x = 0;
   leftWand.y = 0;
   leftWand.z = rightWand.z;
   */

  PVector wandDiff = new PVector(rightWand.x - leftWand.x, 
  0, 
  rightWand.z - leftWand.z);

  float a = rightWand.y - leftWand.y;
  float b = wandDiff.mag();

  float angle = atan2(a, b);

  // account for going over 90'
  if (wandDiff.x > 0) angle = -angle;

  if (!useKeyboard)
    plane.setEuler(angle, wand[0].pitch);

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
  if (useKeyboard && countdown.isFinished()) {

    if (wand3 != null) {
      if (key == 'a') wand3.x -= 0.6;
      if (key == 'd') wand3.x += 0.6;
      if (key == 'w') wand3.y -= 0.6;
      if (key == 's') wand3.y += 0.6;
    }

    if (keyCode == LEFT ) plane.roll(0.05);
    if (keyCode == RIGHT) plane.roll(-0.05);
    if (keyCode == UP   ) plane.pitch(-0.05);
    if (keyCode == DOWN ) plane.pitch(0.05);
    if (key == ',') plane.accelerate();
    if (key == '.') plane.decelerate();

    if (key == 'p')
      wand[0].pitch = 1.0f;
  }
  
  if (keyCode == 32 ) countdown.start(); // Space
  // Mikä ois hyvä nappi wandille?
  
  // TODO: Kaasu ja jarru wandin kanssa
  //if (???) plane.accelerate();
  //if (???) plane.decelerate();
  

  // Simulate head tracking with keyboard. Notice the view distortion.
  /*if (key == 'f') viewManager.incThreadedHeadX(-5);
   if (key == 'h') viewManager.incThreadedHeadX(5);
   if (key == 'y') viewManager.incThreadedHeadY(-5);
   if (key == 'r') viewManager.incThreadedHeadY(5);
   if (key == 't') viewManager.incThreadedHeadZ(-5);
   if (key == 'g') viewManager.incThreadedHeadZ(5);*/
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
