rapachehandler <- function(){
  
  #Post has not been parsed
  if(isTRUE(SERVER$method %in% c("POST", "PUT") && !length(POST))){
    rawdata <- receiveBin(1e8);
    ctype <- SERVER[["headers_in"]][["Content-Type"]];
    MYRAW <- list(
      body = rawdata,
      ctype = ctype
    );
    NEWPOST <- NULL
    NEWFILES <- NULL;
  } else {
    #evaluate promises
    MYRAW <- NULL;
    NEWPOST <- get("POST", "rapache");
    NEWFILES <- get("FILES", "rapache");
    NEWPOST[names(NEWFILES)] <- NULL;    
  }
  
	#collect request data from rapache
  REQDATA <- list(
    METHOD = SERVER$method,
    MOUNT = SERVER$cmd_path,
    PATH_INFO = SERVER$path_info,
    POST = NEWPOST,
    GET = get("GET", "rapache"),
    FILES = NEWFILES,
    RAW = MYRAW
  );
    
	#select method to parse request in a trycatch 
	sink(tempfile())
	response <- serve(REQDATA);
	sink();
	
	#set status code
	setStatus(response$status);
	  
  #set headers
  headerlist <- response$headers;
  for(i in seq_along(headerlist)){
    setHeader(names(headerlist[i]), headerlist[[i]]);    
  }
	  
  #send buffered body
	sendBin(readBin(response$body,'raw',n=file.info(response$body)$size));

  #return
	return(OK);
}