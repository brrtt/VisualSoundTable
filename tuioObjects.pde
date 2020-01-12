//tuioObjects.pde
//JBC SNRDSGN
//functions, and their relevant classes and variables, for handling TUIO Object Events

//////////////////////////////////////////////////VARIABLE & CLASS DECLARATIONS

//object draw variables
float twoPi=44/7; //used for drawing circles and arcs
float obj_size = object_size*scale_factor; //important for scaling drawn shapes to physical size of fiducials 
boolean resonant; //used in the rotation functionality of base fiducials. if resonant=true then the arc surrounding the fiducial turns green. will add more graphic functionality late
float rotationRange0=10; 
float rotationRange=30; //currently sets the size of the band of frequencies each base block can be rotated through. 
float haloSize=2.4; //sets the size of the interactive halo for linking and the outer halo (diameter not radius)
float playHalo=9;
float arcScalar=1.9; //used for tuning exact size of rotation arc

int npCount=0;


//////////////////////////////////////////////////FUNCTIONS

void tuioObjectDraw()
{
  ArrayList<TuioObject> tuioObjectList = tuioClient.getTuioObjectList();
  for (int i=0; i<tuioObjectList.size(); i++) 
  {
    TuioObject tobj = tuioObjectList.get(i);


    pushMatrix();
    strokeWeight(2);
    lineRender(tobj);
    if(state==main)
    {
    drawOrder(setSequence());
    }

    translate(tobj.getScreenX(width), tobj.getScreenY(height));
    rotate(-PI/2);

    //outer halo
    strokeWeight(4);
    outerHalo(tobj);

    //changed stroke weight for filled arcs
    strokeWeight(1);
    if (tobj.getSymbolID()<=15)
    {
      innerArc(tobj);
    } else rotationArc(tobj); 

    noStroke(); 
    //rectangle illuminating fiducial, will add specific colors depending on fiducial ID 
    innerEllipse(tobj); 
    //centerRect(tobj); 
    centerCircle(tobj); 

    popMatrix();

    fill(255);  //text color
    Long ID=tobj.getSessionID(); 
    if (baseBlockMap.get(ID)!=null && verboseTable) 
    {
      try
      {
        text("pitch: "+baseBlockMap.get(ID).getPitch(), tobj.getScreenX(width)-160, tobj.getScreenY(height)-80);
        text("dist: "+baseBlockMap.get(ID).getDist(), tobj.getScreenX(width)-160, tobj.getScreenY(height)-100);
        text("playing: "+baseBlockMap.get(ID).isPlaying(), tobj.getScreenX(width)-160, tobj.getScreenY(height)-120);
        text("center: "+baseBlockMap.get(ID).isCenterInRange(), tobj.getScreenX(width)-160, tobj.getScreenY(height)-140);
        text("linkedEnv: "+baseBlockMap.get(ID).getLinkedEnv(), tobj.getScreenX(width)-160, tobj.getScreenY(height)-160);
        text("symbol ID: "+tobj.getSymbolID(), tobj.getScreenX(width)-160, tobj.getScreenY(height)-180);
      }
      catch(java.lang.NullPointerException e)
      {
        println("caught nullpointer line 55 tuioObjects");
      }
    }
    fill(0);
    if (tobj.getSymbolID()==squareID)
    {
      text("square wave", tobj.getScreenX(width)-50, tobj.getScreenY(height)+100);
    }

    if (tobj.getSymbolID()==triangleID)
    {
      text("triangle wave", tobj.getScreenX(width)-50, tobj.getScreenY(height)+100);
    }

    if (tobj.getSymbolID()==sawtoothID)
    {
      text("sawtooth wave", tobj.getScreenX(width)-50, tobj.getScreenY(height)+100);
    }
  }
}

public void lineRender(TuioObject tobj)
{
  stroke(255);
  fill(255);
  switch(tobj.getSymbolID())
  {
  default:
    if (baseBlockMap.get(tobj.getSessionID()) != null && baseBlockMap.get(tobj.getSessionID()).isCenterInRange())
    {
          try
    {
      if (baseBlockMap.get(tobj.getSessionID()) != null && baseBlockMap.get(tobj.getSessionID()).isPlaying() && state==play) //nullpointerException
      {
        stroke(0, 255, 0);
        npCount++;
      } else stroke(255);
    }
    catch(java.lang.NullPointerException e)
    {
      println("caught nullpointer line 146 tuioObjects"); 
      stroke(255);
    }
      switch(baseBlockMap.get(tobj.getSessionID()).getLinkedEnv())
      {
      default: 
        sineTo(tobj.getScreenX(width), tobj.getScreenY(height), centerX, centerY, baseBlockMap.get(tobj.getSessionID()).getPitch(), 20);
        break;

      case 2: 
        squareTo(tobj.getScreenX(width), tobj.getScreenY(height), centerX, centerY, baseBlockMap.get(tobj.getSessionID()).getPitch(), 20);
        break;
        
      case 3:
        triangleTo(tobj.getScreenX(width), tobj.getScreenY(height), centerX, centerY, baseBlockMap.get(tobj.getSessionID()).getPitch(), 20);
        break;

      case 4:
        sawToothTo(tobj.getScreenX(width), tobj.getScreenY(height), centerX, centerY, baseBlockMap.get(tobj.getSessionID()).getPitch(), 20);
        break;
      }
    }
    break;

  case sineID:
    drawEnvLink(tobj, Sine);
    break; 

  case squareID: 
    drawEnvLink(tobj, Square);
    break;

  case triangleID:
    drawEnvLink(tobj, Triangle);
    break;

  case sawtoothID:
    drawEnvLink(tobj, Sawtooth);
    break;
  }
}

public void outerHalo(TuioObject tobj)
{
  stroke(255, 255, 255);
  noFill();
  float envHalo=(haloSize*map(tobj.getAngle(), radians(0), radians(360), .95, 2));
  switch(tobj.getSymbolID())
  {
  default:
    try
    {
      if (baseBlockMap.get(tobj.getSessionID()) != null && baseBlockMap.get(tobj.getSessionID()).isPlaying() && state==play) //nullpointerException
      {
        stroke(0, 255, 0);
        npCount++;
      } else stroke(255);
    }
    catch(java.lang.NullPointerException e)
    {
      println("caught nullpointer line 146 tuioObjects"); 
      stroke(255);
    }
    try
    {
      if (tuioClient.getTuioObjectList().size()<6 || baseBlockMap.get(tobj.getSessionID()).isPlaying())
      {
        waveHalo();
      } else
      {
        ellipse(tobj.getX(), tobj.getY(), obj_size*haloSize, obj_size*haloSize);
      }
    }
    catch(java.lang.NullPointerException e)
    {
      println("caught nullpointer line 163 tuioObjects");
    }

    break;

  case sineID:
    ellipse(tobj.getX(), tobj.getY(), obj_size*envHalo, obj_size*envHalo);
    break;

  case squareID:
    ellipse(tobj.getX(), tobj.getY(), obj_size*envHalo, obj_size*envHalo);
    break;

  case triangleID:
    ellipse(tobj.getX(), tobj.getY(), obj_size*envHalo, obj_size*envHalo);
    break;

  case sawtoothID:
    ellipse(tobj.getX(), tobj.getY(), obj_size*envHalo, obj_size*envHalo);
    break;

  case timingBlock:
    pushMatrix();
    rotate(PI/2);
    fill(0);
    textFont(font, 20*scale_factor);
    text("5s", 80, -80);
    text("10s", 85, 85);
    text("15s", -90, 90);
    text("Off", -85, -85);
    textFont(font, 12*scale_factor);
    popMatrix();
    break;    
    
    case sandReFeedBlock:
    break;
  }
}

public void rotationArc(TuioObject tobj)
{
  if (tobj.getSymbolID()>=15)
  {
    if (tobj.getSymbolID()<40 && tobj.getSymbolID()!=volumeBlock) //determines color of inner arc based on rotation angle, see further down 
    {
      fill(255, 0, 255);
    } else fill(15, 152, 255);
    noStroke();

    ellipse(tobj.getX(), tobj.getY(), obj_size*arcScalar, obj_size*arcScalar);

    fill(0);
    if(tobj.getSymbolID()!=sandReFeedBlock)
    {
    arc(tobj.getX(), tobj.getY(), obj_size*2.2, obj_size*2.2, tobj.getAngle()-.1, tobj.getAngle()+.1);
    }
  }
}

public void innerArc(TuioObject tobj)
{
  if (tobj.getSymbolID()<=15 || tobj.getSymbolID()==40)
  {
    fill(57, 255, 20);
  } else fill(15, 152, 255);
  noStroke();

  float arcScalar=1.9; //used for tuning exact size of inner arc
  ellipse(tobj.getX(), tobj.getY(), obj_size*arcScalar, obj_size*arcScalar);
}



public void innerEllipse(TuioObject tobj)
{
  noStroke();
  fill(background);
  ellipse(tobj.getX(), tobj.getY(), sqrt(2)*obj_size, sqrt(2)*obj_size); //to fit fiducial square in circle
}

public void centerRect(TuioObject tobj)
{
  pushMatrix();

  //noStroke();
  fill(255);
  rotate(tobj.getAngle());
  rect(tobj.getX(), tobj.getY(), obj_size, obj_size);
  //fill(255, 0, 0);

  popMatrix();
}

public void centerCircle(TuioObject tobj)
{
  fill(background); 
  ellipse(tobj.getX(), tobj.getY(), obj_size, obj_size);
}


void drawEnvLink(TuioObject tobj, int env)
{
  try
  {
    for (BaseBlock item : baseBlockMap.values()) //ConcurrentModificationException
    {
      if (item.getLinkedEnv()==env)
      {
        stroke(0);
        line(tobj.getScreenX(width), tobj.getScreenY(height), item.getObj().getScreenX(width), item.getObj().getScreenY(height));
      }
    }
  }
  catch(java.util.ConcurrentModificationException e)
  {
    println("caught concurrentModificationException line 231 tuioObjects");
  }
}
