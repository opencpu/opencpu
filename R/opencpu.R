#' The httpuv based single-user OpenCPU server.
#' 
#' This object controls the httpuv based OpenCPU server. 
#' This is the preferred method of running OpenCPU inside an R session.
#' The server runs in a parallel process and does not interact with the current session.
#' 
#' Note that this is a single user server; i.e. for local use only.
#' Because R is single-threaded, the single-user server has no support for concurrent http requests 
#' (but httpuv does a nice job queueing them).
#' Also there are no security restrictions being enforced, as is the case for the OpenCPU cloud server.
#' 
#' The OpenCPU server will automatically be started when the OpenCPU packge is attached.
#' By default, the server starts at a random port and the API will be available under the /ocpu path. 
#' For example: \url{http://localhost:12345/ocpu/library/stats}.
#' 
#' Once apps are working on the local OpenCPU server, they can easily be published using the OpenCPU cloud server.
#' The cloud server does have support for concurrent requests, security policies and caching mechanisms to boost performance.
#'  
#' @import parallel tools utils stats
#' @importFrom brew brew
#' @importFrom evaluate evaluate
#' @importFrom knitr knit pandoc
#' @importFrom devtools install_github
#' @importFrom pander pander
#' @importFrom RJSONIO toJSON fromJSON isValidJSON
#' @importFrom httr GET stop_for_status add_headers
#' @S3method print opencpu
#' @usage -
#' @format Control object
#' @family opencpu
#' @export
#' @references \url{http://www.opencpu.org}
#' @examples
#' \dontrun{
#' opencpu$start(12345);
#' opencpu$restart()
#' opencpu$url()
#' opencpu$browse('library/stats/man/glm')
#' opencpu$stop()
#' }
opencpu <- local({
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
    message("OpenCPU stopped.")
    try(parallel::stopCluster(cl), silent=TRUE);
    invisible();
  }
  
  start <- function(port, rootpath = "/ocpu"){
    #make sure rootpath starts with a slash and no trailing slash
    rootpath <- sub("^//", "/", paste0("/", rootpath));
    rootpath <- sub("/$", "", rootpath);
    
    #check if we already have a process going
    if(!is.null(pid)){
      message("OpenCPU already running: ", uvurl);
      return(invisible())
    }
    
    #start cluster
    cluster <- parallel::makePSOCKcluster(1);
    child <- cluster[[1]];
    from("parallel", "sendCall")(child, eval, list(quote(Sys.getpid())));
    mypid <- from("parallel", "recvResult")(child);    
    
    #start httpuv
    myport <- ifelse(missing(port), round(runif(1, 1024, 9999)), port);
    from("parallel", "sendCall")(child, eval, list(quote(httpuv::runServer("0.0.0.0", myport, list(call=get("rookhandler", envir=asNamespace("opencpu"))(rootpath)))), envir=list(rootpath=rootpath, myport=myport)));
    
    #should test for running server here
    pid <<- mypid;
    cl <<- cluster;
    
    #try to get url
    mainurl <- Sys.getenv("RSTUDIO_HTTP_REFERER");
    if(!nchar(mainurl)){
      uvurl <<- paste("http://localhost:", myport, rootpath, sep="");
    } else {
      uvurl <<- paste0(gsub(":[0-9]{3,5}", paste(":", myport, sep=""), mainurl), substring(rootpath,2))
    }
    message("[httpuv] ", uvurl);    
    invisible();
  }  
  
  getchild <- function(){
    return(cl)
  }
  
  readchild <- function(){
    from("parallel", "recvResult")(getchild()[[1]]);   
  }
  
  hasdied <- function(){
    #set the timeout
    output <- try({
      setTimeLimit(elapsed=1, transient=TRUE);
      on.exit({
        #reset time limit
        setTimeLimit(cpu=Inf, elapsed=Inf, transient=FALSE);    
      })
      readchild()   
    }, silent=TRUE);    
    
    if(is(output, "try-error") && grepl("reached elapsed time limit", output)){
      return(FALSE);
    } else {
      message(output);
      this$stop();
      return(invisible(TRUE));
    }
  }
  
  url <- function(){
    return(uvurl)
  }
  
  browse <- function(path="/library/"){
    path <- sub("^//", "/", paste0("/", path));    
    if(is.null(uvurl)){
      message("OpenCPU not started.")
      return(invisible());
    }
    browseURL(paste0(uvurl, path));    
  }
  
  restart <- function(){
    this$stop();
    this$start();
  }
  
  structure(this, class=c("opencpu", "environment"));
});

print.opencpu <- function(x, ...){
  currenturl <- x$url();
  currentstatus <- if(is.null(currenturl)){
    "OFFLINE"
  } else {
    paste("ONLINE at", currenturl)
  }
  cat("Current status: OpenCPU (httpuv) is", currentstatus, "\n")
  cat("Example Usage:\n")
  cat("  opencpu$start()                          - Start server.\n")  
  cat("  opencpu$stop()                           - Stop current server.\n")  
  cat("  opencpu$start(12345)                     - Start server on port 12345.\n")
  cat("  opencpu$restart()                        - Restart current server.\n")    
  cat("  opencpu$url()                            - Return the server address of current server.\n")
  cat("  opencpu$browse('/library/stats/man/glm') - Try to open current server in a web browser.\n")  
  cat("Note that httpuv runs in a parallel process and does not interact with the current session.\n")  
}
