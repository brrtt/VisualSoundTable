//Visual Sound Table UI //<>// //<>// //<>//
//New improved version built on tuio demo 
//barrett.c

// import libraries
import processing.sound.*;
import TUIO.*;

// declare a TuioProcessing client
TuioProcessing tuioClient;

// these are some helper variables which are used
// to create scalable graphical feedback
float cursor_size = 15;
float object_size = 60;
float table_size = 760;
float scale_factor = 1;
PFont font;

boolean verbose = false; // print console debug messages
boolean callback = true; // updates only after callbacks

//Oscillator Bank set up 
SinOsc osc0 = new SinOsc(this);
//SinOsc osc1 = new SinOsc(this); 

//counters
int t; 

void setup()
{
  // GUI setup
  noCursor();
  size(displayWidth,displayHeight);
  noStroke();
  fill(0);
  
  //periodic updates
  if (!callback) 
  {
    loop();
    frameRate(60);
  } 
  else noLoop(); // or callback updates 
  
  font = createFont("Arial", 12);
  scale_factor = height/table_size;
  
  // finally we create an instance of the TuioProcessing client
  // since we add "this" class as an argument the TuioProcessing class expects
  // an implementation of the TUIO callback methods in this class (see below)
  tuioClient  = new TuioProcessing(this);
}

// within the draw method we retrieve an ArrayList of type <TuioObject>, <TuioCursor> or <TuioBlob>
// from the TuioProcessing client and then loops over all lists to draw the graphical feedback.


void draw()
{
  if(t > 0) //object removed from screen 
  {
    t--;
  }
  else if(t == 0) //object is gone. (2 count to account for blips in reactivision)
  {
    osc0.stop();
  }
  
  background(0,0,64);
  textFont(font,12*scale_factor);
  float obj_size = object_size*scale_factor; 
  float cur_size = cursor_size*scale_factor; 
   
  ArrayList<TuioObject> tuioObjectList = tuioClient.getTuioObjectList();
  for (int i=0;i<tuioObjectList.size();i++) 
  {
     TuioObject tobj = tuioObjectList.get(i);
     pushMatrix();
     translate(tobj.getScreenX(width),tobj.getScreenY(height));
     
     //halo addition
     stroke(255,255,255);
     fill(15,152,255);
     arc(-obj_size/2,-obj_size/2,obj_size*1.5,obj_size*1.5,0,tobj.getAngle());
     
     //inner ellipse
     fill(0,0,64);
     ellipse(-obj_size/2,-obj_size/2,obj_size,obj_size);
     
     print(tobj.getSymbolID()); 
     if(tobj.getSymbolID() == 0)
     {
       float pitch = 100*norm(tobj.getAngle(),0,44/7)+100; // 44/7 to estimate 2pi
       osc0.play(pitch,1);
       t=2;
       
     }
     else if(tobj.getSymbolID() == 1)
     {
       float pitch = 100*norm(tobj.getAngle(),0,44/7)+200; // 44/7 to estimate 2pi
       osc0.play(pitch,1); 
       t=2;
     }
     else osc0.stop(); 
     
     if(t > 0)
     {
       t--;
     }
     else if(t == 0)
     {
       osc0.stop();
     }
     
     popMatrix();
     fill(255);  //text color
     text(""+tobj.getSymbolID(), tobj.getScreenX(width), tobj.getScreenY(height));
   }
   
   ArrayList<TuioCursor> tuioCursorList = tuioClient.getTuioCursorList();
   for (int i=0;i<tuioCursorList.size();i++) 
   {
      TuioCursor tcur = tuioCursorList.get(i);
      ArrayList<TuioPoint> pointList = tcur.getPath();
      
      if (pointList.size()>0) {
        stroke(0,0,255);
        TuioPoint start_point = pointList.get(0);
        for (int j=0;j<pointList.size();j++) {
           TuioPoint end_point = pointList.get(j);
           line(start_point.getScreenX(width),start_point.getScreenY(height),end_point.getScreenX(width),end_point.getScreenY(height));
           start_point = end_point;
        }
        
        stroke(64,0,64);
        fill(64,255,64);
        ellipse( tcur.getScreenX(width), tcur.getScreenY(height),cur_size,cur_size);
        fill(0);
        text(""+ tcur.getCursorID(),  tcur.getScreenX(width)-5,  tcur.getScreenY(height)+5);
      }
   }
   
  ArrayList<TuioBlob> tuioBlobList = tuioClient.getTuioBlobList();
  for (int i=0;i<tuioBlobList.size();i++) 
  {
     TuioBlob tblb = tuioBlobList.get(i);
     stroke(64);
     fill(64);
     pushMatrix();
     translate(tblb.getScreenX(width),tblb.getScreenY(height));
     rotate(tblb.getAngle());
     ellipse(0,0, tblb.getScreenWidth(width), tblb.getScreenHeight(height));
     popMatrix();
     fill(255);
     text(""+tblb.getBlobID(), tblb.getScreenX(width), tblb.getScreenY(height));
   }
}
