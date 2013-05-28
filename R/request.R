## do req is the main function
## it should never actually return
## functions should always call respond() 
request <- function(...){
	tryCatch({
		eval(...);
		respond(503L, utils$write_to_file("function returned without calling respond"));
	}, error=reshandler);
}


respond <- function(status = 503L, body=NULL, headers=list()){
	if(!is.numeric(status)){
		stop("respond was called with non-numeric status");
	}
	
	if(!file.exists(body)){
		stop("respond was called with invalid file as body: ", body)
	}
  
  if(!is.list(headers)){
    stop("respond was called with invalid headers argument.")
  }
	
	e <- simpleError("ocpu_response", call=NULL);
	attr(e, "status") <- status;
	attr(e, "body") <- body;
	attr(e, "headers") <- headers;
	stop(e)
}

reshandler <- function(e){
  #reset timer in case of error
  setTimeLimit();   
  
  #process response
  message <- e$message;
  if(message == "ocpu_response"){
    #successful response
    response <- list(
      status = attr(e, "status"),
      body = attr(e, "body"),
      headers = attr(e, "headers")
    );
  } else {
    #error response
    response <- list(
      status = 400L,
      body = utils$write_to_file(message),
      headers = list("Content-Type" ="text/plain")
    );
  }
  
  #set response size header here?

  #reset req/res state
  res$reset();
  req$reset();
  
  #return
  return(response);
}

