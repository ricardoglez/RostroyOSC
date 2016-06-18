/*////////////////////////////////////////////////////////////////////7
 Clase Rostros
 ////////////////////////////////////////////////////////////////////7*/
class Rostros {
  PImage caraROI;
  //Objetos OpenCVP5
  OpenCV caraCV;
  OpenCV ojosCV;
  OpenCV narizCV;
  OpenCV bocaCV;
  OpenCV contornos;
  ArrayList<Contour> contours; // Arreglo variable del numero de contornos
  Point[] puntos;
  //Timers que controlan el tiempo que aparece la etiqueta y el Error
  CountdownTimer timer;
  //Etiquetas mostradas
  String[] etiqueta = {
    "HOMBRE", "MUJER"
  };
  PApplet parent;
  //Fuentes
  PFont coolv, cour ;
  // Camara
  Capture cam;
  // Imagenes Escaladas
  PImage smaller;
  PGraphics capaEtiquetas;
  //dato del color muestra
  int colorMuestra;
  float[][] points = new float[36][2];
  PVector[] posiciones = new PVector[36]; //
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
  int scale =3;
  /*////////////////////////////////////////////////////////////////////7
   Inicializador de la clase Rostro
   Aqui se puede controlar la escala de la imagen este sketch usa (640,480)
   */  ////////////////////////////////////////////////////////////////////7
  Rostros(PApplet parent) {
    this.parent = parent;
  }

  void captureEvent(Capture cam) {
    cam.read();
  }
  /* ////////////////////////////////////////////////////////////////////7
   ///Aqui se colocan los valores del intervalo del cronometro que activa las
   etiquetas y envia por ultimo los datos al sketch de la orquidea
   */  ////////////////////////////////////////////////////////////////////7
  void setting(int intervalo, int total) {
    timer = CountdownTimerService.getNewCountdownTimer(parent).configure(intervalo, total);
    String[] camaras = Capture.list();
    println(camaras);
    println(camaras[0]);
    cam = new Capture(parent, 640, 480, "/dev/video0");
    cam.start();
    coolv = loadFont("CoolveticaRg-Regular-48.vlw");
    cour = loadFont("Courier10PitchBT-Roman-48.vlw");
    // Create the OpenCV object
    caraCV = new OpenCV(parent, cam.width / scale, cam.height / scale);
    ojosCV = new OpenCV(parent, cam.width / scale, cam.height / scale);
    narizCV = new OpenCV(parent, cam.width / scale, cam.height / scale);
    bocaCV = new OpenCV(parent, cam.width / scale, cam.height / scale);
    // Archivos de cascada
    caraCV.loadCascade(OpenCV.CASCADE_FRONTALFACE);
    ojosCV.loadCascade("haarcascade_mcs_eyepair_small.xml");
    narizCV.loadCascade(OpenCV.CASCADE_NOSE);
    bocaCV.loadCascade(OpenCV.CASCADE_MOUTH);
    // Make scaled down image y capa de las etiquetas

    smaller = createImage(caraCV.width, caraCV.height, GRAY);

    //capaEtiquetas = createGraphics(cam.width, cam.height);

    stroke(#ffffff);
  }
  /*////////////////////////////////////////////////////////////////////7
   Esta funcion ajusta las preferencias
   para el proceso de vision computarizada
   */  ////////////////////////////////////////////////////////////////////7
  void preprocessing() {
    // ObtenerDatos de camara
    println("Read Cam", cam.available());
    cam.read();
    // Copiar contenido a la imagen escalada

    println("Copy Content");
    //smaller.loadPixels();
    smaller.copy(cam, 0, 0, cam.width, cam.height, 0, 0, smaller.width, smaller.height);
    cam.loadPixels();

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

    println("Preprocessing");
  }

  void preprocessingCont(PImage src, int thresh) {
    contornos = new OpenCV(parent, src.width, src.height);
    contornos.loadImage(src);
    contornos.threshold(thresh);
    contornos.dilate();
    contornos.erode();
    contours = contornos.findContours();

    println("Preprocessing Contornos");
  }
  void dibujarContornos(float x_, float y_, float size, float escala) {
    int i = 0;
    pushMatrix();
    translate(x_, y_);
    scale(escala);
    stroke(#ffffff);
    //fill(#ffffff);
    strokeWeight(size);
    for (Contour contour : contours) {
      contour.draw();
      i++;
    }
    i=0;
    popMatrix();

    println("Dibujar Contornos");
  }


  /*//////////////////////////////////////////////////////
   Funcion que Por medio de una muestra de un color de la camara
   ajusta la saturacion y la luminosidad del mismo para
   generar una paleta del color con la libreria toxiclibs
   */  //////////////////////////////////////////////////////
  int tomarMuestra(int x_, int y_, int numMu_) {
    int muest_ = cam.get(x_, y_ );
    TColor colorM = TColor.newHex(hex(muest_, 6));
    //println("Muestra",colorM);
    TColor lightCol = colorM.getLightened(.32);
    lightCol = lightCol.getSaturated(.5);

    println("Tomar Muestra Color");
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
  PVector[] obtenerPos(int[] c, int num) {
    switch(num) {
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
      posiciones[9] = new PVector(c[0]*2 + c[2]/4*2, c[1]*2);
      posiciones[10] = new PVector(c[0]*2 + c[2]/2*2, c[1]*2);
      posiciones[11] = new PVector(c[0]*2 + c[2]/2*2 + c[2] /4*2, c[1]*2);
      posiciones[12] = new PVector(c[0]*2 + c[2]*2, c[1]*2);
      posiciones[13] = new PVector(c[0]*2 + c[2]*2, c[1]*2 + c[3] / 2*2);
      posiciones[14] = new PVector(c[0]*2 + c[2]*2, c[1]*2 + c[3]*2);
      posiciones[15] = new PVector(c[0]*2 + c[2]*2 - c[2]/4*2, c[1]*2 + c[3]*2);
      posiciones[16] = new PVector(c[0]*2 + c[2] / 2*2, c[1]*2 + c[3]*2);
      posiciones[17] = new PVector(c[0]*2 + c[2] / 2*2 - c[2]/4*2, c[1]*2 + c[3]*2);
      posiciones[18] = new PVector(c[0]*2, c[1]*2 + c[3]*2);
      posiciones[19] = new PVector(c[0]*2, c[1]*2 + c[3] / 2 *2 );
      for (int i = 8; i <= 19; i++) {
        points[i][0] = posiciones[i].x;
        points[i][1] = posiciones[i].y;
      }
      break;
    case 2:
      posiciones[20] = new PVector(c[0]*2, c[1]*2);
      posiciones[21] = new PVector(c[0]*2 + c[2] / 2*2, c[1]*2);
      posiciones[22] = new PVector(c[0]*2 + c[2]*2, c[1]*2);
      posiciones[23] = new PVector(c[0]*2 + c[2]*2, c[1]*2 + c[3] / 2*2);
      posiciones[24] = new PVector(c[0]*2 + c[2]*2, c[1]*2 + c[3]*2);
      posiciones[25] = new PVector(c[0]*2 + c[2] / 2*2, c[1]*2 + c[3]*2);
      posiciones[26] = new PVector(c[0]*2, c[1]*2 + c[3]*2);
      posiciones[27] = new PVector(c[0]*2, c[1]*2 + c[3] / 2 *2 );
      for (int i = 20; i <= 27; i++) {
        points[i][0] = posiciones[i].x;
        points[i][1] = posiciones[i].y;
      }
      break;
    case 3:
      posiciones[28] = new PVector(c[0]*2, c[1]*2);
      posiciones[29] = new PVector(c[0]*2 + c[2] / 2*2, c[1]*2);
      posiciones[30] = new PVector(c[0]*2 + c[2]*2, c[1]*2);
      posiciones[31] = new PVector(c[0]*2 + c[2]*2, c[1]*2 + c[3] / 2*2);
      posiciones[32] = new PVector(c[0]*2 + c[2]*2, c[1]*2 + c[3]*2);
      posiciones[33] = new PVector(c[0]*2 + c[2] / 2*2, c[1]*2 + c[3]*2);
      posiciones[34] = new PVector(c[0]*2, c[1]*2 + c[3]*2);
      posiciones[35] = new PVector(c[0]*2, c[1]*2 + c[3] / 2 *2 );
      for (int i = 28; i <= 35; i++) {
        points[i][0] = posiciones[i].x;
        points[i][1] = posiciones[i].y;
      }

      println("Obtener Pos");
      break;
    }
    /*//////////////////////////////////////////////////////////
     Posterior a almacenar los datos
     se genera un objeto Delaunay por cada dato encontrado
     En este caso 32 datos = 32 puntos para generar la triangulacion
     //////////////////////////////////////////////////////////*/
    Delaunay myDelaunay = new Delaunay( points );
    float[][] myEdges = myDelaunay.getEdges();
    for (int i=0; i<myEdges.length-1; i++) {
      if ((myEdges[i][0] != 0) || (myEdges[i][1]  != 0)) {
        float startX = myEdges[i][0];
        float startY = myEdges[i][1];
        float endX = myEdges[i][2];
        float endY = myEdges[i][3];
        strokeWeight(.7);
        line( startX, startY, endX, endY );
      } else {
        //Error Handler
      }
    }

    println("Delaunay");
    return posiciones;
  }
  /*////////////////////////////////////////////////////
   Funcion en la que se dibuja los elementos gráficos
   de Open Cv y los textos que refieren a la
   información extraida
   */  ////////////////////////////////////////////////////
  void dibujarAnalisis() {
    pushMatrix();
    translate(-50, 60);
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
         */        /////////////////////////////////
        if ( timer.getTimeLeftUntilFinish() > 100  ) {
          strokeWeight(5);
          stroke(#ffffff);
          noFill();
          rect(caraDatos[0]*2, caraDatos[1]*2, caraDatos[2]*2, caraDatos[3]*2);
          caraROI = cropFace(caraCV.getOutput(), caras[car]);          //image(caraROI, width-caraROI.width, 0);
          preprocessingCont(caraROI, 122);
          pushMatrix();
          translate(0, 0);
          dibujarContornos(caraDatos[0]*2, caraDatos[1]*2, .6, 6);
          popMatrix();
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
           */          /////////////////////////////////
          if (  timer.getTimeLeftUntilFinish() > 100  ) {
            stroke(#ffffff);
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
             */            /////////////////////////////////
            if (  timer.getTimeLeftUntilFinish() > 100  ) {
              strokeWeight(3);
              stroke(#ffffff);
              noFill();
              rect(narizDatos[0]*2, narizDatos[1]*2, narizDatos[2]*2, narizDatos[3]*2);
            }
            //sendData(3);
            // Dentro de la cara hay una boca
            if ((boca.length != 0) &&
              ((boca[0].x * scale > caraDatos[0]) && (boca[0].x * scale < caraDatos[0] + caraDatos[2])) &&
              ((boca[0].y * scale > caraDatos[1]) && (boca[0].y * scale < caraDatos[1] + caraDatos[3])) &&
              boca[0].y * scale > ojosDatos[1]) {
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
               */              /////////////////////////////////
              if (  timer.getTimeLeftUntilFinish() > 100  ) {
                stroke(#ffffff);
                noFill();
                rect(bocaDatos[0]*2, bocaDatos[1]*2, bocaDatos[2]*2, bocaDatos[3]*2);
              }
            }
            //Fin de proceo de boca
            else {//
              bocaB = false;
            }
          }//Fin Nariz
          else {
            narizB = false;
            bocaB = false;
          }
        } else {
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
    }

    println("Dibujar Analisis");
    popMatrix();
  }
  /*/////////////////////////////////////////////////////
   Funcion para activar y revisar los tiempos del timer
   */  /////////////////////////////////////////////////////
  void revisarTimer(int etique) {
    PImage err ;
    err = loadImage("errorr.png");
    int ra = int(random(25, 50));

    switch(contador) {
    case 0:
      /*/////////////////////////////////////////
       si no esta avanzando ningun timer
       y las variables cara ojos nariz y boca estan activados
       comienza el primer vuelta 0
       */      /////////////////////////////////////////////////
      if ( (!timer.isRunning()) && (caraB && ojosB && narizB && bocaB )) {
        timer.start();
        println("Comienzo");
        println("Conteo= ", contador);
        /*/////////////////////////////////////////
         el timer esta avanazando,
         si faltan menos de 10s y mas de 7s (osea si han pasado entre 0s y 3s)
         */        /////////////////////////////////////////////////
      } else if ((timer.isRunning()) && (timer.getTimeLeftUntilFinish() < 10000 && timer.getTimeLeftUntilFinish() > 7000) ) {
        textFont(cour);
        textSize(45);
        fill(#ffffff);
        textAlign(1);
        text("Analizando rasgos"+'\n'+"para designar sexo.", 70, 100);
        /*/////////////////////////////////////////
         el timer esta avanazando,
         si faltan menos de 7s y mas de 5s (osea si han pasado entre 3s y 5s)
         */        /////////////////////////////////////////////////
      } else if ( (timer.isRunning()) && (timer.getTimeLeftUntilFinish() < 7000 && timer.getTimeLeftUntilFinish() > 2000) ) {
        switch(etique) {
        case 1:
          textFont(coolv);
          textSize(90);
          textAlign(1);
          text(etiqueta[0], 70, 100);
          textFont(coolv);
          textSize(25);
          text(ra+"%", 70, 140);
          fill(#ffffff);
          rect(120, 130, ra*5, 10);
          break;
        case 2:
          textFont(coolv);
          textSize(90);
          textAlign(1);
          text(etiqueta[1], 70, 100);
          textFont(coolv);
          textSize(25);
          text(ra+"%", 70, 140);
          fill(#ffffff);
          rect(120, 130, ra*5, 10);
          //println("##Etiquetas entre 3 y 5 S' ", contador ,timer.getTimeLeftUntilFinish() );
          break;
        }
        /*/////////////////////////////////////////
         el timer esta avanazando,
         si faltan menos de 4s y mas de .5s (osea si han pasado entre 6s y 9.5s)
         */        /////////////////////////////////////////////////
      } else if ((timer.isRunning()) && (timer.getTimeLeftUntilFinish() < 1900 && timer.getTimeLeftUntilFinish() > 500)  ) {
        fill(#FFDA44);
        noStroke();
        rect(ojosDatos[0]-50, ojosDatos[1]-80, 280, 90);
        textFont(cour);
        textSize(90);
        fill(0);
        textAlign(1);
        text("ERROR", ojosDatos[0]-50, ojosDatos[1]);
        image(err, ojosDatos[0]+250, ojosDatos[1]-60, 70, 70);
        textSize(45);
        fill(#ffffff);
        textAlign(1);
        text("Sexo desconocido", 70, 100);
        //println("##ERROR entre 7.8 y 9.5  S' " ,timer.getTimeLeftUntilFinish() );
      } else if (timer.isRunning() && timer.getTimeLeftUntilFinish() <= 500) {
        println("Una Vueltaa: +1", timer.getTimeLeftUntilFinish(), contador);
        contador = 1;
        timer.stop(CountdownTimer.StopBehavior.STOP_IMMEDIATELY);
        println("Una Vueltaa: +1", timer.getTimeLeftUntilFinish(), contador);
      }
      break;
    case 1:
      /*/////////////////////////////////////////
       si no esta avanzando ningun timer
       y las variables cara ojos nariz y boca estan activados
       comienza el primer vuelta 1
       */      /////////////////////////////////////////////////
      if ( (!timer.isRunning()) && (caraB && ojosB && narizB && bocaB )) {
        timer.start();
        println("Segunda", timer.getTimeLeftUntilFinish(), contador);
        println("Conteo= ", contador);
        /*/////////////////////////////////////////
         el timer esta avanazando,
         si faltan menos de 10s y mas de 7s (osea si han pasado entre 0s y 3s)
         */        /////////////////////////////////////////////////
      } else if ((timer.isRunning()) && (timer.getTimeLeftUntilFinish() < 10000 && timer.getTimeLeftUntilFinish() > 7000) ) {
        textFont(cour);
        textSize(45);
        fill(#ffffff);
        textAlign(1);
        text("Analizando rasgos"+'\n'+"para designar sexo.", 70, 100);
        /*/////////////////////////////////////////
         el timer esta avanazando,
         si faltan menos de 7s y mas de 5s (osea si han pasado entre 3s y 5s)
         */        /////////////////////////////////////////////////
      } else if ( (timer.isRunning()) && (timer.getTimeLeftUntilFinish() < 7000 && timer.getTimeLeftUntilFinish() > 2000) ) {
        if (etique == 1) {
          etique = 2;
        } else {
          etique = 1;
        }
        switch(etique) {
        case 1:
          textFont(coolv);
          textSize(90);
          textAlign(1);
          text(etiqueta[0], 70, 100);
          textFont(coolv);
          textSize(25);
          text(ra+"%", 70, 140);
          fill(#ffffff);
          rect(120, 130, ra*5, 10);
          break;
        case 2:
          textFont(coolv);
          textSize(90);
          textAlign(1);
          text(etiqueta[1], 70, 100);
          textFont(coolv);
          textSize(25);
          text(ra+"%", 70, 140);
          fill(#ffffff);
          rect(120, 130, ra*5, 10);
          //println("##Etiquetas entre 3 y 5 S' ", contador ,timer.getTimeLeftUntilFinish() );
          break;
        }
        /*/////////////////////////////////////////
         el timer esta avanazando,
         si faltan menos de 4s y mas de .5s (osea si han pasado entre 6s y 9.5s)
         */        /////////////////////////////////////////////////
      } else if ((timer.isRunning()) && (timer.getTimeLeftUntilFinish() < 2000 && timer.getTimeLeftUntilFinish() > 500)  ) {
        fill(#FFDA44);
        noStroke();
        rect(ojosDatos[0]-50, ojosDatos[1]-80, 280, 90);
        textFont(cour);
        textSize(90);
        fill(0);
        textAlign(1);
        text("ERROR", ojosDatos[0]-50, ojosDatos[1]);
        image(err, ojosDatos[0]+250, ojosDatos[1]-60, 70, 70);
        textSize(45);
        fill(#ffffff);
        textAlign(1);
        text("Sexo desconocido", 70, 100);
        //println("##ERROR entre 7.8 y 9.5  S' " ,timer.getTimeLeftUntilFinish() );
      } else if (timer.isRunning() && timer.getTimeLeftUntilFinish() <= 500) {
        println("Dos Vueltas: +1", timer.getTimeLeftUntilFinish(), contador);
        contador =2;
        timer.stop(CountdownTimer.StopBehavior.STOP_IMMEDIATELY);
      }
      break;
    case 2:
      /*/////////////////////////////////////////
       si no esta avanzando ningun timer
       y las variables cara ojos nariz y boca estan activados
       comienza el primer vuelta 2
       */      /////////////////////////////////////////////////
      if ( (!timer.isRunning()) && (caraB && ojosB && narizB && bocaB )) {
        timer.start();
        println("Tercera", timer.getTimeLeftUntilFinish(), contador);
        println("Conteo= ", contador);
        /*/////////////////////////////////////////
         el timer esta avanazando,
         si faltan menos de 10s y mas de 7s (osea si han pasado entre 0s y 3s)
         */        /////////////////////////////////////////////////
      } else if ((timer.isRunning()) && (timer.getTimeLeftUntilFinish() < 10000 && timer.getTimeLeftUntilFinish() > 7000) ) {
        textFont(cour);
        textSize(45);
        fill(#ffffff);
        textAlign(1);
        text("Analizando rasgos"+'\n'+"para designar sexo.", 70, 100);
        /*/////////////////////////////////////////
         el timer esta avanazando,
         si faltan menos de 7s y mas de 5s (osea si han pasado entre 3s y 5s)
         */        /////////////////////////////////////////////////
      } else if ( (timer.isRunning()) && (timer.getTimeLeftUntilFinish() < 7000 && timer.getTimeLeftUntilFinish() > 2000) ) {        
        switch(round(random(1, 2))) {
        case 1:
          textFont(coolv);
          textSize(90);
          textAlign(1);
          text(etiqueta[0], 70, 100);
          textFont(coolv);
          textSize(25);
          text(ra+"%", 70, 140);
          fill(#ffffff);
          rect(120, 130, ra*5, 10);
          break;
        case 2:
          textFont(coolv);
          textSize(90);
          textAlign(1);
          text(etiqueta[1], 70, 100);
          textFont(coolv);
          textSize(25);
          text(ra+"%", 70, 140);
          fill(#ffffff);
          rect(120, 130, ra*5, 10);
          //println("##Etiquetas entre 3 y 5 S' ", contador ,timer.getTimeLeftUntilFinish() );
          break;
        }
        /*/////////////////////////////////////////
         el timer esta avanazando,
         si faltan menos de 4s y mas de .5s (osea si han pasado entre 6s y 9.5s)
         */        /////////////////////////////////////////////////
      } else if ((timer.isRunning()) && (timer.getTimeLeftUntilFinish() < 2000 && timer.getTimeLeftUntilFinish() > 500)  ) {
        fill(#FFDA44);
        noStroke();
        rect(ojosDatos[0]-50, ojosDatos[1]-80, 280, 90);
        textFont(cour);
        textSize(90);
        fill(0);
        textAlign(1);
        text("ERROR", ojosDatos[0]-50, ojosDatos[1]);
        image(err, ojosDatos[0]+250, ojosDatos[1]-60, 70, 70);
        textSize(45);
        fill(#ffffff);
        textAlign(1);
        text("Sexo desconocido", 70, 100);
        //println("##ERROR entre 7.8 y 9.5  S' " ,timer.getTimeLeftUntilFinish() );
      } else if (timer.isRunning() && timer.getTimeLeftUntilFinish() <= 500) {
        println("Tres Vueltas: +1", timer.getTimeLeftUntilFinish(), contador);
        contador =3;
        timer.stop(CountdownTimer.StopBehavior.STOP_IMMEDIATELY);
      }

      println("Revisar Timer");
      break;
    }
  }


  void onFinishEvent(CountdownTimer t, long l) {
  }
  void onTickEvent(CountdownTimer t, long timeLeftUntilFinish) {
  }
  /*//////////////////////////////////////////////////////
   Funcion que dibuja los iconos y cambia el color si ya
   se detecto este elemento en el proceso de cv
   */  //////////////////////////////////////////////////////
  void dibujarIconos( int cuantos) {

    PImage carab, carar, ojob, ojor, narizr, narizb, bocab, bocar;
    /*//////////////////////////////////////////////////////////////
     Esta funcion utiliza iconos
     creados por Freepix http://www.freepik.com/
     */    /////////////////////////////////////////////////////////////

    carab = loadImage("carab.png");
    carar = loadImage("carar.png");

    ojob = loadImage("ojob.png");
    ojor = loadImage("ojor.png");

    narizb = loadImage("narizb.png");
    narizr = loadImage("narizr.png");

    bocab = loadImage("bocab.png");
    bocar = loadImage("bocar.png");
    //TODO Modificar Posicion y Color de iconos rojos
    pushMatrix();
    translate(width/2, height);
    textFont(cour);
    //fill(#ffffff);
    scale(.5);
    if (caraB == true) {
      textSize(36);
      fill(#ffffff);
      text("x:" + caraDatos[0]*2 +'\n'+ "y:" + caraDatos[1]*2 +'\n' + "w:" +caraDatos[2]*2 + '\n'+"h:" + caraDatos[3]*2, -(width/4+width/8)-carab.width+25, -cuantos-150);
      image(carab, -(width/4+width/8)-carab.width, -cuantos);
    } else {
      textSize(36);
      fill(#ffffff);
      text("x:" + caraDatos[0]*2 +'\n'+ "y:" + caraDatos[1]*2 +'\n' + "w:" +caraDatos[2]*2 + '\n'+"h:" + caraDatos[3]*2, -(width/4+width/8)-carab.width+25, -cuantos-150);
      image(carar, -(width/4+width/8)-carab.width, -cuantos);
    }
    if (ojosB == true) {
      textSize(36);
      fill(#ffffff);
      text("x:" + ojosDatos[0]*2 +'\n'+ "y:" + ojosDatos[1]*2 +'\n' + "w:" +ojosDatos[2]*2 + '\n'+"h:" + ojosDatos[3]*2, -(width/8)-carab.width/2+25, -cuantos-150);
      image(ojob, -(width/8)-carab.width/2, -cuantos);
    } else {
      textSize(36);
      fill(#ffffff);
      text("x:" + ojosDatos[0]*2 +'\n'+ "y:" + ojosDatos[1]*2 +'\n' + "w:" +ojosDatos[2]*2 + '\n'+"h:" + ojosDatos[3]*2, -(width/8)-carab.width/2+25, -cuantos-150);
      image(ojor, -(width/8)-carab.width/2, -cuantos );
    }
    if (narizB == true) {
      textSize(36);
      fill(#ffffff);
      text("x:" + narizDatos[0]*2 +'\n'+ "y:" + narizDatos[1]*2 +'\n' + "w:" + narizDatos[2]*2 + '\n'+"h:" + narizDatos[3]*2, carab.width/2+25, -cuantos-150);
      image(narizb, carab.width/2, -cuantos);
    } else {
      textSize(36);
      fill(#ffffff);
      text("x:" + narizDatos[0]*2 +'\n'+ "y:" + narizDatos[1]*2 +'\n' + "w:" + narizDatos[2]*2 + '\n'+"h:" + narizDatos[3]*2, carab.width/2+25, -cuantos-150);
      image(narizr, carab.width/2, -cuantos);
    }
    if (bocaB == true) {
      textSize(36);
      fill(#ffffff);
      text("x:" + bocaDatos[0]*2 +'\n'+ "y:" + bocaDatos[1]*2 +'\n' + "w:" + bocaDatos[2]*2 + '\n'+"h:" + bocaDatos[3]*2, width/8+width/4+25, -cuantos-150);
      image(bocab, width/8+width/4, -cuantos);
    } else {
      textSize(36);
      fill(#ffffff);
      text("x:" + bocaDatos[0]*2 +'\n'+ "y:" + bocaDatos[1]*2 +'\n' + "w:" + bocaDatos[2]*2 + '\n'+"h:" + bocaDatos[3]*2, width/8+width/4+25, -cuantos-150);
      image(bocar, width/8+width/4, -cuantos );
    }

    println("Dibujar Iconos");
    popMatrix();
  }

  /*//////////////////////////////////////////////////////
   Funcion que envia los datos obtenidos del proceso de CV
   al sketch de la orquidea
   */  //////////////////////////////////////////////////////
  boolean revisarIteraciones() {
    boolean val = false;
    if (contador >= 3 && !caraB) {
      println("Reiniciar");
      contador =0;
      val = true;
    } else if (contador >= 3 && caraB) {
      //noStroke();
      val = false;
    }

    println("Revisar Iteraciones");
    return val;
  }

  PImage cropFace(PImage s, Rectangle source) {
    PImage img = createImage(source.width, source.height, GRAY);
    img.copy(s, source.x, source.y, source.width, source.height, 0, 0, source.width, source.height);
    img.updatePixels();

    println("Crop Face");
    return img;
  }
  /*//////////////////////////////////////////////////////
   Funcion que guarda muestra del rostro del interactor
   */  //////////////////////////////////////////////////////
  void keyPressed() {
    if (key == 'S') {
      println("Muestra Guardada");
      PImage muestra = createImage(caraDatos[2], caraDatos[3], RGB);
      muestra.copy(cam, caraDatos[0], caraDatos[1], caraDatos[2], caraDatos[3], 0, 0, caraDatos[2], caraDatos[2]);
      muestra.updatePixels();
      muestra.save("muestra-0.jpg");
      //println("Muestra Guardada");}
    }
  }
}