class paletaGen {
TColor col;
ColorList tria;
ColorList anal;
ColorList comp;
ColorList lSplit;
int[] paletaCustom = new int[6];
float SWATCH_HEIGHT = 20;
float SWATCH_WIDTH = 0;
int SWATCH_GAP = 15;

int yoff = 85;
int rand;

paletaGen(){

}

int[] createPal(String hex){
        col = TColor.newHex(hex);
        // Creacuion de las listas donde se guardan las paletas creadas
        tria = new ColorList();
        anal = new ColorList();
        comp = new ColorList();
        lSplit = new ColorList();
        //background(0);
        // ArrayList strategies = ColorTheoryRegistry.getRegisteredNames();
        // println(strategies);
        tria = ColorList.createUsingStrategy(
                ColorTheoryRegistry.getStrategyForName("TRIAD"), col);
        tria = tria.sortByProximityTo(col, false);
        //SWATCH_WIDTH = (width - 200) / tria.size();
        //swatches(tria, 100, 50);

        anal = ColorList.createUsingStrategy(
                ColorTheoryRegistry.getStrategyForName("ANALOGOUS"), col);
        anal = anal.sortByProximityTo(col, false);
        //SWATCH_WIDTH = (width - 200) / anal.size();
        //swatches(anal, 100, 100);

        comp = ColorList.createUsingStrategy(
                ColorTheoryRegistry.getStrategyForName("COMPOUND"), col);
        comp = comp.sortByProximityTo(col, false);
        //SWATCH_WIDTH = (width - 200) / comp.size();
        //swatches(comp, 100, 150);

        lSplit = ColorList.createUsingStrategy(
                ColorTheoryRegistry.getStrategyForName("SPLIT_COMPLEMENTARY"), col);
        lSplit = lSplit.sortByProximityTo(col, false);
        //SWATCH_WIDTH = (width - 200) / lSplit.size();
        //swatches(lSplit, 100, 200);
        // Convertir paleta a integers RGBA
        int[] colTria = tria.toARGBArray();
        int[] colAnal = anal.toARGBArray();
        int[] colComp = comp.toARGBArray();
        int[] colSplit = lSplit.toARGBArray();
        paletaCustom[0] = colComp[1];
        paletaCustom[1] = colAnal[1];
        paletaCustom[2] = colAnal[3];
        paletaCustom[3] = colAnal[4];
        paletaCustom[4] = colTria[2];
        paletaCustom[5] = colSplit[1];

        //println("#######");
        //println("####Paleta Nueva: ", hex);
        return paletaCustom;
}

void dibujarPaletaF(){
        // Dibujar la paleta generada en relacion al color extraido
        fill(paletaCustom[0]);
        rect(10, 0, 80, 30);
        fill(paletaCustom[1]);
        rect(10, 30, 80, 30);
        fill(paletaCustom[2]);
        rect(10, 30*2, 80, 30);
        fill(paletaCustom[3]);
        rect(10, 30*3, 80, 30);
        fill(paletaCustom[4]);
        rect(10, 30*4, 80, 30);
        fill(paletaCustom[5]);
        rect(10, 30*5, 80, 30);

}

// Dibujar las paletas
void swatch(TColor c, int x, int y) {
        fill(c.toARGB());
        rect(x, y, SWATCH_WIDTH, SWATCH_HEIGHT);
}
void swatches(ColorList sorted, int x, int y) {
        noStroke();
        for (Iterator i = sorted.iterator(); i.hasNext(); ) {
                TColor c = (TColor)i.next();
                swatch(c, x, y);
                x += SWATCH_WIDTH + SWATCH_GAP;
        }
}
}