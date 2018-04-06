//int numFrames = 42;
//int frame = 0;
//PImage[] images = new PImage[numFrames]; //image array

//void setup(){
// size(1080, 720);
// frameRate(10);
// for (int i=1; i<numFrames; i++){
//   if(i<10){
//     images[i] = loadImage("img000"+i+".png");
//   }
//   else{
//     images[i] = loadImage("img00"+i+".png");
//   }
// }
//}

//void draw(){
// frame++;
// if(frame == numFrames){
//   frame = 1;
// }
// image(images[frame], 0, 0, 1080, 720);
//}

import processing.video.*;

float counter=1.0;
float x;
float r;
float g;
float b;
ArrayList frames = new ArrayList();
int numPixels;
int keyColor = 0xff000000;
int keyR = (keyColor >> 16) & 0xFF;
int keyG = (keyColor >> 8) & 0xFF;
int keyB = keyColor & 0xFF;
int thresh = 10; // tolerance of 
int currentImage;
float op;
int bars = 8;

Movie mov;

void setup() {
  size(640,480);
  background(0);
  mov = new Movie(this, "test1.mp4");
  mov.loop();
  x = 0;
  numPixels = mov.width * mov.height;
}


void draw() {    
  r=map(counter,2.5,3.0,255.0,0.0);
  g=map(counter,0.5,1.5,0.0,255.0);
  b=map(counter,0.5,1.5,0.0,255.0);
  image(mov, 0, 0);
  //float newSpeed = random(1,2);
  frameRate(30);
  mov.speed(counter);
  fill(255);

  System.out.println(frameCount);
  System.out.println(counter);
  x=frameCount;
  counter=map(sin(x/50),-1,1,0.5,3.0);
  
  //if(counter<1.5||counter>2.5){
  //  bars=6;
  //}else{bars=4;}
  
  // Set the image counter to 0
  if (frameCount<100){
    currentImage = frameCount/10;
  }
  else if ( frameCount<1000){
    currentImage = frameCount/100;
  }
  else if (frameCount<10000){
    currentImage = frameCount/1000;
  }
 
 loadPixels();
  
  // Begin a loop for displaying pixel rows of 4 pixels height
  for (int y = 0; y < mov.height; y+=bars) {
    tint(r,g,b,255);
    // Go through the frame buffer and pick an image, starting with the oldest one
    if (currentImage < frames.size()) {
      PImage img = (PImage)frames.get(currentImage);
      
      if (img != null) {
        img.loadPixels();
        
        // Put 4 rows of pixels on the screen
        for (int x = 0; x < mov.width; x++) {
          pixels[x + y * width] = img.pixels[x + y * mov.width];
          pixels[x + (y + 1) * width] = img.pixels[x + (y + 1) * mov.width];
          pixels[x + (y + 2) * width] = img.pixels[x + (y + 2) * mov.width];
          pixels[x + (y + 3) * width] = img.pixels[x + (y + 3) * mov.width];
        }  
      }
      
      // Increase the image counter
      currentImage++;
       
    } else {
      break;
    }
  }
  
  updatePixels();
  
  // For recording an image sequence
  //saveFrame("frame-####.jpg"); 
  
  //op=map(sin(x/100),-1,1,0,100);
  //fill(r,g,b,op);
  //rect(0,0,width/3,height);

}  

void movieEvent(Movie mov) {
  mov.read();
  
  // Copy the current video frame into an image, so it can be stored in the buffer

  PImage img = createImage(width, height, RGB);
  mov.loadPixels();
          
  arrayCopy(mov.pixels, img.pixels);
  
  frames.add(img);
  
  // Once there are enough frames, remove the oldest one when adding a new one
  if (frames.size() > height/4) {
    frames.remove(0);
  }
}
