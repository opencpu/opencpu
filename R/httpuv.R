#' The httpuv based OpenCPU server.
#' 
#' This object controls the httpuv based OpenCPU server. 
#' It has methods: start, stop, restart, browse and url.
#' 
#' @import parallel tools utils stats
#' @importFrom brew brew
#' @importFrom evaluate evaluate
#' @importFrom knitr knit pandoc
#' @importFrom devtools install_github
#' @importFrom RJSONIO toJSON fromJSON isValidJSON
#' @importFrom httr GET stop_for_status add_headers
#' @export
#' @S3method print httpuv
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
    parallel:::sendCall(child, eval, list(quote(httpuv::runServer("0.0.0.0", myport, list(call=opencpu:::rookhandler))), envir=list(myport=myport)));
    
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
    message("[httpuv] ", uvurl);    
    invisible();
	}  
  
  url <- function(){
    return(uvurl)
  }
  
  browse <- function(path="library/stats/man"){
    if(is.null(uvurl)){
      message("httpuv not started.")
      return(invisible());
    }
    browseURL(paste0(uvurl, path));    
  }
  
	restart <- function(){
		this$stop();
		this$start();
    this$browse();
	}
  
  structure(this, class=c("httpuv", "environment"));
});

print.httpuv <- function(x, ...){
  cat("Control the httpuv based single-user OpenCPU server.\n")
  cat("Note that httpuv runs in a parallel process and does not interact with the current session.\n")
  cat("Example Usage:\n")
  cat("  httpuv$start()                          - Start server.\n")  
  cat("  httpuv$start(12345)                     - Start server on port 12345.\n")
  cat("  httpuv$stop()                           - Stop current server.\n")  
  cat("  httpuv$restart()                        - Restart current server.\n")    
  cat("  httpuv$url()                            - Return the server address of current server.\n")
  cat("  httpuv$browse('library/stats/man/glm')  - Try to open current server a web browser.\n")  
}
