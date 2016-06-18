

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
int coloresPaleta[];
String colorDatosHex;
int colorDatosInt;
int etiqueR;

void setup() {
  size(800, 1400);
  analisis = new Rostros(this);
  paleta = new paletaGen();
  analisis.setting(10000, 10000);
  analisis.preprocessing();
  etiqueR = round(random(1, 2));
}
void draw() {
  background(0);
  analisis.preprocessing();
  colorDatosInt = analisis.tomarMuestra( (analisis.cam.width / 2) /2, analisis.cam.height - 50, 0);
  colorDatosHex = hex(colorDatosInt, 6);
  //analisis.sendData(0);
  coloresPaleta = paleta.createPal(colorDatosHex);
  pushMatrix();
  //scale(.5);
  translate(width-120, height/2-height/4);
  noStroke();
  //paleta.dibujarPaletaF();
  popMatrix();

  pushMatrix();
  scale(-1, 1);
  translate(-width, 0);
  analisis.revisarIteraciones();
  pushMatrix();
  scale(.7);
  analisis.dibujarAnalisis();
  popMatrix();
  
  popMatrix();
  analisis.dibujarIconos( 950);
  pushMatrix();
  analisis.revisarTimer(etiqueR);
  int numerodefiguras = 1;
  //randomSeed(0);
  if (analisis.contador >= 3 && analisis.caraB ) {
    println("dijubar");
    orq = new Orquidea(coloresPaleta, 0, 100, -20, 0,
    
    map(analisis.caraDatos[3], 200,300, 200,600), map(analisis.caraDatos[2],200,300,200,400),
    map(analisis.ojosDatos[3],120,260, -50,0), map(analisis.ojosDatos[2],28,60, -80,0),
    map(analisis.bocaDatos[3],10,156, 0,80), map(analisis.bocaDatos[2],60,92,0,40), 
    map(analisis.narizDatos[3],80,168, -80,50), map(analisis.narizDatos[2], 68,140,-10,30),
    numerodefiguras);
    
    pushMatrix();
    scale(-1, 1); //<>//
    translate(-width+analisis.caraDatos[0]*2+analisis.caraDatos[3]/2*1, analisis.caraDatos[1]+analisis.caraDatos[2]);

    for (int i = 0; i <= numerodefiguras; i ++) {
      orq.dibujarBase(orq.vhor0, orq.vvert0, orq.vvert1, orq.vhor1, orq.anchoSBase-i, orq.altoSBase-i, random(220, 240), orq.paleta[0], -5);
    }
    for (int i = 0; i <= numerodefiguras*2; i++) {
      orq.dibujarMota(orq.anchoM0, orq.altoM0, 2);
    }
    orq.dibujarPetalo5(orq.vhor0, orq.vvert0, orq.vhor0, orq.vvert0, (orq.anchoP0), (orq.altoP0), random(200, 220), orq.paleta[4], 3);
    orq.dibujarPetalo2(orq.vhor0, orq.vvert0, orq.vhor0, orq.vvert0, (orq.anchoP0), (orq.altoP1), random(200, 220), orq.paleta[3], 1 );

    popMatrix();
  }

  popMatrix();
}