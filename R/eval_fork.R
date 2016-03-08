eval_fork <- function(..., timeout=60){
  
  #this limit must always be higher than the timeout on the fork!
  setTimeLimit(timeout+5);		
  
  #dispatch based on method
  ##NOTE!!!!! Due to a bug in mcparallel, we cannot use silent=TRUE for now.
  myfork <- parallel::mcparallel({
    eval(...)
  }, silent=FALSE);
  
  #wait max n seconds for a result.
  starttime <- Sys.time()
  myresult <- parallel::mccollect(myfork, wait = FALSE, timeout = timeout)
  enddtime <- Sys.time()
  totaltime <- as.numeric(enddtime - starttime, units="secs")
  
  #try to avoid bug/race condition where mccollect returns null without waiting full timeout.
  #see https://github.com/jeroenooms/opencpu/issues/131
  #waits for max another 2 seconds if proc looks dead
  while(is.null(myresult) && totaltime < timeout && totaltime < 2) {
    Sys.sleep(.1)
    enddtime <- Sys.time();
    totaltime <- as.numeric(enddtime - starttime, units="secs")
    myresult <- parallel::mccollect(myfork, wait = FALSE, timeout = timeout);
  }
  
  #kill fork after collect has returned
  tools::pskill(myfork$pid, tools::SIGKILL);	
  tools::pskill(-1 * myfork$pid, tools::SIGKILL);  
  
  #clean up:
  parallel::mccollect(myfork, wait=FALSE);
  
  #timeout?
  if(is.null(myresult)){
    stop("R call did not return within ", timeout, " seconds. Terminating process.", call.=FALSE);		
  }
  
  #move this to distinguish between timeout and NULL returns
  myresult <- myresult[[1]];
  
  #reset timer
  setTimeLimit();	  
  
  #forks don't throw errors themselves
  if(inherits(myresult,"try-error")){
    #stop(myresult, call.=FALSE);
    stop(attr(myresult, "condition"));
  }
  
  #send the buffered response
  return(myresult);  
}
