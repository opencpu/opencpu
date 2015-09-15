httpuv_fork <- local({
  this <- environment();
  server <- NULL;
  port <- NULL;
  uvurl <- NULL;

  #note that this will mask base::stop()
  stop <- function() {
    tools::pskill(server$pid, SIGTERM)
    mccollect(wait = FALSE);
    server <<- NULL;
    port <<- NULL;
    message("httpuv stopped.")
    invisible();
  }

  start <- function(){
    if(!is.null(server)) {
      message("httpuv already running.");
      return(invisible())
    }

    # TODO: Think about a more systematic way to do this.
    myport <- round(runif(1, 1024, 9999))
    myfork <- parallel::mcparallel({
      httpuv::runServer("0.0.0.0", myport, list(call = rookhandler))
    }, silent = TRUE);

    # we test if the server is running
    # 0.5s should be enough to start the server
    output <- mccollect(myfork, timeout = 0.5, wait = FALSE)[[1]];
    if(inherits(output, "try-error")){
      message(attr(output, "condition")$message);
      tools::pskill(myfork$pid, SIGTERM)
      mccollect(wait = FALSE);
    } else {
      port <<- myport;
      server <<- myfork;

      #try to get url
      mainurl <- Sys.getenv("RSTUDIO_HTTP_REFERER");
      if(!nchar(mainurl)){
        uvurl <<- paste("http://localhost:", port, "/", sep="");
      } else {
        uvurl <<- gsub(":[0-9]{3,5}", paste(":", port, sep = ""), mainurl);
      }
    }
    invisible();
  }

  url <- function(){
    return(uvurl)
  }

  browse <- function(){
    if(is.null(server)){
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
