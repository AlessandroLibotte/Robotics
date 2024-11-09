/* Questo sketch disegna un robot SCARA (senza pinza) e un uniciclo nella sua posizione reale (rosso) e 
in quella stimata in base all'odometria (grigio). Lo SCARA insegue l'uniciclo nella sua posizione stimata.
I tasti u/U e d/D permettono di alzare e rispettivamente abbassare la visuale della scena. 
Per muovere l'uniciclo occorre utilizzare le frecce della tastiera:
freccia SU = accelerazione in avanti;
freccia GIU = accelerazione all'indietro;
freccia SINISTRA = accelerazione verso sinistra;
freccia DESTRA = accelerazione verso destra;
Con il tasto s/S si può fermare istantaneamente l'uniciclo. 
Con i tasti '+' e '-' si può modificare il parametro Kp della legge di controllo dello SCARA per
renderlo quindi più o meno reattivo.
Con i tasti q/Q, w/W, e/E, r/R, t/T e y/Y si possono modificare le perturbazioni pR, PL e pD sui raggi 
delle ruote e sulla loro distanza. Queste perturbazioni possono essere eliminate con il tasto SHIFT che 
riporta pR, pL e pD a uno.
Con il tasto k/K si può riportare a zero l'errore odometrico.
Con il tasto 1 si attiva la compensazione odometrica (da completare!) mentre con 0 la si disattiva. 
 */

// Parametro altezza telecamera 
float eyeY = 0;

// Variabile booleana che attiva o disattiva la compensazione all'errore odometrico
boolean COMPENSO = true;

// VARIABILI UNICICLO
//Posizione reale uniciclo
float xU = 0;
float yU = 0;
float thetaU = 0;
// Posizione stimata con odometria che è quella che insegue lo SCARA
float xOdo = 0;
float yOdo = 0;
float thetaOdo = 0;
// Velocità desiderate impostate da tastiera
float v1des = 0;
float v2des = 0;
// Velocità comandate (da aggiustare opportunamente)
float v1com = 0;
float v2com = 0;
// Velocità reali dell'uniciclo (l'obiettivo è che coincidano con quelle desiderate)
float v1r = 0;
float v2r = 0;
// Velocità angolari ruote [rad/s]
float omegaR = 0; // velocità angolare ruota destra
float omegaL = 0; // velocità angolare ruota sinistra
// Parametri nominali uniciclo
float rNom = 8; // raggio nominale ruote
float dNom = 25; // distanza nominale tra le ruote
// Parametri reali uniciclo
float pR = 1.01; // Perturbazione su raggio ruota destra
float pL = .9; // Perturbazione su raggio ruota sinistra
float pD = .95; // Perturbazione su distanza d
float rRvera = pR*rNom; // raggio reale ruota desta
float rLvera = pL*rNom; // raggio reale ruota sinistra
float dVera = pD*dNom; // distanza reale tra le ruote
// Altri parametri
float hUniciclo = 40; // altezza uniciclo 
float kpU = .5; // costante accelerazione uniciclo

float dt = (float) 1/60; // tempo di campionamento

// VARIABILI SCARA
// Coordinate del centro del link 1 del robot
float xBase;
float yBase;
// Variabile per compattare le condizioni di fine corsa
int segno = 1;
// Permette di selezionare il giunto da muovere
int giunto = 0;
// Dimensioni link 0:
float d0x = 50; // lungo x
float d0y = 50; // lungo y
float d0z = 20; // lungo z
// dimensioni link 1
float d1x = 50; // lungo x
float d1y = 50; // lungo y
float d1z = 20; // lungo z
// dimensioni giunto 2
float g2x = 20; // lungo x
float g2y = 20; // lungo y
float g2z = 40; // lungo z
// dimensioni link 2
float d2x = 20; // lungo x
float d2y = 150; // lungo y
float d2z = 20; // lungo z
// dimensioni giunto 3
float g3x = 20; // lungo x
float g3y = 20; // lungo y
float g3z = 40; // lungo z
// dimensioni link 3
float d3x = 20; // lungo x
float d3y = 150; // lungo y
float d3z = 20; // lungo z
// dimensioni giunto 4
float g4x = 20; // lungo x
float g4y = 20; // lungo y
float g4z = 40; // lungo z
// dimensioni link 4
float d4x = 20; // lungo x
float d4y = 20; // lungo y
float d4z = 30; // lungo z
// dimensioni link 5
float d5x = 20; // lungo x
float d5y = 20; // lungo y
float d5z = 30; // lungo z

float[] q = {0,0,0,0,0}; // Variabili di giunto attuali
float[] qDes = {0,0,0,0,0}; // Variabili di giunto desiderate
float kp = .5; // Costante controllo proporzionale SCORBOT
float argCos2,C2,S2,L1,L2; // Variabili cinematica inversa SCORBOT
float precisione = 0.001; // precisione posizionamento SCORBOT
float nGiri = 0; // correzione atan2 SCARA
float hSCORBOTdes = 10; // altezza desiderata dell'estremità dello SCARA sopra l'uniciclo
float c11,c12,c21,c22; // Coefficienti compensazione odometrica (da determinare!)
float zpolso;

Cam cam;

////////////// SETUP
void setup() 
{
  size(1000, 800, P3D);
  stroke(255);
  strokeWeight(2);
  xBase = width/2;
  yBase = height/2;  
  // Assegno coefficienti compensazione odometrica (da aggiustare qui e ogni volta che si cambiano
  // i parametri perturbativi del robot!)
  c11 = 1;
  c12 = 0;
  c21 = 0;
  c22 = 1;
  
  cam = new Cam();
  cam.updatePos();
}

////////////// DRAW
void draw() 
{
  
  background(0);
  lights();
  cam.setPos((width/2.0), height/2 - eyeY, (height/2.0) / tan(PI*60.0 / 360.0), width/2.0, height/2.0, 0, 0, 1, 0);  

  // Verifico se e quale tasto è stato premuto
  controllaTastiera();

// Velocità comandate
  if (COMPENSO)
  {
    
    c11 = (float)((pR + pL)/2);
    c12 = (float)((dNom/4) * (pR - pL));
    c21 = (float)((pR - pL)/(pD*dNom));
    c22 = (float)((1/(2*pD)) * (pR + pL));
    
    v2com = ((c11 * v2des) - (c21 * v1des))/((c11 * c22) - (c21 * c12));
    v1com = (v1des-(c12 * v2com))/c11;
    
    //v1com = c11*v1des + c12*v2des;
    //v2com = c21*v1des + c22*v2des;
  }
  else
  {
    v1com = v1des;
    v2com = v2des;
  }

// Velocità delle ruote calcolate in base alle velocità comandate e ai parametri nominali
  omegaR = (v1com+v2com*dNom/2)/rNom;
  omegaL = (v1com-v2com*dNom/2)/rNom;
    
// Velocità reali ottenute
  v1r = (rRvera*omegaR+rLvera*omegaL)/2;
  v2r = (rRvera*omegaR-rLvera*omegaL)/(dVera);
  
// Cinematica reale uniciclo
  xU = xU + v1r*cos(thetaU)*dt;
  yU = yU + v1r*sin(thetaU)*dt;
  thetaU = thetaU + v2r*dt;

  // Stima odometrica posa uniciclo basata sulle velocità desiderate impostate
  xOdo = xOdo + v1des*cos(thetaOdo)*dt;
  yOdo = yOdo + v1des*sin(thetaOdo)*dt;
  thetaOdo = thetaOdo + v2des*dt;

  // Cinematica inversa SCORBOT (per raggiungere xOdo, yOdo a una certa altezza fissata hSCARAdes 
  // sopra l'uniciclo): calcola le coordinate di giunto e muove i giunti con la legge proporzionale.
  inversaSCORBOT();
  
  pushMatrix(); // Memorizza il sistema di riferimento attuale

  // Disegno il piano d'appoggio
  fill(255);
  translate(xBase,yBase+d0y/2);
  beginShape();
    vertex(-width/2,0,-500);
    vertex(width/2,0,-500);
    vertex(width/2,0,500);
    vertex(-width/2,0,500);
  endShape(CLOSE);
  
  
  pushMatrix(); // Memorizza il sistema di riferimento attuale
  
  // Disegno uniciclo stimato in grigio con freccia verde davanti
  translate(xOdo,-hUniciclo/2,-yOdo);
  rotateY(thetaOdo);
  fill(150);
  box(60,hUniciclo,40); // uniciclo
  disegnaFreccia(2);  

  popMatrix(); // Ritorna al sistema di riferimento memorizzato al precedente pushMatrix()
  
  // Disegno uniciclo vero in rosso con freccia verde davanti
  translate(xU,-hUniciclo/2,-yU);
  rotateY(thetaU);
  fill(255,0,0);
  box(60,hUniciclo,40); // uniciclo
  disegnaFreccia(1);   
  
  
  popMatrix(); // Ritorna al sistema di riferimento memorizzato al precedente pushMatrix()
  
  pushMatrix(); // Memorizza il sistema di riferimento attuale

  // Disegno il robot SCARA 
  disegnaSCORBOT();
    
  popMatrix(); // Ritorna al sistema di riferimento memorizzato al precedente pushMatrix()
  
  // Scrivo sullo schermo le variabili d'interesse
  scriviTesto();

} 


////////////// CONTROLLA_TASTIERA
void controllaTastiera()
{
  if (keyPressed)
  {
    if ((key == 'd') || (key == 'D')) // abbasso la telecamera
    {
      eyeY -= 5;
    }
    if ((key == 'u') || (key == 'U')) // alzo la telecamera
    {
      eyeY += 5;
    }
    if (keyCode == UP) // aumento velocità longitudinale uniciclo
    {
      v1des += 5*kpU;
    }
    if (keyCode == DOWN)  // diminuisco velocità longitudinale uniciclo
    {
      v1des -= 5*kpU;
    }
    if (keyCode == LEFT)  // aumento velocità angolare uniciclo
    {
      v2des += .2*kpU;
    }
    if (keyCode == RIGHT)  // diminuisco velocità angolare uniciclo
    {
      v2des -= .2*kpU;
    }
    if ((key == 's') || (key == 'S'))  // fermo l'uniciclo
    {
      v1des = 0;
      v2des = 0;
    }
    if (key == '+') // aumento coefficiente accelerazione uniciclo
    {
      kp = min(1.99,kp+.01);
    }
    if (key == '-') // diminuisco coefficiente accelerazione uniciclo
    {
      kp = max(.01,kp-.01);
    }
    if ((key == 'q') || (key == 'Q')) // aumento raggio ruota destra
    {
      pR = min(1.3,pR+.01);
      rRvera = pR*rNom;
    }
    if ((key == 'w') || (key == 'W')) // diminuisco raggio ruota destra
    {
      pR = max(.7,pR-.01);
      rRvera = pR*rNom;
    }
    if ((key == 'e') || (key == 'E')) // aumento raggio ruota sinistra
    {
      pL = min(1.3,pL+.01);
      rLvera = pL*rNom;
    }
    if ((key == 'r') || (key == 'R')) // diminuisco raggio ruota sinistra
    {
      pL = max(.7,pL-.01);
      rLvera = pL*rNom;
    }
    if ((key == 't') || (key == 'T')) // aumento distanza d tra le ruote
    {
      pD = min(1.3,pD+.01);
      dVera = pD*dNom;
    }
    if ((key == 'y') || (key == 'Y')) // diminuisco distanza d tra le ruote
    {
      pD = max(.7,pD-.01);
      dVera = pD*dNom;
    }
    if (keyCode == SHIFT)
    {
      pR = 1;
      rRvera = rNom;
      pL = 1;
      rLvera = rNom;
      pD = 1;
      dVera = dNom;
    }
    if ((key == 'k') || (key == 'K'))
    {
      xOdo = xU;
      yOdo = yU;
      thetaOdo = thetaU;
    }
    if (key == '1')
    {
      COMPENSO = true;
    }
    if (key == '0')
    {
      COMPENSO = false;
    }    
  }  
}  


////////////// INVERSA_SCORBOT
void inversaSCORBOT()
{
  
  qDes[0] = atan2(-yOdo,xOdo) + nGiri*2*PI;
  
  float A1 = (xOdo * cos(qDes[0])) +(-yOdo * sin(qDes[0]));
  float d1 = d0z+d1z+(g2y/2);
  float zpolso = hUniciclo + hSCORBOTdes + d4z +d5z + (g4y/2);
  float A2 = d1 - zpolso;
  
  float l2 = (g2y/2)+d2y+(g3y/2);
  float l3 = (g3y/2)+d3y+(g4y/2);
  
  float argAcos = (pow(A1,2)+pow(A2,2)-pow(l2,2)-pow(l2,2))/(2*l2*l3);
  qDes[2] = acos(argAcos);
  
  float arg1Atan = ((l2 + (l3*cos(qDes[2]))) * A2) - (l3*sin(qDes[2])*A1);
  float arg2Atan = ((l2 + (l3*cos(qDes[2]))) * A1) + (l3*sin(qDes[2])*A2);
  
  qDes[1] = atan2(arg1Atan, arg2Atan)+PI/2;
  
  qDes[3] = -qDes[2]-qDes[1] + PI; //setto l'angolo di beccheggio desiderato 
  
  qDes[4] = thetaOdo+qDes[0]+PI;
  
  if (abs(q[0]-qDes[0]) > abs(q[0]-(qDes[0] + 2*PI)))
  {
    qDes[0] = qDes[0] + 2*PI;
    nGiri += 1;
  }
  if (abs(q[0]-qDes[0]) > abs(q[0]-(qDes[0] - 2*PI)))
  {
    qDes[0] = qDes[0] - 2*PI;
    nGiri -= 1;
  }
  if (abs(q[0]-qDes[0])>precisione)
  {
    q[0] += kp*(qDes[0]-q[0]);
  }
  if (abs(q[1]-qDes[1])>precisione)
  {
    q[1] += kp*(qDes[1]-q[1]);
  }
  if (abs(q[2]-qDes[2])>precisione)
  {
    q[2] += kp*(qDes[2]-q[2]);
  }    
  if (abs(q[3]-qDes[3])>precisione)
  {
    q[3] += kp*(qDes[3]-q[3]);
  }    
  if (abs(q[4]-qDes[4])>precisione)
  {
    q[4] += kp*(qDes[4]-q[4]);
  }    
}  


////////////// DISEGNA_SCARA
void disegnaSCORBOT()
{
  fill(200,0,200);// Colore dello SCORBOT
  translate(xBase,yBase+25);
  rotateX(PI/2);
  print_axes(true);//terna0
  translate(0,0,d0z/2);
  box(d0x,d0y,d0z);//link0 
  translate(0,0,(d0z/2)+(d1z/2));
  rotateZ(q[0]);
  box(d1x,d1y,d1z);//link1
  translate(0,0,(d1z/2)+(g2y/2));
  rotateX(-PI/2);
  print_axes(false);//terna 1
  box(g2x,g2y,g2z);//giunto 2
  rotateZ(q[1]);
  translate(0,-((g2y/3)+(d2y/2)),0);
  box(d2x,d2y,d2z);
  translate(0,-((d2y/2)+(g3y/3)),0);
  print_axes(false);//terna2
  box(g3x,g3y,g3z);//giunto3
  rotateZ(q[2]);
  translate(0,-((g2y/3)+(d3y/2)),0);
  box(d3x,d3y,d3z);//link3
  translate(0,-((d3y/2)+(g4y/3)),0);
  print_axes(false);//terna3
  box(g4x,g4y,g4z);//giunto4
  rotateZ(q[3]);
  rotateX(PI/2);
  print_axes(false);//terna4
  translate(0,0,(g4y/3)+(d4z/2));
  box(d4x,d4y,d4z);//link4
  translate(0,0,(d4z/2));
  rotateZ(q[4]);
  translate(0,0,(d5z/2));
  box(d5x,d5y,d5z);//link5
  translate(0,0,(d5z/2));
  print_axes(false);//terna5
  
  
  
  
}

void print_axes(boolean y){
 
  pushMatrix();
  stroke(255,0,0);
  line(0,0,0, 30,0,0);
  if(y){
    stroke(0,255,0);
    line(0,0,0, 0,30,0);
  }
  stroke(0,0,255);
  line(0,0,0, 0,0,30);
  stroke(0);
  popMatrix();
  
}

////////////// SCRIVI_TESTO
void scriviTesto()
{
  fill(200,0,200); 
  textSize(25);
  text("theta1 = ",10,70); 
  text(q[0]*180/PI,120,70);
  text("gradi",250,70);
  text("theta2 = ",10,120); 
  text(q[1]*180/PI,120,120);
  text("gradi",250,120);
  text("theta3 = ",10,170); 
  text(q[2]*180/PI,120,170);
  text("gradi",250,170);
  text("theta4 = ",10,220); 
  text(q[3]*180/PI,120,220);
  text("gradi",250,220);
  text("theta5 = ",10,270); 
  text(q[4]*180/PI,120,270);
  text("gradi",250,270);
  
  text("kpS = ",10,320); 
  text(kp,120,320);
  fill(0,0,255);  
  text("coordinata y vista = ",500,50); 
  text(eyeY,750,50);
  fill(255,0,0);  
  text("xU = ",500,100); 
  text(xU,570,100);
  text("yU = ",500,140); 
  text(yU,570,140);
  fill(150);  
  text("xOdo = ",700,100); 
  text(xOdo,800,100);
  text("yOdo = ",700,140); 
  text(yOdo,800,140);
  fill(255);
  text("pR = ",860,240); 
  text(pR,900,240);
  text("pL = ",860,290); 
  text(pL,900,290);
  text("pD = ",860,340); 
  text(pD,900,340);
  if (COMPENSO)
  {
    fill(0,255,0);
    text("ON",860,400);
  }
  else
  {
    fill(255,0,0);
    text("OFF",860,400);
  }
}


////////////// DISEGNA_FRECCIA
void disegnaFreccia(int tipo)
{
  translate(30,0,0);
  strokeWeight(5);
  if (tipo == 1)
  {
    fill(0,255,0);
    stroke(0,255,0);
  }
  else
  {
    fill(150);
    stroke(200);
  }
  beginShape();
    vertex(0,0,5);
    vertex(20,0,5);
    vertex(20,0,10);
    vertex(30,0,0);
    vertex(20,0,-10);
    vertex(20,0,-5);    
    vertex(0,0,-5);    
  endShape(CLOSE);
  beginShape();
    vertex(0,-5,0);
    vertex(20,-5,0);
    vertex(20,-10,0);
    vertex(30,0,0);
    vertex(20,10,0);
    vertex(20,5,0);    
    vertex(0,5,0);    
  endShape(CLOSE);
  strokeWeight(1);
  stroke(255);
}

void mousePressed(){
  if(mouseButton == LEFT) {
    cam.camMoving = true;
    cam.setStartPoint();
  }
  else cam.camMoving = false;
}

void mouseReleased() {
  cam.camMoving = false;
}

void mouseDragged(){
  if (cam.camMoving) cam.updatePos();
}

void mouseWheel(MouseEvent event) {
  cam.setStartPoint();
  cam.camOrbitRad += event.getCount()*10;
  cam.updatePos();
}
