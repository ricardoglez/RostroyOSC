
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

color cProceso = #8c1b1b;
color cCompreto = #105e31;
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


void setup() {
  size(640, 480);
  // Captura
  timer = CountdownTimerService.getNewCountdownTimer(this).configure(4000, 10000);
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
  rand = int(random(0, 1));
}

/*//////////////////////////////////////////////////////
 Funcion que genera todo el setup de las operaciones de
 vision computarizada
 *///////////////////////////////////////////////////////
void preprocessing() {
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
int tomarMuestra(int x_, int y_, int numMu_) {
  int muest_ = cam.get(x_, y_ );
  TColor colorM = TColor.newHex(hex(muest_, 6));
  //println("Muestra",colorM);
  TColor lightCol = colorM.getLightened(.32);
  lightCol = lightCol.getSaturated(.5);
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

void draw() {
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
void dibujarAnalisis() {
  textFont(fuente);
  if (caras.length != 0) {
    caraB = true;
    for (int car = 0; car < caras.length; car++) {
      caraDatos[0] = caras[car].x * scale;      // ubicacion de cara x
      caraDatos[1] = caras[car].y * scale;      // ubicacion de cara y
      caraDatos[2] = caras[car].width * scale;  // ancho de cara
      caraDatos[3] = caras[car].height * scale; // alto de cara
      if ( timerS.getTimeLeftUntilFinish() > 1000  || timer.getTimeLeftUntilFinish() > 1000  ) {
        textSize(16);
        fill(#ffffff);
        text("Cara: x-" + caraDatos[0] + " y-" + caraDatos[1] + " w-" +caraDatos[2] + " h-" + caraDatos[3],
         caraDatos[0], caraDatos[1] - 30);
         strokeWeight(3);
         stroke(#ffffff);
         noFill();
         rect(caraDatos[0], caraDatos[1], caraDatos[2], caraDatos[3]);
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
        if ( timerS.getTimeLeftUntilFinish() > 1000  || timer.getTimeLeftUntilFinish() > 1000  ) {
          fill(#ffffff);
          textSize(16);
          text("Ojos: x-" + ojosDatos[0] + " y-" + ojosDatos[1] + " w-" +ojosDatos[2] + " h-" + ojosDatos[3],
           ojosDatos[0], ojosDatos[1] - 30);
           stroke(#ffffff);
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
          if ( timerS.getTimeLeftUntilFinish() > 1000  || timer.getTimeLeftUntilFinish() > 1000  ) {
            fill(#ffffff);
            textSize(16);
            text("Nariz: x-" + narizDatos[0] + " y-" + narizDatos[1] + " w-" + narizDatos[2] + " h-" + narizDatos[3], narizDatos[0] - 200,
             narizDatos[1] + narizDatos[3] - 30);
             strokeWeight(3);
             stroke(#ffffff);
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

            if ( timerS.getTimeLeftUntilFinish() > 1000  || timer.getTimeLeftUntilFinish() > 1000  ) {
              fill(#ffffff);
              textSize(16);
              text("Boca: x-" + bocaDatos[0] + " y-" + bocaDatos[1] + " w-" +bocaDatos[2]
                + " h-" + bocaDatos[3], bocaDatos[0], bocaDatos[1]+bocaDatos[3]);
                strokeWeight(3);
                stroke(#ffffff);
                noFill();
                rect(bocaDatos[0], bocaDatos[1], bocaDatos[2], bocaDatos[3]);
            }
              if(contador == 3){
                tint(#ffffff, 255);
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



void revisarTimer(){
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
      textSize(20);
      fill(#ffffff);
      textAlign(1);
      
      text("Analizando rasgos para designar sexo.", 20, 20);
      
      if ( (timer.getTimeLeftUntilFinish() < 10000 && timer.getTimeLeftUntilFinish() > 9000) ){
      //text(etiqueta[rand], ojosDatos[0], ojosDatos[1]);
      text("Analizando rasgos para designar sexo.", 20, 20);
              }
      if ( (timer.getTimeLeftUntilFinish() < 10000 && timer.getTimeLeftUntilFinish() > 8000) ){
      //text(etiqueta[rand], ojosDatos[0], ojosDatos[1]);
      text("Analizando rasgos para designar sexo..", 20, 20);
              }      
                    if ( (timer.getTimeLeftUntilFinish() < 10000 && timer.getTimeLeftUntilFinish() > 7000) ){
      //text(etiqueta[rand], ojosDatos[0], ojosDatos[1]);
      text("Analizando rasgos para designar sexo..", 20, 20);
              }
      println("##Analizando entre 0 y 3 S' " ,timer.getTimeLeftUntilFinish() );
  } else if ( (timer.isRunning() && !timerS.isRunning()) &&
              (timer.getTimeLeftUntilFinish() < 7000 && timer.getTimeLeftUntilFinish() > 5000) ) {//Si esta corriendo el timer0 y tiene mas de 2 segundos para acabar
      tint(255, 120);
      textFont(fuente1);
      textSize(70);
      fill(#ffffff);
      textAlign(1);
      //text(etiqueta[rand], ojosDatos[0], ojosDatos[1]);
      text(etiqueta[rand],ojosDatos[0]-50, ojosDatos[1]);
      println("##Etiquetas entre 3 y 5 S' " ,timer.getTimeLeftUntilFinish() );
  } else if ( (timer.isRunning() && !timerS.isRunning()) &&
              (timer.getTimeLeftUntilFinish() < 2200 && timer.getTimeLeftUntilFinish() > 500)  ) {//Si esta corriendo el timer0 y tiene mas de 2 segundos para acabar
      tint(255,0,0, 120);
      textFont(fuente);
      textSize(70);
      fill(#ffffff);
      textAlign(1);
      text("##ERROR",ojosDatos[0]-50, ojosDatos[1]);
      textFont(fuente);
      textSize(20);
      fill(#ffffff);
      textAlign(1);
      text("Sexo desconocido", 20, 50);
      println("##ERROR entre 7.8 y 9.5  S' " ,timer.getTimeLeftUntilFinish() );
  }  else if( (timerS.isRunning() && !timer.isRunning() ) &&
            (timerS.getTimeLeftUntilFinish() < 10000 && timerS.getTimeLeftUntilFinish() < 7000 ) ) {
      contador = 2;
      tint(255, 120);
      textFont(fuente);
      textSize(20);
      fill(#ffffff);
      textAlign(1);
      text("Analizando rasgos para designar sexo", 20, 50);
      println("##Analizando +1 S: " ,timerS.getTimeLeftUntilFinish() );
  } else if( (timerS.isRunning() && !timer.isRunning() ) &&
            (timerS.getTimeLeftUntilFinish() < 7000 && timerS.getTimeLeftUntilFinish() > 5000)  ) {
      tint(255, 120);
      textFont(fuente1);
      textSize(70);
      fill(#ffffff);
      textAlign(1);
      text(etiqueta[rand], ojosDatos[0]-50, ojosDatos[1]);
      println("##ETIQUETA entre 3 y 5 S' " ,timerS.getTimeLeftUntilFinish() );
  } else if ( (timerS.isRunning() && !timer.isRunning()) &&
              timerS.getTimeLeftUntilFinish() < 5000  ) {//Si esta corriendo el timer0 y tiene mas de 2 segundos para acabar
      tint(255,0,0, 120);
      textFont(fuente);
      textSize(70);
      fill(#ffffff);
      textAlign(1);
      text("##ERROR",ojosDatos[0]-50, ojosDatos[1]);
      textFont(fuente);
      textSize(20);
      fill(#ffffff);
      textAlign(1);
      text("Sexo desconocido", 20, 50);
      println("##ERROR entre 7.8 y 9 S' " ,timerS.getTimeLeftUntilFinish() );
      contador = 3;
  }
}

void onFinishEvent(CountdownTimer t) {
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

void onTickEvent(CountdownTimer t, long timeLeftUntilFinish) {


}
/*//////////////////////////////////////////////////////
 Funcion que dibuja las etiquetas Caras
 *///////////////////////////////////////////////////////
int generarEtiqueta(int num) {
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
void dibujarIconos() {
  PImage carab, carar, ojob, ojor, narizr, narizb, bocab, bocar;
  /*////////////////////////////////////////////////////////////////////////////////
        Este código utiliza iconos hechos por Freepixhttp://www.freepik.com/
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

  fill(#ffffff);
  scale(.5);
  if (caraB == true) {
    image(carab, 0, margen);
  } else {
    image(carar, 0, margen);
  }
  // image(carab, 0, margen);

  if (ojosB == true) {
    image(ojob, 0, margen * 4.5);
  } else {
    image(ojor, 0, margen * 4.5);
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
void sendData(int msjNum) {
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