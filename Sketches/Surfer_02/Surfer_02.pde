PImage surfer;
float x, y, s = 0.6; // s = scale factor 
boolean followMouse =true; // toggle m to pause following

void setup() {
  size(900, 600, P2D); // P2D for GPU-smooth transforms
  pixelDensity(displayDensity()); // makes image sharp on HiDPI
  imageMode(CENTER);
  
  surfer = loadImage("Surfer.png");
  
  float maxW = width * 0.45; // image should use at most 45% of canvas width
  float maxH = height * 0.60; // at most 60% of canvas height
  s = min(maxW / surfer.width, maxH /surfer.height);
  
  x = width / 2.0;
  y = height / 2.0;
}

void draw() {
  setGradient(0, 0, width, height, 
  color(140,160,185),
  color(40,50,70), 
  "Y"); 
  
  if(followMouse) {
    x = lerp(x, mouseX, 0.08);
    y = lerp(y, mouseY, 0.08); // surfer chases my mouse instead of snapping to it
  }
  
  // motion layers
  float bob = sin(frameCount*0.05)*8; // up-down
  float tilt = radians(sin(frameCount*0.03)*3); // rotation
  float pulse = map(sin(frameCount*0.02),-1, 1, 0.95, 1.05); // breathing scale
  
  float halfW = surfer.width  * s * 0.5;
  float halfH = surfer.height * s * 0.5;
  float cx = constrain(x, halfW, width  - halfW);
  float cy = constrain(y, halfH, height - halfH);
  
  pushMatrix(); // save the current drawing state
  translate(cx,cy + bob); // move the surfer to the desired spot, adding the bobbing
  rotate(tilt); // tilt around the center
  scale(s * pulse); //scale * pulsing effect
  image(surfer, 0, 0); 
  popMatrix(); // reset to normal system 
}

void setGradient(int x, int y, float w, float h, color c1, color c2, String axis ) {
  noFill();
  
  if (axis == "Y") {  // Top to bottom gradient
    for (int i = y; i <= y+h; i++) {
      float inter = map(i, y, y+h, 0, 1);
      color c = lerpColor(c1, c2, inter);
      stroke(c);
      line(x, i, x+w, i);
    }
  } 
  else if (axis == "X") {  // Left to right gradient
    for (int i = x; i <= x+w; i++) {
      float inter = map(i, x, x+w, 0, 1);
      color c = lerpColor(c1, c2, inter);
      stroke(c);
      line(i, y, i, y+h);
    }
  }
}
void keyPressed() {
  if (key == 'm' || key == 'M') followMouse = !followMouse; // toggle mouse follow
  
  if (keyCode == LEFT)  x -= 10;
  if (keyCode == RIGHT) x += 10;
  if (keyCode == UP)    y -= 10;
  if (keyCode == DOWN)  y += 10;

  if (key == '+') s *= 1.05;
  if (key == '-') s *= 0.95;
}
