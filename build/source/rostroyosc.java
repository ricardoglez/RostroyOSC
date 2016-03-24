import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import processing.video.*; 
import gab.opencv.*; 
import java.awt.Rectangle; 
import oscP5.*; 
import netP5.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class rostroyosc extends PApplet {







OscP5 oscp5;
NetAddress dir;

// Library object
OpenCV caraCV;
OpenCV ojosCV;
OpenCV narizCV;
OpenCV bocaCV;

PFont fuente;

// Capture object
Capture cam;

// Scaled down image
PImage smaller;

// Array of caras found
Rectangle[] caras;
Rectangle[] ojos;
Rectangle[] nariz;
Rectangle[] boca;

int scale = 4;

int numMuestras = 1;

//Arreglos de los datos guardados
int[] caraDatos = new int[4]; //Orden de Valores de matriz//x, y ,w, h //
int[] ojosDatos = new int[8]; //x0, y0 ,w0, h0, //x1, y1 ,w1, h1//
int[] bocaDatos = new int[4];//x, y ,w, h//
int[] narizDatos = new int[4];//x, y ,w, h//


public void setup() {
  

  // Start capturing
  cam = new Capture(this, 640, 480, "/dev/video0");
  cam.start();

  fuente = loadFont("ArialMT-48.vlw");

  //Obtiene info
  oscp5 = new OscP5(this, 12000);
  //Envia info
  dir = new NetAddress("127.0.0.1", 6448);

  // Create the OpenCV object
  caraCV = new OpenCV(this, cam.width/scale, cam.height/scale);
  ojosCV = new OpenCV(this, cam.width/scale, cam.height/scale);
  narizCV = new OpenCV(this, cam.width/scale, cam.height/scale);
  bocaCV  = new OpenCV(this, cam.width/scale, cam.height/scale);

  // Which "cascade" are we going to use?
  caraCV.loadCascade(OpenCV.CASCADE_FRONTALFACE);
  //ojosCV.loadCascade(OpenCV.CASCADE_EYE);
  //ojosCV.loadCascade("haarcascade_eye_tree_eyeglasses.xml");
  ojosCV.loadCascade("haarcascade_mcs_eyepair_small.xml");
  //ojosCV.loadCascade("haarcascade_mcs_righteye.xml");

  narizCV.loadCascade(OpenCV.CASCADE_NOSE);
  bocaCV.loadCascade(OpenCV.CASCADE_MOUTH);

  // Make scaled down image
  smaller = createImage(caraCV.width, caraCV.height, RGB);
}

public void draw() {

  background(0);

  cam.read();
  // Make smaller image
  smaller.copy(cam, 0, 0, cam.width, cam.height, 0, 0, smaller.width, smaller.height);
  smaller.updatePixels();

  // We have to always "load" the  image into OpenCV
  // But we check against the smaller image here
  caraCV.loadImage(smaller);
  ojosCV.loadImage(smaller);
  narizCV.loadImage(smaller);
  bocaCV.loadImage(smaller);

  // Detect the caras
  caras = caraCV.detect();
  ojos = ojosCV.detect();
  nariz = narizCV.detect();
  boca = bocaCV.detect();

  // Draw the video
  image(cam, 0, 0);

  // If we find caras, draw them!

  if (caras != null) {
    for (int car = 0; car < caras.length; car++) {
      caraDatos[0] = caras[car].x*scale; // ubicacion de cara x
      caraDatos[1] = caras[car].y*scale; // ubicacion de cara y
      caraDatos[2] = caras[car].width*scale; // ancho de cara
      caraDatos[3] = caras[car].height*scale;// alto de cara

      text("Cara: x-"+caraDatos[0] +" y-"+caraDatos[1]+" w-"+caraDatos[2]+" h-"+caraDatos[3], caraDatos[0], caraDatos[1]-30);

      strokeWeight(2);
      stroke(255, 0, 0);
      noFill();
      rect(caraDatos[0], caraDatos[1], caraDatos[2], caraDatos[3]);

      //Dentro de la cara hay ojos
      if ((ojos.length != 0)
        && ((ojos[0].x*scale > caraDatos[0])&&(ojos[0].x*scale < caraDatos[0]+caraDatos[2]))
        && ((ojos[0].y*scale > caraDatos[1])&&(ojos[0].y*scale < caraDatos[1]+caraDatos[3]))
        )
      {
        strokeWeight(2);
        stroke( 0, 255, 0);
        noFill();

        ojosDatos[0] = ojos[0].x*scale; // ubicacion de ojo x
        ojosDatos[1] = ojos[0].y*scale; // ubicacion de ojo y
        ojosDatos[2] = ojos[0].width*scale; // ancho de ojo
        ojosDatos[3] = ojos[0].height*scale;// alto de ojo

        text("Ojos: x-"+ojosDatos[0] +" y-"+ojosDatos[1]+" w-"+ojosDatos[2]+" h-"+ojosDatos[3], ojosDatos[0], ojosDatos[1]-30);

        rect(ojosDatos[0], ojosDatos[1], ojosDatos[2], ojosDatos[3]);
        //Dentro de la cara hay una nariz
        if ((nariz.length != 0)
          && ((nariz[0].x*scale > caraDatos[0])&&(nariz[0].x*scale < caraDatos[0]+caraDatos[2]))
          && ((nariz[0].y*scale > caraDatos[1])&&(nariz[0].y*scale < caraDatos[1]+caraDatos[3]))
          && (nariz[0].width*scale < caraDatos[2]/2)
          )
        {
          strokeWeight(2);
          stroke( 0, 0, 255);
          noFill();


          narizDatos[0] = nariz[0].x*scale; // ubicacion de ojo x
          narizDatos[1] = nariz[0].y*scale; // ubicacion de ojo y
          narizDatos[2] = nariz[0].width*scale; // ancho de ojo
          narizDatos[3] = nariz[0].height*scale;// alto de ojo

          text("Nariz: x-"+narizDatos[0] +" y-"+narizDatos[1]+" w-"+narizDatos[2]+" h-"+narizDatos[3], narizDatos[0]-200, narizDatos[1]+narizDatos[3]-30);
          rect(narizDatos[0], narizDatos[1], narizDatos[2], narizDatos[3]);

          //Dentro de la cara hay una boca
          if ((boca.length != 0)
            && ((boca[0].x*scale > caraDatos[0]) && (boca[0].x*scale < caraDatos[0]+caraDatos[2]))
            && ((boca[0].y*scale > caraDatos[1]) && (boca[0].y*scale < caraDatos[1]+caraDatos[3]))
            && (boca[0].y*scale > ojosDatos[1] && boca[0].y*scale < caraDatos[1]+caraDatos[3])
            )
          {
            strokeWeight(2);
            stroke(255);
            noFill();

            bocaDatos[0] = boca[0].x*scale; // ubicacion de ojo x
            bocaDatos[1] = boca[0].y*scale; // ubicacion de ojo y
            bocaDatos[2] = boca[0].width*scale; // ancho de ojo
            bocaDatos[3] = boca[0].height*scale;// alto de ojo

            text("Boca: x-"+bocaDatos[0] +" y-"+bocaDatos[1]+" w-"+bocaDatos[2]+" h-"+bocaDatos[3], bocaDatos[0], bocaDatos[1]+bocaDatos[3]+30);
            rect(bocaDatos[0], bocaDatos[1], bocaDatos[2], bocaDatos[3] );
          }
        }
      }
    }
  }
}

public void mousePressed() {
  sendData();
}

public void sendData() {
  OscMessage myMessage = new OscMessage("/wek/inputs");
  myMessage.add((float)caraDatos[2]);
  myMessage.add((float)caraDatos[3]);
  myMessage.add((float)ojosDatos[2]);
  myMessage.add((float)ojosDatos[3]);
  myMessage.add((float)narizDatos[2]);
  myMessage.add((float)narizDatos[3]);
  myMessage.add((float)bocaDatos[2]);
  myMessage.add((float)bocaDatos[3]);
  oscp5.send(myMessage, dir);
  println("Mensaje:", myMessage.get(0).floatValue());
  println("Mensaje:", myMessage.get(1).floatValue());
  println("Mensaje:", myMessage.get(2).floatValue());
  println("Mensaje:", myMessage.get(3).floatValue());
  println("Mensaje:", myMessage.get(4).floatValue());
  println("Mensaje:", myMessage.get(5).floatValue());
  println("Mensaje:", myMessage.get(6).floatValue());
  println("Mensaje:", myMessage.get(7).floatValue());
}

public void oscEvent(OscMessage theOscMessage) {
  /* print the address pattern and the typetag of the received OscMessage */
  print("### received an osc message.");
  print(" addrpattern: "+theOscMessage.addrPattern());
}
  public void settings() {  size(640, 480); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "rostroyosc" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
