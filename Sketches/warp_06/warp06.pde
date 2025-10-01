int cols = 60;   // number of circular segments
int rows = 100;  // depth of the tunnel
float angle = 0;
float speed = 0.2; // 50% faster

void setup() { 
  size(800, 800, P3D);
  colorMode(HSB, 360, 100, 100);
}

void draw() {
  background(0);
  
  // view from the center
  translate(width/2, height/2, -1000);
  
  // rotate faster
  rotateZ(frameCount * 0.015);
  
  angle += speed;
  
  // draw tunnel
  for (int z = 0; z < rows; z++) {
    float depth = map(z, 0, rows, 0, 2000);
    
    beginShape();
    for (int i = 0; i <= cols; i++) {
      float theta = map(i, 0, cols, 0, TWO_PI);
      
      // sinusoidal deformation
      float r = 200 + 40 * sin(theta * 3 + angle + z * 0.3);
      
      float x = r * cos(theta);
      float y = r * sin(theta);
      
      stroke((theta*180/PI + frameCount*2) % 360, 80, 100);
      strokeWeight(2);
      noFill();
      vertex(x, y, depth);
    }
    endShape();
  }
}
