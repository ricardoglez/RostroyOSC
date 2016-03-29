import processing.video.*;
import gab.opencv.*;
import java.awt.Rectangle;
import oscP5.*;
import netP5.*;

OscP5 oscp5;
NetAddress dir;

// Library object
OpenCV caraCV;
OpenCV ojosCV;
OpenCV narizCV;
OpenCV bocaCV;

PFont fuente;

color cProceso = #8c1b1b;
color cCompreto = #105e31;

// Capture object
Capture cam;

// Scaled down image
PImage smaller;

// Array of caras found
Rectangle[] caras;
Rectangle[] ojos;
Rectangle[] nariz;
Rectangle[] boca;

boolean caraB = false, ojosB = false, narizB = false, bocaB = false;

int scale = 4;

int colorMuestra ;

int numMuestras = 1;

// Arreglos de los datos guardados
int[] caraDatos = new int[4];  // Orden de Valores de matriz//x, y ,w, h //
int[] ojosDatos = new int[4];  // x0, y0 ,w0, h0, //x1, y1 ,w1, h1//
int[] bocaDatos = new int[4];  // x, y ,w, h//
int[] narizDatos = new int[4]; // x, y ,w, h//

void setup() {
  size(640, 480);
  // Start capturing
  cam = new Capture(this, 640, 480, "/dev/video0");
  cam.start();

  fuente = loadFont("ArialMT-48.vlw");

  // Obtiene datos
  oscp5 = new OscP5(this, 12000);
  // Envia datos
  dir = new NetAddress("127.0.1.1", 12000);
  // Create the OpenCV object
  caraCV = new OpenCV(this, cam.width / scale, cam.height / scale);
  ojosCV = new OpenCV(this, cam.width / scale, cam.height / scale);
  narizCV = new OpenCV(this, cam.width / scale, cam.height / scale);
  bocaCV = new OpenCV(this, cam.width / scale, cam.height / scale);

  // Archivos de cascada
  caraCV.loadCascade(OpenCV.CASCADE_FRONTALFACE);
  ojosCV.loadCascade("haarcascade_mcs_eyepair_small.xml");
  narizCV.loadCascade(OpenCV.CASCADE_NOSE);
  bocaCV.loadCascade(OpenCV.CASCADE_MOUTH);
  // ojosCV.loadCascade(OpenCV.CASCADE_EYE);
  // ojosCV.loadCascade("haarcascade_eye_tree_eyeglasses.xml");
  // ojosCV.loadCascade("haarcascade_mcs_righteye.xml");
  // Make scaled down image
  smaller = createImage(caraCV.width, caraCV.height, RGB);
}

void draw() {
  background(0);
  //ObtenerDatos de camara
  cam.read();
  // Copiar contenido a la imagen escalada
  smaller.copy(cam, 0, 0, cam.width, cam.height, 0, 0, smaller.width,smaller.height);
  smaller.updatePixels();

  caraCV.loadImage(smaller);
  ojosCV.loadImage(smaller);
  narizCV.loadImage(smaller);
  bocaCV.loadImage(smaller);

  // caras
  caras = caraCV.detect();
  ojos = ojosCV.detect();
  nariz = narizCV.detect();
  boca = bocaCV.detect();
//Imagen de la Camara
  image(cam, 0, 0);
//Proceso de crear una paleta de color
  //fill(#00ff00);
  //ellipse(width/2, height-height/20, 5,5);
  colorMuestra = get(width/2, height - height/20);

  //fill(colorMuestra);
  //noStroke();
  //rect(50,50, width/10,80);
  sendDataC();

  if (caras != null) {
    caraB = true;
    for (int car = 0; car < caras.length; car++) {
      caraDatos[0] = caras[car].x * scale;      // ubicacion de cara x
      caraDatos[1] = caras[car].y * scale;      // ubicacion de cara y
      caraDatos[2] = caras[car].width * scale;  // ancho de cara
      caraDatos[3] = caras[car].height * scale; // alto de cara
    noStroke();
     fill(#ffffff);
            textSize(16);
      text("Cara: x-" + caraDatos[0] + " y-" + caraDatos[1] + " w-" +
               caraDatos[2] + " h-" + caraDatos[3],
           caraDatos[0], caraDatos[1] - 30);
      strokeWeight(5);
      stroke(cProceso);
      noFill();
      rect(caraDatos[0], caraDatos[1], caraDatos[2], caraDatos[3]);

      // Dentro de la cara hay ojos
      if ((ojos.length != 0) &&
          ((ojos[0].x * scale > caraDatos[0]) &&
           (ojos[0].x * scale < caraDatos[0] + caraDatos[2])) &&
          ((ojos[0].y * scale > caraDatos[1]) &&
           (ojos[0].y * scale < caraDatos[1] + caraDatos[3]))) {
        ojosB = true;
        ojosDatos[0] = ojos[0].x * scale;      // ubicacion de ojo x
        ojosDatos[1] = ojos[0].y * scale;      // ubicacion de ojo y
        ojosDatos[2] = ojos[0].width * scale;  // ancho de ojo
        ojosDatos[3] = ojos[0].height * scale; // alto de ojo
        noStroke();
        fill(#ffffff);
            textSize(16);
        text("Ojos: x-" + ojosDatos[0] + " y-" + ojosDatos[1] + " w-" +
                 ojosDatos[2] + " h-" + ojosDatos[3],
             ojosDatos[0], ojosDatos[1] - 30);
         strokeWeight(5);
         stroke(cProceso);
         noFill();
        rect(ojosDatos[0], ojosDatos[1], ojosDatos[2], ojosDatos[3]);
        // Dentro de la cara hay una nariz
        if ((nariz.length != 0) &&
            ((nariz[0].x * scale > caraDatos[0]) &&
             (nariz[0].x * scale < caraDatos[0] + caraDatos[2])) &&
            ((nariz[0].y * scale > caraDatos[1]) &&
             (nariz[0].y * scale < caraDatos[1] + caraDatos[3])) &&
            (nariz[0].width * scale < caraDatos[2] / 2)) {
          narizB = true;
          strokeWeight(5);
          stroke(cProceso);
          narizDatos[0] = nariz[0].x * scale;      // ubicacion de ojo x
          narizDatos[1] = nariz[0].y * scale;      // ubicacion de ojo y
          narizDatos[2] = nariz[0].width * scale;  // ancho de ojo
          narizDatos[3] = nariz[0].height * scale; // alto de ojo
          noStroke();
          fill(#ffffff);
            textSize(16);
          text("Nariz: x-" + narizDatos[0] + " y-" + narizDatos[1] + " w-" +
                   narizDatos[2] + " h-" + narizDatos[3],
               narizDatos[0] - 200, narizDatos[1] + narizDatos[3] - 30);
           strokeWeight(5);
           stroke(cProceso);
           noFill();
          rect(narizDatos[0], narizDatos[1], narizDatos[2], narizDatos[3]);

          // Dentro de la cara hay una boca
          if ((boca.length != 0) &&
              ((boca[0].x * scale > caraDatos[0]) &&
               (boca[0].x * scale < caraDatos[0] + caraDatos[2])) &&
              ((boca[0].y * scale > caraDatos[1]) &&
               (boca[0].y * scale < caraDatos[1] + caraDatos[3])) &&
              (boca[0].y * scale > ojosDatos[1] &&
               boca[0].y * scale < caraDatos[1] + caraDatos[3])) {
            bocaB = true;
            bocaDatos[0] = boca[0].x * scale;      // ubicacion de ojo x
            bocaDatos[1] = boca[0].y * scale;      // ubicacion de ojo y
            bocaDatos[2] = boca[0].width * scale;  // ancho de ojo
            bocaDatos[3] = boca[0].height * scale; // alto de ojo
            noStroke();
            fill(#ffffff);
            textSize(16);

            text("Boca: x-" + bocaDatos[0] + " y-" + bocaDatos[1] + " w-" +
                     bocaDatos[2] + " h-" + bocaDatos[3],
                 bocaDatos[0], bocaDatos[1] + bocaDatos[3] + 30);
             strokeWeight(5);
             stroke(cProceso);
             noFill();
            rect(bocaDatos[0], bocaDatos[1], bocaDatos[2], bocaDatos[3]);

            sendData();
          } else {
            bocaB = false;
          }
        } else {
          narizB = false;
          bocaB = false;
        }
      } else {
        ojosB = false;
        narizB = false;
        bocaB = false;
      }
    } // Final del For loop de las caras
  } else {
    caraB = false;
    ojosB = false;
    narizB = false;
    bocaB = false;
  }
  dibujarIconos();


  //println("Cara : ", caraB);
  //println("Ojos : ", ojosB);
  //println("Nariz : ", narizB);
  //println("Boca : ", bocaB);
}

void dibujarIconos() {
  PImage carab, carar, carav, ojob, ojor, ojov, narizr, narizb, narizv, bocab,
      bocar, bocav;
  carav = loadImage("cara00v.png");
  carab = loadImage("cara00b.png");
  carar = loadImage("cara00r.png");

  ojob = loadImage("ojo3b.png");
  ojor = loadImage("ojo3r.png");
  ojov = loadImage("ojo3v.png");

  narizb = loadImage("nariz2b.png");
  narizr = loadImage("nariz2r.png");
  narizv = loadImage("nariz2v.png");

  bocab = loadImage("boca3b.png");
  bocar = loadImage("boca3r.png");
  bocav = loadImage("boca3v.png");
  int ran = round(random(25800,28999));
  int margen = 40;

  translate(30, height / 2 - height / 5);
  pushMatrix();

  fill(#ffffff);
  String txt = "1/"+ ran;
  textSize(10);
   text(txt,520 ,320 );
  scale(.2);
  if (caraB == true) {
    image(carav, 0, margen);
  } else {
    image(carar, 0, margen);
  }
  // image(carab, 0, margen);

  if (ojosB == true) {
    image(ojov, 0, margen * 8);
  } else {
    image(ojor, 0, margen * 8);
  }
  // image(ojob, 0, margen * 8);

  if (narizB == true) {
    image(narizv, 0, margen * 16);
  } else {
    image(narizr, 0, margen * 16);
  }
  // image(narizb, 0, margen * 16);

  if (bocaB == true) {
    image(bocav, 0, margen * 24);
  } else {
    image(bocar, 0, margen * 24);
  }
  // image(bocab, 0, margen * 24);

  popMatrix();
}

void keyPressed() {
  println("Muestra Guardada");
  PImage muestra = createImage(caraDatos[2], caraDatos[3], RGB);
  muestra.copy(cam, caraDatos[0], caraDatos[1], caraDatos[2], caraDatos[3], 0,
               0, caraDatos[2], caraDatos[2]);
  muestra.updatePixels();
  muestra.save("muestra-0.jpg");
  println("Muestra Guardada");
}


void sendData() {
  OscMessage msjCara = new OscMessage("/datos/cara/");
  msjCara.add((int)caraDatos[0]);//x Cara
  msjCara.add((int)caraDatos[1]);//y Cara
  msjCara.add((int)caraDatos[2]);//ancho Cara
  msjCara.add((int)caraDatos[3]);//alto Cara
  oscp5.send( msjCara, dir);
OscMessage msjOjos = new OscMessage("/datos/ojos/");
  msjOjos.add((int)ojosDatos[0]);// x Ojos
  msjOjos.add((int)ojosDatos[1]);//y Ojos
  msjOjos.add((int)ojosDatos[2]);// ancho Ojos
  msjOjos.add((int)ojosDatos[3]);//alto Ojos
  oscp5.send(msjOjos, dir);
OscMessage msjNariz = new OscMessage("/datos/nariz/");
  msjNariz.add((int)narizDatos[0]);//x Nariz
  msjNariz.add((int)narizDatos[1]);//y Nariz
  msjNariz.add((int)narizDatos[2]);//ancho Nariz
  msjNariz.add((int)narizDatos[3]);//alto Nariz
  oscp5.send(msjNariz, dir);
OscMessage msjBoca = new OscMessage("/datos/boca/");
  msjBoca.add((int)bocaDatos[0]);//x Boca
  msjBoca.add((int)bocaDatos[1]);//y Boca
  msjBoca.add((int)bocaDatos[2]);//ancho Boca
  msjBoca.add((int)bocaDatos[3]);//alto Boca
  oscp5.send(msjBoca, dir);
//Imprimir Los Mensajes
/*/Cara
  println("/datos/cara/:", msjCara.get(0).intValue());
  println("/datos/cara/:", msjCara.get(1).intValue());
  println("/datos/cara/:", msjCara.get(2).intValue());
  println("/datos/cara/:", msjCara.get(3).intValue());
  println("####TypeTag:", msjCara.typetag());
//Ojos
  println("/datos/ojos/:", msjOjos.get(0).intValue());
  println("/datos/ojos/:", msjOjos.get(1).intValue());
  println("/datos/ojos/:", msjOjos.get(2).intValue());
  println("/datos/ojos/:", msjOjos.get(3).intValue());
  println("####TypeTag:", msjOjos.typetag());
//Nariz
  println("/datos/nariz/:", msjNariz.get(0).intValue());
  println("/datos/nariz/:", msjNariz.get(1).intValue());
  println("/datos/nariz/:", msjNariz.get(2).intValue());
  println("/datos/nariz/:", msjNariz.get(3).intValue());
  println("####TypeTag:", msjNariz.typetag());
//Boca
  println("/datos/boca/:", msjBoca.get(0).intValue());
  println("/datos/boca/:", msjBoca.get(1).intValue());
  println("/datos/boca/:", msjBoca.get(2).intValue());
  println("/datos/boca/:", msjBoca.get(3).intValue());
  println("####TypeTag:", msjBoca.typetag());
*/
}

void sendDataC() {
    OscMessage msjColor = new OscMessage("/datos/color/");
      msjColor.add((int)colorMuestra);//Color Muestra
      oscp5.send(msjColor, dir);
  //Color
    println("/datos/color/:", msjColor.get(0).intValue());
    println("####TypeTag:", msjColor.typetag());
}
