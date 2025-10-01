int numWaves = 60;     // number of rings
float angleStep = 0.2; // wave density

void setup() {
  size(800, 800);
  colorMode(HSB, 255);
  noFill();
}

void draw() {
  background(0);
  translate(width/2, height/2);

  for (int i = 0; i < numWaves; i++) {
    // Each ring’s radius decreases depending on frameCount
    float radius = (width * 1.2) - ((frameCount * 4 + i * 50) % (int)(width * 1.2));
    float waveShift = frameCount * 0.15 + i * 0.3; // animation speed

    beginShape();
    stroke((i*8 + frameCount) % 255, 255, 255, 200);
    strokeWeight(2);

    for (float a = 0; a < TWO_PI; a += angleStep) {
      float r = radius + sin(a * 3 + waveShift) * 30; // wave distortion
      float x = cos(a) * r;
      float y = sin(a) * r;
      vertex(x, y);
    }
    endShape(CLOSE);
  }
}
