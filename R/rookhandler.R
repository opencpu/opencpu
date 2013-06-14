#rookhandler can either be used by Rook or by httpuv
rookhandler <- function(env){
  
  #do some Rook processing
  GET <- parse_query(env[["QUERY_STRING"]]);   
  
  if(env[["REQUEST_METHOD"]] %in% c("POST", "PUT")){
    input <- env[["rook.input"]];
    input$rewind();
    content_length <- as.integer(env$CONTENT_LENGTH);
    postdata <- input$read(content_length);
    RAWPOST <- parse_post(postdata, env[["CONTENT_TYPE"]]);
  } else {
    RAWPOST <- list();
  }
  
  #extract files
  fileindex <- vapply(RAWPOST, is.list, logical(1));
  FILES <- RAWPOST[fileindex];
  POST <- RAWPOST[!fileindex];     
  
  #collect data from Rook
  REQDATA <- list(
    METHOD = env[["REQUEST_METHOD"]],
    MOUNT = env[["SCRIPT_NAME"]],
    PATH_INFO = env[["PATH_INFO"]],
    POST = POST,
    GET = GET,
    FILES = FILES
  );  
  
  #call method
	response <- serve(REQDATA);

  #we always assume a file
  response$body = utils$asfile(response$body);

	#return output
	return(response);	
}

# The function below starts the R help server via the Rook package.
# It is probably better to use httpuv instead.
initrook <- function(){
  library(Rook);
  s <- Rhttpd$new();
  s$start(quiet=TRUE);
  
  s$add(
    name="ocpu",
    app=rookhandler
  );
  
  s$browse("ocpu")
  return(s);	
}