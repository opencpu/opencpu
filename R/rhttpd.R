#We can use this when Rook is not available
#Some notes: 
# - currently multipart POST is not supported
# - there is a bug in rhttpd when doing POST/PUT with body content-length:0
rhttpdhandler <- function(reqpath, reqquery, reqbody, reqheaders){
  
  #process POST request body
  POST <- list();  
  FILES <- list();
  if(!is.null(reqbody)){
    contenttype <- grep("Content-Type:", strsplit(rawToChar(reqheaders), "\n")[[1]], ignore.case=TRUE, value=TRUE);
    contenttype <- sub("Content-Type: ?", "", contenttype, ignore.case=TRUE);
    if(grepl("multipart", contenttype)){
      stop("multipart not supported by rhttpdhandler.")
    } else if(grepl("x-www-form-urlencoded", contenttype)){
      if(is.raw(reqbody)){
        POST <- parse_query(reqbody);
      } else {
        POST <- as.list(reqbody);
      }
    } else {
      stop("POST body with unknown conntent type: ", contenttype);
    }
  }
  
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
    POST = POST,
    GET = reqquery,
    FILES = FILES
  );  
  
  #call method
  response <- serve(REQDATA);

  #build DynamicHelp output
  contenttype <- response$headers[["Content-Type"]];
  response$headers["Content-Type"] <- NULL;
  
  list(
    "payload" = readBin(response$body, "raw", file.info(response$body)$size),
    "content-type" = contenttype,
    "headers" = paste(names(response$headers), ": ", response$headers, sep=""),
    "status code" = response$status
  );
}

rhttpd <- local({
  rhttpdurl <- "";
  init <- function(){
    try(startDynamicHelp(TRUE), silent=TRUE);
    assign("ocpu", rhttpdhandler, tools:::.httpd.handlers.env);
    rhttpdurl <<- Sys.getenv("RSTUDIO_HTTP_REFERER");
    if(!nchar(rhttpdurl)){
      rhttpdurl <<- paste("http://localhost:", tools:::httpdPort, "/", sep="");
    }
    rhttpdurl <<- paste(rhttpdurl, "custom/ocpu/", sep="");
    invisible();
  }
  url <- function(){
    return(rhttpdurl)
  }
  browse <- function(){
    message("[rhttpd] ", rhttpdurl);
    browseURL(rhttpdurl);
    invisible();
  }
  environment();
});