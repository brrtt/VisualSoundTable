// An example of how to use the SerialGCodeSender_c class.
// The class handles all Serial port transactions, reading
// from an ASCII GCode file, and handles resend requests.
//
// This has been developed against Marlin 1.1.0-RC4 - 24
// 3D printer firmware available here:
// https://github.com/MarlinFirmware/Marlin
// which is installed on an arduino mega 2560 ramps1.4 system
// running a serial interface at 115200 baud.
//
// Other firmwwares will probably require some modification.


// We need the Serial library.
import processing.serial.*;

// Instance of SerialGCodeSender_c
SerialGCodeSender_c Printer;

// A flag so that we only send the GCode
// once.
boolean SEND_ONCE;

int reFeedPos=1; 
boolean sandDisperse; 

void sandRefeeder()
{ 
  if (reFeedPos==1)
  {
    if (timeElapsed)
    {
      fill(0);
      textAlign(CENTER);
      text("sand refeed ready!", 120, 797);
      textAlign(LEFT);
      stroke(0, 255, 0);
    } else { 
      fill(0);
      time(120, 797);
      stroke(255, 0, 0);
    }
    noFill();

    ellipse(120, 797, obj_size*haloSize, obj_size*haloSize);
  } else 
  {
    if (timeElapsed)
    {
      fill(0);
      textAlign(CENTER);
      text("sand refeed ready!", 1160, 797);
      textAlign(LEFT);
      stroke(0, 255, 0);
    } else { 
      fill(0);
      time(1160, 797);
      stroke(255, 0, 0);
    }
    noFill(); 
    ellipse(1160, 797, obj_size*haloSize, obj_size*haloSize);
  }
}

void checkSandReFeed(TuioObject tobj)
{
  if (reFeedPos==1)
  {
    if (dist(tobj.getScreenX(width), tobj.getScreenY(height), 120, 797)<=obj_size*haloSize && timeElapsed)
    {
      sw.start();
      sandDisperse=true;
      timeElapsed=false;
      disperseSand(sandDisperse); 
      reFeedPos=2;
    } else 
    {
      sandDisperse=false;
    }
  } else if (reFeedPos==2)
  {
    if (dist(tobj.getScreenX(width), tobj.getScreenY(height), 1160, 796)<=obj_size*haloSize && timeElapsed)
    {
      sw.start();
      sandDisperse=true;
      timeElapsed=false;
      disperseSand(sandDisperse); 
      reFeedPos=1;
    } else 
    {
      sandDisperse=false;
    }
  }
}

void disperseSand(boolean sandDisperse)
{
  sw.start();
  if (sandDisperse)
  {
    if ( SEND_ONCE == false ) {
      // Load in a gcode file.
      Printer.loadGCode("test4processing (2).gcode");
      SEND_ONCE = true;

      thread("initiatePrint");
    }
  }
}
void keyPressed() {
  if ( key == 'p' || key == 'P' ) {
    if ( SEND_ONCE == false ) {
      Printer.openPort( this, 1 );


      // Load in a gcode file.
      Printer.loadGCode("test4processing (1).gcode");
      SEND_ONCE = true;

      thread("initiatePrint");
    }
  }

  if (key=='t')
  {
    sw.start();
  }
  if (key=='s')
  {
    sw.stop();
  }
}


// Pass all serial events to the SerialGCodeManger
// instance.  
void serialEvent( Serial port ) {
  Printer.serialEvent( port );
}

// To run as a thread, which means the Serial
// transmission can happen outside of the timing
// of the draw loop, allowing you to do renders
// etc. whilst transmitting.
void initiatePrint() {
  int retval;

  println("Attempting To Send GCode to Printer");

  // Ensure flags are initialised
  Printer.resetTransmit();

  // Gets stuck here until retval is
  // -1 (finished or error)
  do {
    retval = Printer.transmit();
  } while ( retval >= 0 );
}
