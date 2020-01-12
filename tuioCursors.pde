//tuioCursors.pde //<>// //<>//
//JBC SNRDSGN
//functions, and their relevant classes and variables, for handling TUIO Cursor Events

//////////////////////////////////////////////////VARIABLE & CLASS DECLARATIONS

float cur_size = cursor_size*scale_factor; 

//////////////////////////////////////////////////FUNCTIONS

void tuioCursorHandle()
{
  strokeWeight(0);
  ArrayList<TuioCursor> tuioCursorList = tuioClient.getTuioCursorList();
  for (int i=0; i<tuioCursorList.size(); i++) 
  {
    TuioCursor tcur = tuioCursorList.get(i);
    if(tcur.getScreenY(height)<900)
    {
    //cursorT=1;
    ArrayList<TuioPoint> pointList = tcur.getPath(); 
    if (pointList.size()>0) 
    {
      stroke(0, 0, 255);
      TuioPoint start_point = pointList.get(0);
        for (int j=0; j<pointList.size(); j++) {
          TuioPoint end_point = pointList.get(j);
          //getCursorCoords(end_point);
          //println(end_point.getX()," ", end_point.getY());
          //line(start_point.getScreenX(width), start_point.getScreenY(height), end_point.getScreenX(width), end_point.getScreenY(height));
          start_point = end_point;
        }

       // stroke(64, 0, 64);
       //         fill(64,255,64);
       // ellipse( tcur.getScreenX(width), tcur.getScreenY(height), cur_size, cur_size);
                fill(0);
       // text(""+ tcur.getCursorID(), tcur.getScreenX(width)-5, tcur.getScreenY(height)+5);
      }
    }
  }
}

public void getCursorCoords(TuioPoint cur) //currently not in use
{ 
  cursorCoordsX=cur.getScreenX(width);
  cursorCoordsY=cur.getScreenY(height);
  //println(cursorCoordsX," ", cursorCoordsY);
}

void clearCursorCoords() //currently not in use but still running in main loop
{
  if (cursorT>0)
  {
    cursorT--;
  } else
  {
    cursorCoordsX=0;
    cursorCoordsY=0;
  }
}  



public void cursorTouch(int x, int y, float radius) //not in use but checks if a cursor is inside of a tuioObject's halo
{
  if (cursorCoordsX != 0 && cursorCoordsY != 0)
  {
    if (dist(cursorCoordsX, cursorCoordsY, x, y)<=radius)
    {
      //println("u done it");
      state=play;
    } 
  }
}
