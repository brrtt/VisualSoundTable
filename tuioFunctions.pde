//functions for managing events on the TUIO board

// --------------------------------------------------------------
// these callback methods are called whenever a TUIO event occurs
// there are three callbacks for add/set/del events for each object/cursor/blob type
// the final refresh callback marks the end of each TUIO frame
// called when an object is added to the scene

boolean cursorTouched;

static final int sineID=36;
static final int squareID=37;
static final int triangleID=38;
static final int sawtoothID=39;

static final int timingBlock=40;
static final int sandReFeedBlock=46;
static final int volumeBlock=17;

int Default=0;
int Sine=1;
int Square=2;
int Triangle=3;
int Sawtooth=4;

int pitch0=255;
int pitch1=294;
int pitch2 =355; 
int pitch3=368;
int pitch4=575;
int pitch5=723;
int pitch6=799;
int pitch7=1295;
int pitch8=1422;
int pitch9=1599;
int pitch10=1712;


void addTuioObject(TuioObject tobj) 
{
  float envHalo=(haloSize*map(tobj.getAngle(), radians(0), radians(360), .5, 2));
  float linkDist=.5*obj_size*(envHalo+haloSize);

  switch(tobj.getSymbolID())
  {
  case 0: 
    addToMap(tobj);
    checkCenter(tobj);
    setBasePitch(tobj, pitch0);  
    break;

  case 1: 
    addToMap(tobj);
    checkCenter(tobj); 
    setBasePitch(tobj, pitch1);
    break; 

  case 2: 
    addToMap(tobj);
    checkCenter(tobj); 
    setBasePitch(tobj, pitch2);
    break; 

  case 3: 
    addToMap(tobj);
    checkCenter(tobj); 
    setBasePitch(tobj, pitch3);
    break; 

  case 4: 
    addToMap(tobj);
    checkCenter(tobj); 
    setBasePitch(tobj, pitch4);
    break; 

  case 5: 
    addToMap(tobj);
    checkCenter(tobj); 
    setBasePitch(tobj, pitch5);
    break; 

  case 6: 
    addToMap(tobj);
    checkCenter(tobj); 
    setBasePitch(tobj, pitch6);
    break;

  case 7: 
    addToMap(tobj);
    checkCenter(tobj); 
    setBasePitch(tobj, pitch7);
    //setPitch(tobj);
    //checkResonant(tobj);
    break; 

  case 8: 
    addToMap(tobj);
    checkCenter(tobj); 
    setBasePitch(tobj, pitch8);
    break; 

  case 9: 
    addToMap(tobj);
    checkCenter(tobj); 
    setBasePitch(tobj, pitch9);
    break; 

  case 10: 
    addToMap(tobj);
    checkCenter(tobj); 
    setBasePitch(tobj, pitch10);
    break; 

  case sineID:
    addEnvLink(tobj, Sine, linkDist);
    break;

  case squareID:
    addEnvLink(tobj, Square, linkDist);
    break;

  case triangleID:
    addEnvLink(tobj, Triangle, linkDist);
    break;

  case sawtoothID:
    addEnvLink(tobj, Sawtooth, linkDist);
    break;

  case timingBlock:
    setPlayDuration(tobj); 
    break;

  case volumeBlock:
    setVolume(tobj); 
    break;

  case sandReFeedBlock:
    checkSandReFeed(tobj); 
    break;
  }


  if (verbose) println("add obj "+tobj.getSymbolID()+" ("+tobj.getSessionID()+") "+tobj.getX()+" "+tobj.getY()+" "+tobj.getAngle());
}

// called when an object is moved
void updateTuioObject (TuioObject tobj) 
{
  float envHalo=(haloSize*map(tobj.getAngle(), radians(0), radians(360), .5, 2));
  float linkDist=.5*obj_size*(envHalo+haloSize);

  switch(tobj.getSymbolID())
  {
  case 0: 
    updateDistFromCenter(tobj);
    checkCenter(tobj); 
    break;

  case 1: 
    updateDistFromCenter(tobj);
    checkCenter(tobj); 
    break; 

  case 2: 
    updateDistFromCenter(tobj);
    checkCenter(tobj); 
    break; 

  case 3: 
    updateDistFromCenter(tobj);
    checkCenter(tobj); 
    setBasePitch(tobj, pitch3);  
    //setPitch(tobj);
    //checkResonant(tobj);
    if (baseBlockMap.get(tobj.getSessionID()).isPlaying())
    {
      pitch=baseBlockMap.get(tobj.getSessionID()).getPitch();
    }
    break; 

  case 4: 
    updateDistFromCenter(tobj);
    checkCenter(tobj); 
    setBasePitch(tobj, pitch4);  
    break; 

  case 5: 
    updateDistFromCenter(tobj);
    checkCenter(tobj); 
    break; 

  case 6: 
    updateDistFromCenter(tobj);
    checkCenter(tobj); 
    break;

  case 7: 
    updateDistFromCenter(tobj);
    checkCenter(tobj); 
    break; 

  case 8: 
    updateDistFromCenter(tobj);
    checkCenter(tobj); 
    break; 

  case 9: 
    updateDistFromCenter(tobj);
    checkCenter(tobj); 
    break; 
    
  case 10: 
    updateDistFromCenter(tobj);
    checkCenter(tobj); 
    break; 

  case sineID:
    updateEnvLink(tobj, Sine, linkDist);
    break;

  case squareID:
    updateEnvLink(tobj, Square, linkDist);
    break;

  case triangleID:
    updateEnvLink(tobj, Triangle, linkDist);
    break;

  case sawtoothID:
    updateEnvLink(tobj, Sawtooth, linkDist);
    break;

  case timingBlock:
    setPlayDuration(tobj);
    break;

  case volumeBlock:
    setVolume(tobj); 
    break;

  case sandReFeedBlock:
    checkSandReFeed(tobj); 
    break;
  }
  if (verbose) println("set obj "+tobj.getSymbolID()+" ("+tobj.getSessionID()+") "+tobj.getScreenX(width)+" "+tobj.getScreenY(height)+" "+tobj.getAngle()
    +" "+tobj.getMotionSpeed()+" "+tobj.getRotationSpeed()+" "+tobj.getMotionAccel()+" "+tobj.getRotationAccel());
}

// called when an object is removed from the scene
void removeTuioObject(TuioObject tobj) 
{
  float envHalo=(haloSize*map(tobj.getAngle(), radians(0), radians(360), .5, 2));
  float linkDist=.5*obj_size*(envHalo+haloSize);

  switch(tobj.getSymbolID())
  {
  default:
    //try
    //{
    //  if (state==play && baseBlockMap.get(tobj.getSymbolID()).isCenterInRange()) //kills play sequence if an object is removed
    //  {
    //    playFlag=0;
    //    ID=null;
    //    playCounter=0; 
    //    state=main;
    //    allOscStop();
    //  }
    //}
    //catch(java.lang.NullPointerException e) 
    //{
    //  playFlag=0; 
    //  ID=null; 
    //  playCounter=0; 
    //  state=main;
    //  allOscStop();
    //  println("caught nullpointer line 237 tuioFunctions");
    //}
    baseBlockMap.remove(tobj.getSessionID());
    break;

  case sineID:
    removeEnvLink(tobj, Sine, linkDist);
    break;

  case squareID:
    removeEnvLink(tobj, Square, linkDist);
    break;

  case triangleID:
    removeEnvLink(tobj, Triangle, linkDist);
    break;

  case sawtoothID:
    removeEnvLink(tobj, Sawtooth, linkDist);
    break;

  case timingBlock:
    playDuration=defaultPlayDuration;
    break;

  case volumeBlock:
    setVolume=1;
    break;
  }
  if (verbose) println("del obj "+tobj.getSymbolID()+" ("+tobj.getSessionID()+")");
  //redraw();
}


// --------------------------------------------------------------
// called when a cursor is added to the scene
void addTuioCursor(TuioCursor tcur) 
{
  getCursorCoords(tcur); 
  cursorTouch(centerX, centerY, centerRad*2); 
  if (verbose) println("add cur "+tcur.getCursorID()+" ("+tcur.getSessionID()+ ") " +tcur.getX()+" "+tcur.getY());
  //redraw();
  //cursorTouched=true;
}

// called when a cursor is moved
void updateTuioCursor (TuioCursor tcur) 
{
  getCursorCoords(tcur); 
  cursorTouch(centerX, centerY, centerRad*2);
  if (verbose) println("set cur "+tcur.getCursorID()+" ("+tcur.getSessionID()+ ") " +tcur.getX()+" "+tcur.getY()
    +" "+tcur.getMotionSpeed()+" "+tcur.getMotionAccel());
  //redraw();
  //cursorTouched=true;
}

// called when a cursor is removed from the scene
void removeTuioCursor(TuioCursor tcur) 
{
  cursorCoordsX=0;
  cursorCoordsY=0;
  if (verbose) println("del cur "+tcur.getCursorID()+" ("+tcur.getSessionID()+")");
  //redraw()
  cursorTouched=false;
}

// --------------------------------------------------------------
// called when a blob is added to the scene
void addTuioBlob(TuioBlob tblb) 
{
  if (verbose) println("add blb "+tblb.getBlobID()+" ("+tblb.getSessionID()+") "+tblb.getX()+" "+tblb.getY()+" "+tblb.getAngle()+" "+tblb.getWidth()+" "+tblb.getHeight()+" "+tblb.getArea());
  //redraw();
}

// called when a blob is moved
void updateTuioBlob (TuioBlob tblb) 
{
  if (verbose) println("set blb "+tblb.getBlobID()+" ("+tblb.getSessionID()+") "+tblb.getX()+" "+tblb.getY()+" "+tblb.getAngle()+" "+tblb.getWidth()+" "+tblb.getHeight()+" "+tblb.getArea()
    +" "+tblb.getMotionSpeed()+" "+tblb.getRotationSpeed()+" "+tblb.getMotionAccel()+" "+tblb.getRotationAccel());
  //redraw()
}

// called when a blob is removed from the scene
void removeTuioBlob(TuioBlob tblb) 
{
  if (verbose) println("del blb "+tblb.getBlobID()+" ("+tblb.getSessionID()+")");
  //redraw()
}

// --------------------------------------------------------------
// called at the end of each TUIO frame
void refresh(TuioTime frameTime) 
{
  if (verbose) println("frame #"+frameTime.getFrameID()+" ("+frameTime.getTotalMilliseconds()+")");
  if (callback) redraw();
}
