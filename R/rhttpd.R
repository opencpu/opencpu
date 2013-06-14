#We can use this when Rook is not available
#Some notes: 
# - currently multipart POST is not supported
# - there is a bug in rhttpd when doing POST/PUT with body content-length:0
rhttpdhandler <- function(reqpath, reqquery, reqbody, reqheaders){
  
  #process POST request body
  if(!is.null(reqbody)){
    contenttype <- grep("Content-Type:", strsplit(rawToChar(reqheaders), "\n")[[1]], ignore.case=TRUE, value=TRUE);
    RAWPOST <- parse_post(reqbody, contenttype);
  } else {
    RAWPOST <- list();  
  }
  
  #extract files
  fileindex <- vapply(RAWPOST, is.list, logical(1));
  FILES <- RAWPOST[fileindex];
  POST <- RAWPOST[!fileindex];    
  
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