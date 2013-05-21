#rookhandler can either be used by Rook or by httpuv
rookhandler <- function(env){
  
  #do some Rook processing
  ROOKREQ <- Rook::Request$new(env);
  GET <- ROOKREQ$GET();   
  RAWPOST <- ROOKREQ$POST();		
  fileindex <- vapply(RAWPOST, is.list, logical(1));
  REQFILES <- RAWPOST[fileindex];
  POST <- RAWPOST[!fileindex];  

  #collect data from Rook
  REQDATA <- list(
    METHOD = ROOKREQ$request_method(),
    URI = ROOKREQ$path(),
    MOUNT = env$SCRIPT_NAME,
    PATH_INFO = ROOKREQ$path_info(),
    POST = POST,
    GET = GET,
    FILES = REQFILES
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