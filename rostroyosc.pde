import ddf.minim.*;
import megamu.mesh.*;
import processing.video.*;
import gab.opencv.*;
import java.awt.Rectangle;
import toxi.color.*;
import toxi.color.theory.*;
import toxi.util.datatypes.*;
import java.util.Iterator;
import com.dhchoi.CountdownTimer;
import com.dhchoi.CountdownTimerService;
import java.awt.Point;

Rostros analisis;
paletaGen paleta;
Orquidea orq;
Minim mini;
AudioPlayer fplayer;
int coloresPaleta[];
String colorDatosHex;
int colorDatosInt;
int etiqueR;
boolean taken, takenF, audio;

void setup() {
  size(800, 1400);
  analisis = new Rostros(this);
  paleta = new paletaGen();
  mini = new Minim(this);
  analisis.setting(10000, 10000);
  analisis.preprocessing();
  etiqueR = round(random(1, 2));
  taken = false;
  takenF = false;
}

void draw() {
  analisis.timeStamp =  nf(day(), 2) + "-"  + nf(hour(), 2) + nf(minute(), 2) + (second());
  background(0);
  analisis.preprocessing();
  colorDatosInt = analisis.tomarMuestra( (analisis.cam.width / 2) /2, analisis.cam.height - 50, 0);
  colorDatosHex = hex(colorDatosInt, 6);
  //analisis.sendData(0);
  coloresPaleta = paleta.createPal(colorDatosHex);
  pushMatrix();//All
  scale(-1, 1);
  translate(-width, 0);
  analisis.revisarIteraciones();
  pushMatrix();//SA
  scale(.5);
  translate(-190, 130);
  analisis.dibujarAnalisis();
  popMatrix();//SA
  popMatrix();//All
  analisis.dibujarIconos(950);
  pushMatrix();//TEXTOS
  analisis.revisarTimer(etiqueR);
  int numerodefiguras = 4;
  //randomSeed(0);
  if (analisis.contador == 3 && analisis.caraB ) {
    float anchoTotal = analisis.caraDatos[3] + analisis.ojosDatos[3] + analisis.narizDatos[3] +analisis.bocaDatos[3];
    float nv = randomGaussian()*random(8, 10);
    float distanciaNO = dist(analisis.ojosDatos[0], analisis.ojosDatos[1], analisis.narizDatos[0], analisis.narizDatos[0]+analisis.narizDatos[3]);
    float distanciaCO = dist (analisis.caraDatos[0], analisis.caraDatos[1], analisis.ojosDatos[0], analisis.ojosDatos[1]);
    nv = noise(nv*100, randomGaussian()*150);
    //anchoTotal = anchoTotal /6;
    if (distanciaNO <= 150 && distanciaNO >= 80) {
      /*///////////////////
       /////////N///////////
       ///////////////////*/
      println("#####N");
      orq = new Orquidea(coloresPaleta, map(anchoTotal, 120, 250, -1, 1), map(anchoTotal, 50, 200, 0, 70 ), map(distanciaNO, 50, 250, 50, 100), map(distanciaNO, 5, 150, -8, 8), 
        analisis.caraDatos[3]*nv *2, analisis.caraDatos[2]-analisis.caraDatos[3]/8 *nv *1  , 
        map(analisis.ojosDatos[3], 120, 260, -50, 0), map(analisis.ojosDatos[2], 28, 60, 0, 50), 
        map(analisis.bocaDatos[3], 10, 156, 00, 50), map(analisis.bocaDatos[2], 60, 92, 0, 50), 
        map(analisis.narizDatos[3], 80, 168, 00, 50), map(analisis.narizDatos[3], 68, 140, 0, 10), 
        numerodefiguras);
      println("dijubar", anchoTotal, distanciaNO, distanciaCO);
      pushMatrix();//OrquideaV
      scale(-1, 1);
      translate(-340-width+analisis.caraDatos[0]*2+analisis.caraDatos[3]/2*1, analisis.caraDatos[1]+analisis.caraDatos[2]);
      pushMatrix();//OrquideaS
      scale(1.4);
      for (int i = 0; i <= numerodefiguras; i ++) {
        orq.dibujarBase(orq.vhor0, orq.vvert0, orq.vvert1, orq.vhor1, orq.anchoSBase*(i*.10), orq.altoSBase*(i*.10), random(220, 240), orq.paleta[0], -5);
      }
      for (int i = 0; i <= numerodefiguras*2; i++) {
        orq.dibujarMota(orq.anchoM0, orq.altoM0, 2);
      }
      orq.dibujarPetalo5(orq.vhor0, orq.vvert0, orq.vhor0, orq.vvert0, (orq.anchoP0), (orq.altoP0), random(200, 220), orq.paleta[4], 3);
      orq.dibujarPetalo2(orq.vhor0, orq.vvert0, orq.vhor0, orq.vvert0, (orq.anchoP0), (orq.altoP1), random(200, 220), orq.paleta[3], 1 );
      popMatrix(); //OrquideaV
      popMatrix(); //OrquideaS
    } else if (distanciaNO > 150) {
      /*///////////////////
       /////////G///////////
       ///////////////////*/
      println("#####G");
      orq = new Orquidea(coloresPaleta, map(distanciaNO, 50, 180, -100, -50), map(distanciaNO, 50, 150, -100, -70 ), map(distanciaNO, 50, 120, 50, 100), map(distanciaNO, 5, 180, -8, 8), 
        analisis.caraDatos[3]*nv *2.5, analisis.caraDatos[2]-analisis.caraDatos[3]/8 *nv *2, 
        map(analisis.ojosDatos[3], 0, 260, -20, 20), map(analisis.ojosDatos[2], 0, 60, -30, 30), 
        map(analisis.bocaDatos[3], 10, 156, -20, 20), map(analisis.bocaDatos[2], 60, 92, -30, 40), 
        map(analisis.narizDatos[3], 80, 168, -80, 50), map(analisis.narizDatos[3], 68, 140, -10, 10), 
        numerodefiguras);
      println("dijubar", anchoTotal, distanciaNO, distanciaCO);
      pushMatrix();//OrquideaV
      scale(-1, 1);
      translate(-340-width+analisis.caraDatos[0]*2+analisis.caraDatos[3]/2*1, analisis.caraDatos[1]+analisis.caraDatos[2]);
      pushMatrix();//OrquideaS
      scale(1.4);
      for (int i = 0; i <= numerodefiguras; i ++) {
        orq.dibujarBase(orq.vhor0, orq.vvert0, orq.vvert1, orq.vhor1, orq.anchoSBase*(i*.10), orq.altoSBase*(i*.10), random(220, 240), orq.paleta[0], -5);
      }
      for (int i = 0; i <= numerodefiguras*2; i++) {
        orq.dibujarMota(orq.anchoM0, orq.altoM0, 2);
      }
      orq.dibujarPetalo5(orq.vhor0, orq.vvert0, orq.vhor0, orq.vvert0, (orq.anchoP0), (orq.altoP0), random(200, 220), orq.paleta[4], 3);
      orq.dibujarPetalo2(orq.vhor0, orq.vvert0, orq.vhor0, orq.vvert0, (orq.anchoP0), (orq.altoP1), random(200, 220), orq.paleta[3], 1 );
      popMatrix(); //OrquideaV
      popMatrix(); //OrquideaS
    } else if (distanciaNO < 80 ) {
      /*///////////////////
       /////////CH///////////
       ///////////////////*/

      println("#####CH");
      orq = new Orquidea(coloresPaleta, map(distanciaNO, 50, 180, -100, -80), map(distanciaNO, 50, 200, 0, 70 ), map(distanciaNO, 50, 180, -100, -30), map(distanciaNO, 5, 150, -8, 8), 
       analisis.caraDatos[3]*nv *2.5, analisis.caraDatos[2]-analisis.caraDatos[3]/8 *nv *1,
        map(analisis.ojosDatos[3], 0, 260, -20, 20), map(analisis.ojosDatos[2], 0, 60, -30, 30), 
        map(analisis.bocaDatos[3], 10, 156, -20, 20), map(analisis.bocaDatos[2], 60, 92, -30, 40), 
        map(analisis.narizDatos[3], 80, 168, -80, 50), map(analisis.narizDatos[3], 68, 140, -10, 10), 
        numerodefiguras);
      println("dijubar", anchoTotal, distanciaNO, nv);
      pushMatrix();//OrquideaV
      scale(-1, 1);
      translate(-340-width+analisis.caraDatos[0]*2+analisis.caraDatos[3]/2*1, analisis.caraDatos[1]+analisis.caraDatos[2]);
      pushMatrix();//OrquideaS
      scale(1.4);
      for (int i = 0; i <= numerodefiguras; i ++) {
        orq.dibujarBase(orq.vhor0, orq.vvert0, orq.vvert1, orq.vhor1, orq.anchoSBase*(i*.10), orq.altoSBase*(i*.10), random(220, 240), orq.paleta[0], -5);
      }
      for (int i = 0; i <= numerodefiguras*2; i++) {
        orq.dibujarMota(orq.anchoM0, orq.altoM0, 2);
      }
      orq.dibujarPetalo5(orq.vhor0, orq.vvert0, orq.vhor0, orq.vvert0, (orq.anchoP0), (orq.altoP0), random(200, 220), orq.paleta[4], 3);
      orq.dibujarPetalo2(orq.vhor0, orq.vvert0, orq.vhor0, orq.vvert0, (orq.anchoP0), (orq.altoP1), random(200, 220), orq.paleta[3], 1 );
      popMatrix(); //OrquideaV
      popMatrix(); //OrquideaS
    }
    
     if (analisis.contador == 3 && taken == false) {
          saveFrame("MuestraOrquidea-"+analisis.contador+"-"+analisis.timeStamp+".jpg");
          analisis.captureFace(analisis.timeStamp);
          taken =true;
          println();
        } else if ( taken == true &&  analisis.reiniciado ) {
          //NONE
          taken = false;
          println("none");
        }
    
    
  }
  
  popMatrix();//TEXTOS
}