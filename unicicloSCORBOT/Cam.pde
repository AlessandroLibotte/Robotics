
public class Cam{
 
  public boolean camMoving = false;
  private float cypos, cxpos, czpos = 1;
  private float camCurrang, camStartx, camStarty, camOldy = 0;
  private int camOrbitRad = 300;
  
  public void setPos(float bex, float bey, float bez, float bcx, float bcy, float bcz, int bux, int buy, int buz){
    beginCamera();
    camera(bex+cxpos, bey+cypos, bez+czpos, bcx+0, bcy+0, bcz+0, bux, buy, buz);
    endCamera();
  }
  
  public void updatePos(){
    cypos = (mouseY-camStarty)+camOldy;
    cxpos = cos(radians((mouseX-camStartx)/3)+camCurrang)*camOrbitRad;
    czpos = sin(radians((mouseX-camStartx)/3)+camCurrang)*camOrbitRad;
  }

  public void setStartPoint(){
    camCurrang = atan2(czpos,cxpos);
    camStartx = mouseX;
    camStarty = mouseY;
    camOldy = cypos;
  }
    
}
