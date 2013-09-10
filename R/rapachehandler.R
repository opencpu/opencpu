rapachehandler <- function(){
  
  #Post has not been parsed
  if(isTRUE(getrapache("SERVER")$method %in% c("POST", "PUT") && !length(getrapache("POST")))){
    rawdata <- getrapache("receiveBin")();
    ctype <- getrapache("SERVER")[["headers_in"]][["Content-Type"]];
    MYRAW <- list(
      body = rawdata,
      ctype = ctype
    );
    NEWPOST <- NULL
    NEWFILES <- NULL;
  } else {
    #evaluate promises
    MYRAW <- NULL;
    NEWPOST <- getrapache("POST");
    NEWFILES <- getrapache("FILES");
    NEWPOST[names(NEWFILES)] <- NULL;    
  }
  
	#collect request data from rapache
  REQDATA <- list(
    METHOD = getrapache("SERVER")$method,
    MOUNT = getrapache("SERVER")$cmd_path,
    PATH_INFO = getrapache("SERVER")$path_info,
    POST = NEWPOST,
    GET = getrapache("GET"),
    FILES = NEWFILES,
    RAW = MYRAW
  );
    
	#select method to parse request in a trycatch 
  tmpnull <- tempfile();
	sink(tmpnull);
	response <- serve(REQDATA);
	sink();
  unlink(tmpnull);
	
  #set server header  
  response$headers["X-ocpu-server"] <- "rApache";      

  #set status code
  getrapache("setStatus")(response$status);

  #set headers
  headerlist <- response$headers;
  for(i in seq_along(headerlist)){
    getrapache("setHeader")(names(headerlist[i]), headerlist[[i]]);    
  }
	  
  #send buffered body
  getrapache("sendBin")(readBin(response$body,'raw',n=file.info(response$body)$size));

  #return
	return(getrapache("OK"));
}
