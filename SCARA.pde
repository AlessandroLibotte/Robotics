
float[] theta = {0, 0, 0};
int currLink = 0;
int l3h = 0;
int l4o = 0;
Cam cam;

void setup(){
  size(700,700,P3D);
  
  cam = new Cam();
  cam.updatePos();
}

void draw() {
  background(220);
  
  cam.setPos();
  
  //controllo manuale
  if(keyPressed){
    //giunti rotoidali [link1, link2, polso]
    if (currLink >= 0 && currLink < 3){
      if (keyCode == LEFT && theta[currLink] < PI-0.4) theta[currLink]+=0.05;
      else if(keyCode == RIGHT && theta[currLink] > -PI+0.4) theta[currLink]-=0.05;
    }
    //link3
    else if (currLink == 3){
      if (keyCode == LEFT && l3h < 27.5) l3h+=1;
      else if(keyCode == RIGHT && l3h > -27.5) l3h-=1;
    }
    //pinza
    else{
      if (keyCode == LEFT && l4o < 10) l4o+=1;
      else if(keyCode == RIGHT && l4o > 0) l4o-=1;
    }
  }
  
  fill(200,150,250);
  //link 1
  translate(0,45,0);
  box(25, 70, 25);
  //link2
  rotateY(theta[0]);
  translate(-32.5,47.5,0);
  if (currLink == 0) fill(200,0,100);
  else fill(200,150,250);
  box(90,25,25);
  //link3
  translate(-45,0,0);
  rotateY(theta[1]);
  translate(-35,0,0);
  if (currLink == 1) fill(200,0,100);
  else fill(200,150,250);
  box(90,25,25);
  //link4
  translate(-32.5,l3h,0);
  if (currLink == 3) fill(200,0,100);
  else fill(200,150,250);
  box(25,80,25);
  //polso
  translate(0,-45, 0);
  rotateY(theta[2]);
  if (currLink == 2) fill(200,0,100);
  else fill(200,150,250);
  box(30,10,15);
  //pinza
  if (currLink == 4) fill(200,0,100);
  else fill(200,150,250);
  translate(2.5+l4o,-15,0);
  box(5,20,15);
  translate(-5-(2*l4o),0,0);
  box(5,20,15);
  
}

void keyPressed(){
  if(keyCode == UP && currLink < 4) currLink+=1;
  if(keyCode == DOWN && currLink > 0) currLink -=1;
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
