
public class Cam{
 
  public boolean camMoving = false;
  private float cypos, cxpos, czpos = 1;
  private float camCurrang, camStartx, camStarty, camOldy = 0;
  private int camOrbitRad = 500;
  
  public void setPos(){
    beginCamera();
    camera(cxpos, cypos, czpos, 0, 0, 0, 0, -1, 0);
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
