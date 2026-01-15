//  TODO - We are not using our gaussian blur for now because it is sweeping our background color
//  * blur.glsl is an adaptation of https://www.shadertoy.com/view/Xltfzj 
//  There it reads "This is a very simple, compact and very fast Gaussian Blur shader based on
//the Gaussian Blur shader published at https://xorshaders.weebly.com/tutorials/blur-shaders-5-part-2

// ROADMAP
// 1. Allow usage of a custom halftone pattern
// 2. Interactive distorion of the halftone pattern

PShader blur, halftone, blurLinH, blurLinV;
PGraphics pg1, pg2; // Use two PGraphics for potential feedback loops or just one as a source for the final pass
PImage img;
int opt = 2;
//  circles
float ringDensity = 4.0f;
//  lines
float lin_phase = 0.0f;
float lin_period = 0.5f;
float lin_orientation = 0.0f;

float blur_directions = 16.0;  // BLUR DIRECTIONS (Default 16.0 - More is better but slower)
float blur_quality = 4.0;  // BLUR QUALITY (Default 4.0 - More is better but slower)
float blur_size = 8.0;  // BLUR SIZE (Radius)

void setup() {
  /*size(800, 800, P2D); // 1000, 1000
  pg1 = createGraphics(800, 800, P2D);
  pg2 = createGraphics(800, 800, P2D);
  img = loadImage("f_800x800_fundof0f0f0.png");*/
  /*size(560, 560, P2D); // 1000, 1000
  pg1 = createGraphics(560, 560, P2D);
  pg2 = createGraphics(560, 560, P2D);
  img = loadImage("f_blur_linear_fundof0f0f0.png");*/
  /*size(438, 418, P3D);
  pg1 = createGraphics(438, 418, P2D);
  pg2 = createGraphics(438, 418, P2D);
  img = loadImage("ficpop_texto_fundof0f0f0.png");*/
  size(1536, 1024, P3D);
  pg1 = createGraphics(1536, 1024, P2D);
  pg2 = createGraphics(1536, 1024, P2D);
  img = loadImage("encarnado_1536x1024_fundoBranco.png");
  
  halftone = loadShader("halftones.glsl");
  halftone.set("tex0", img);
  halftone.set("option", 2);       // 0 = shape halftone, 1 = line halftone, 2 = circle halftone
  // shapes
  halftone.set("shapeType", 0);    // 0 = circle, 1 = square, 2 = diamond
  // circles
  halftone.set("ringDensity", ringDensity);
  halftone.set("center", 0.5, 0.5);
  // lines
  halftone.set("lin_phase", lin_phase);
  halftone.set("lin_freq", 1.0f/lin_period);
  halftone.set("lin_orientation", lin_orientation);
  
  /*blur = loadShader("blur.glsl");  //"blur.frag", "blur.vert");
  blur.set("u_resolution", (float)width, (float)height);
  blur.set("Directions", blur_directions);
  blur.set("Quality", blur_quality);
  blur.set("Size", blur_size);*/
  
  blurLinH = loadShader("blur_linear_horizontal.glsl");
  blurLinH.set("u_resolution", (float)width, (float)height);
  blurLinH.set("Size", blur_size);
  blurLinV = loadShader("blur_linear_vertical.glsl");
  blurLinV.set("u_resolution", (float)width, (float)height);
  blurLinV.set("Size", blur_size);
  
  
  reset_parameters(opt);
}

void reset_parameters(int option) {
  switch(option)
  {
    case 0: break;
    
    case 1:
    lin_phase = 0.0f;
    lin_period = 0.5f;
    lin_orientation = 0.0f;
    halftone.set("lin_phase", lin_phase);
    halftone.set("lin_freq", 1.0f/lin_period);
    halftone.set("lin_orientation", lin_orientation);
    break;
    
    case 2:
    ringDensity = 4.0f;
    halftone.set("ringDensity", ringDensity);
    break;
  }
  
  blur_directions = 16.0;
  blur_quality = 4.0;
  blur_size = 8.0;
  /*blur.set("Directions", blur_directions);
  blur.set("Quality", blur_quality);
  blur.set("Size", blur_size);*/
  
  blurLinH.set("Size", blur_size);
  blurLinV.set("Size", blur_size);
}

void draw() {
  halftone.set("resolution", float(width), float(height));
  
  // --- Pass 1 ---
  pg1.beginDraw();
  pg1.shader(blurLinV); // blur (and then halftone is in Pass 2) when we improve our blur
  pg1.image(img, 0, 0, width, height);
  pg1.endDraw();
  
  // --- Pass 2 ---
  pg2.beginDraw();
  pg2.shader(blurLinH);
  pg2.image(pg1, 0, 0);
  pg2.endDraw();
  
  // --- Pass 3 ---
  shader(halftone); // Apply the second shader to the main drawing surface
  // Draw the results to the main sketch window
  image(pg2, 0, 0);
  
  //  And invert colors
  filter(INVERT);
}

void mouseMoved() {
  switch (opt) {
    case 1:
    lin_orientation = atan( (mouseX - width/2.0f) / (mouseY - height/2.0f) );
    halftone.set("lin_orientation", lin_orientation);
    print("lin_orientation: " + lin_orientation);
    break;
    case 2:
    halftone.set("center", mouseX/float(width), mouseY/float(height));
    break;
  }
}

void keyReleased() {
  int key_minus_48 = int(key) - 48;
  if(key_minus_48 <= 9 && key_minus_48 >= 0) {
    opt = key_minus_48;
    halftone.set("option", opt);
  }
  else if (key == 'r') {
    reset_parameters(opt);
  }
  else if (key == '-') {
    lin_phase -= 0.025;
    halftone.set("lin_phase", lin_phase);
    println("lin_phase: " + lin_phase);
  }
  else if (key == '+') {
    lin_phase += 0.025;
    halftone.set("lin_phase", lin_phase);
    println("lin_phase: " + lin_phase);
  }
  else if (key == CODED) {
    println("opt: " + opt);
    if(keyCode == UP) {
      if(opt == 2) {
        ringDensity++;
        halftone.set("ringDensity", ringDensity);
      }
      else if(opt == 1) {
        lin_period += 0.01;
        halftone.set("lin_freq", 1.0f/lin_period);
        print("lin_period: " + lin_period + ", lin_freq: " + (1.0f/lin_period));
      }
    }
    else if(keyCode == DOWN) {
      if(opt == 2) {
        if(ringDensity > 1) {
          ringDensity--;
          halftone.set("ringDensity", ringDensity);
        }
      }
      else if(opt == 1) {
        lin_period -= 0.01;
        halftone.set("lin_freq", 1.0f/lin_period);
        print("lin_period: " + lin_period + ", lin_freq: " + (1.0f/lin_period));
      }
    }
    else if(keyCode == RIGHT) {
      blur_size++;
      /*blur.set("Size", blur_size);*/
      blurLinH.set("Size", blur_size);
      blurLinV.set("Size", blur_size);
    }
    else if(keyCode == LEFT) {
      if(blur_size > 1) {
        blur_size--;
        /*blur.set("Size", blur_size);*/
        blurLinH.set("Size", blur_size);
        blurLinV.set("Size", blur_size);
      }
    }
  }
}
