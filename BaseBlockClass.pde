//BaseBlock Class home

public class BaseBlock implements Comparable<BaseBlock>
{

  TuioObject obj;
  float dist;
  int linkedEnv; 
  boolean centerInRange;
  boolean envInRange;
  float basePitch; 
  float pitch;
  boolean resonant; 
  boolean playing; 

  public BaseBlock(TuioObject givenObj, float givenDist)
  {
    obj=givenObj; 
    dist=givenDist;
    linkedEnv=Default;
    centerInRange=false;
    envInRange=false;
    resonant=false;
    playing=false;
  }

  public TuioObject getObj()
  {
    return obj;
  }

  public float getDist()
  {
    return dist;
  }

  public void setDist(float newDist)
  {
    dist=newDist;
  }

  public int getLinkedEnv()
  {
    return linkedEnv;
  }

  public void setLinkedEnv(int newEnv)
  {
    linkedEnv=newEnv;
  }

  public boolean isCenterInRange()
  {
    return centerInRange;
  }

  public void setCenterInRange(boolean _centerInRange)
  {
    centerInRange=_centerInRange;
  }

  public boolean isEnvInRange()
  {
    return envInRange;
  }

  public void setEnvInRange(boolean _envInRange)
  {
    envInRange=_envInRange;
  }

  public float getBasePitch()
  {
    return basePitch;
  }

  public void setBasePitch(float _basePitch)
  {
    basePitch=_basePitch;
    pitch=_basePitch;
  }

  public float getPitch()
  {
    return pitch;
  }

  public void setPitch(float _pitch)
  {
    pitch=_pitch;
  }

  public boolean isResonant()
  {
    return resonant;
  }

  public void setResonant(boolean _resonant)
  {
    resonant=_resonant;
  }

  public boolean isPlaying()
  {
    return playing;
  }

  public void setPlaying(boolean _playing)
  {
    playing=_playing;
  }

  public int compareTo(BaseBlock o)
  {
    if (this.dist < o.dist)
      return -1;
    else if (this.dist > o.dist)
      return 1;
    else return 0;
  }
}
