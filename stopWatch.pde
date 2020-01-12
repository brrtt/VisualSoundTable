StopWatchTimer sw;
int elapsed;   
boolean timeElapsed=true;
int startTime;
int waitTime=300000;

void stopTimer()
{
    if(sw.getElapsedTime()>=waitTime)
  {
    //println("sw stopped");
    sw.stop();
    timeElapsed=true;
  }
}

void time(int x, int y) {
  textAlign(CENTER);
  // textFont(words, 50);
  //
  //  text(second()+ , 350, 175);
  //
  //  text(":", 300, 175);
  //
  //  text(minute(), 250, 175);
  //
  //  text(":", 200, 175);
  //  text(hour(), 150, 175);
  text(nf(sw.minute(), 2)+":"+nf(sw.second(), 2), x, y);
  textAlign(LEFT);
}
// =================================================
// classes
class StopWatchTimer {
  int stopTime = 0,setTime = 0;
  boolean running = false; 
  void start() {
    startTime = millis(); //3 minutes
    running = true;
  }
  void stop() {
    stopTime = millis();
    running = false;
  }
  int getElapsedTime() {
    if (running) {
      elapsed = (millis()-startTime);
    }
    //println(elapsed); 
    return elapsed;
  }
  int second() {
    return (-1*(getElapsedTime()-waitTime) / 1000) % 60;
  }
  int minute() {
    return (-1*(getElapsedTime()-waitTime) / (1000*60)) % 60;
  }
  int hour() {
    return (getElapsedTime() / (1000*60*60)) % 24;
  }
}
// ====================================================
