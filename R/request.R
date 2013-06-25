## do req is the main function
## it should never actually return
## functions should always call respond() 
request <- function(expr){
	tryCatch({
		eval(expr);
		respond(503L, utils$write_to_file("function returned without calling respond"));
	}, error=reshandler);
}

respond <- function(status = 503L, body=NULL, headers=list()){
	if(!is.numeric(status)){
		stop("respond was called with non-numeric status");
	}
	
	if(!file.exists(body)){
		stop("respond was called with invalid file as body: ", body);
	}
  
  if(!is.list(headers)){
    stop("respond was called with invalid headers argument.");
  }
  
  #some static headers
  headers[["X-ocpu-r"]] = R.version.string;
	headers[["X-ocpu-locale"]] = Sys.getlocale("LC_CTYPE");
	headers[["X-ocpu-time"]] = format(Sys.time(), usetz=TRUE); 
  headers[["X-ocpu-version"]] = as.character(packageVersion(packagename));
  
	#Echo location to support AJAX with PRG pattern
	if(is.null(headers[["Location"]]) && req$method() %in% c("GET", "HEAD")){
	  headers[["Location"]] <- req$uri();
	}
    
	e <- structure(
    list(
      message="ocpu success", 
      call=NULL
    ),
    class=c("error", "condition", "ocpu_response"),
    status = status,
    body = body,
    headers = headers
  );
  
	stop(e)
}

reshandler <- function(e){
  
  #reset timer in case of error
  setTimeLimit();   
  
  #process response
  if(is(e, "ocpu_response")){    
    response <- list(
      status = attr(e, "status"),
      body = attr(e, "body"),
      headers = attr(e, "headers")
    );
  } else {
    #error response
    response <- list(
      status = 400L,
      body = utils$write_to_file(c(e$message, "","In call:", deparse(e$call))),
      headers = list("Content-Type" ="text/plain")
    );
  }

  #reset req/res state
  res$reset();
  req$reset();
  
  #return
  return(response);
}

