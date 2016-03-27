# RostroyOSC
Detecta caracteristaicas faciales con OpenCV Processing 

Detecta El rostro, y de este extrae el ancho y alto del mismo, asi como las coordenadas donde se encuentra el rectangulo.
Dentro del rostro detecta los ojos, estos tienen los mismos atributos de la cara (alto, ancho , y posicion -x, y-). 
Debajo de los ojos detecta la nariz, con el mismo numero de atributos que los demás objetos.
Debajo de la nariz detecta finalmente la nariz y envia los datos obtenidos por osc al puerto 12000.

Este proyecto es parte del proyecto Terminal de MaDIC 2016 Arte electrónico y procesos creativos.

Librerias utilizadas en el proyecto se pueden descargar directamente del apartado de herramientas del IDE de Processing,o desgcargarlas por medio de los links proporcionadosen .

OpenCV para processing. https://github.com/atduskgreg/opencv-processing
OscP5. http://www.sojamo.de/libraries/oscP5/#installation
NetP5. http://www.sojamo.de/libraries/oscP5/#installation
Rectangle. Incluido en la instalación de Java.

