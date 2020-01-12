// This class handles all the Serial port transactions to
// send GCode to a 3D Printer with an Arduino Mega 2560
// fitted with Marlin firmware and a Ramps 1.4 board.  The
// Code reads from a preprepared ASCII GCode file.  It 
// shouldn't be too tricky to extend this class to accept
// real time coordinate information.  
// This code handles Resend commands by keeping a StringList
// buffer of previously read lines.  
// The code looks for 'ok' from the printer to keep flow
// control of the transmit sequence.  
class SerialGCodeSender_c {
  
  volatile int progress;
  volatile int tx_line;
  
  // Processings Serial library
  Serial       PrinterPort;    // handle for open Serial port

  // Used to load in GCode files.
  BufferedReader GCodeFile;
  
  // A short buffer so we can do resends.
  // volatile because an event handler is modifying.
  volatile StringList cmd_buffer;
  final int BUFFER_SIZE = 50;
  

  // Final string of your machines boot sequence. Don't forget the new line.
  //final String READY_STRING = "echo:  M200 D0\n";  
  final String READY_STRING = "echo:SD init fail\n";
  //final String READY_STRING = "echo:  M851 Z0.00\n";
  final int BAUD_RATE = 250000;
  
  // Flags to watch state of the class.
  // Volatile, event handlers modify the value.
  volatile boolean SERIAL_ALIVE;  // Serial port ok
  volatile boolean ACK;           // Last command acknowledged
  volatile boolean ABORT;         // User wants to stop.
  
  // Used to save filename.
  String filename;
  
  // Short constructor.
  SerialGCodeSender_c() {
    filename = null;
    SERIAL_ALIVE = false;
    resetTransmit();
  }

  // To check if the port is open.
  boolean portReady() {
    return SERIAL_ALIVE;
  }

  // To get the latest line sent.
  int getProgress() {
     return tx_line; 
  }

  // To close the serial port.
  void closePort() {
    try {
      println("closePort");
     PrinterPort.stop();
      SERIAL_ALIVE = false;
    } catch( Exception e ) {
       println("Failed to close serial port: " + e ); 
    }
  }
  
  // Opens the port.
  // Importantly, this watches for a specific string
  // to OK the connection.  
  // This should be the last string your printer sends
  // after it has boot up.  This ensures you are connected
  // to the right machine, and stops you from sending commands
  // before it is ready.  FDM printers have important startup
  // routines with hardware brought to high temperature.
  boolean openPort( visualSoundTableCode context, int which_port ) {

    // Used to watch for no response.
    long time_out;

    // Check request for port is sane.
    if ( which_port < 0 || which_port >= PrinterPort.list().length ) {
      println("hello whichport");
      println(PrinterPort.list());
      println(PrinterPort.list().length);
      println("Error: serial port selection is out of range");
      return false;
    }

    // Check if a serial port is already open
    if ( PrinterPort != null ) {
      // Close the port.
      closePort();
    } 

    println("Opening Serial Port:");
    try {
      // Try opening the port.
      SERIAL_ALIVE = false;
      PrinterPort = new Serial( context, PrinterPort.list()[ which_port ], BAUD_RATE );
      PrinterPort.bufferUntil('\n');

      // Catch a timeout.
      // serialEvent is working in the background
      // Sending commands before a proper boot up is bad.
      // If we don't get the string we are looking for
      // after a few seconds, its probably the wrong
      // machine or machine problem.
      time_out = millis();
      while ( !SERIAL_ALIVE ) {
        if ( millis() - time_out > 5000 ) {
          println("Failed to open serial port, time out");
          closePort();
          break;
        }
      }

      println("Serial port open: " + SERIAL_ALIVE );
    } 
    catch( Exception e ) {
      PrinterPort = null;
      println("Failed to open serial port");
    } 

    return SERIAL_ALIVE;
  }



  // Will return a list of avilable
  // Serial ports.
  String[] getPortList() {
    return PrinterPort.list();
  }
  
  // Expects to recieve an ASCII GCode file
  // where each GCode instruction has a \n
  // at the end of the line.
  boolean loadGCode( String file_in ) {
  println("in the loadGCode");
    // Check if a file is already open.
    if( GCodeFile != null ) {
       closeGCode(); 
    }
    
    // Try to open the file.
    // Handle errors.
    try {
      GCodeFile = createReader( file_in );
      return true;
    } catch( Exception e ) {
       println("Failed to open GCode file: " + file_in );
       return false;
    }
  }
  
  // Safely close the file.
  void closeGCode() {
    println("gcode close");
    if( GCodeFile != null ) {
       try {
          GCodeFile.close(); 
       } catch( Exception e ) {
          println("Error closing GCode file: " + e );
       }
    }
  }
  
  // Used to terminate the sending process.
  void abort() {
     println("Abort printing");
     ABORT = true; 
  }
  
  // Used to  flags
  void resetTransmit() {
     tx_line = 0;
     cmd_buffer = new StringList();
     ACK = true;
     ABORT = false;
     
     if( filename != null ) {
         if( GCodeFile != null ) {
           closeGCode();
         }
         loadGCode( filename );
     }
  }
  
  
  // Flow control with Marlin is not great.
  // OK is given on receipt of commands, but 
  // there is no guarantee OK will be received.
  int transmit( ) {
    
    // Exit procedure
    if( ABORT ) {
      //closePort();
      println("exit");
      return -1;
    }
    
    // Check it is ok to transmit
    if( !SERIAL_ALIVE || PrinterPort == null || GCodeFile == null ) {
        return -1;
    }
    
    
    // Wait for ACK on previous send.
    // If we time out, we abort this send
    // so the next call will attempt to 
    // send the same line.
    long WAIT_TIME;
    WAIT_TIME = millis();
    while( !ACK ) {
         
      if( millis() - WAIT_TIME > 1000 ) {
         println("ACK Timeout!");
         
         // Break out of this call.
         return tx_line;
      }
    }
    
      try {
        String cmd = GCodeFile.readLine();
        if( cmd == null ) {
           // end of file, exit
           println("EOF");   //BARRETTS WORK
           println(cmd_buffer.size());
           closeGCode();
           //closePort(); 
           resetTransmit();
           println(tx_line);
           SEND_ONCE=false; 
           return -1; 
        }
        
        // add a newline, stripped out during
        // file read.
        cmd += "\n";
        
        // Add command to the buffer
        cmd_buffer.append( cmd );
       
        // Monitor the buffer size, remove first entry
        // FIFO
        if( cmd_buffer.size() > BUFFER_SIZE ) cmd_buffer.remove(0);
        
        // Try a transmit
        try {
         ACK = false;
         //println("Sending: " + cmd );
         PrinterPort.write( cmd );
         tx_line++;
        } catch( Exception e ) {
          println("Error sending: " + e );
        }
      } catch( Exception e ) {
        println("Failed to read from GCode file");
      }
    
    
    // Return current progress, line number
    return tx_line;
  }
  
  // Send a specific line.
  // Used to do resend requests.
  // Note, this function looks at the latest
  // entry in the command buffer, and then counts
  // backward from that entry.  If the line number
  // request goes back further than the buffer, an
  // error occurs.
  void transmitLine( int line_num ) {
    
     // Watch for abort action
     if( ABORT ) {
       closePort();
       return;
     }
    
     // Get the latest line number in the buffer.
     int latest;
     String buf;
     buf = cmd_buffer.get( cmd_buffer.size()-1); //xcould be it
     
     // get index of first space in string.
     // N12 G1 X10.00 Y10.00 F2000
     int space = buf.indexOf(" ");
     
     // We know N is the 0th character, drop that.
     // Convert to int.
     latest = (int)parseFloat(buf.substring(1, space ));
     
     // Work out difference between latest line 
     // number and the requested line number.
     int diff = latest - line_num;
     
     // Use difference to get StringList index
     int index = (cmd_buffer.size()-1) - diff;
     
     // If the index is less than 0, the request
     // can not be fulfilled because the buffer is
     // too small.
     if( index < 0 ) {
        println("ERROR: Buffer expired");
        println("Looking back " + index );
        println("Buffer too small?");
        abort();
     }
     
     // Otherwise get the command.
     String cmd = cmd_buffer.get( index );
     
     print("Resending: " + cmd );
     
     // Try sending it.
     try {
         PrinterPort.write( cmd );
      } catch( Exception e ) {
         println("Failed to resend");
      }
  }
  
  
  // This is the event handler for activity on the 
  // Serial port.  We have set the serial port to 
  // create events once a \n is received.  SO we 
  // should get complete string reponses.
  void serialEvent( Serial port ) {
    String inString;
    
    if( ABORT ) return;
    
    // Try to read from serial buffer
    try {
      inString = port.readString();
    } catch( Exception e ) {
      println("Serial Event error: " + e );
      return;
    }
    
    print(inString);

    // If the serial port is just opened, this 
    // section checks if it is the right machine 
    // and if the machine is ready.  
    // See: controlEvent()
    if ( !SERIAL_ALIVE ) {
      if ( inString.equals( READY_STRING ) ) {
        
        // Set flag if successful.
        SERIAL_ALIVE = true;
        return;
      }
    }
    
    // If we recieve ok, it means the machine
    // successfully got the last command.
    // Set the flag to allow next transmit
    if( inString.equals("ok\n") ) {
      ACK = true;
      return;
    }
    
    // A resend needs to have the number 
    // isolated from the string.
    // Resend: 2
    // We split by blankspace
    String[] subs;
    subs = split( inString, ' ');
    
    if( subs[0].equals("Resend:") ) {
       //println("Second sub string: " + subs[1] );
       
       // For some reason parseInt does not work.
       int resend = (int)parseFloat( subs[1] );
       
       // Try a resend of the line.
       transmitLine( resend );  
    }
  }
}
