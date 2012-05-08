public class Timer {
  
  long startTime;
  long stopTime;
  
  public Timer() {
    this.reset();
  }
  
  public void start() {
    startTime = System.currentTimeMillis();
  }
  
  public void stop() {
    // Can be stopped only once
    if(stopTime < 0) {
      stopTime = System.currentTimeMillis();
    }
  }
  
  /**
   * Notice, this is RESET, not restart
   */
  public void reset() {
    startTime = -1;
    stopTime = -1;
  }
  
  public long getTimeMillis() {
    if(startTime < 0) {
      return 0;
    }
    
    long stop = stopTime;
    if(stop < 0) {
      stop = System.currentTimeMillis();
    }
    
    return stop - startTime;
  }
  
  public String formattedTime() {
    long time = this.getTimeMillis();
    
    int tsec, sec, min;
    String sTsec, sSec, sMin;
    
    long TENTH_SECONDS = 100;
    long SECONDS = 1000;
    long MINUTES = 60 * 1000;
    
    min = floor(time / MINUTES);
    time = time % MINUTES;
    sec = floor(time / SECONDS);
    time = time % SECONDS;
    tsec = floor(time / TENTH_SECONDS);
    
    sMin = min < 10 ? "0" + min : "" + min;
    sSec = sec < 10 ? "0" + sec : "" + sec;
    sTsec = "" + tsec;
    
    return sMin + ":" + sSec + "." + sTsec;
  }
}
