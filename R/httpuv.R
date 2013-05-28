#object that interfaces to the server
httpuv <- local({
  this <- environment();
	pid <- NULL;
  uvurl <- NULL;
  cl <- NULL;
  
  #note that this will mask base::stop()
	stop <- function(){
	  tools::pskill(pid); #win
	  tools::pskill(pid, tools::SIGKILL); #nix
	  pid <<- NULL;
    uvurl <<- NULL;
		message("httpuv stopped.")
	  try(parallel::stopCluster(cl), silent=TRUE);
    invisible();
	}
  
	start <- function(port){
    if(!is.null(pid)){
      message("httpuv already running: ", uvurl);
      return(invisible())
    }
    
    #start cluster
    cluster <- parallel::makePSOCKcluster(1);
    child <- cluster[[1]];
    parallel:::sendCall(child, eval, list(quote(Sys.getpid())));
    mypid <- parallel:::recvResult(child);    
    
    #start httpuv
    myport <- ifelse(missing(port), round(runif(1, 1024, 9999)), port);
    parallel:::sendCall(child, eval, list(quote(httpuv::runServer("0.0.0.0", myport, list(call=ocpu:::rookhandler))), envir=list(myport=myport)));
    
    #should test for running server here
    
    #if ok:
    pid <<- mypid;
    cl <<- cluster;
    
    #try to get url
    mainurl <- Sys.getenv("RSTUDIO_HTTP_REFERER");
    if(!nchar(mainurl)){
      uvurl <<- paste("http://localhost:", myport, "/", sep="");
    } else {
      uvurl <<- gsub(":[0-9]{3,5}", paste(":", myport, sep=""), mainurl)
    }       
    invisible();
	}  
  
  url <- function(){
    return(uvurl)
  }
  
  browse <- function(){
    if(is.null(uvurl)){
      message("httpuv not started.")
      return(invisible());
    }
    message("[httpuv] ", uvurl);
    browseURL(uvurl);    
  }
  
	restart <- function(){
		this$stop();
		this$start();
    this$browse();
	}
  
  this;
});
