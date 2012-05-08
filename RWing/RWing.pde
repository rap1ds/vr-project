import processing.core.*;
import processing.opengl.*;

import net.ruisystem.*;
import net.ruisystem.input.*;
import net.ruisystem.kinect.*;
import net.ruisystem.view.*;

import java.lang.reflect.*;
import javax.vecmath.*;

import mri.*;
import mri.v3ds.*;

import ddf.minim.*;
import ddf.minim.effects.*;

import SimpleOpenNI.*;

public RUIS ruis;
public ViewManager viewManager;
public InputManager inputManager;

// Width and height in pixels for each rendered screen

// DEV
// int VIEW_WIDTH  = 640;
// int VIEW_HEIGHT = 640;

// PROD
int VIEW_WIDTH  = 800;
int VIEW_HEIGHT = 600;

// String displayConfigFileName = "displayConfigDev.xml";
// String inputConfigFileName = "inputConfigDev.xml";
String displayConfigFileName = "displayConfig.xml";
String inputConfigFileName = "inputConfig.xml";
String ruisConfigFileName = "ruisConfig.xml";

public void setup()
{ 
  int viewCount = ViewManager.readViewCount(this, displayConfigFileName);
  
  size(viewCount*VIEW_WIDTH, VIEW_HEIGHT, OPENGL); // RUIS requires OpenGL
  
  inputManager = new InputManager(this, this.inputConfigFileName);

  viewManager = new ViewManager(this, VIEW_WIDTH, VIEW_HEIGHT, displayConfigFileName);
  
  ruis = new RUIS(this, viewManager, inputManager, ruisConfigFileName);

  createShortcuts();

  mySetup();

  ruis.physicsThread.start();
  inputManager.inputThread.start();
}

public void draw()
{    
  
  // Clear displays
  background(0);
  
  // You can change camera location with ruisCamera() function that
  // behaves identically to camera() function of Processing. Do not call 
  // camera(), frustum(), or perspective() functions, because they mess 
  // up the OpenGL perspective and modelview transformations that are needed
  // by RUIS.
  
  // Update Wiimotes and other wands (location etc.)
  ruis.updateWands();
  
  // Execute interaction behavior of wands (controllers) and objects
  ruis.doInteraction();

  // For every draw() iteration, each view is rendered in the below for-loop.
  // Place inside this loop only drawing functions and those functions that
  // need to be called once per each display. Calling other functions and 
  // modification of application state variables should be done in the above
  // myInteraction().
  for(int viewID = 0; viewID < viewManager.getViewCount(); ++viewID)
  {
    // Here you can set conditions when to not to render a viewport
    if(!viewManager.isViewDrawn(viewID))
      continue;
    
    // Set modelview and projection matrices for 3D drawing
    viewManager.prepareDrawing3D(viewID);
    pushMatrix();

    // Call your 3D drawing functions here
    /*---------------------------------------*/
    
    // Your own function where you draw what you want (see MyApp.pde)
    myDraw(viewID);
    
    /*---------------------------------------*/
    

    
    // Set 2D drawing mode - Essentially calls camera() and perspective()
    viewManager.prepareDrawingHUD(viewID);
    
    // Call your own 2D drawing functions here.
    // Keystone correction will not be applied on these drawings.
    /*---------------------------------------*/
 
    /*---------------------------------------*/
    
    viewManager.drawBlackOutsideKeystones(viewID);
    popMatrix();
  }

}

// Close all audio resources when the program exits
void stop() {
  plane.cleanUp();
  minim.stop();
  super.stop();
}

