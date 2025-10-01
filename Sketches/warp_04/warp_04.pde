int numHex = 60;    // more hexagons (greater depth)
float[] zPos;       
float speed = 20;   // movement speed
float rot = 0;      
float hexSize = 400; // enlarged hexagon size

void setup() {
  size(1000, 1000, P3D); // larger canvas
  zPos = new float[numHex];
  for (int i = 0; i < numHex; i++) {
    zPos[i] = i * 200;
  }
  colorMode(HSB, 360, 100, 100);
  strokeWeight(3); // thicker lines
  noFill();
}

void draw() {
  background(0);
  translate(width/2, height/2, 0);
  rot += 0.01;
  rotateZ(rot);

  for (int i = 0; i < numHex; i++) {
    pushMatrix();
    translate(0, 0, -zPos[i]);

    // psychedelic colors
    float hue = (frameCount*2 + i*10) % 360;
    stroke(hue, 100, 100);

    // get hexagon corners
    PVector[] corners = getHexCorners(hexSize);
    
    // draw hexagon
    beginShape();
    for (int j = 0; j < 6; j++) {
      vertex(corners[j].x, corners[j].y);
    }
    endShape(CLOSE);
    
    // side lines → connect to the next + the one after (stronger depth effect)
    if (i < numHex-2) {
      PVector[] nextCorners = getHexCorners(hexSize);
      for (int j = 0; j < 6; j++) {
        // closer layer
        line(corners[j].x, corners[j].y, 0, 
             nextCorners[j].x, nextCorners[j].y, 200);
        // further layer
        line(corners[j].x, corners[j].y, 0, 
             nextCorners[j].x, nextCorners[j].y, 400);
      }
    }
    
    popMatrix();
    
    // movement
    zPos[i] -= speed;
    if (zPos[i] < 0) {
      zPos[i] = numHex * 200;
    }
  }
}

PVector[] getHexCorners(float r) {
  PVector[] pts = new PVector[6];
  for (int i = 0; i < 6; i++) {
    float angle = TWO_PI/6 * i;
    pts[i] = new PVector(cos(angle)*r, sin(angle)*r);
  }
  return pts;
}
