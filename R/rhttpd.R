# Host via R's built-in httpd.
# This only works well in rstudio-server (which runs it's own httpd).
# In base R rhttpd it can freezes the UI.
rhttpd_init <- function(root = "/ocpu"){
  fullpath <- paste0("/custom", paste0("/", gsub("/", "", root)))
  port <- tools::startDynamicHelp(NA)
  assign(substring(root, 2), rhttpd_handler(fullpath), from("tools", ".httpd.handlers.env"))
  host <- Sys.getenv("RSTUDIO_HTTP_REFERER", paste0("http://localhost:", port))
  paste0(sub("/$", "", host), fullpath)
}

rhttpd_handler <- function(rootpath){
  function(reqpath, reqquery, reqbody, reqheaders){

    #get headers
    contenttype <- grep("Content-Type:", strsplit(rawToChar(reqheaders), "\n")[[1]], ignore.case=TRUE, value=TRUE);
    accept <- grep("Accept:", strsplit(rawToChar(reqheaders), "\n")[[1]], ignore.case=TRUE, value=TRUE);
    accept <- sub("^accept: ?", "", accept, ignore.case=TRUE)

    #process POST request body
    MYRAW <- if(length(reqbody)){
      list(
        body = reqbody,
        ctype = contenttype
      )
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
      PATH_INFO = gsub(rootpath, "", reqpath),
      MOUNT = rootpath,
      FULLMOUNT = paste0(sub("/$", "", Sys.getenv("RSTUDIO_HTTP_REFERER")), rootpath),
      GET = reqquery,
      RAW = MYRAW,
      CTYPE = contenttype,
      ACCEPT = accept
    );

    #call method
    response <- serve(REQDATA, call_psock);

    #build DynamicHelp output
    contenttype <- response$headers[["Content-Type"]];
    response$headers["Content-Type"] <- NULL;

    #start rhttpd only in rstudio server
    if(nchar(Sys.getenv("RSTUDIO_HTTP_REFERER"))){
      response$headers["X-ocpu-server"] <- "rhelp/rstudio";
    } else {
      response$headers["X-ocpu-server"] <- "rhelp/rhttpd";
    }

    # response must be file path or raw vector
    stopifnot(is.raw(response$body))

    list(
      "payload" = response$body,
      "content-type" = contenttype,
      "headers" = paste(names(response$headers), ": ", response$headers, sep=""),
      "status code" = response$status
    );
  }
}
