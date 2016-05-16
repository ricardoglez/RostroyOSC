import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import processing.video.*; 
import gab.opencv.*; 
import java.awt.Rectangle; 
import toxi.color.*; 
import toxi.color.theory.*; 
import toxi.util.datatypes.*; 
import java.util.Iterator; 
import oscP5.*; 
import netP5.*; 
import com.dhchoi.CountdownTimer; 
import com.dhchoi.CountdownTimerService; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class rostroyosc extends PApplet {













//Librerias de comunicacion OPENCV

OscP5 oscp5;
NetAddress dir;
// Library object
OpenCV caraCV;
OpenCV ojosCV;
OpenCV narizCV;
OpenCV bocaCV;
//Timers que controlan el tiempo que aparece la etiqueta y el Error
CountdownTimer timer;
CountdownTimer timerS ;

String[] etiqueta = {
  "HOMBRE", "MUJER"
};


PFont fuente, fuente1 ;

int cProceso = 0xff8c1b1b;
int cCompreto = 0xff105e31;
// Capture object
Capture cam;
// Scaled down image
PImage smaller;
// Array of caras, ojo ,nariz, boca
Rectangle[] caras;
Rectangle[] ojos;
Rectangle[] nariz;
Rectangle[] boca;
boolean caraB = false, ojosB = false, narizB = false, bocaB = false;

int scale = 4;

boolean capaEtiq = false;

PGraphics capaEtiquetas;

int contador = 0;
//dato del color muestra
int colorMuestra;
int numMuestras = 1;

// Arreglos de los datos guardados
int[] caraDatos = new int[4];  // Orden de Valores de matriz//x, y ,w, h //
int[] ojosDatos = new int[4];  // x0, y0 ,w0, h0, //x1, y1 ,w1, h1//
int[] bocaDatos = new int[4];  // x, y ,w, h//
int[] narizDatos = new int[4]; // x, y ,w, h//
//Este rand selecciona la primer etiqueta que aparezca
int rand ;


public void setup() {
  
  // Captura
  timer = CountdownTimerService.getNewCountdownTimer(this).configure(4000, 5000);
  timerS = CountdownTimerService.getNewCountdownTimer(this).configure(4000, 5000);
  //println(Capture.list());
  //cam = new Capture(this, 640, 480, "/dev/video0");
  cam = new Capture(this, 640, 480, "/dev/video0");
  cam.start();
  fuente1 = loadFont("CoolveticaRg-Regular-48.vlw");
  fuente = loadFont("Courier10PitchBT-Roman-48.vlw");
  textFont(fuente);
  // Recibe datos
  oscp5 = new OscP5(this, 12000);
  // Envia datos
  dir = new NetAddress("127.0.3.1", 12000);
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
  // Make scaled down image y capa de las etiquetas
  smaller = createImage(caraCV.width, caraCV.height, RGB);
  capaEtiquetas = createGraphics(cam.width, cam.height);
  rand = PApplet.parseInt(random(0, 1));
}

/*//////////////////////////////////////////////////////
 Funcion que genera todo el setup de las operaciones de
 vision computarizada
 *///////////////////////////////////////////////////////
public void preprocessing() {
  // ObtenerDatos de camara
  cam.read();
  // Copiar contenido a la imagen escalada
  smaller.copy(cam, 0, 0, cam.width, cam.height, 0, 0, smaller.width, smaller.height);
  smaller.updatePixels();
  //Cargar la imagen de captura escalada
  caraCV.loadImage(smaller);
  ojosCV.loadImage(smaller);
  narizCV.loadImage(smaller);
  bocaCV.loadImage(smaller);
  // caras
  caras = caraCV.detect();
  ojos = ojosCV.detect();
  nariz = narizCV.detect();
  boca = bocaCV.detect();
}
/*//////////////////////////////////////////////////////
 Funcion que Por medio de una muestra de un color de la camara
 ajusta la saturacion y la luminosidad del mismo para
 generar una paleta del color con la libreria toxiclibs
 *///////////////////////////////////////////////////////
public int tomarMuestra(int x_, int y_, int numMu_) {
  int muest_ = cam.get(x_, y_ );
  TColor colorM = TColor.newHex(hex(muest_, 6));
  //println("Muestra",colorM);
  TColor lightCol = colorM.getLightened(.32f);
  lightCol = lightCol.getSaturated(.5f);
  //lightCol = colorM.getLightened(.10);
  //lightCol = colorM.getBlended(satCol,15 );
  //int promCol =  (satCol.toARGB()+  lightCol.toARGB()) /2;
  //noFill();
  //strokeWeight(1);
  //stroke(#ff0000);
  //ellipseMode(CENTER);
  //ellipse(x_, y_, 5, 5);
  //fill(lightCol.toARGB());
  //noStroke();
  //rect(20, 50, 50, 30);
  //println("##Muestra",muest_);
  return lightCol.toARGB();
}

public void draw() {
  background(0);
  //Previous Settings
  preprocessing();
  // Imagen de la Camara
  image(cam, 0, 0);
  // Proceso de crear una paleta de color
  colorMuestra = tomarMuestra( (width / 2) /2, height - 50, 0);
  //Enviar el color obtenido
  sendData(0);
  //Dibujar Rectangulos y datos del
  dibujarAnalisis();
  dibujarIconos();

  //image(capaEtiquetas, 0, 0);
}

/*//////////////////////////////////////////////////////
 Funcion que dibuja los recudros y agrega la
 informacion obtenida del rostro
 *///////////////////////////////////////////////////////
public void dibujarAnalisis() {
  textFont(fuente);
  if (caras.length != 0) {
    caraB = true;
    for (int car = 0; car < caras.length; car++) {
      caraDatos[0] = caras[car].x * scale;      // ubicacion de cara x
      caraDatos[1] = caras[car].y * scale;      // ubicacion de cara y
      caraDatos[2] = caras[car].width * scale;  // ancho de cara
      caraDatos[3] = caras[car].height * scale; // alto de cara
      if ( timerS.getTimeLeftUntilFinish() > 2000  || timer.getTimeLeftUntilFinish() > 2000  ) {
        textSize(16);
        fill(0xffffffff);
        text("Cara: x-" + caraDatos[0] + " y-" + caraDatos[1] + " w-" +caraDatos[2] + " h-" + caraDatos[3],
         caraDatos[0], caraDatos[1] - 30);
         strokeWeight(3);
         stroke(0xffffffff);
         noFill();
         rect(caraDatos[0], caraDatos[1], caraDatos[2], caraDatos[3]);
      }

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
        if ( timerS.getTimeLeftUntilFinish() > 2000  || timer.getTimeLeftUntilFinish() > 2000  ) {
          fill(0xffffffff);
          textSize(16);
          text("Ojos: x-" + ojosDatos[0] + " y-" + ojosDatos[1] + " w-" +ojosDatos[2] + " h-" + ojosDatos[3],
           ojosDatos[0], ojosDatos[1] - 30);
           stroke(0xffffffff);
           strokeWeight(3);
           noFill();
           rect(ojosDatos[0], ojosDatos[1], ojosDatos[2], ojosDatos[3]);
        }
        //sendData(2);
        // Dentro de la cara hay una nariz
        if ((nariz.length != 0) &&
          ((nariz[0].x * scale > caraDatos[0]) &&
          (nariz[0].x * scale < caraDatos[0] + caraDatos[2])) &&
          ((nariz[0].y * scale > caraDatos[1]) &&
          (nariz[0].y * scale < caraDatos[1] + caraDatos[3])) &&
          (nariz[0].width * scale < caraDatos[2] / 2)) {
          narizB = true;
          narizDatos[0] = nariz[0].x * scale;      // ubicacion de ojo x
          narizDatos[1] = nariz[0].y * scale;      // ubicacion de ojo y
          narizDatos[2] = nariz[0].width * scale;  // ancho de ojo
          narizDatos[3] = nariz[0].height * scale; // alto de ojo
          if ( timerS.getTimeLeftUntilFinish() > 2000  || timer.getTimeLeftUntilFinish() > 2000  ) {
            fill(0xffffffff);
            textSize(16);
            text("Nariz: x-" + narizDatos[0] + " y-" + narizDatos[1] + " w-" + narizDatos[2] + " h-" + narizDatos[3], narizDatos[0] - 200,
             narizDatos[1] + narizDatos[3] - 30);
             strokeWeight(3);
             stroke(0xffffffff);
             noFill();
             rect(narizDatos[0], narizDatos[1], narizDatos[2], narizDatos[3]);
          }

          //sendData(3);
          // Dentro de la cara hay una boca
          if ((boca.length != 0) &&
            ((boca[0].x * scale > caraDatos[0]) && (boca[0].x * scale < caraDatos[0] + caraDatos[2])) &&
            ((boca[0].y * scale > caraDatos[1]) && (boca[0].y * scale < caraDatos[1] + caraDatos[3])) &&
            boca[0].y * scale > ojosDatos[1]){
            bocaB = true;
            bocaDatos[0] = boca[0].x * scale;      // ubicacion de ojo x
            bocaDatos[1] = boca[0].y * scale;      // ubicacion de ojo y
            bocaDatos[2] = boca[0].width * scale;  // ancho de ojo
            bocaDatos[3] = boca[0].height * scale; // alto de ojo

            if ( timerS.getTimeLeftUntilFinish() > 2000  || timer.getTimeLeftUntilFinish() > 2000  ) {
              fill(0xffffffff);
              textSize(16);
              text("Boca: x-" + bocaDatos[0] + " y-" + bocaDatos[1] + " w-" +bocaDatos[2]
                + " h-" + bocaDatos[3], bocaDatos[0], bocaDatos[1]+bocaDatos[3]);
                strokeWeight(3);
                stroke(0xffffffff);
                noFill();
                rect(bocaDatos[0], bocaDatos[1], bocaDatos[2], bocaDatos[3]);
            }
              if(contador != 3){
                revisarTimer();
              } else{
                tint(0xffffffff, 255);
                sendData(1);
                sendData(2);
                sendData(3);
                sendData(4);
              }
            }//Fin de proceo de boca
            else {//
            bocaB = false;
        }}//Fin Nariz
         else {
          narizB = false;
          bocaB = false;
        }}
       else {
        ojosB = false;
        narizB = false;
        bocaB = false;
      }//Fin ojos
    } // Final del For loop de las caras
  } else {//Si no encuentra caras todo es falso
    caraB = false;
    ojosB = false;
    narizB = false;
    bocaB = false;
    sendData(5);
  }
}



public void revisarTimer(){
  //funcion si no esta corriendo el timer
  if (!timer.isRunning() && !timerS.isRunning()) {
    timer.start();
    contador =1;
  }  else if ( (timer.isRunning() && !timerS.isRunning()) &&
              timer.getTimeLeftUntilFinish() > 2000  ) {//Si esta corriendo el timer0 y tiene mas de 2 segundos para acabar
      tint(255, 120);
      textFont(fuente);
      textSize(20);
      fill(0xffffffff);
      textAlign(1);
      //text(etiqueta[rand], ojosDatos[0], ojosDatos[1]);
      text("Analizando rasgos para designar sexo.", 20, 50);
  } else if ( (timer.isRunning() && !timerS.isRunning()) &&
              timer.getTimeLeftUntilFinish() < 3000 && timer.getTimeLeftUntilFinish() >1000 ) {//Si esta corriendo el timer0 y tiene mas de 2 segundos para acabar
      tint(255, 120);
      textFont(fuente1);
      textSize(70);
      fill(0xffffffff);
      textAlign(1);
      //text(etiqueta[rand], ojosDatos[0], ojosDatos[1]);
      text(etiqueta[rand],ojosDatos[0]-50, ojosDatos[1]);
  } else if ( (timer.isRunning() && !timerS.isRunning()) &&
              timer.getTimeLeftUntilFinish() < 2000  ) {//Si esta corriendo el timer0 y tiene mas de 2 segundos para acabar
      tint(255,0,0, 120);
      textFont(fuente);
      textSize(70);
      fill(0xffffffff);
      textAlign(1);
      text("##ERROR",ojosDatos[0]-50, ojosDatos[1]);
      textFont(fuente);
      textSize(20);
      fill(0xffffffff);
      textAlign(1);
      text("Sexo desconocido", 20, 50);
  }  else if( (timerS.isRunning() && !timer.isRunning() ) &&
            (timerS.getTimeLeftUntilFinish() > 2000) ) {
      tint(255, 120);
      textFont(fuente);
      textSize(20);
      fill(0xffffffff);
      textAlign(1);
      text("Analizando rasgos para designar sexo", 20, 50);
  } else if( (timerS.isRunning() && !timer.isRunning() ) &&
            (timerS.getTimeLeftUntilFinish() < 3000 && timerS.getTimeLeftUntilFinish() > 2000)  ) {
      tint(255, 120);
      textFont(fuente1);
      textSize(70);
      fill(0xffffffff);
      textAlign(1);
      text(etiqueta[rand], ojosDatos[0]-50, ojosDatos[1]);
  } else if ( (timerS.isRunning() && !timer.isRunning()) &&
              timerS.getTimeLeftUntilFinish() < 2000  ) {//Si esta corriendo el timer0 y tiene mas de 2 segundos para acabar
      tint(255,0,0, 120);
      textFont(fuente);
      textSize(70);
      fill(0xffffffff);
      textAlign(1);
      text("##ERROR",ojosDatos[0]-50, ojosDatos[1]);
      textFont(fuente);
      textSize(20);
      fill(0xffffffff);
      textAlign(1);
      text("Sexo desconocido", 20, 50);
  }

}

public void onFinishEvent(CountdownTimer t) {
  timer.stop(CountdownTimer.StopBehavior.STOP_IMMEDIATELY);
  if (!timerS.isRunning()) {
    timerS.start();
    contador = 2;
    tint(200,120);
    if (rand == 0){
      rand = 1;
    } else if(rand ==1){
      rand =0;
    }
    //println("Corriendo timerS:", timerS.getTimerDuration());
  } else if ((timerS.getTimeLeftUntilFinish() <= 1) || (timer.getTimeLeftUntilFinish() <= 1)) {
    println("Etiqueta---",rand);
    if (rand == 0){
      rand = 1;
    } else if(rand ==1){
      rand =0;
    }
    timerS.stop(CountdownTimer.StopBehavior.STOP_IMMEDIATELY);

  }
  if(!timer.isRunning() && !timerS.isRunning()){
    println("SendData", timerS.getTimeLeftUntilFinish(), timer.getTimeLeftUntilFinish());
    sendData(0);
    sendData(1);
    sendData(2);
    sendData(3);
    sendData(4);
    contador= 3;
  }
}

public void onTickEvent(CountdownTimer t, long timeLeftUntilFinish) {


}
/*//////////////////////////////////////////////////////
 Funcion que dibuja las etiquetas Caras
 *///////////////////////////////////////////////////////
public int generarEtiqueta(int num) {
  float cDX;
  float cDY;
  float cDW;
  float cDH;
  int ran = round(random(0, 8));
  PShape cara;
  String  caraname = "c-"+ran+".svg";
  //println(caraname);
  cara = loadShape(caraname);
  cDX = caraDatos[0];
  cDY = caraDatos[1];
  cDW = caraDatos[2];
  cDH = caraDatos[3];
  tint(255, 120);
  shape(cara, cDX, cDY, cDW, cDH);
  return num;
}
/*//////////////////////////////////////////////////////
 Funcion que dibuja los iconos y cambia el color si ya
 se detecto este elemento en el proceso de cv
 *///////////////////////////////////////////////////////
public void dibujarIconos() {
  PImage carab, carar, ojob, ojor, narizr, narizb, bocab, bocar;
  /*////////////////////////////////////////////////////////////////////////////////
        Este c\u00f3digo utiliza iconos hechos por Freepixhttp://www.freepik.com/
  */////////////////////////////////////////////////////////////////////////////////

  carab = loadImage("cara00b.png");
  carar = loadImage("cara00r.png");

  ojob = loadImage("ojo3b.png");
  ojor = loadImage("ojo3r.png");

  narizb = loadImage("narizb.png");
  narizr = loadImage("narizr.png");

  bocab = loadImage("boca3b.png");
  bocar = loadImage("boca3r.png");
  int margen = 40;

  translate(30, height / 2 - height / 5);
  pushMatrix();

  fill(0xffffffff);
  scale(.2f);
  if (caraB == true) {
    image(carab, 0, margen);
  } else {
    image(carar, 0, margen);
  }
  // image(carab, 0, margen);

  if (ojosB == true) {
    image(ojob, 0, margen * 8);
  } else {
    image(ojor, 0, margen * 8);
  }
  // image(ojob, 0, margen * 8);

  if (narizB == true) {
    image(narizb, 0, margen * 16);
  } else {
    image(narizr, 0, margen * 16);
  }
  // image(narizb, 0, margen * 16);

  if (bocaB == true) {
    image(bocab, 0, margen * 24);
  } else {
    image(bocar, 0, margen * 24);
  }
  // image(bocab, 0, margen * 24);

  popMatrix();
}
/*//////////////////////////////////////////////////////
 Funcion que guarda muestra del rostro del interactor
 *///////////////////////////////////////////////////////
/*void keyPressed() {
 println("Muestra Guardada");
 PImage muestra = createImage(caraDatos[2], caraDatos[3], RGB);
 muestra.copy(cam, caraDatos[0], caraDatos[1], caraDatos[2], caraDatos[3], 0,0, caraDatos[2], caraDatos[2]);
 muestra.updatePixels();
 muestra.save("muestra-0.jpg");
 println("Muestra Guardada");
 }*/
/*//////////////////////////////////////////////////////
 Funcion queenvia los datos obtenidos del proceso de CV
 al sketch de los petalos para dibujar la orquidea
 *///////////////////////////////////////////////////////
public void sendData(int msjNum) {
  switch(msjNum) {
  case 0 :
    OscMessage msjColor = new OscMessage("/datos/color/");
    msjColor.add((int)colorMuestra); // Color Muestra
    oscp5.send(msjColor, dir);
    // Color
    //    println("/datos/color/");
    //println("####TypeTag:", msjColor.typetag());
    break;
  case 1:
    OscMessage msjCara = new OscMessage("/datos/cara/");
    msjCara.add((int)caraDatos[0]); // x Cara
    msjCara.add((int)caraDatos[1]); // y Cara
    msjCara.add((int)caraDatos[2]); // ancho Cara
    msjCara.add((int)caraDatos[3]); // alto Cara
    oscp5.send(msjCara, dir);
    //println("/datos/cara/");
    break;
  case 2:
    OscMessage msjOjos = new OscMessage("/datos/ojos/");
    msjOjos.add((int)ojosDatos[0]); // x Ojos
    msjOjos.add((int)ojosDatos[1]); // y Ojos
    msjOjos.add((int)ojosDatos[2]); // ancho Ojos
    msjOjos.add((int)ojosDatos[3]); // alto Ojos
    oscp5.send(msjOjos, dir);
    //println("/datos/ojos/");
    break;
  case 3:
    OscMessage msjNariz = new OscMessage("/datos/nariz/");
    msjNariz.add((int)narizDatos[0]); // x Nariz
    msjNariz.add((int)narizDatos[1]); // y Nariz
    msjNariz.add((int)narizDatos[2]); // ancho Nariz
    msjNariz.add((int)narizDatos[3]); // alto Nariz
    oscp5.send(msjNariz, dir);
    //println("/datos/nariz/");
    break;
  case 4:
    OscMessage msjBoca = new OscMessage("/datos/boca/");
    msjBoca.add((int)bocaDatos[0]); // x Boca
    msjBoca.add((int)bocaDatos[1]); // y Boca
    msjBoca.add((int)bocaDatos[2]); // ancho Boca
    msjBoca.add((int)bocaDatos[3]); // alto Boca
    oscp5.send(msjBoca, dir);
    //println("/datos/boca/");
    break;
  case 5:
    OscMessage msjVacio = new OscMessage("/datos/null/");
    msjVacio.add((int)0); // x Boca
    oscp5.send(msjVacio, dir);
    //println("/datos/null/");
    break;
  }
  // Imprimir Los Mensajes
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
