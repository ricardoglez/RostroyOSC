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
  paleta.dibujarPaletaF();
  popMatrix();

  pushMatrix();
  scale(-1, 1);
  translate(-width, 0);
  analisis.revisarIteraciones();
  analisis.dibujarAnalisis();
  popMatrix();
  analisis.dibujarIconos( 950);
  pushMatrix();
  analisis.revisarTimer(etiqueR);

  if (analisis.contador ==3 && analisis.caraB ) {
    println("dijubar");
    orq = new Orquidea(coloresPaleta, random(-28, 28), random(-28, 28), random(-28, 28), random(-28, 28), analisis.caraDatos[3], analisis.caraDatos[2], analisis.ojosDatos[3], analisis.ojosDatos[2], analisis.narizDatos[3], analisis.narizDatos[2], analisis.bocaDatos[3], analisis.bocaDatos[2], 4);
    pushMatrix();
    translate(analisis.caraDatos[0]+analisis.caraDatos[3], analisis.caraDatos[1]+analisis.caraDatos[2]);
    int numerodefiguras = 4;
    scale(-1, 1);
    randomSeed(0);
    float rand = random(-3.2, 6.2);
    for (int i = 0; i <= numerodefiguras; i ++) {
      orq.dibujarBase(orq.vhor0, orq.vvert0, orq.vvert1, orq.vhor1, analisis.caraDatos[3]-i*rand, analisis.caraDatos[2]-i*rand, random(200, 220), orq.paleta[0], -5);
    }
    for (int i = 0; i <= numerodefiguras*2; i++) {
      orq.dibujarMota(orq.anchoM0, orq.altoM0, 2);
    }

    orq.dibujarPetalo5(orq.vhor0, orq.vvert0, orq.vhor0, orq.vvert0, (orq.anchoP0*rand), (orq.altoP0*rand), random(200, 220), orq.paleta[4], 3);
    orq.dibujarPetalo2(orq.vhor0, orq.vvert0, orq.vhor0, orq.vvert0, (orq.anchoP0*rand), (orq.altoP1*rand), random(200, 220), orq.paleta[3], 1 );

  popMatrix();
}

popMatrix();
}
