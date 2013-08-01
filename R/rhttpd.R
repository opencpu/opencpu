#We can use this when Rook is not available
#Some notes: 
# - currently multipart POST is not supported
# - there is a bug in rhttpd when doing POST/PUT with body content-length:0
rhttpdhandler <- function(reqpath, reqquery, reqbody, reqheaders){
  
  #process POST request body
  if(!is.null(reqbody)){
    contenttype <- grep("Content-Type:", strsplit(rawToChar(reqheaders), "\n")[[1]], ignore.case=TRUE, value=TRUE);
    MYRAW <- list(
      body = reqbody,
      ctype = contenttype
    );
  } else {
    MYRAW <- NULL;
  }
  
  #fix for missing method in old versions of R
  METHOD <- grep("Request-Method:", strsplit(rawToChar(reqheaders), "\n")[[1]], ignore.case=TRUE, value=TRUE);
  METHOD <- sub("Request-Method: ?", "", METHOD, ignore.case=TRUE);
  if(!length(METHOD)){
    METHOD <- ifelse(is.null(reqbody), "GET", "POST");
  }
  
  #collect data from Rook
  REQDATA <- list(
    METHOD = METHOD,
    PATH_INFO = gsub("/custom/ocpu", "", reqpath),
    MOUNT = "/custom/ocpu",
    GET = reqquery,
    RAW = MYRAW
  );  
  
  #call method
  response <- serve(REQDATA);

  #build DynamicHelp output
  contenttype <- response$headers[["Content-Type"]];
  response$headers["Content-Type"] <- NULL;
  
  #start rhttpd only in rstudio server
  if(nchar(Sys.getenv("RSTUDIO_HTTP_REFERER"))){
    response$headers["X-ocpu-server"] <- "rhelp/rstudio";        
  } else {
    response$headers["X-ocpu-server"] <- "rhelp/rhttpd";      
  }
  
  #sort headers
  #response$headers <- response$headers[order(names(response$headers))];  
  
  list(
    "payload" = readBin(response$body, "raw", file.info(response$body)$size),
    "content-type" = contenttype,
    "headers" = paste(names(response$headers), ": ", response$headers, sep=""),
    "status code" = response$status
  );
}

#' The Rhttpd based single-user OpenCPU server.
#' 
#' The Rhttpd, a.k.a "Dynamic Help Server" provides an alternative http server in case httpuv
#' is not available (e.g. due to firewall restrictions). Currently, two different implementations
#' of Rhttpd exist: a simple built-in version in R (\code{\link{startDynamicHelp}}), and
#' a reimplementation which is part of rstudio-server (not rstudio-desktop). 
#' 
#' The performance and reliability of the built-in Rhttpd varies a lot, especially on Windows.
#' When possible, it is recommended to avoid this and use the httpuv based OpenCPU server instead (see \code{\link{opencpu}}).
#' The rstudio-server implementation of Rhttpd seems a bit better.
#' Another disadvantage is that Rhttpd runs in the currrent process and will block the session during http requests.
#' 
#' When hosted using the Rhttpd, OpenCPU is API is mounted under the \url{/custom/ocpu/} url. 
#' For example: \url{http://localhost:8787/custom/ocpu/library/stats}.
#' 
#' @S3method print rhttpd
#' @usage -
#' @format Control object
#' @family opencpu
#' @export
#' @references \url{http://www.opencpu.org}
#' @examples
#' \dontrun{
#' rhttpd$init()
#' rhttpd$url()
#' rhttpd$browse('library/stats/man/glm')
#' }
rhttpd <- local({
  rhttpdurl <- "";
  init <- function(){
    if(identical(.Platform$OS.type, "windows")){
      warning("DyanmicHelp server has some serious issues on windows. Better use httpuv.")
    }
    try(startDynamicHelp(TRUE), silent=TRUE);
    assign("ocpu", rhttpdhandler, tools:::.httpd.handlers.env);
    rhttpdurl <<- Sys.getenv("RSTUDIO_HTTP_REFERER");
    if(!nchar(rhttpdurl)){
      rhttpdurl <<- paste("http://localhost:", tools:::httpdPort, "/", sep="");
    }
    rhttpdurl <<- paste(rhttpdurl, "custom/ocpu/", sep="");
    message("[rhttpd] ", rhttpdurl);    
    invisible();
  }
  url <- function(){
    return(rhttpdurl)
  }
  browse <- function(path="library/stats/man"){
    browseURL(paste0(rhttpdurl, path));
    invisible();
  }
  structure(environment(), class=c("rhttpd", "environment"));
});

print.rhttpd <- function(x, ...){
  cat("Control the rhttpd (r-help or r-studio) based OpenCPU server.\n")
  cat("Note that rhttpd runs in the currrent process and will block the session during http requests.\n")
  cat("Unless you are using rstudio-server behind a firewall, the httpuv based OpenCPU server is preferred.\n")  
  cat("Example Usage:\n")
  cat("  rhttpd$init()                           - Start rhttpd and register OpenCPU.\n")  
  cat("  rhttpd$url()                            - Return the server address of current server.\n")
  cat("  rhttpd$browse('library/stats/man/glm')  - Try to open current server a web browser.\n")    
}