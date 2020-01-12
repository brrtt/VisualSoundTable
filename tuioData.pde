//tuioLink.pde
//JBC SNRDSGN
//functions, and their relevant classes and variables, for linking TuioObjects

//////////////////////////////////////////////////VARIABLES & CLASS DECLARATIONSb

public int cursorCoordsX;
public int cursorCoordsY;
public int cursorT;

//data structure 

public HashMap<Long, BaseBlock> baseBlockMap = new HashMap<Long, BaseBlock>();

//////////////////////////////////////////////////FUNCTIONS

void addToMap(TuioObject tobj)
{
  baseBlockMap.put(tobj.getSessionID(), new BaseBlock(tobj, dist(tobj.getScreenX(width), tobj.getScreenY(height), centerX, centerY)));
}

void updateDistFromCenter(TuioObject tobj)
{
  baseBlockMap.get(tobj.getSessionID()).setDist(dist(tobj.getScreenX(width), tobj.getScreenY(height), centerX, centerY));
}

void checkCenter(TuioObject tobj)
{
  if (dist(tobj.getScreenX(width), tobj.getScreenY(height), centerX, centerY)<=centerRange)
  {
    baseBlockMap.get(tobj.getSessionID()).setCenterInRange(true);
    //println("in range");
  } else 
  {
    baseBlockMap.get(tobj.getSessionID()).setCenterInRange(false);
    //println("out range");
  }
}

void setBasePitch(TuioObject tobj, float basePitch)
{
  baseBlockMap.get(tobj.getSessionID()).setBasePitch(basePitch);
}

void setPitch(TuioObject tobj)
{
  float basePitch=baseBlockMap.get(tobj.getSessionID()).getBasePitch();
  baseBlockMap.get(tobj.getSessionID()).setPitch(rotationRange*norm(tobj.getAngle(), 0, twoPi)+(basePitch-10));
}

void setPitch0(TuioObject tobj)
{
  float basePitch=baseBlockMap.get(tobj.getSessionID()).getBasePitch();
  baseBlockMap.get(tobj.getSessionID()).setPitch(rotationRange0*norm(tobj.getAngle(), 0, twoPi)+(basePitch-10));
}

void checkResonant(TuioObject tobj)
{
  float basePitch=baseBlockMap.get(tobj.getSessionID()).getBasePitch();
  if ((basePitch-1)<baseBlockMap.get(tobj.getSessionID()).getPitch() && baseBlockMap.get(tobj.getSessionID()).getPitch()<(basePitch+1))
  {
    baseBlockMap.get(tobj.getSessionID()).setResonant(true);
  } else baseBlockMap.get(tobj.getSessionID()).setResonant(false);
}

void addEnvLink(TuioObject tobj, int env, float linkDist)
{
  for (Map.Entry<Long, BaseBlock> entry : baseBlockMap.entrySet())
  {
    Long Key = entry.getKey();
    BaseBlock item = entry.getValue();    
    if (!item.isEnvInRange() && dist(tobj.getScreenX(width), tobj.getScreenY(height), item.getObj().getScreenX(width), item.getObj().getScreenY(height))<linkDist)
    {
      baseBlockMap.get(Key).setLinkedEnv(env);
      baseBlockMap.get(Key).setEnvInRange(true);
    }
  }
}

void updateEnvLink(TuioObject tobj, int env, float linkDist)
{    
  for (Map.Entry<Long, BaseBlock> entry : baseBlockMap.entrySet())
  {
    Long Key = entry.getKey();
    BaseBlock item = entry.getValue();    
    if (dist(tobj.getScreenX(width), tobj.getScreenY(height), item.getObj().getScreenX(width), item.getObj().getScreenY(height))<linkDist)
    {
      baseBlockMap.get(Key).setLinkedEnv(env);
      baseBlockMap.get(Key).setEnvInRange(true);
    } else if (item.getLinkedEnv()==env)
    {
      baseBlockMap.get(Key).setLinkedEnv(Default);
      baseBlockMap.get(Key).setEnvInRange(false);
    }
  }
}

void removeEnvLink(TuioObject tobj, int env, float linkDist)
{
  for (Map.Entry<Long, BaseBlock> entry : baseBlockMap.entrySet())
  {
    Long Key = entry.getKey();
    BaseBlock item = entry.getValue();    
    if (item.getLinkedEnv()==env && dist(tobj.getScreenX(width), tobj.getScreenY(height), item.getObj().getScreenX(width), item.getObj().getScreenY(height))<linkDist)
    {
      baseBlockMap.get(Key).setLinkedEnv(Default);
      baseBlockMap.get(Key).setEnvInRange(false);
    }
  }
}

void setPlayDuration(TuioObject tobj)
{
  float angle=tobj.getAngle(); 
  if (angle<=.5*PI)
  {
    playDuration=5;
  } else if (angle<=PI)
  {
    playDuration=10;
  } else if (angle<=1.5*PI)
  {
    playDuration=15;
  } else if (angle<=2*PI)
  {
    endPlaySequence();
    try
    {
      for (BaseBlock item : baseBlockMap.values()) //ConcurrentModificationException
      {
        if (item.isPlaying())
        {
          Long playingID=item.getObj().getSessionID();
          baseBlockMap.get(playingID).setPlaying(false);
        }
      }
    }
    catch(java.util.ConcurrentModificationException e)
    {
      println("caught concurrentModificationException line 231 tuioObjects");
    }
  }

  //println(playDuration);
}
