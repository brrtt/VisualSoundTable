//tuioPlay.pde //<>// //<>//
//JBC SNRDSGN
//functions for sorting and playing objects linked to playButton

public SinOsc sinOsc = new SinOsc(this);
public SawOsc sawOsc = new SawOsc(this);
public SqrOsc sqrOsc = new SqrOsc(this); 
public TriOsc triOsc = new TriOsc(this);

public float volume=1;
public float setVolume=1;   //handled by volume fiducial. sets start volume between 0 and 1. ramp drops from there
public int playCounter=0; 
public int playFlag=0;
public long playTime;
int playDuration=5; 
int defaultPlayDuration=5; 

public float pitch;
public int linkedEnv;
public Long ID; 

public int setFlag=0;
ArrayList<BaseBlock> sortedSequence; 

public ArrayList<BaseBlock> setSequence()
{
  ArrayList<BaseBlock> sequence = new ArrayList<BaseBlock>(); 
  sequence.addAll(baseBlockMap.values()); 
  Collections.sort(sequence);
  return sequence;
} 

public void drawSequence(ArrayList<BaseBlock> sequence)
{
  for (int i=0; i<sequence.size()-1; i++)
  {
    int j=i+1;
    TuioObject item1=sequence.get(i).getObj();
    TuioObject item2=sequence.get(i+1).getObj();
    stroke(255, 0, 0);
    line(item1.getScreenX(width), item1.getScreenY(height), item2.getScreenX(width), item2.getScreenY(height));
    fill(255, 0, 0); 
    text(""+j, sequence.get(i).getObj().getScreenX(width)+75, sequence.get(i).getObj().getScreenY(height)-100);
  }
  fill( 255, 0, 0);
  if (sequence.size()>0)
  {
    text(""+sequence.size(), sequence.get(sequence.size()-1).getObj().getScreenX(width)+75, sequence.get(sequence.size()-1).getObj().getScreenY(height)-100);
  }
}

public void drawOrder(ArrayList<BaseBlock> sequence)
{
  for (int i=0; i<sequence.size()-1; i++)
  {
    int j=i+1;
    fill(0); 
    text(""+j, sequence.get(i).getObj().getScreenX(width)+75, sequence.get(i).getObj().getScreenY(height)-100);
  }
  fill(0);
  if (sequence.size()>0)
  {
    text(""+sequence.size(), sequence.get(sequence.size()-1).getObj().getScreenX(width)+75, sequence.get(sequence.size()-1).getObj().getScreenY(height)-100);
  }
}

public void setTime(int flag)
{
  if (flag==0)
  {
    //println("setTime cleared");
    playTime=TuioTime.getSessionTime().getSeconds();
    playFlag=1;
  }
}

public void checkTimeSetVolume(float playTime, float playDuration)
{ 
  //println(ID);
  if (TuioTime.getSessionTime().getSeconds()>=playTime+1.3)
  {
    if (volume >= .1)
    {
      volume=volume-.02;
      //println(volume);
    }
  }

  if (TuioTime.getSessionTime().getSeconds()>=playTime+2 && ID==9)
  {
    if (volume >= .05)
    {
      volume=volume-.09;
      //println(volume);
    }
  }

  if (TuioTime.getSessionTime().getSeconds()>=playTime+playDuration)
  {
    //println("checkTime cleared");
    try
    {
      baseBlockMap.get(ID).setPlaying(false); //nullpointer
    }
    catch(java.lang.NullPointerException e)
    {
      println("caught nullpointer line 61 tuioPlay");
    }
    volume=setVolume;
    //println(volume);
    playCounter++;
    playFlag=0;
  }
}

public void playTone(ArrayList<BaseBlock> sequence)
{
  if (playCounter<sequence.size())
  {
    ID=sequence.get(playCounter).getObj().getSessionID();
    try
    {
      baseBlockMap.get(ID).setPlaying(true); 
      pitch=baseBlockMap.get(ID).getPitch(); 
      linkedEnv=baseBlockMap.get(ID).getLinkedEnv();
    }
    catch(java.lang.NullPointerException e)
    {
      pitch=sequence.get(playCounter).getPitch();
      linkedEnv=sequence.get(playCounter).getLinkedEnv(); 
      println("caught nullpointer line 80 tuioPlay");
    }

    oscillatorBankPlay(pitch, linkedEnv, volume);
  } else 
  {
    try
    {
      baseBlockMap.get(ID).setPlaying(false);
    }
    catch(java.lang.NullPointerException e)
    {
      println("caught nullpointer line 90 tuioPlay");
    }
    endPlaySequence();
  }
}


public void oscillatorBankPlay(float pitch, int linkedEnv, float on)
{
  switch(linkedEnv)
  {
  default:
    sinOsc.play(pitch, on);
    sawOsc.stop();
    sqrOsc.stop();
    triOsc.stop();
    break;

  case 1:
    sinOsc.play(pitch, on);
    sawOsc.stop();
    sqrOsc.stop();
    triOsc.stop();
    break;

  case 2:
    sqrOsc.play(pitch, on);
    sinOsc.stop(); 
    triOsc.stop(); 
    sawOsc.stop(); 
    break;

  case 3:
    triOsc.play(pitch, on);
    sinOsc.stop();
    sqrOsc.stop(); 
    sawOsc.stop(); 
    break;

  case 4:
    sawOsc.play(pitch, on);
    sinOsc.stop();
    sqrOsc.stop();
    triOsc.stop();
    break;
  }
}

void allOscStop()
{
  sinOsc.stop();
  sawOsc.stop();
  sqrOsc.stop();
  triOsc.stop();
}

void endPlaySequence()
{
  playCounter=0; 
  playFlag=0; 
  state=main; 
  setFlag=0;
  allOscStop();
}

void setVolume(TuioObject tobj)
{
  setVolume=map(tobj.getAngle(),0,2*PI,.5,1);
}
