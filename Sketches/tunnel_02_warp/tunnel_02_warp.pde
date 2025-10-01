int numStars = 400; 
Star[] stars;

void setup() {
  size(800, 800);
  colorMode(HSB, 360, 100, 100);
  stars = new Star[numStars];
  for (int i = 0; i < numStars; i++) {
    stars[i] = new Star();
  }
}

void draw() {
  background(0);
  translate(width/2, height/2); // draw from center
  for (int i = 0; i < numStars; i++) {
    stars[i].update();
    stars[i].display();
  }
}

class Star {
  float angle;
  float distance;
  float speed;
  float length;
  color c;
  
  Star() {
    reset();
  }
  
  void reset() {
    angle = random(TWO_PI);
    distance = random(0, 50);
    speed = random(3, 8) * 0.8;   // 🔹 %20 daha yavaş
    length = random(5, 25);
    c = color(random(360), 80, 100);
  }
  
  void update() {
    // accelerate with distance to simulate warp effect
    distance += speed + distance * 0.03 * 0.8; // 🔹 ivmeyi de yavaşlattık
    if (distance > width) {
      reset();
    }
  }
  
  void display() {
    float x1 = cos(angle) * distance;
    float y1 = sin(angle) * distance;
    float x2 = cos(angle) * (distance + length + distance*0.05);
    float y2 = sin(angle) * (distance + length + distance*0.05);
    
    stroke(c);
    strokeWeight(map(distance, 0, width, 1, 4)); // closer = thicker
    line(x1, y1, x2, y2);
  }
}
