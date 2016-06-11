import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import megamu.mesh.*; 
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
import megamu.mesh.*; 
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













Delaunay mydelaunay;

float[][] points = new float[32][2];
PVector[] posiciones = new PVector[32];

//Librerias de comunicacion OPENCV
OscP5 oscp5;
NetAddress dir;
//Library object
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

int scale =3;

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

public PVector[] obtenerPos(int[] c,  int num) {
  switch(num){
    case 0 :
      posiciones[0] = new PVector(c[0]*2, c[1]*2);
      posiciones[1] = new PVector(c[0]*2 + c[2] / 2*2, c[1]*2);
      posiciones[2] = new PVector(c[0]*2 + c[2]*2, c[1]*2);
      posiciones[3] = new PVector(c[0]*2 + c[2]*2, c[1]*2 + c[3] / 2*2);
      posiciones[4] = new PVector(c[0]*2 + c[2]*2, c[1]*2 + c[3]*2);
      posiciones[5] = new PVector(c[0]*2 + c[2] / 2*2, c[1]*2 + c[3]*2);
      posiciones[6] = new PVector(c[0]*2, c[1]*2 + c[3]*2);
      posiciones[7] = new PVector(c[0]*2, c[1]*2 + c[3] / 2 *2 );
      for (int i = 0; i <= 7; i++) {
        points[i][0] = posiciones[i].x;
        points[i][1] = posiciones[i].y;
      }

    break;
    case 1:
    posiciones[8] = new PVector(c[0]*2, c[1]*2);
    posiciones[9] = new PVector(c[0]*2 + c[2] / 2*2, c[1]*2);
    posiciones[10] = new PVector(c[0]*2 + c[2]*2, c[1]*2);
    posiciones[11] = new PVector(c[0]*2 + c[2]*2, c[1]*2 + c[3] / 2*2);
    posiciones[12] = new PVector(c[0]*2 + c[2]*2, c[1]*2 + c[3]*2);
    posiciones[13] = new PVector(c[0]*2 + c[2] / 2*2, c[1]*2 + c[3]*2);
    posiciones[14] = new PVector(c[0]*2, c[1]*2 + c[3]*2);
    posiciones[15] = new PVector(c[0]*2, c[1]*2 + c[3] / 2 *2 );
    for (int i = 8; i <= 15; i++) {
      points[i][0] = posiciones[i].x;
      points[i][1] = posiciones[i].y;
    }

    break;
    case 2:
    posiciones[16] = new PVector(c[0]*2, c[1]*2);
    posiciones[17] = new PVector(c[0]*2 + c[2] / 2*2, c[1]*2);
    posiciones[18] = new PVector(c[0]*2 + c[2]*2, c[1]*2);
    posiciones[19] = new PVector(c[0]*2 + c[2]*2, c[1]*2 + c[3] / 2*2);
    posiciones[20] = new PVector(c[0]*2 + c[2]*2, c[1]*2 + c[3]*2);
    posiciones[21] = new PVector(c[0]*2 + c[2] / 2*2, c[1]*2 + c[3]*2);
    posiciones[22] = new PVector(c[0]*2, c[1]*2 + c[3]*2);
    posiciones[23] = new PVector(c[0]*2, c[1]*2 + c[3] / 2 *2 );
    for (int i = 16; i <= 23; i++) {
        points[i][0] = posiciones[i].x;
        points[i][1] = posiciones[i].y;
      }

    break;
    case 3:
    posiciones[24] = new PVector(c[0]*2, c[1]*2);
    posiciones[25] = new PVector(c[0]*2 + c[2] / 2*2, c[1]*2);
    posiciones[26] = new PVector(c[0]*2 + c[2]*2, c[1]*2);
    posiciones[27] = new PVector(c[0]*2 + c[2]*2, c[1]*2 + c[3] / 2*2);
    posiciones[28] = new PVector(c[0]*2 + c[2]*2, c[1]*2 + c[3]*2);
    posiciones[29] = new PVector(c[0]*2 + c[2] / 2*2, c[1]*2 + c[3]*2);
    posiciones[30] = new PVector(c[0]*2, c[1]*2 + c[3]*2);
    posiciones[31] = new PVector(c[0]*2, c[1]*2 + c[3] / 2 *2 );
    for (int i = 24; i <= 31; i++) {
        points[i][0] = posiciones[i].x;
        points[i][1] = posiciones[i].y;
      }

    break;

  }
  Delaunay myDelaunay = new Delaunay( points );
  float[][] myEdges = myDelaunay.getEdges();
  for(int i=0; i<myEdges.length-1; i++){
    if((myEdges[i][0] != 0) || (myEdges[i][1]  != 0)){
    //float prevX = myEdges[i][0];
    //float prevY = myEdges[i][1];
    float startX = myEdges[i][0];
    float startY = myEdges[i][1];

    float endX = myEdges[i][2];
    float endY = myEdges[i][3];
    /*fill(0,255,0);
    ellipse(startX,startY, 10,10);
    text(i,startX-10,startY-10);
    fill(0,0,255);
    ellipse(endX, endY, 5,5);
    text(i,endX+10,endY+10);
    */
    strokeWeight(2);
    line( startX, startY, endX, endY );

  } else {
    //Error Handler

  }
  }
  // posiciones[0].set(posiciones_[0]);
  return posiciones;
}

public void draw() {
  background(0);
  //Previous Settings
  preprocessing();
  // Imagen de la Camara
  //image(cam, 0, 0);
  // Proceso de crear una paleta de color
  colorMuestra = tomarMuestra( (width / 2) /2, height - 50, 0);
  //Enviar el color obtenido
  sendData(0);
  //Dibujar Rectangulos y datos del
  dibujarAnalisis();
  dibujarIconos();
  pushMatrix();
  translate(-20, -100);
    revisarTimer();
  popMatrix();
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
      obtenerPos(caraDatos, 0);
      if ( timerS.getTimeLeftUntilFinish() > 1000  || timer.getTimeLeftUntilFinish() > 1000  ) {
        textSize(36);
        fill(0xffffffff);
        text("Cara: x-" + caraDatos[0]*2 + " y-" + caraDatos[1]*2 + " w-" +caraDatos[2]*2 + " h-" + caraDatos[3]*2,
         caraDatos[0]*2, caraDatos[1]*2 - 30);
         strokeWeight(3);
         stroke(0xffffffff);
         noFill();
         rect(caraDatos[0]*2, caraDatos[1]*2, caraDatos[2]*2, caraDatos[3]*2);
        // println(" ####mas de 1-- TS: " ,timerS.getTimeLeftUntilFinish(), "T: ",timer.getTimeLeftUntilFinish() );
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
        obtenerPos(ojosDatos, 1);
        if ( timerS.getTimeLeftUntilFinish() > 1000  || timer.getTimeLeftUntilFinish() > 1000  ) {
          fill(0xffffffff);
          textSize(36);
          text("Ojos: x-" + ojosDatos[0]*2 + " y-" + ojosDatos[1]*2 + " w-" +ojosDatos[2]*2 + " h-" + ojosDatos[3]*2,
           ojosDatos[0]*2, ojosDatos[1]*2 - 30);
           stroke(0xffffffff);
           strokeWeight(5);
           noFill();
           rect(ojosDatos[0]*2, ojosDatos[1]*2, ojosDatos[2]*2, ojosDatos[3]*2);
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
          obtenerPos(narizDatos, 2);
          if ( timerS.getTimeLeftUntilFinish() > 1000  || timer.getTimeLeftUntilFinish() > 1000  ) {
            fill(0xffffffff);
            textSize(36);
            text("Nariz: x-" + narizDatos[0]*2 + " y-" + narizDatos[1]*2 + " w-" + narizDatos[2]*2 + " h-" + narizDatos[3]*2, narizDatos[0]*2 - 200,
             narizDatos[1]*2 + narizDatos[3]*2 - 30);
             strokeWeight(3);
             stroke(0xffffffff);
             noFill();
             rect(narizDatos[0]*2, narizDatos[1]*2, narizDatos[2]*2, narizDatos[3]*2);
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
            obtenerPos(bocaDatos, 3);
            if ( timerS.getTimeLeftUntilFinish() > 1000  || timer.getTimeLeftUntilFinish() > 1000  ) {
              fill(0xffffffff);
              textSize(36);
              text("Boca: x-" + bocaDatos[0]*2 + " y-" + bocaDatos[1]*2 + " w-" +bocaDatos[2]*2
                + " h-" + bocaDatos[3]*2, bocaDatos[0]*2, bocaDatos[1]*2+bocaDatos[3]*2);
                strokeWeight(3);
                stroke(0xffffffff);
                noFill();
                rect(bocaDatos[0]*2, bocaDatos[1]*2, bocaDatos[2]*2, bocaDatos[3]*2);

            }
              if(contador == 3){
                tint(0xffffffff, 255);
                sendData(1);
                sendData(2);
                sendData(3);
                sendData(4);
              }
            }
            //Fin de proceo de boca
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
  //Revisar Timer 0
  if( (!timer.isRunning() && !timerS.isRunning()) && (caraB && ojosB && narizB && bocaB )) {
    timer.start();
    contador =1;
    println("Conteo= ", contador);
}  else if ( (timer.isRunning() && !timerS.isRunning()) &&
              (timer.getTimeLeftUntilFinish() < 10000 && timer.getTimeLeftUntilFinish() > 7000) ) {//Si esta corriendo el timer0 y tiene mas de 2 segundos para acabar
      tint(255, 120);
      textFont(fuente);
      textSize(45);
      fill(0xffffffff);
      textAlign(1);

      text("Analizando rasgos para designar sexo.", 20, 20);
      println("##Analizando entre 0 y 3 S' " ,timer.getTimeLeftUntilFinish() );
  } else if ( (timer.isRunning() && !timerS.isRunning()) &&
              (timer.getTimeLeftUntilFinish() < 7000 && timer.getTimeLeftUntilFinish() > 5000) ) {//Si esta corriendo el timer0 y tiene mas de 2 segundos para acabar
      tint(255, 120);
      textFont(fuente1);
      textSize(90);
      fill(0xffffffff);
      textAlign(1);
      //text(etiqueta[rand], ojosDatos[0], ojosDatos[1]);
      switch(contador){
        case 1:
        text(etiqueta[0],ojosDatos[0]*2, ojosDatos[1]*2);
        println("##Etiquetas entre 3 y 5 S' ", contador ,timer.getTimeLeftUntilFinish() );
        break;
        case 2:
        text(etiqueta[1],ojosDatos[0]*2, ojosDatos[1]*2);
        println("##Etiquetas entre 3 y 5 S' ", contador ,timer.getTimeLeftUntilFinish() );
        break;
    }
  } else if ( (timer.isRunning() && !timerS.isRunning()) &&
              (timer.getTimeLeftUntilFinish() < 2200 && timer.getTimeLeftUntilFinish() > 500)  ) {//Si esta corriendo el timer0 y tiene mas de 2 segundos para acabar
      tint(255,0,0, 120);
      textFont(fuente);
      textSize(110);
      fill(0xffffffff);
      textAlign(1);
      text("##ERROR",ojosDatos[0]*2-50, ojosDatos[1]*2);
      textFont(fuente);
      textSize(45);
      fill(0xffffffff);
      textAlign(1);
      text("Sexo desconocido", 20, 50*2);
      println("##ERROR entre 7.8 y 9.5  S' " ,timer.getTimeLeftUntilFinish() );
      contador = 2;
  }  else if( (timerS.isRunning() && !timer.isRunning() ) &&
            (timerS.getTimeLeftUntilFinish() < 10000 && timerS.getTimeLeftUntilFinish() < 7000 ) ) {

      tint(255, 120);
      textFont(fuente);
      textSize(90);
      fill(0xffffffff);
      textAlign(1);
      //text(etiqueta[rand], ojosDatos[0], ojosDatos[1]);
      switch(contador){

        case 1:
        println(etiqueta[0]);
        text(etiqueta[0],ojosDatos[0]*2, ojosDatos[1]*2);
        println("##Etiquetas entre 3 y 5 S' ", contador ,timerS.getTimeLeftUntilFinish() );
        break;
        case 2:
        println(etiqueta[1]);
        text(etiqueta[1],ojosDatos[0]*2, ojosDatos[1]*2);
        println("##Etiquetas entre 3 y 5 S' ", contador ,timerS.getTimeLeftUntilFinish() );
        break;
      }
  } else if( (timerS.isRunning() && !timer.isRunning() ) &&
            (timerS.getTimeLeftUntilFinish() < 7000 && timerS.getTimeLeftUntilFinish() > 5000)  ) {
      tint(255, 120);
      textFont(fuente1);
      textSize(90);
      fill(0xffffffff);
      textAlign(1);
      text(etiqueta[rand], ojosDatos[0]*2-50, ojosDatos[1]*2);
      println("##ETIQUETA entre 3 y 5 S' " ,timerS.getTimeLeftUntilFinish() );
  } else if ( (timerS.isRunning() && !timer.isRunning()) &&
              timerS.getTimeLeftUntilFinish() < 5000  ) {//Si esta corriendo el timer0 y tiene mas de 2 segundos para acabar
      tint(255,0,0, 120);
      textFont(fuente);
      textSize(110);
      fill(0xffffffff);
      textAlign(1);
      text("##ERROR",ojosDatos[0]*2-50, ojosDatos[1]*2);
      textFont(fuente);
      textSize(45);
      fill(0xffffffff);
      textAlign(1);
      text("Sexo desconocido", 20, 50*2);
      println("##ERROR entre 7.8 y 9 S' " ,timerS.getTimeLeftUntilFinish() );
      contador = 3;
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

  translate(20, height / 2 - height / 3);
  pushMatrix();

  fill(0xffffffff);
  scale(.5f);
  if (caraB == true) {
    image(carab, 0, margen);
  } else {
    image(carar, 0, margen);
  }
  // image(carab, 0, margen);

  if (ojosB == true) {
    image(ojob, 0, margen * 4.5f);
  } else {
    image(ojor, 0, margen * 4.5f);
  }
  // image(ojob, 0, margen * 8);

  if (narizB == true) {
    image(narizb, 0, margen * 8);
  } else {
    image(narizr, 0, margen * 8);
  }
  // image(narizb, 0, margen * 16);

  if (bocaB == true) {
    image(bocab, 0, margen * 12);
  } else {
    image(bocar, 0, margen * 12);
  }
  // image(bocab, 0, margen * 30);

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
}












Delaunay mydelaunay;
/*////////////////////////////////////////////////////////////////////7
Clase Rostros
////////////////////////////////////////////////////////////////////7*/
class Rostros{
//Librerias de comunicacion OSCP5
OscP5 oscp5;
NetAddress dir;
//Objetos OpenCVP5
OpenCV caraCV;
OpenCV ojosCV;
OpenCV narizCV;
OpenCV bocaCV;
//Timers que controlan el tiempo que aparece la etiqueta y el Error
CountdownTimer timer;
CountdownTimer timer02;
CountdownTimer timer03;
//Etiquetas mostradas
String[] etiqueta = {
  "HOMBRE", "MUJER"
};
//Fuentes
PFont coolv, cour ;
// Camara
Capture cam;
// Imagenes Escaladas
PImage smaller;
PGraphics capaEtiquetas;
//dato del color muestra
int colorMuestra;

/*////////////////////////////////////////////////////////////////////7
Inicializador de la clase Rostro
Aqui se puede controlar la escala de la imagen este sketch usa (640,480)
*/////////////////////////////////////////////////////////////////////7
Rostro(int scale){
    //Puntos y posiciones extraidos del CV
  float[][] points = new float[32][2];
  PVector[] posiciones = new PVector[32]; //
  // Arreglos de los datos guardados
  int[] caraDatos = new int[4];  // Orden de Valores de matriz//x, y ,w, h //
  int[] ojosDatos = new int[4];  // x0, y0 ,w0, h0, //x1, y1 ,w1, h1//
  int[] bocaDatos = new int[4];  // x, y ,w, h//
  int[] narizDatos = new int[4]; // x, y ,w, h//
  // Array of caras, ojo ,nariz, boca
  Rectangle[] caras;
  Rectangle[] ojos;
  Rectangle[] nariz;
  Rectangle[] boca;
  boolean caraB = false, ojosB = false, narizB = false, bocaB = false;
  boolean capaEtiq = false;
  int contador = 0;

}
/* ////////////////////////////////////////////////////////////////////7
///Aqui se colocan los valores del intervalo del cronometro que activa las
etiquetas y envia por ultimo los datos al sketch de la orquidea
*/////////////////////////////////////////////////////////////////////7
  public void settings(int intervalo, int total){
    timer = CountdownTimerService.getNewCountdownTimer(this).configure(intervalo, total);
    timer02 = CountdownTimerService.getNewCountdownTimer(this).configure(intervalo, total);
    timer03 = CountdownTimerService.getNewCountdownTimer(this).configure(intervalo, total);
    //println(Capture.list());
    cam = new Capture(this, 640, 480, "/dev/video0");
    cam.start();
    coolv = loadFont("CoolveticaRg-Regular-48.vlw");
    cour = loadFont("Courier10PitchBT-Roman-48.vlw");
    textFont(coolv);
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
  }
  /*////////////////////////////////////////////////////////////////////7
  Esta funcion ajusta las preferencias
  para el proceso de vision computarizada
  */////////////////////////////////////////////////////////////////////7
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
    return lightCol.toARGB();
  }
  /*//////////////////////////////////////////////////////////
  Funcion que almacena las posiciones
  obtenidas por el proceso de CV en un arreglo 2D
  Para poder generar la estructura de Triangulacion
  La funcion acepta dos variables:
        1- Es un arreglo donde se van a almacenar
        los datos del Proceso de CV
        2- Este dato refiere a que rasgo del CV
         va aser  almacenado en el arreglo antes mencionado
        solo pueden ser del 0 al 3
           Ejemplo:
           0 = Cara, 1 = Ojos, 2 = Nariz, 3 = Boca
  //////////////////////////////////////////////////////////*/
  public PVector[] obtenerPos(int[] c,  int num) {
    switch(num){
      case 0 :
        posiciones[0] = new PVector(c[0]*2, c[1]*2);
        posiciones[1] = new PVector(c[0]*2 + c[2] / 2*2, c[1]*2);
        posiciones[2] = new PVector(c[0]*2 + c[2]*2, c[1]*2);
        posiciones[3] = new PVector(c[0]*2 + c[2]*2, c[1]*2 + c[3] / 2*2);
        posiciones[4] = new PVector(c[0]*2 + c[2]*2, c[1]*2 + c[3]*2);
        posiciones[5] = new PVector(c[0]*2 + c[2] / 2*2, c[1]*2 + c[3]*2);
        posiciones[6] = new PVector(c[0]*2, c[1]*2 + c[3]*2);
        posiciones[7] = new PVector(c[0]*2, c[1]*2 + c[3] / 2 *2 );
        for (int i = 0; i <= 7; i++) {
          points[i][0] = posiciones[i].x;
          points[i][1] = posiciones[i].y;
        }
      break;
      case 1:
      posiciones[8] = new PVector(c[0]*2, c[1]*2);
      posiciones[9] = new PVector(c[0]*2 + c[2] / 2*2, c[1]*2);
      posiciones[10] = new PVector(c[0]*2 + c[2]*2, c[1]*2);
      posiciones[11] = new PVector(c[0]*2 + c[2]*2, c[1]*2 + c[3] / 2*2);
      posiciones[12] = new PVector(c[0]*2 + c[2]*2, c[1]*2 + c[3]*2);
      posiciones[13] = new PVector(c[0]*2 + c[2] / 2*2, c[1]*2 + c[3]*2);
      posiciones[14] = new PVector(c[0]*2, c[1]*2 + c[3]*2);
      posiciones[15] = new PVector(c[0]*2, c[1]*2 + c[3] / 2 *2 );
      for (int i = 8; i <= 15; i++) {
        points[i][0] = posiciones[i].x;
        points[i][1] = posiciones[i].y;
      }
      break;
      case 2:
      posiciones[16] = new PVector(c[0]*2, c[1]*2);
      posiciones[17] = new PVector(c[0]*2 + c[2] / 2*2, c[1]*2);
      posiciones[18] = new PVector(c[0]*2 + c[2]*2, c[1]*2);
      posiciones[19] = new PVector(c[0]*2 + c[2]*2, c[1]*2 + c[3] / 2*2);
      posiciones[20] = new PVector(c[0]*2 + c[2]*2, c[1]*2 + c[3]*2);
      posiciones[21] = new PVector(c[0]*2 + c[2] / 2*2, c[1]*2 + c[3]*2);
      posiciones[22] = new PVector(c[0]*2, c[1]*2 + c[3]*2);
      posiciones[23] = new PVector(c[0]*2, c[1]*2 + c[3] / 2 *2 );
      for (int i = 16; i <= 23; i++) {
          points[i][0] = posiciones[i].x;
          points[i][1] = posiciones[i].y;
        }
      break;
      case 3:
      posiciones[24] = new PVector(c[0]*2, c[1]*2);
      posiciones[25] = new PVector(c[0]*2 + c[2] / 2*2, c[1]*2);
      posiciones[26] = new PVector(c[0]*2 + c[2]*2, c[1]*2);
      posiciones[27] = new PVector(c[0]*2 + c[2]*2, c[1]*2 + c[3] / 2*2);
      posiciones[28] = new PVector(c[0]*2 + c[2]*2, c[1]*2 + c[3]*2);
      posiciones[29] = new PVector(c[0]*2 + c[2] / 2*2, c[1]*2 + c[3]*2);
      posiciones[30] = new PVector(c[0]*2, c[1]*2 + c[3]*2);
      posiciones[31] = new PVector(c[0]*2, c[1]*2 + c[3] / 2 *2 );
      for (int i = 24; i <= 31; i++) {
          points[i][0] = posiciones[i].x;
          points[i][1] = posiciones[i].y;
        }
      break;
    }
    /*//////////////////////////////////////////////////////////
    Posterior a almacenar los datos
    se genera un objeto Delaunay por cada dato encontrado
    En este caso 32 datos = 32 puntos para generar la triangulacion
    //////////////////////////////////////////////////////////*/
    Delaunay myDelaunay = new Delaunay( points );
    float[][] myEdges = myDelaunay.getEdges();
    for(int i=0; i<myEdges.length-1; i++){
      if((myEdges[i][0] != 0) || (myEdges[i][1]  != 0)){
      //float prevX = myEdges[i][0];
      //float prevY = myEdges[i][1];
      float startX = myEdges[i][0];
      float startY = myEdges[i][1];
      float endX = myEdges[i][2];
      float endY = myEdges[i][3];
      /*fill(0,255,0);
      ellipse(startX,startY, 10,10);
      text(i,startX-10,startY-10);
      fill(0,0,255);
      ellipse(endX, endY, 5,5);
      text(i,endX+10,endY+10);
      */
      strokeWeight(1);
      line( startX, startY, endX, endY );
    } else {
      //Error Handler

    }
    }
    // posiciones[0].set(posiciones_[0]);
    return posiciones;
  }
/*////////////////////////////////////////////////////
Funcion en la que se dibuja los elementos gr\u00e1ficos
de Open Cv y los textos que refieren a la
informaci\u00f3n extraida
*/////////////////////////////////////////////////////
  public void dibujarAnalisis() {
    textFont(coolv);
    if (caras.length != 0) {
      caraB = true;
      for (int car = 0; car < caras.length; car++) {
        caraDatos[0] = caras[car].x * scale;      // ubicacion de cara x
        caraDatos[1] = caras[car].y * scale;      // ubicacion de cara y
        caraDatos[2] = caras[car].width * scale;  // ancho de cara
        caraDatos[3] = caras[car].height * scale; // alto de cara
        obtenerPos(caraDatos, 0);
        /*//////////////////////////////
         Si ha pasado un segundo o mas
         en cualquiera de los dos timers
         Dibuja el texto y el rectangulo referente
         *//////////////////////////////////
        if ( timer02.getTimeLeftUntilFinish() > 1000  || timer.getTimeLeftUntilFinish() > 1000  ) {
          textSize(36);
          fill(0xffffffff);
          text("Cara: x-" + caraDatos[0]*2 + " y-" + caraDatos[1]*2 + " w-" +caraDatos[2]*2 + " h-" + caraDatos[3]*2,
           caraDatos[0]*2, caraDatos[1]*2 - 30);
           strokeWeight(3);
           stroke(0xffffffff);
           noFill();
           rect(caraDatos[0]*2, caraDatos[1]*2, caraDatos[2]*2, caraDatos[3]*2);
          // println(" ####mas de 1-- TS: " ,timer02.getTimeLeftUntilFinish(), "T: ",timer.getTimeLeftUntilFinish() );
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
          obtenerPos(ojosDatos, 1);
          /*//////////////////////////////
           Si ha pasado un segundo o mas
           en cualquiera de los dos timers
           Dibuja el texto y el rectangulo referente
           *//////////////////////////////////
          if ( timer02.getTimeLeftUntilFinish() > 1000  || timer.getTimeLeftUntilFinish() > 1000  ) {
            fill(0xffffffff);
            textSize(36);
            text("Ojos: x-" + ojosDatos[0]*2 + " y-" + ojosDatos[1]*2 + " w-" +ojosDatos[2]*2 + " h-" + ojosDatos[3]*2,
             ojosDatos[0]*2, ojosDatos[1]*2 - 30);
             stroke(0xffffffff);
             strokeWeight(5);
             noFill();
             rect(ojosDatos[0]*2, ojosDatos[1]*2, ojosDatos[2]*2, ojosDatos[3]*2);
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
            obtenerPos(narizDatos, 2);
            /*//////////////////////////////
             Si ha pasado un segundo o mas
             en cualquiera de los dos timers
             Dibuja el texto y el rectangulo referente
             *//////////////////////////////////
            if ( timer02.getTimeLeftUntilFinish() > 1000  || timer.getTimeLeftUntilFinish() > 1000  ) {
              fill(0xffffffff);
              textSize(36);
              text("Nariz: x-" + narizDatos[0]*2 + " y-" + narizDatos[1]*2 + " w-" + narizDatos[2]*2 + " h-" + narizDatos[3]*2, narizDatos[0]*2 - 200,
               narizDatos[1]*2 + narizDatos[3]*2 - 30);
               strokeWeight(3);
               stroke(0xffffffff);
               noFill();
               rect(narizDatos[0]*2, narizDatos[1]*2, narizDatos[2]*2, narizDatos[3]*2);
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
              obtenerPos(bocaDatos, 3);
              /*//////////////////////////////
               Si ha pasado un segundo o mas
               en cualquiera de los dos timers
               Dibuja el texto y el rectangulo referente
               *//////////////////////////////////
              if ( timer02.getTimeLeftUntilFinish() > 1000  || timer.getTimeLeftUntilFinish() > 1000  ) {
                fill(0xffffffff);
                textSize(36);
                text("Boca: x-" + bocaDatos[0]*2 + " y-" + bocaDatos[1]*2 + " w-" +bocaDatos[2]*2
                  + " h-" + bocaDatos[3]*2, bocaDatos[0]*2, bocaDatos[1]*2+bocaDatos[3]*2);
                  strokeWeight(3);
                  stroke(0xffffffff);
                  noFill();
                  rect(bocaDatos[0]*2, bocaDatos[1]*2, bocaDatos[2]*2, bocaDatos[3]*2);

              }
              /*//////////////////////////////
               Si ha iterado mas de 2 veces
               Envia los datos al sketch de la orquidea
               *//////////////////////////////////
                if(contador == 3){
                  tint(0xffffffff, 255);
                  sendData(1);
                  sendData(2);
                  sendData(3);
                  sendData(4);
                }
              }
              //Fin de proceo de boca
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
      //Enviar informacion de error
      sendData(5);
    }
  }
  /*/////////////////////////////////////////////////////
  Funcion para activar y revisar los tiempos de los timers
  timer de la primer etiqueta = timer
  timer de la segunda etiqueta = timer02
   *//////////////////////////////////////////////////////
  public void revisarTimer(){
    /*/////////////////////////////////////////
    si no esta avanzando ningun timer
    y las variables cara ojos nariz y boca estan activados
    activar el primer timer
    *//////////////////////////////////////////////////
    if( (!timer.isRunning() && !timer02.isRunning()) && (caraB && ojosB && narizB && bocaB )) {
      timer.start();
      contador =1;
      println("Conteo= ", contador);
      /*/////////////////////////////////////////
      si no esta avanzando el timer02 y el timer esta avanazando,
      si faltan menos de 10s y mas de 7s (osea si han pasado 3s)
      *//////////////////////////////////////////////////
  }  else if ( (timer.isRunning() && !timer02.isRunning()) &&
                (timer.getTimeLeftUntilFinish() < 10000 && timer.getTimeLeftUntilFinish() > 7000) ) {//Si esta corriendo el timer0 y tiene mas de 2 segundos para acabar
        tint(255, 120);
        textFont(coolv);
        textSize(45);
        fill(0xffffffff);
        textAlign(1);
        text("Analizando rasgos para designar sexo.", 20, 20);
    } else if ( (timer.isRunning() && !timer02.isRunning()) &&
                (timer.getTimeLeftUntilFinish() < 7000 && timer.getTimeLeftUntilFinish() > 5000) ) {//Si esta corriendo el timer0 y tiene mas de 2 segundos para acabar
        tint(255, 120);
        textFont(coolv);
        textSize(90);
        fill(0xffffffff);
        textAlign(1);
        //text(etiqueta[rand], ojosDatos[0], ojosDatos[1]);
        switch(contador){
          case 1:
          text(etiqueta[0],ojosDatos[0]*2, ojosDatos[1]*2);
          //println("##Etiquetas entre 3 y 5 S' ", contador ,timer.getTimeLeftUntilFinish() );
          break;
          case 2:
          text(etiqueta[1],ojosDatos[0]*2, ojosDatos[1]*2);
          //println("##Etiquetas entre 3 y 5 S' ", contador ,timer.getTimeLeftUntilFinish() );
          break;
      }
    } else if ( (timer.isRunning() && !timer02.isRunning()) &&
                (timer.getTimeLeftUntilFinish() < 4000 && timer.getTimeLeftUntilFinish() > 500)  ) {//Si esta corriendo el timer0 y tiene mas de 2 segundos para acabar
        tint(255,0,0, 120);
        textFont(cour);
        textSize(110);
        fill(0xffffffff);
        textAlign(1);
        text("##ERROR",ojosDatos[0]*2-50, ojosDatos[1]*2);
        textSize(45);
        fill(0xffffffff);
        textAlign(1);
        text("Sexo desconocido", 20, 50*2);
        //println("##ERROR entre 7.8 y 9.5  S' " ,timer.getTimeLeftUntilFinish() );
        contador = 2;
        /*/////////////////////////////////////////////
        Aqui comienza la segunda iteracion
        *//////////////////////////////////////////////
    }  else if( (timer02.isRunning() && !timer.isRunning() ) &&
              (timer02.getTimeLeftUntilFinish() < 10000 && timer02.getTimeLeftUntilFinish() < 7000 ) ) {
                tint(255, 120);
                textFont(coolv);
                textSize(45);
                fill(0xffffffff);
                textAlign(1);
                text("Analizando rasgos para designar sexo.", 20, 20);
    } else if( (timer02.isRunning() && !timer.isRunning() ) &&
              (timer02.getTimeLeftUntilFinish() < 7000 && timer02.getTimeLeftUntilFinish() > 5000)  ) {
                tint(255, 120);
                textFont(coolv);
                textSize(90);
                fill(0xffffffff);
                textAlign(1);
                //text(etiqueta[rand], ojosDatos[0], ojosDatos[1]);
                switch(contador){
                  case 1:
                  text(etiqueta[0],ojosDatos[0]*2, ojosDatos[1]*2);
                  //println("##Etiquetas entre 3 y 5 S' ", contador ,timer.getTimeLeftUntilFinish() );
                  break;
                  case 2:
                  text(etiqueta[1],ojosDatos[0]*2, ojosDatos[1]*2);
                  //println("##Etiquetas entre 3 y 5 S' ", contador ,timer.getTimeLeftUntilFinish() );
                  break;
              }
    } else if ( (timer02.isRunning() && !timer.isRunning()) &&
                (timer02.getTimeLeftUntilFinish() < 4000 && timer02.getTimeLeftUntilFinish() > 500)  ) {//Si esta corriendo el timer0 y tiene mas de 2 segundos para acabar
        tint(255,0,0, 120);
        textFont(cour);
        textSize(110);
        fill(0xffffffff);
        textAlign(1);
        text("##ERROR",ojosDatos[0]*2-50, ojosDatos[1]*2);
        textSize(45);
        fill(0xffffffff);
        textAlign(1);
        text("Sexo desconocido", 20, 50*2);
        //println("##ERROR entre 7.8 y 9.5  S' " ,timer.getTimeLeftUntilFinish() );
        contador = 3;
        /*/////////////////////////////////////////////
        Aqui comienza la tercer y ultima iteracion
        *//////////////////////////////////////////////
    }
    else if( (timer03.isRunning() && !timer02.isRunning() ) &&
              (timer03.getTimeLeftUntilFinish() < 10000 && timer03.getTimeLeftUntilFinish() < 7000 ) ) {
                tint(255, 120);
                textFont(coolv);
                textSize(45);
                fill(0xffffffff);
                textAlign(1);
                text("Analizando rasgos para designar sexo.", 20, 20);
    } else if( (timer03.isRunning() && !timer02.isRunning() ) &&
              (timer03.getTimeLeftUntilFinish() < 7000 && timer03.getTimeLeftUntilFinish() > 5000)  ) {
                tint(255, 120);
                textFont(coolv);
                textSize(90);
                fill(0xffffffff);
                textAlign(1);
                //text(etiqueta[rand], ojosDatos[0], ojosDatos[1]);
                switch(contador){
                  case 1:
                  text(etiqueta[0],ojosDatos[0]*2, ojosDatos[1]*2);
                  //println("##Etiquetas entre 3 y 5 S' ", contador ,timer.getTimeLeftUntilFinish() );
                  break;
                  case 2:
                  text(etiqueta[1],ojosDatos[0]*2, ojosDatos[1]*2);
                  //println("##Etiquetas entre 3 y 5 S' ", contador ,timer.getTimeLeftUntilFinish() );
                  break;
              }
    } else if ( (timer03.isRunning() && !timer02.isRunning()) &&
                (timer03.getTimeLeftUntilFinish() < 4000 && timer03.getTimeLeftUntilFinish() > 500)  ) {//Si esta corriendo el timer0 y tiene mas de 2 segundos para acabar
        tint(255,0,0, 120);
        textFont(cour);
        textSize(110);
        fill(0xffffffff);
        textAlign(1);
        text("##ERROR",ojosDatos[0]*2-50, ojosDatos[1]*2);
        textSize(45);
        fill(0xffffffff);
        textAlign(1);
        text("Sexo desconocido", 20, 50*2);
        //println("##ERROR entre 7.8 y 9.5  S' " ,timer.getTimeLeftUntilFinish() );
    }
  }

  public void onFinishEvent(CountdownTimer t) {
    timer.stop(CountdownTimer.StopBehavior.STOP_IMMEDIATELY);
    if (!timer02.isRunning()) {
      timer02.start();
      contador = 2;
      tint(200,120);
      if (rand == 0){
        rand = 1;
      } else if(rand ==1){
        rand =0;
      }
      //println("Corriendo timer02:", timer02.getTimerDuration());
    } else if ((timer02.getTimeLeftUntilFinish() <= 1) || (timer.getTimeLeftUntilFinish() <= 1)) {
      println("Etiqueta---",rand);
      if (rand == 0){
        rand = 1;
      } else if(rand ==1){
        rand =0;
      }
      timer02.stop(CountdownTimer.StopBehavior.STOP_IMMEDIATELY);

    }
    if(!timer.isRunning() && !timer02.isRunning()){
      println("SendData", timer02.getTimeLeftUntilFinish(), timer.getTimeLeftUntilFinish());
      sendData(0);
      sendData(1);
      sendData(2);
      sendData(3);
      sendData(4);
      contador= 3;
    }
  }


}

  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "rostroyosc" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
