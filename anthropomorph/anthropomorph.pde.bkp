int currLink = 0;
float[] theta = {0,0,0,0,0,0};
int l6o = 0;
Cam cam;

void setup(){
  size(700,700,P3D);
  
  cam = new Cam();
  cam.updatePos();
}

void draw(){
 
  background(220);
  
  cam.setPos();
  
  if(keyPressed){
    if (currLink >= 0 && currLink < 6){
      if (keyCode == LEFT && theta[currLink] < PI-0.4) theta[currLink]+=0.05;
      else if(keyCode == RIGHT && theta[currLink] > -PI+0.4) theta[currLink]-=0.05;
    }
    else{
      if (keyCode == LEFT && l6o < 4) l6o+=1;
      else if(keyCode == RIGHT && l6o > 0) l6o-=1;
    }
  }
  
  //Base
  box(50,30,50);
  //link1
  translate(0,20,0);
  box(10,10,10);
  //link2
  rotateY(theta[0]);
  translate(0,10,0);
  box(10,10,10);
  //link3
  rotateX(theta[1]);
  translate(0,30,0);
  box(10,50,10);
  //link4
  translate(0,25,0);
  rotateX(theta[2]);
  translate(0,25,0);
  box(10,50,10);
  //link5
  translate(0,25,0);
  rotateY(theta[3]);
  translate(0,10,0);
  box(10,20,10);
  //link6
  translate(0,10,0);
  rotateX(theta[4]);
  translate(0,10,0);
  box(10,20,10);
  //pinza
  translate(0,11.5,0);
  rotateY(theta[5]);
  box(15,3,15);
  translate(-1.5-l6o,5,0);
  box(3,7,10);
  translate(3+(2*l6o),0,0);
  box(3,7,10);
  
}

void keyPressed(){
  if(keyCode == UP && currLink < 7) currLink+=1;
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
