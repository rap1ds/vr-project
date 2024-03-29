/* The application logic is here */

boolean useKeyboard = false;

Wand leftWand;
Wand rightWand;
Wand gunWand;

Minim minim;

Plane plane;
RaceLine raceLine;
Camera camera;
Timer timer;
Countdown countdown;
int enemyCount = 10;
EnemyPlane[] enemyPlanes = new EnemyPlane[enemyCount];
PVector firePos;
PVector enemyPlanePos;
PVector fireRay;
PVector wandDirection;
Terrain terrain;
Sky sky;

// This function is called only once in the setup() function
public void mySetup()
{
  viewManager.setDisplayGridDraw(false);
   
  minim = new Minim(this);

  terrain = new Terrain();
  sky = new Sky();

  plane = new Plane(this, "biplane.3DS");
  
  for(int i = 0; i < enemyCount; i++) {
    enemyPlanes[i] = new EnemyPlane(this, "biplane.3DS");
  }

  raceLine = new RaceLine();
  raceLine.setup();

  camera = new Camera(plane, new PVector(0.0f, -25.0f, -300.0f));
  timer = new Timer();
  countdown = new Countdown();

  camera.location.set(viewManager.getHeadX(), viewManager.getHeadY(), viewManager.getHeadZ());
  camera.target.set(display[0].center.x, display[0].center.y, display[0].center.z);
  
  leftWand = wand[0];
  rightWand = wand[2];
  
  if(wand.length > 3) {
    gunWand = wand[3];
    gunWand.setFollowCamera(true);
  }
}

// This function is called for each view in the draw() loop.
// Place only drawing function calls here, and NO interaction code!
public void myDraw(int viewID)
{ 
  noLights();
  
  sky.draw();
  
  // Lights
  lightSetup();

  //ruis.drawWands(1.f);
  //ruis.drawSelectables();
  ruis.drawPlainObjects();
  //ruis.drawSelectionRanges(); // Only if selection button is pressed

  // Draw frames around the walls in world coordinates
  //viewManager.drawWallFrames();

  terrain.draw();
  plane.draw();
  raceLine.draw();  
  
  for(int i = 0; i < enemyCount; i++) {
    enemyPlanes[i].draw();
  }

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

  //stroke(color(255, 0, 0));
  //line(wand[0].x, wand[0].y, wand[0].z, wand[2].x, wand[2].y, wand[2].z);

  if(fireRay != null) {
    stroke(color(255, 0, 0));
    line(plane.location.x, plane.location.y, plane.location.z, fireRay.x, fireRay.y, fireRay.z);
  }

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
    
    for(int i = 0; i < enemyCount; i++) {
      enemyPlanes[i].startEngine();
    }
  }
  
  if(raceLine.finished) {
    viewManager.renderText("Finish!", 0.4, 0.45, color(200, 255, 100), 2, viewID);
    viewManager.renderText(timer.formattedTime(), 0.4, 0.55, color(200, 255, 100), 2, viewID);
  }
  
  // println("Gun wand " + gunWand.worldX + ", " + gunWand.worldY + ", " + gunWand.worldZ);

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

  PVector wandDiff = new PVector(rightWand.x - leftWand.x, 
  0, 
  rightWand.z - leftWand.z);

  float a = rightWand.y - leftWand.y;
  float b = wandDiff.mag();

  float angle = atan2(a, b);

  // account for going over 90'
  if (wandDiff.x > 0) angle = -angle;

  if (!useKeyboard) {
    float factor = 0.02f;
    plane.setEuler(1.5f * angle, (wand[0].pitch + wand[2].pitch) * 0.5f * factor);
  }
  
  /*PVector wandDiff = PVector.sub(new PVector(leftWand.x, leftWand.y, 0), new PVector(rightWand.x, rightWand.y, 0));
  if(wandDiff.x > 0)
    wandDiff.x = -wandDiff.x;
    
  wandDiff.normalize();
  
  PVector R = wandDiff;
  PVector U = new PVector(0, -1, 0);
  U.normalize();
  
  PVector F = R.cross(U);
  F.normalize();
  
  U = R.cross(F);
  U.normalize();
  
  PMatrix3D m = new PMatrix3D(
    F.x, F.y, F.z, 0,
    U.x, U.y, U.z, 0,
    R.x, R.y, R.z, 0,
    0, 0, 0, 1);
  
  //Quaternion q = Quaternion.fromMatrix(m);
  //plane.setQuaternion(q);
  
  if(!useKeyboard) {
    float factor = 0.1f;
    plane.pitch((wand[0].pitch + wand[2].pitch) * 0.5f * factor);
    plane.setQuaternion(q);  
  }*/
  
  plane.update();

  for(int i = 0; i < enemyCount; i++) {
    enemyPlanes[i].update();
  }
  
  if ((raceLine.finished || !countdown.isStarted()) && leftWand.buttonTrigger) {
    resetGame();
  }
  else if (!countdown.isStarted()) {
    if (rightWand.buttonTrigger)
      countdown.start();
  }
  else if (countdown.isFinished()) {
    if (rightWand.buttonTrigger)
      plane.accelerate();
    if (leftWand.buttonTrigger)
      plane.decelerate();
  
    if(gunWand != null && gunWand.buttonTrigger) {
      firePos = plane.getLocation();
      
      PVector gun = new PVector(gunWand.worldX, gunWand.worldY, gunWand.worldZ);
      PVector gunDirection = new PVector(2000*gunWand.vectForwardWorld.x, 
                                             2000*gunWand.vectForwardWorld.y, 
                                             2000*gunWand.vectForwardWorld.z);
      
      fireRay = PVector.add(gun, gunDirection);
      
      for(int i = 0; i < enemyPlanes.length; i++) {
        EnemyPlane enemy = enemyPlanes[i];
        boolean hit = enemy.intersects(gun, fireRay);
        if(hit) {
          enemy.destroy();
          println("HIT!!!");
        }
      }
    }
  }

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
  if (useKeyboard /* && countdown.isFinished() */ ) {

    /*
    if (wand3 != null) {
      if (key == 'a') wand3.x -= 0.6;
      if (key == 'd') wand3.x += 0.6;
      if (key == 'w') wand3.y -= 0.6;
      if (key == 's') wand3.y += 0.6;
    }
    */

    if (gunWand != null) {
      if (key == 'a') { gunWand.yaw -= 0.6; }
      if (key == 'd') gunWand.yaw += 0.6;
      if (key == 'w') gunWand.pitch -= 0.6;
      if (key == 's') gunWand.pitch += 0.6;
      if (key == 'e') gunWand.roll += 0.6;
      if (key == 'q') gunWand.roll -= 0.6;
    }

    if (keyCode == LEFT ) plane.roll(0.05);
    if (keyCode == RIGHT) plane.roll(-0.05);
    if (keyCode == UP   ) plane.pitch(-0.05);
    if (keyCode == DOWN ) plane.pitch(0.05);
    if (key == ',') plane.accelerate();
    if (key == '.') plane.decelerate();
  }
  
  if (keyCode == 32 ) countdown.start(); // Space
  if (key == 'z') resetGame();
  // Mikä ois hyvä nappi wandille?
  
  if(key == 'f') {
    // Debug gun fire
  } 

  // Simulate head tracking with keyboard. Notice the view distortion.
  /*if (key == 'f') viewManager.incThreadedHeadX(-5);
   if (key == 'h') viewManager.incThreadedHeadX(5);
   if (key == 'y') viewManager.incThreadedHeadY(-5);
   if (key == 'r') viewManager.incThreadedHeadY(5);
   if (key == 't') viewManager.incThreadedHeadZ(-5);
   if (key == 'g') viewManager.incThreadedHeadZ(5);*/
}

public void resetGame() {
  plane.reset();
  raceLine.reset();
  timer.reset();
  countdown = new Countdown();
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
