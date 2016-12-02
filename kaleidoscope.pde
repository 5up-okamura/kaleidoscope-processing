/*
 * Kaleidoscope
 * code by hiroshi okamura (okamura@5andup.com, @agesfiveandup)
 */
import processing.video.*;
import processing.serial.*;

boolean useSrrial = false;
Serial myPort;

Capture cam;
PGraphics mask;
PImage maskedImage;

float rotation;

void setup() {
    size(1280, 960, P2D);
    frameRate(60);

    if (useSrrial) myPort = new Serial(this, Serial.list()[3], 9600);

    startCamera();

    imageMode(CENTER);
    background(0);
}

void draw() {
    if (cam == null) return;

    if (cam.available()) {
        cam.read();
        if (mask == null) makeTriangleMask();
        maskedImage = cam.get();
        maskedImage.mask(mask);
    }

    if (maskedImage == null) return;

    if (myPort != null && myPort.available() > 0) {
        rotation = myPort.read()/255.0*TWO_PI;
    }

    translate(width/2, height/2);
    if (myPort == null) rotation += PI*0.0005;
    rotate(rotation);

    // Draw original image
    //image(cam, 0, 0, width, height);

    blendMode(BLEND);
    tint(255, 16);

    float s = width/maskedImage.width;
    s *= (sin(TWO_PI*frameCount/60.0/32.0) + 1) + 1;

    for (int i = 0; i < 8; ++ i) {
        pushMatrix();
        rotate(TWO_PI/8*i);
        translate(0, width*0.28);
        if ((i & 1) == 0) scale(-1, 1);
        image(maskedImage, 0, 0, maskedImage.width*s, maskedImage.height*s);
        popMatrix();
    }
}

void makeTriangleMask() {
    int w = cam.width, h = cam.height;
    mask = createGraphics(w, h);
    mask.beginDraw();

    mask.background(0);

    mask.fill(255);
    mask.noStroke();

    mask.beginShape();
    mask.vertex(w/2, 0);
    mask.vertex(w/2 + w*0.207, w/2);
    mask.vertex(w/2 - w*0.207, w/2);
    mask.endShape();

    mask.endDraw();
}

void startCamera() {
    String[] cameras = Capture.list();
    printArray(cameras);
    if (cameras.length == 0) {
        println("There are no cameras available for capture.");
        exit();
    } else {
        //[3] "name=FaceTime HD Camera,size=640x360,fps=30"
        cam = new Capture(this, cameras[3]);
        cam.start();
    }
}