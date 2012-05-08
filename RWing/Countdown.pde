public class Countdown {
 
  long seconds = 3;
  boolean started = false;
  boolean done = false;
  boolean finished = false;
  boolean finishedOnce = false;
  long showGoSeconds = 3;
  long end;
  
  public Countdown() { }
  
  public Countdown(long seconds) {
    this.seconds = seconds;
  }
  
  public void start() {
    this.end = System.currentTimeMillis() + (this.seconds * 1000);
    this.started = true;
  }
  
  /**
   * Returns seconds to go (number), or "Go!" for 3 seconds after finished countdown
   */
  public String getCountdown() {
    if(started == false) {
      return "Ready to start?";
    }
    
    long time = this.end - System.currentTimeMillis();
    
    if(time > 0) {
      return "" + (ceil(time / 1000l) + 1);
    } else {
      
      if(finished == false) {
        finished = true;
        finishedOnce = true;
      }
    
      if (time < (showGoSeconds * -1000)) {
        this.done = true;
      }
      
      return "Go!"; 
    }
  }
  
  public boolean isStarted() {
    return this.started;
  }
  
  public boolean isFinished() {
    return this.finished;
  }
  
  /**
   * This is true only once. Use this to start Play Timer etc.
   */
  public boolean isFinishedOnce() {
    if(finishedOnce) {
      finishedOnce = false;
      return true;  
    }
    return false;
  }
  
  public boolean isDone() {
    return this.done;
  }
}
