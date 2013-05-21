rapachehandler <- function(){
  
	#collect request data from rapache
  REQDATA <- list(
    METHOD = SERVER$method,
    URI = SERVER$uri,
    MOUNT = SERVER$cmd_path,
    PATH_INFO = SERVER$path_info,
    POST = POST,
    GET = GET,
    FILES = FILES
  );
    
	#select method to parse request in a trycatch 
	sink(tempfile())
	response <- serve(REQDATA);
	sink();
	
	#set status code
	setStatus(response$status);
	
	#set headers
	if(length(headerlist <- response$headers)){
		for(i in length(headerlist)){
			setHeader(names(headerlist[i]), headerlist[[i]]);
		}
	}
	  
  #send buffered body
	sendBin(readBin(response$body,'raw',n=file.info(response$body)$size));

  #return
	return(OK);
}