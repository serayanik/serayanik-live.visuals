// TUNNEL / STARS / WARP03 / WARP04 / WARP06 / WARP07 + SURFER + SEGMENTED AUDIO (Minim)
// + HAHA INTRO (00:18–00:23) pulses in place
// + SCHEDULED REVERSE WINDOWS & AUTO TRIANGLE COLORS to 51s
// + MIDDLE IMAGES (24s-43s): Sun4, 2me, saywhat, huh cycling
// + CORNER IMAGES (44s-51s): Attention & Feel Good cycling
// P toggles backgrounds: 0 Tunnel → 1 Stars → 2 Warp03 → 3 Warp04 → 4 Warp06 → 5 Warp07
// Plays only 00:18 → 01:20 of the track (looping by default).
// Keys:
//   Visuals: M, O, U, P, Arrows, +/-
//   Audio: SPACE = play/pause | L = toggle loop | R = restart segment | S = stop | [ / ] volume

import ddf.minim.*;
Minim minim;
AudioPlayer music;

String AUDIO_FILE = "Gorillaz - Feel Good .mp3";

// Segment boundaries
int SEGMENT_START_MS = 18000;
int SEGMENT_END_MS   = 80000;

boolean segmentLoop = true;
float musicGainDb   = -6;

//  Background mode 
int bgMode = 0; // 0 Tunnel, 1 Stars, 2 Warp03, 3 Warp04, 4 Warp06, 5 Warp07

//  Tunnel 
int   numCircles = 24;
float maxR;
float spacing;
int   LOOP_FRAMES = 240;
float growthSpeed = 4;
int   ringsPerLoop = 32;

int   dir = 1;
int   manualDir = 1;
float shiftPos = 0;

boolean autoReverse = false;
int autoReverseIntervalMs = 4000;
int lastReverseMs = 0;

int triPalette = 0;

//  Stars 
int   numStars = 400;
Star[] stars;

//  Warp03 
int   w3_numWaves = 16;
float w3_angleStep = 0.05f;
float w3_waveAmp = 30;
float w3_speedBase = 4;

//  Warp04 
int     w4_numHex = 60;
float[] w4_zPos;
float   w4_speed = 20;
float   w4_rot = 0;
float   w4_hexSize;
float   w4_layerGap = 200;

//  Warp06 (Sinusoidal Tunnel) 
int w6_cols = 60;
int w6_rows = 100;
float w6_angle = 0;
float w6_speed = 0.2;

//  Warp07 (Torus Tunnel) 
float w7_time = 0;
float w7_tunnelZ = 0;
int w7_rings = 80;
int w7_pointsPerRing = 120;
float w7_warpTime = 0;
float w7_warpIntensity = 0;
float w7_surferTimer = 0;
int w7_lastBgMode = -1;

//  Surfer 
PImage surfer;
float x, y, s = 0.18;
float tx, ty;
boolean followMouse = false;

//  HAHA intro 
PImage hahaImg;
int HAHA_START_MS = 18000;
int HAHA_END_MS   = 23000;

//  Middle images (24s - 43s) 
PImage sun4Img;
PImage moonImg;
PImage twoMeImg;
PImage sayWhatImg;
PImage huhImg;
int MIDDLE_START_MS = 24000;
int MIDDLE_END_MS   = 34000;
int MOON_START_MS   = 34000;
int MOON_END_MS     = 44000;
int SPEECH_START_MS = 30000;
int SPEECH_END_MS   = 43000;
int SPEECH_CYCLE_MS = 1000;

//Corner images (44s - 51s) 
PImage attentionImg;
PImage feelGoodImg;
int CORNER_START_MS = 44000;
int CORNER_END_MS   = 51000;
int CORNER_CYCLE_MS = 875;

//Scheduled reverse windows (ms) 
int[][] REVERSE_WINDOWS = new int[][] {
  {22000, 23000},
  {26000, 27000},
  {29000, 30000},
  {33000, 34000},
  {36000, 37000},
  {40000, 41000},
  {43000, 44000},
  {47000, 48000},
  {50000, 51000}
};

int TRI_AUTO_END_MS = 51000;

void setup() {
  size(900, 600, P3D);
  hint(ENABLE_DEPTH_SORT);
  pixelDensity(displayDensity());
  imageMode(CENTER);

  surfer = loadImage("Surfer.png");
  s  = 0.18;
  tx = width * 0.5 * 1.2;
  ty = height * 0.58 * 0.8 * 1.25;
  x  = tx;
  y  = ty;

  hahaImg = loadImage("hahaha.png");
  
  try {
    attentionImg = loadImage("attention.png");
    println("✓ Loaded attention.png");
  } catch (Exception e) {
    println("✗ Failed to load attention.png");
  }
  
  try {
    feelGoodImg = loadImage("feelgood.png");
    println("✓ Loaded feelgood.png");
  } catch (Exception e) {
    println("✗ Failed to load feelgood.png");
  }
  
  try {
    sun4Img = loadImage("sun4.png");
    println("✓ Loaded sun4.png");
  } catch (Exception e) {
    println("✗ Failed to load sun4.png");
  }
  
  try {
    moonImg = loadImage("moon.png");
    println("✓ Loaded moon.png");
  } catch (Exception e) {
    println("✗ Failed to load moon.png");
  }
  
  try {
    twoMeImg = loadImage("2me.png");
    println("✓ Loaded 2me.png");
  } catch (Exception e) {
    println("✗ Failed to load 2me.png");
  }
  
  try {
    sayWhatImg = loadImage("saywhat.png");
    println("✓ Loaded saywhat.png");
  } catch (Exception e) {
    println("✗ Failed to load saywhat.png");
  }
  
  try {
    huhImg = loadImage("huh.png");
    println("✓ Loaded huh.png");
  } catch (Exception e) {
    println("✗ Failed to load huh.png");
    try {
      huhImg = loadImage("Huh.png");
      println("✓ Loaded Huh.png (capital H)");
    } catch (Exception e2) {
      println("✗ Failed to load Huh.png too");
    }
  }

  maxR    = max(width, height);
  spacing = (growthSpeed * LOOP_FRAMES) / (float) ringsPerLoop;

  stars = new Star[numStars];
  for (int i = 0; i < numStars; i++) stars[i] = new Star();

  w4_hexSize = min(width, height) * 0.55;
  w4_zPos = new float[w4_numHex];
  for (int i = 0; i < w4_numHex; i++) {
    w4_zPos[i] = i * w4_layerGap;
  }

  minim = new Minim(this);
  try {
    music = minim.loadFile(AUDIO_FILE, 2048);
    if (music != null) {
      music.setGain(musicGainDb);
      music.cue(SEGMENT_START_MS);
    }
  } catch (Exception e) {
    println("⚠ Could not load audio. Check file is in data/: " + AUDIO_FILE);
    e.printStackTrace();
  }

  lastReverseMs = millis();
}

void draw() {
  switch (bgMode) {
    case 0: drawTunnelLooping(); break;
    case 1: drawStarsBackground(); break;
    case 2: drawWarp03(); break;
    case 3: drawWarp04(); break;
    case 4: drawWarp06(); break;
    case 5: drawWarp07(); break;
  }

  int tms = (music != null) ? music.position() : 0;
  if (tms >= HAHA_START_MS && tms < HAHA_END_MS) {
    drawHahaPulse();
  } else if (tms >= HAHA_END_MS) {
    drawSurferLayer();
  }

  if (tms >= MIDDLE_START_MS && tms < SPEECH_END_MS) {
    drawMiddleImages(tms);
  }

  if (tms >= CORNER_START_MS && tms < CORNER_END_MS) {
    float fadeAlpha = 1.0;
    if (tms < CORNER_START_MS + 1000) {
      fadeAlpha = map(tms, CORNER_START_MS, CORNER_START_MS + 1000, 0, 1);
    }
    drawCornerImages(tms, fadeAlpha);
  }

  updateSegmentPlayback();
  drawAudioHUD();
}

void updateSegmentPlayback() {
  if (music == null) return;
  if (music.isPlaying()) {
    if (music.position() >= SEGMENT_END_MS) {
      if (segmentLoop) {
        music.cue(SEGMENT_START_MS);
        music.play();
      } else {
        music.pause();
        music.cue(SEGMENT_START_MS);
      }
    } else if (music.position() < SEGMENT_START_MS) {
      music.cue(SEGMENT_START_MS);
    }
  } else {
    if (music.position() < SEGMENT_START_MS || music.position() > SEGMENT_END_MS) {
      music.cue(SEGMENT_START_MS);
    }
  }
}

void drawAudioHUD() {
  if (music == null) return;
  String playing = music.isPlaying() ? "Playing" : "Paused";
  String loopTxt = segmentLoop ? "Loop ON" : "Loop OFF";
  String modeTxt = (bgMode==0?"Tunnel": bgMode==1?"Stars": bgMode==2?"Warp03": bgMode==3?"Warp04": bgMode==4?"Warp06":"Warp07");
  fill(255, 180);
  noStroke();
  rect(10, 10, 390, 74, 8);
  fill(0);
  textSize(12);
  text("Mode: " + modeTxt, 20, 28);
  text("Audio: " + playing + "  |  " + loopTxt + "   Gain: " + nf(musicGainDb, 0, 1) + " dB  [ / ]", 20, 44);
  text("Segment: 00:18 → 01:20   SPACE/L/R/S • P: backgrounds • O: flip dir • U: palettes", 20, 60);
}

boolean inReverseWindow(int tms) {
  for (int i = 0; i < REVERSE_WINDOWS.length; i++) {
    int start = REVERSE_WINDOWS[i][0];
    int end   = REVERSE_WINDOWS[i][1];
    if (tms >= start && tms < end) return true;
  }
  return false;
}

int getAutoPaletteForTime(int tms) {
  int idx = ((tms - SEGMENT_START_MS) / 2000) % 4;
  if (idx < 0) idx = 0;
  return idx;
}

void drawTunnelLooping() {
  int tms = (music != null) ? music.position() : 0;

  if (inReverseWindow(tms)) dir = -1;
  else                      dir = manualDir;

  background(0);
  pushMatrix();
  translate(width/2f, height/2f);
  noFill();
  strokeWeight(3);

  shiftPos += growthSpeed * dir;
  float shift = shiftPos % maxR;
  if (shift < 0) shift += maxR;

  float startR = -spacing;
  float endR   = maxR + spacing;

  for (float r = startR; r <= endR; r += spacing) {
    float rw = (r - shift) % maxR;
    if (rw < 0) rw += maxR;
    float h = (rw * 360f / maxR) % 360f;
    strokeHSB(h, 100, 100);
    ellipse(0, 0, rw*2, rw*2);
  }

  int paletteForDraw = (tms < TRI_AUTO_END_MS) ? getAutoPaletteForTime(tms) : triPalette;

  drawTriangleRays(paletteForDraw);
  popMatrix();
}

void drawStarsBackground() {
  background(0);
  pushMatrix();
  translate(width/2f, height/2f);
  for (int i = 0; i < numStars; i++) {
    stars[i].update();
    stars[i].display();
  }
  popMatrix();
}

void drawWarp03() {
  background(0);
  pushMatrix();
  translate(width/2f, height/2f);
  noFill();
  for (int i = 0; i < w3_numWaves; i++) {
    float radius = (min(width, height) * 1.2) - ((frameCount * w3_speedBase + i * 50) % (int)(min(width, height) * 1.2));
    float waveShift = frameCount * 0.15 + i * 0.3;
    pushStyle();
    colorMode(HSB, 255);
    stroke((i*8 + frameCount) % 255, 255, 255, 200);
    strokeWeight(2);
    beginShape();
    for (float a = 0; a < TWO_PI; a += w3_angleStep) {
      float r = radius + sin(a * 3 + waveShift) * w3_waveAmp;
      vertex(cos(a) * r, sin(a) * r);
    }
    endShape(CLOSE);
    popStyle();
  }
  popMatrix();
}

void drawWarp04() {
  background(0);
  pushMatrix();
  translate(width/2f, height/2f, 0);
  w4_rot += 0.01;
  rotateZ(w4_rot);
  for (int i = 0; i < w4_numHex; i++) {
    pushMatrix();
    translate(0, 0, -w4_zPos[i]);
    float h = (frameCount*2 + i*10) % 360;
    pushStyle();
    colorMode(HSB, 360, 100, 100);
    stroke(h, 100, 100);
    strokeWeight(3);
    noFill();
    PVector[] corners = w4_getHexCorners(w4_hexSize);
    beginShape();
    for (int j = 0; j < 6; j++) vertex(corners[j].x, corners[j].y, 0);
    endShape(CLOSE);
    popStyle();
    popMatrix();
    w4_zPos[i] -= w4_speed;
    if (w4_zPos[i] < 0) w4_zPos[i] = w4_numHex * w4_layerGap;
  }
  popMatrix();
}

PVector[] w4_getHexCorners(float r) {
  PVector[] pts = new PVector[6];
  for (int i = 0; i < 6; i++) {
    float angle = TWO_PI/6 * i;
    pts[i] = new PVector(cos(angle)*r, sin(angle)*r, 0);
  }
  return pts;
}

void drawWarp06() {
  background(0);
  
  pushMatrix();
  translate(width/2, height/2, -1000);
  
  rotateZ(frameCount * 0.015);
  
  w6_angle += w6_speed;
  
  pushStyle();
  colorMode(HSB, 360, 100, 100);
  
  for (int z = 0; z < w6_rows; z++) {
    float depth = map(z, 0, w6_rows, 0, 2000);
    
    beginShape();
    for (int i = 0; i <= w6_cols; i++) {
      float theta = map(i, 0, w6_cols, 0, TWO_PI);
      
      float r = 200 + 40 * sin(theta * 3 + w6_angle + z * 0.3);
      
      float x = r * cos(theta);
      float y = r * sin(theta);
      
      stroke((theta*180/PI + frameCount*2) % 360, 80, 100);
      strokeWeight(2);
      noFill();
      vertex(x, y, depth);
    }
    endShape();
  }
  
  popStyle();
  popMatrix();
}

void drawWarp07() {
  background(0);
  
  pushMatrix();
  translate(width/2, height/2, 0);
  
  float camX = cos(w7_time * 0.1) * 50;
  float camY = sin(w7_time * 0.15) * 30;
  camera(camX, camY, 200, 0, 0, -200, 0, 1, 0);
  
  w7_warpTime += 0.02;
  if (sin(w7_warpTime * 0.5) > 0.95) {
    w7_warpIntensity = lerp(w7_warpIntensity, 50, 0.1);
  } else {
    w7_warpIntensity = lerp(w7_warpIntensity, 0, 0.05);
  }
  
  w7_tunnelZ += 1.5;
  if (w7_tunnelZ > 150) {
    w7_tunnelZ = 0;
  }
  
  pushStyle();
  colorMode(HSB, 360, 100, 100);
  strokeWeight(3);
  
  for (int r = 0; r < w7_rings; r++) {
    float z = map(r, 0, w7_rings, -w7_tunnelZ, 1500 - w7_tunnelZ);
    float ringSize = map(sin(z * 0.01 + w7_time * 0.5), -1, 1, 0.3, 1.2);
    
    beginShape(POINTS);
    for (int i = 0; i < w7_pointsPerRing; i++) {
      float angle = map(i, 0, w7_pointsPerRing, 0, TWO_PI);
      
      float R = 150 * ringSize;
      float r_small = 80 * ringSize;
      
      float theta = angle;
      float phi = z * 0.02 + w7_time;
      
      float x = (R + r_small * cos(phi)) * cos(theta);
      float y = (R + r_small * cos(phi)) * sin(theta);
      float z_pos = r_small * sin(phi);
      
      if (w7_warpIntensity > 0) {
        float warpAngle = w7_time * 3 + r * 0.5;
        x += sin(warpAngle + i * 0.1) * w7_warpIntensity;
        y += cos(warpAngle + i * 0.1) * w7_warpIntensity;
        z_pos += sin(warpAngle * 2) * w7_warpIntensity * 0.5;
      }
      
      float hue = (w7_time * 20 + r * 3 + i * 0.8 + z * 0.1) % 360;
      float sat = map(sin(w7_time + r * 0.1), -1, 1, 60, 100);
      float bright = map(z, -w7_tunnelZ, 1500 - w7_tunnelZ, 100, 20);
      
      if (z < 100) {
        bright *= map(z, -w7_tunnelZ, 100, 0.3, 1);
      }
      
      stroke(hue, sat, bright);
      vertex(x, y, z + z_pos);
    }
    endShape();
  }
  
  popStyle();
  popMatrix();
  
  w7_time += 0.02;
}

void drawTriangleRays(int paletteIdx) {
  float angleL = atan2(height/2f, -width/2f);
  float angleR = atan2(height/2f,  width/2f);
  int   rays  = 140;
  float alpha = 110;

  pushStyle();
  colorMode(HSB, 360, 100, 100, 255);
  noStroke();
  for (int i = 0; i < rays; i++) {
    float t0 = i / (float)rays;
    float t1 = (i + 1) / (float)rays;

    float a0 = lerp(angleL, angleR, t0);
    float a1 = lerp(angleL, angleR, t1);

    float r0 = (height/2f) / max(0.0001f, sin(a0));
    float r1 = (height/2f) / max(0.0001f, sin(a1));

    float x0 = cos(a0) * r0, y0 = sin(a0) * r0;
    float x1 = cos(a1) * r1, y1 = sin(a1) * r1;

    float h  = hueForTriangleWithPalette((t0+t1)*0.5, paletteIdx);

    fill(h, 100, 100, alpha);
    beginShape();
    vertex(0,0);
    vertex(x0,y0);
    vertex(x1,y1);
    endShape(CLOSE);
  }
  popStyle();
}

float hueForTriangleWithPalette(float tMid, int paletteIdx) {
  switch (paletteIdx) {
    case 0: return (tMid * 360f) % 360f;
    case 1: return lerp(10, 60, tMid);
    case 2: return lerp(180, 260, tMid);
    case 3: return lerp(280, 330, tMid);
    default: return (tMid * 360f) % 360f;
  }
}

void strokeHSB(float h, float s, float b) {
  colorMode(HSB, 360, 100, 100);
  stroke(color(h, s, b));
  colorMode(RGB, 255);
}

void drawHahaPulse() {
  if (hahaImg == null) return;
  float cx = width*0.5;
  float cy = height*0.5;
  float pulse = 1.0 + 0.08 * sin(frameCount * 0.2);
  hint(DISABLE_DEPTH_TEST);
  pushMatrix();
  pushStyle();
  imageMode(CENTER);
  blendMode(BLEND);
  tint(255);
  float maxW = width * 0.5;
  float maxH = height * 0.5;
  float ss   = min(maxW / hahaImg.width, maxH / hahaImg.height) * pulse;
  translate(cx, cy);
  scale(ss);
  image(hahaImg, 0, 0);
  popStyle();
  popMatrix();
  hint(ENABLE_DEPTH_TEST);
}

void drawSurferLayer() {
  if (surfer == null) return;
  x = tx;
  y = ty;
  
  // Track when switching to Warp07
  if (bgMode == 5 && w7_lastBgMode != 5) {
    w7_surferTimer = 0; // Reset timer when entering Warp07
  }
  w7_lastBgMode = bgMode;
  
  float bob   = sin(frameCount*0.045)*14;
  float tilt  = radians(sin(frameCount*0.028)*6);
  float pulse = map(sin(frameCount*0.018), -1, 1, 0.92, 1.08);
  float currentScale = s * pulse;
  
  // Special effect for Warp07: rotate and shrink to disappear
  float extraRotation = 0;
  float shrinkFactor = 1.0;
  if (bgMode == 5) { // Warp07
    w7_surferTimer += 0.02; // Increment timer
    extraRotation = w7_surferTimer * 2; // Continuous rotation
    shrinkFactor = max(0, 1.0 - (w7_surferTimer * 0.15)); // Shrink over ~6-7 seconds
    currentScale *= shrinkFactor;
  }
  
  // Only draw if not completely shrunk
  if (currentScale > 0.01) {
    hint(DISABLE_DEPTH_TEST);
    pushMatrix();
    pushStyle();
    blendMode(BLEND);
    tint(255);
    imageMode(CENTER);
    translate(tx, ty + bob);
    rotate(tilt + extraRotation);
    scale(currentScale);
    image(surfer, 0, 0);
    popStyle();
    popMatrix();
    hint(ENABLE_DEPTH_TEST);
  }
}

void drawMiddleImages(int tms) {
  hint(DISABLE_DEPTH_TEST);
  
  // Sun4 - pulsating in top right corner (24-34s)
  if (sun4Img != null && tms >= MIDDLE_START_MS && tms < MIDDLE_END_MS) {
    float pulse = 1.0 + 0.12 * sin(frameCount * 0.15);
    pushMatrix();
    pushStyle();
    blendMode(BLEND);
    tint(255);
    imageMode(CENTER);
    
    float imgScale = 0.15 * pulse;
    float sunX = (width - 150) * 0.75 * 1.08 * 1.2;
    float sunY = 100 * 1.2 * 1.3;
    translate(sunX, sunY);
    scale(imgScale);
    image(sun4Img, 0, 0);
    
    popStyle();
    popMatrix();
  }
  
  // Moon - pulsating in same position as sun (34-44s)
  if (moonImg != null && tms >= MOON_START_MS && tms < MOON_END_MS) {
    float pulse = 1.0 + 0.12 * sin(frameCount * 0.15);
    pushMatrix();
    pushStyle();
    blendMode(BLEND);
    tint(255);
    imageMode(CENTER);
    
    float imgScale = 0.15 * pulse;
    float moonX = (width - 150) * 0.75 * 1.08 * 1.2;
    float moonY = 100 * 1.2 * 1.3;
    translate(moonX, moonY);
    scale(imgScale);
    image(moonImg, 0, 0);
    
    popStyle();
    popMatrix();
  }
  
  // Speech bubbles continue as before...
  if (tms >= SPEECH_START_MS && tms < SPEECH_END_MS) {
    int elapsed = tms - SPEECH_START_MS;
    int cyclePos = (elapsed / SPEECH_CYCLE_MS) % 3;
    
    float cycleProgress = (elapsed % SPEECH_CYCLE_MS) / (float)SPEECH_CYCLE_MS;
    float pulse;
    
    if (cycleProgress < 0.5) {
      pulse = map(cycleProgress, 0, 0.5, 0, 1);
    } else {
      pulse = map(cycleProgress, 0.5, 1, 1, 0);
    }
    
    pulse = pulse * (0.8 + 0.2 * sin(frameCount * 0.1));
    
    if (cyclePos == 0 && twoMeImg != null) {
      pushMatrix();
      pushStyle();
      blendMode(BLEND);
      tint(255, pulse * 255);
      imageMode(CENTER);
      
      float imgScale = 0.15 * 0.8;
      translate(150, height / 2 * 1.2);
      scale(imgScale);
      image(twoMeImg, 0, 0);
      
      popStyle();
      popMatrix();
    } else if (cyclePos == 1 && sayWhatImg != null) {
      pushMatrix();
      pushStyle();
      blendMode(BLEND);
      tint(255, pulse * 255);
      imageMode(CENTER);
      
      float imgScale = 0.15;
      translate(width - 150, height / 2 * 1.08);
      scale(imgScale);
      image(sayWhatImg, 0, 0);
      
      popStyle();
      popMatrix();
    } else if (cyclePos == 2 && huhImg != null) {
      pushMatrix();
      pushStyle();
      blendMode(BLEND);
      tint(255, pulse * 255);
      imageMode(CENTER);
      
      float imgScale = 0.15;
      translate(150 * 1.15, 100 * 1.2 * 1.1 * 1.1);
      scale(imgScale);
      image(huhImg, 0, 0);
      
      popStyle();
      popMatrix();
    }
  }
  
  hint(ENABLE_DEPTH_TEST);
}

void drawCornerImages(int tms, float fadeAlpha) {
  if (attentionImg == null || feelGoodImg == null) {
    fill(255, 0, 0);
    textSize(14);
    text("Missing corner images! Check console.", 10, height - 20);
    return;
  }
  
  int elapsedInWindow = tms - CORNER_START_MS;
  int cyclePosition = (elapsedInWindow / CORNER_CYCLE_MS) % 4;
  
  PImage currentImg = null;
  float imgX = 0, imgY = 0;
  
  fill(255, 255, 0);
  textSize(12);
  text("Cycle: " + cyclePosition + " | Time: " + (tms/1000) + "s", width - 200, 20);
  
  switch(cyclePosition) {
    case 0:
      currentImg = attentionImg;
      imgX = 150 * 1.15;
      imgY = 100 * 1.2 * 1.1 * 1.1;
      break;
    case 1:
      currentImg = feelGoodImg;
      imgX = width - 150;
      imgY = 100 * 1.2 * 1.1;
      break;
    case 2:
      currentImg = attentionImg;
      imgX = width - 150;
      imgY = height - 100;
      break;
    case 3:
      currentImg = feelGoodImg;
      imgX = 150;
      imgY = height - 100;
      break;
  }
  
  if (currentImg != null) {
    hint(DISABLE_DEPTH_TEST);
    pushMatrix();
    pushStyle();
    blendMode(BLEND);
    tint(255, fadeAlpha * 255);
    imageMode(CENTER);
    
    float imgScale = 0.15;
    translate(imgX, imgY);
    scale(imgScale);
    image(currentImg, 0, 0);
    
    popStyle();
    popMatrix();
    hint(ENABLE_DEPTH_TEST);
  }
}

void keyPressed() {
  if (key == 'm' || key == 'M') followMouse = !followMouse;

  if (key == 'o' || key == 'O') manualDir *= -1;

  if (key == 'u' || key == 'U') triPalette = (triPalette + 1) % 4;
  if (key == 'p' || key == 'P') bgMode = (bgMode + 1) % 6;

  if (keyCode == LEFT)  tx -= 10;
  if (keyCode == RIGHT) tx += 10;
  if (keyCode == UP)    ty -= 10;
  if (keyCode == DOWN)  ty += 10;

  if (key == '+') s *= 1.05;
  if (key == '-') s *= 0.95;

  if (music != null) {
    if (key == ' ') {
      if (music.isPlaying()) music.pause();
      else { music.cue(SEGMENT_START_MS); music.play(); }
    }
    if (key == 'l' || key == 'L') segmentLoop = !segmentLoop;
    if (key == 'r' || key == 'R') { music.cue(SEGMENT_START_MS); music.play(); }
    if (key == 's' || key == 'S') { music.pause(); music.cue(SEGMENT_START_MS); }
    if (key == '[') { musicGainDb -= 1.5; music.setGain(musicGainDb); }
    if (key == ']') { musicGainDb += 1.5; music.setGain(musicGainDb); }
  }
}

void stop() {
  try {
    if (music != null) music.close();
    if (minim != null) minim.stop();
  } catch (Exception e) { }
  super.stop();
}

class Star {
  float angle;
  float distance;
  float speed;
  float length;
  float hue;

  Star() { reset(); }
  void reset() {
    angle = random(TWO_PI);
    distance = random(0, 50);
    speed = random(3, 8) * 0.8;
    length = random(5, 25);
    hue = random(360);
  }
  void update() {
    distance += speed + distance * 0.03 * 0.8;
    if (distance > max(width, height)) reset();
  }
  void display() {
    float x1 = cos(angle) * distance;
    float y1 = sin(angle) * distance;
    float x2 = cos(angle) * (distance + length + distance*0.05);
    float y2 = sin(angle) * (distance + length + distance*0.05);
    strokeHSB(hue, 80, 100);
    strokeWeight(map(distance, 0, max(width, height), 1, 4));
    line(x1, y1, x2, y2);
  }
}
