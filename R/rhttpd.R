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
#' For example: \code{http://localhost:8787/custom/ocpu/library/stats}.
#'
#' @format Control object
#' @family opencpu
#' @export
#' @references \url{http://www.opencpu.org}
#' @examples
#' \dontrun{
#' rhttpd$init()
#' rhttpd$url()
#' rhttpd$view('/test')
#' rhttpd$browse('test')
#' }
rhttpd <- local({
  rhttpdurl <- "";
  init <- function(rootpath = "/ocpu"){
    rootpath <- paste0("/", gsub("/", "", rootpath));

    fullpath <- paste0("/custom", rootpath)
    if(identical(.Platform$OS.type, "windows")){
      warning("DyanmicHelp server has some serious issues on windows. Better use httpuv. See ?opencpu for more details.", call.=FALSE)
    }

    # Start rhttpd and get port
    port <- if(R.version[["svn rev"]] < 67550) {
      try(startDynamicHelp(TRUE), silent=TRUE);
      getFromNamespace("httpdPort", "tools");
    } else {
      startDynamicHelp(NA);
    }

    assign(substring(rootpath, 2), rhttpdhandler(fullpath), from("tools", ".httpd.handlers.env"));
    rhttpdurl <<- Sys.getenv("RSTUDIO_HTTP_REFERER");
    if(!nchar(rhttpdurl)){
      rhttpdurl <<- paste("http://localhost:", port, "/", sep="");
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

  browse <- function(path="/test/", viewer=FALSE){
    #build url path
    path <- sub("^//", "/", paste0("/", path));
    viewurl <- paste0(url(), path);

    #use viewer or not
    IDEviewer <- getOption("viewer")
    if (isTRUE(viewer) && !is.null(IDEviewer)) {
      IDEviewer(viewurl);
    } else {
      utils::browseURL(viewurl);
    }
  }

  view <- function(path="/test/"){
    browse(path=path, viewer=TRUE)
  }

  structure(environment(), class=c("rhttpd", "environment"));
});

#' @export
print.rhttpd <- function(x, ...){
  cat("Control the rhttpd (r-help or r-studio) based OpenCPU server.\n")
  cat("Note that rhttpd runs in the currrent process and will block the session during http requests.\n")
  cat("The httpuv based OpenCPU server (see ?opencpu) is usually preferred.\n")
  cat("Example Usage:\n")
  cat("  rhttpd$init()                           - Start rhttpd and register OpenCPU.\n")
  cat("  rhttpd$url()                            - Return the server address of current server.\n")
  cat("  rhttpd$view('/test')                    - Open active server in viewer (if available) or browser.\n")
  cat("  rhttpd$browse('/test')                  - Open active server in a web browser.\n")
}
