#rookhandler can either be used by Rook or by httpuv
rookhandler <- function(env){
  
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
    MOUNT = env[["SCRIPT_NAME"]],
    PATH_INFO = env[["PATH_INFO"]],
    GET = GET,
    RAW = MYRAW
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