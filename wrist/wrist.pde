int currJoint = 0;
int currParam = 0;
float[] theta = {0,0,0,0,0,0};
int l6o = 0;
boolean inverse = false;
boolean position = false;
Cam cam;

float[] rpy = new float[3];
float[] pe = {0,50,-30};
float[][] R = new float[3][3];
float[][] T36 = new float[4][4];

import java.util.Arrays;

void setup(){
  size(700,700,P3D);
  
  cam = new Cam();
  cam.updatePos();
}

void draw(){
 
  background(220);
  
  cam.setPos();
  
  if(keyPressed){
    if (currJoint >= 0 && currJoint < 6){
      if (keyCode == LEFT && theta[currJoint] < PI-0.4) theta[currJoint]+=0.05;
      else if(keyCode == RIGHT && theta[currJoint] > -PI+0.4) theta[currJoint]-=0.05;
    }
    else{
      if (keyCode == LEFT && l6o < 4) l6o+=1;
      else if(keyCode == RIGHT && l6o > 0) l6o-=1;
    }
    if(inverse){
      if(key == 'w') if (position) pe[0]+=1; else rpy[0]+=0.1;
      if(key == 's') if (position) pe[0]-=1; else rpy[0]-=0.1;
      if(key == 'a') if (position) pe[1]+=1; else rpy[1]+=0.1;
      if(key == 'd') if (position) pe[1]-=1; else rpy[1]-=0.1;
      if(key == 'z') if (position) pe[2]+=1; else rpy[2]+=0.1;
      if(key == 'c') if (position) pe[2]-=1; else rpy[2]-=0.1; 
    }
  }
  
  if(inverse) computeInverse();
  
  printText();
  
  stroke(150,100,150);
  line(0,0,0, pe[0],pe[1],pe[2]);
  /*
  //Base
  stroke(0);
  noFill();
  translate(0,15,0);
  box(50,30,50);
  //link0
  stroke(0);
  fill(255);
  translate(0,20,0);
  box(10,10,10);
  //link1
  rotateY(theta[0]);
  translate(0,10,0);
  box(10,10,10);
  //link2
  rotateX(theta[1]);
  translate(0,30,0);
  box(10,50,10);
  //link3
  translate(0,25,0);
  rotateX(theta[2]);
  translate(0,25,0);
  box(10,50,10);
  //link4
  translate(0,25,0);
  */
  //stroke(150,100,150);
  
  pushMatrix();
  translate(0,20,0);
  stroke(255,0,0);
  line(0,0,0, 30,0,0);
  stroke(0,255,0);
  line(0,0,0, 0,50,0);
  stroke(0,0,255);
  line(0,0,0, 0,0,30);
  stroke(0);
  popMatrix();
  
  fill(255);
  rotateY(theta[3]);
  translate(0,10,0);
  box(10,20,10);
  //link5
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

//[cos(theta[1])*cos(theta[2]+theta[3]) sin(theta[1]) cos(theta[1]sin(theta[2]+theta[3]) ℓ2c1c2]
//s1c23 −c1 s1s23 ℓ1s1 + ℓ2s1c2
//s23 0 −c23 d1 + ℓ2s2
//0 0 0 1


void printText(){
  pushMatrix();
  
  scale(1, -1);
  
  fill(0);
  text("R", 220,-170);
  
  if(inverse) fill(255,0,0);
  else fill(0);
  text("Inverse", 100,-200);
  if(!inverse) fill(255,0,0);
  else fill(0);
  text("Direct", 100,-220);
  text("Selected Joint: ", 100, -240);
  text(currJoint+1, 175, -240);
  
  if (position&&inverse) fill(255,0,0);
  else fill(0);
  text("Pe", 100, -170);
  text(pe[0], 100, -150);
  text(pe[1], 100, -125);
  text(pe[2], 100, -100);
  
  if (!position&&inverse) fill(255,0,0);
  else fill(0);
  text("RPY", 145, -170);
  text(rpy[0], 140, -150);
  text(rpy[1], 140, -125);
  text(rpy[2], 140, -100);
  
  fill(0);
  text(R[0][0], 180,-150, 0);
  text(R[0][1], 180,-125, 0);
  text(R[0][2], 180,-100, 0);

  text(R[1][0], 220,-150, 0);
  text(R[1][1], 220,-125, 0);
  text(R[1][2], 220,-100, 0);

  text(R[2][0], 260,-150, 0);
  text(R[2][1], 260,-125, 0);
  text(R[2][2], 260,-100, 0);
  
  popMatrix(); 
}

void computeInverse(){
  
  R[0][0] = cos(rpy[0]) * cos(rpy[1]);
  R[0][1] = sin(rpy[0]) * cos(rpy[1]);
  R[0][2] = -sin(rpy[1]);
  
  R[1][0] = (cos(rpy[0])*sin(rpy[1])*sin(rpy[2]))-(sin(rpy[0])*cos(rpy[2]));
  R[1][1] = (sin(rpy[0])*sin(rpy[1])*sin(rpy[2]))+(cos(rpy[0])*cos(rpy[2]));
  R[1][2] = cos(rpy[1]) * sin(rpy[2]);
  
  R[2][0] = (cos(rpy[0]) * sin(rpy[1]) * cos(rpy[2])) +(sin(rpy[0]) * sin(rpy[2]));
  R[2][1] = (sin(rpy[0]) * sin(rpy[1]) * cos(rpy[2])) -(cos(rpy[0]) * sin(rpy[2]));
  R[2][2] = cos(rpy[1]) * cos(rpy[2]);

  if(theta[4] >= 0 && theta[4] < PI){
    theta[3] = atan2(R[2][1], R[2][0]);
    theta[4] = atan2(sqrt(pow(R[2][0], 2) + pow(R[2][1], 2)), R[2][2]);
    theta[5] = atan2(R[1][2], -R[0][2]);
  }
  else if (theta[4] < 0 && theta[4] > -PI){
    theta[3] = atan2(-R[2][1], -R[2][0]);
    theta[4] = atan2(-sqrt(pow(R[2][0], 2) + pow(R[2][1], 2)), R[2][2]);
    theta[5] = atan2(-R[1][2], R[0][2]);
  }

  float[] pw = new float[3];
  
  pw[0] = pe[0] - (R[2][0] * 20);
  pw[1] = pe[1] - (R[2][1] * 20);
  pw[2] = pe[2] - (R[2][2] * 20);
  
  theta[0] = atan2(pw[1], pw[0]);
  
  float A1 = (pw[0] * cos(theta[0])) + (pw[1] * sin(theta[0]));
  float A2 = 20 - pw[2];
  
  float t2 = (pow(A1,2)+pow(A2,2)-pow(70,2)-pow(50,2))/(2*50*70);
  theta[2] = asin(t2);
  
  float t1a = (70*cos(theta[2])*A1)-((70*sin(theta[2])+50)*A2);
  float t1b = ((70 *sin(theta[2])+50)*A1)+(70*cos(theta[2])*A2);
  theta[1] = -atan2(t1a,t1b);
  
}


void keyPressed(){
  
  if(keyCode == UP && currJoint < 6) currJoint+=1;
  if(keyCode == DOWN && currJoint > 0) currJoint -=1;
  
  if (key == 'i') inverse = !inverse;
  if(key =='p') position = !position;
  
  if (key =='0') Arrays.fill(rpy,0.);
    
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
