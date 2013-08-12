#rookhandler can either be used by Rook or by httpuv
rookhandler <- function(rootpath){
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
    
    #collect data from Rook
    REQDATA <- list(
      METHOD = env[["REQUEST_METHOD"]],
      MOUNT = paste0(env[["SCRIPT_NAME"]], rootpath),
      PATH_INFO = env[["PATH_INFO"]],
      GET = GET,
      RAW = MYRAW
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
