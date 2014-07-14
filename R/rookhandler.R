#rookhandler can either be used by Rook or by httpuv
rookhandler <- function(rootpath){
  #load opencpu configuration
  loadconfigs(preload=TRUE);
  
  #handler
  function(env){
    #preprocess
    if(!grepl(paste0("^", rootpath), env[["PATH_INFO"]])){
      return(list(
        status=404, 
        headers=list("X-ocpu-server"="rook/httpuv"), 
        body=paste("Invalid URL:", env[["PATH_INFO"]], "\nTry:", rootpath, "\n")
      ));
    } else {
      env[["PATH_INFO"]] <- sub(paste0("^", rootpath), "", env[["PATH_INFO"]]);
    }
      
    #do some Rook processing
    GET <- parse_query(env[["QUERY_STRING"]]);   
    RAWPOST <- list();
    
    #parse POST request body
    if((env[["REQUEST_METHOD"]] %in% c("POST", "PUT")) && (env$CONTENT_LENGTH > 0)){
      input <- env[["rook.input"]];
      postdata <- input$read();
      MYRAW <- list(
        body = postdata,
        ctype = env[["CONTENT_TYPE"]]
      );
    } else {
      MYRAW <- NULL;
    }
    
    #reconstruct the full URL
    scheme <- env[["rook.url_scheme"]];
    hostport <- env[["HTTP_HOST"]];
    mount <- paste0(env[["SCRIPT_NAME"]], rootpath);
    fullmount <- paste0(scheme, "://", hostport, mount);
    
    #collect data from Rook
    REQDATA <- list(
      METHOD = env[["REQUEST_METHOD"]],
      MOUNT = mount,
      FULLMOUNT = fullmount,
      PATH_INFO = env[["PATH_INFO"]],
      GET = GET,
      RAW = MYRAW,
      CTYPE = env[["CONTENT_TYPE"]],
      ACCEPT = env[["HTTP_ACCEPT"]]
    );  
    
    #call method
  	response <- serve(REQDATA);
  
    #we always assume a file
    response$body = utils$asfile(response$body);
    
    #set server header
    response$headers["X-ocpu-server"] <- "rook/httpuv";  
    
  	#return output
  	return(response);	
  }
}
