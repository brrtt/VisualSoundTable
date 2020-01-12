//vstRework[Date].pde //<>// //<>//
//JBC SNRDSGN
//setup() and draw() main functions for table
//relevant variables for table

import processing.sound.*; //sound library for oscillators. considering replacement w/ minim or beads
import TUIO.*;
import java.util.*;
//import org.apache.commons.math3;

boolean verboseTable =true; //information display for table 
boolean verbose = false; // print console debug messages
boolean callback = false; // updates only after callbacks

TuioProcessing tuioClient;

public float cursor_size = 15;
public float object_size = 90;
public float table_size = 760;
public float scale_factor = 1;
public PFont font;

color background = color(135, 250, 250); 
int centerX;
int centerY;
int centerRad;
int centerD; 
float centerRange=400;

int state; 
static final int main=0;
static final int play=1;
static final int menu=2;

void setup()
{
  fullScreen(2); //full screen to secondary display. display settings need to be extend screen, not duplicate. 
  //size(1000,600); //if you dont want to fullscreen use this. arbitrary size.
  //noCursor();
  noStroke();
  fill(0);
  rectMode(CENTER); 
  ellipseMode(CENTER);
  centerX=width/2;
  centerY=height/2;
  centerRad=width/32;
  centerD=centerRad*2;

  //if (!callback) 
  //{
  //  loop();
  //  frameRate(60);
  //} else noLoop();

  font = createFont("Arial", 12);
  scale_factor = height/table_size;

  // Initialise SerialGCodeSender
  Printer = new SerialGCodeSender_c();

  // Open the serial port.
  // Change 0 to the entry in:
  //Serial.list();
  // Because the class will handle the 
  // serial port we have to pass the 
  // sketch context (this).


  // Set flag to 0
  SEND_ONCE = false;
  sandDisperse=false; 

  tuioClient  = new TuioProcessing(this);
  Printer.openPort( this, 1 );
  sw = new StopWatchTimer();
}

void draw() 
{
  background(background);
  //drawBG();
  noFill();
  if (cursorTouched)
  { 
    stroke(0);
  } else
    stroke(255);
  ellipse(centerX, centerY, centerRange*2.4, centerRange*2.4);

  strokeWeight(2);
  sandRefeeder();

  textFont(font, 12*scale_factor);
  noStroke();

  switch(state)
  {
  default: 
    tuioCursorHandle(); //all functions written in tuioCursors.pde with support from tuioLink.pde
    if (mousePressed)                
    {
      //cursorTouched=true;
      state=play;
    }
    tuioObjectDraw(); //all functions written in tuioObjects.pde with support from tuioLink.pde
    //clearCursorCoords();
    break;

  case play:
    if (setFlag==0)
    {
      sortedSequence=setSequence();
      setFlag=1;
      volume=setVolume;
    }
    //drawShockWave(); 
    drawSequence(sortedSequence);
    setTime(playFlag); 
    checkTimeSetVolume(playTime, playDuration);
    playTone(sortedSequence); 
    tuioObjectDraw();
    break;

  case menu: 
    break;
  }

  drawPlayButton(); 
  //float fps=frameRate;
  //text("frameRate: "+fps, width/16, height/16+5*height/32);

  if (verboseTable)
  {
    float FPS=frameRate;
    fill(0);
    text("frameRate: "+FPS, width/16, height/16+5*height/32);
    text("volume: "+setVolume, width/16, height/16+height/8);
    text("nullPointer: "+npCount, width/16, height/8-height/32);
    text("playTime: "+playTime, width/16, height/16+3*height/32); 
    text("Progress: " + str( Printer.getProgress()), width/16, height/16+height/16); 
    text("state: " +state, width/16, height/16-height/32); 
    text("Play Duration: " +playDuration, width/16, height/16);
  }
  stopTimer();
}

void drawPlayButton()
{
  strokeWeight(2);
  if (state==play)
  {
    stroke(0, 255, 0);
  } else
  {
    stroke(255);
  }
  fill(background);
  ellipse(centerX, centerY, centerD, centerD);
  //fill(0, 100, 0);
  fill(background);
  beginShape();
  vertex(centerX+centerRad, centerY);
  vertex(centerX-centerRad*cos(PI/3), centerY+centerRad*sin(PI/3));
  vertex(centerX-centerRad*cos(PI/3), centerY-centerRad*sin(PI/3));
  endShape(CLOSE);
  fill(0); 
  textAlign(CENTER);
  text("Touch to Play", centerX, centerY-55);
  textAlign(LEFT);
}

void drawBG()
{
  background(background);
  float l = width/255/2;

  for (int i=0; i<width/2; i++)
  {
    stroke(0, 100, 0, 255-i/l);
    line(i, 0, i, height);
    line(width-i, 0, width-i, height);
  }
}

//void drawBG2
