/**
 * WhichFace
 * Daniel Shiffman
 * http://shiffman.net/2011/04/26/opencv-matching-faces-over-time/
 *
 * Modified by Jordi Tost (@jorditost) to work with the OpenCV library by Greg Borenstein:
 * https://github.com/atduskgreg/opencv-processing
 *
 * @url: https://github.com/jorditost/BlobPersistence/
 *
 * University of Applied Sciences Potsdam, 2014
 */

import gab.opencv.*;
import processing.video.*;
import java.awt.*;
import com.hamoid.*;

//videocamera
Capture video;
boolean recording = false;
//face detection
OpenCV opencv1, opencv2;

// List of my Face objects (persistent)
ArrayList<Face> faceList;

// List of detected faces (every frame)
Rectangle[] faces;
Rectangle[] sideFaces;

// Number of faces detected over all time. Used to set IDs.
int faceCount = 0;

// Scaling down the video
int scl = 2;

void setup() {
  size(640, 480);
  video = new Capture(this, width/scl, height/scl);
  opencv1 = new OpenCV(this, width/scl, height/scl);
  opencv1.loadCascade(OpenCV.CASCADE_FRONTALFACE);
  //opencv2.loadCascade(OpenCV.CASCADE_PROFILEFACE);
  
  
  faceList = new ArrayList<Face>();
  
  video.start();
  
  //video setup
  println("Press R to toggle recording");
}

void draw() {
  scale(scl);
  opencv1.loadImage(video);
  //opencv2.loadImage(video);
  image(video, 0, 0 );
  if(recording) {
    saveFrame("output/face_####.png");
  }
  detectFaces();

  // Draw all the faces
  for (int i = 0; i < faces.length; i++) {
    noFill();
    strokeWeight(5);
    stroke(255,0,0);
    //rect(faces[i].x*scl,faces[i].y*scl,faces[i].width*scl,faces[i].height*scl);
    rect(faces[i].x, faces[i].y, faces[i].width, faces[i].height);
  }
  
  //for (Face f : faceList) {
  //  strokeWeight(2);
  //  f.display();
  //}
}

void detectFaces() {
  
  // Faces detected in this frame
  faces = opencv1.detect();
  //sideFaces = opencv2.detect();
  // Check if the detected faces already exist are new or some has disappeared. 
  
  // SCENARIO 1 
  // faceList is empty
  if (faceList.isEmpty()) {
    // Just make a Face object for every face Rectangle
    for (int i = 0; i < faces.length; i++) {
      println("+++ New face detected with ID: " + faceCount);
      faceList.add(new Face(faceCount, faces[i].x,faces[i].y,faces[i].width,faces[i].height));
      faceCount++;
      recording = true;
    }
  
  // SCENARIO 2 
  // We have fewer Face objects than face Rectangles found from OPENCV
  } else if (faceList.size() <= faces.length) {
    boolean[] used = new boolean[faces.length];
    // Match existing Face objects with a Rectangle
    for (Face f : faceList) {
       // Find faces[index] that is closest to face f
       // set used[index] to true so that it can't be used twice
       float record = 50000;
       int index = -1;
       for (int i = 0; i < faces.length; i++) {
         float d = dist(faces[i].x,faces[i].y,f.r.x,f.r.y);
         if (d < record && !used[i]) {
           record = d;
           index = i;
         } 
       }
       // Update Face object location
       used[index] = true;
       f.update(faces[index]);
    }
    // Add any unused faces
    for (int i = 0; i < faces.length; i++) {
      if (!used[i]) {
        println("+++ New face detected with ID: " + faceCount);
        faceList.add(new Face(faceCount, faces[i].x,faces[i].y,faces[i].width,faces[i].height));
        faceCount++;
      }
    }
  
  // SCENARIO 3 
  // We have more Face objects than face Rectangles found
  } else {
    // All Face objects start out as available
    for (Face f : faceList) {
      f.available = true;
    } 
    // Match Rectangle with a Face object
    for (int i = 0; i < faces.length; i++) {
      // Find face object closest to faces[i] Rectangle
      // set available to false
       float record = 50000;
       int index = -1;
       for (int j = 0; j < faceList.size(); j++) {
         Face f = faceList.get(j);
         float d = dist(faces[i].x,faces[i].y,f.r.x,f.r.y);
         if (d < record && f.available) {
           record = d;
           index = j;
         } 
       }
       // Update Face object location
       Face f = faceList.get(index);
       f.available = false;
       f.update(faces[i]);
    } 
    // Start to kill any left over Face objects
    for (Face f : faceList) {
      if (f.available) {
        f.countDown();
        if (f.dead()) {
          f.delete = true;
          recording = false;
        } 
      }
    } 
  }
  
  // Delete any that should be deleted
  for (int i = faceList.size()-1; i >= 0; i--) {
    Face f = faceList.get(i);
    if (f.delete) {
      faceList.remove(i);
    } 
  }
}

void captureEvent(Capture c) {
  c.read();
}

void keyPressed() {
  if(key == 'r' || key == 'R') {
    recording = !recording;
    println("Recording is " + (recording ? "ON" : "OFF"));
  }
  if (key == 'q') {
    exit();
  }
}
