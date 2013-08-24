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
#' rhttpd$browse('/library/stats/man/glm')
#' }
rhttpd <- local({
  rhttpdurl <- "";
  init <- function(rootpath = "/ocpu"){
    rootpath <- paste0("/", gsub("/", "", rootpath));
    
    fullpath <- paste0("/custom", rootpath)
    if(identical(.Platform$OS.type, "windows")){
      warning("DyanmicHelp server has some serious issues on windows. Better use httpuv.")
    }
    try(startDynamicHelp(TRUE), silent=TRUE);
    assign(substring(rootpath, 2), rhttpdhandler(fullpath), from("tools", ".httpd.handlers.env"));
    rhttpdurl <<- Sys.getenv("RSTUDIO_HTTP_REFERER");
    if(!nchar(rhttpdurl)){
      rhttpdurl <<- paste("http://localhost:", from("tools", "httpdPort"), "/", sep="");
    }
    rhttpdurl <<- paste0(rhttpdurl, substring(fullpath, 2));
    message("[rhttpd] ", rhttpdurl);    
    invisible();
  }
  url <- function(){
    if(!nchar(rhttpdurl)){
      stop("Rhttpd not initiated yet. Try: rhttpd$init()")
    }
    return(rhttpdurl)
  }
  browse <- function(path="/library/"){
    path <- sub("^//", "/", paste0("/", path));    
    browseURL(paste0(url(), path));
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
  cat("  rhttpd$browse('/library/stats/man/glm')  - Try to open current server a web browser.\n")    
}