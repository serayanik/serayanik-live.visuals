float time = 0;
float tunnelZ = 0;
int rings = 80;
int pointsPerRing = 120;
float warpTime = 0;
float warpIntensity = 0;

void setup() {
  size(800, 800, P3D);
  colorMode(HSB, 360, 100, 100);
  strokeWeight(3);
}

void draw() {
  background(0);
  
  translate(width/2, height/2, 0);
  
  // Kamera hareketi
  float camX = cos(time * 0.1) * 50;
  float camY = sin(time * 0.15) * 30;
  camera(camX, camY, 200, 0, 0, -200, 0, 1, 0);
  
  // 
  warpTime += 0.02;
  if (sin(warpTime * 0.5) > 0.95) {
    warpIntensity = lerp(warpIntensity, 50, 0.1);
  } else {
    warpIntensity = lerp(warpIntensity, 0, 0.05);
  }
  
  // Tunnel depth 
  if (tunnelZ > 150) {
    tunnelZ = 0;
  }
  
  // Torus 
  for (int r = 0; r < rings; r++) {
    float z = map(r, 0, rings, -tunnelZ, 1500 - tunnelZ);
    float ringSize = map(sin(z * 0.01 + time * 0.5), -1, 1, 0.3, 1.2);
    
    // 
    beginShape(POINTS);
    for (int i = 0; i < pointsPerRing; i++) {
      float angle = map(i, 0, pointsPerRing, 0, TWO_PI);
      
      // Torus geometrisi
      float R = 150 * ringSize; // 
      float r_small = 80 * ringSize; // 
      
      float theta = angle;
      float phi = z * 0.02 + time;
      
      // Torus parametrik denklemleri
      float x = (R + r_small * cos(phi)) * cos(theta);
      float y = (R + r_small * cos(phi)) * sin(theta);
      float z_pos = r_small * sin(phi);
      
      // Warp effect
      if (warpIntensity > 0) {
        float warpAngle = time * 3 + r * 0.5;
        x += sin(warpAngle + i * 0.1) * warpIntensity;
        y += cos(warpAngle + i * 0.1) * warpIntensity;
        z_pos += sin(warpAngle * 2) * warpIntensity * 0.5;
      }
      
      // Psychedelic renkler
      float hue = (time * 20 + r * 3 + i * 0.8 + z * 0.1) % 360;
      float sat = map(sin(time + r * 0.1), -1, 1, 60, 100);
      float bright = map(z, -tunnelZ, 1500 - tunnelZ, 100, 20);
      
      // Depth-based alpha effect
      if (z < 100) {
        bright *= map(z, -tunnelZ, 100, 0.3, 1);
      }
      
      stroke(hue, sat, bright);
      vertex(x, y, z + z_pos);
    }
    endShape();
  }
  
  time += 0.02;
}

void keyPressed() {
  if (key == ' ') {
    warpIntensity = 50; // Manuel warp trigger
  }
}
