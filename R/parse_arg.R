parse_arg <- function(x){

  #special for json obj
  if(is(x, "AsIs")){
    class(x) <- tail(class(x), -1);
    return(x);
  }
  
  #cast (e.g. for NULL)
  x <- as.character(x);
  
  #empty vector causes issues
  if(!length(x)){
    x <- " ";
  }
  
  #some special cases for json compatibility
  switch(x,
    "true" = return(as.expression(TRUE)),
    "false" = return(as.expression(FALSE)),
    "null" = return(as.expression(NULL))
  );
  
  #if string starts with { or [ we test for json
  if(grepl("^[ \t\r\n]*(\\{|\\[)", x)) {
    if(validate(x)) {
      return(fromJSON(x));
    }
  }
  
  #check if it is a session key
  if(grepl("^x[0-9a-f]{6,12}$", x)){
    filepath <- file.path(session$sessiondir(x), ".RData");
    errorifnot(file.exists(filepath), paste("Session not found:", x));
    myenv <- new.env();
    load(filepath, envir=myenv);
    errorifnot(exists(".val", myenv), paste("Session", x, "does not contain an object .val"));
    return(myenv$.val);
  }    
    
  #try to parse code. R doesn't like CR+LF
  x <- gsub("\r\n", "\n", x);  
  myexpr <- tryCatch(parse(text=x, keep.source=FALSE), error = function(e){
    stop("Unparsable argument: ", x);
  });
  
  #inject code if enabled
  if(isTRUE(config("enable.post.code"))){
    #check length
    if(length(myexpr) > 1){
      return(parse(text = paste("{", x, "}"), keep.source=FALSE));
    } else {
      return(myexpr);      
    }
  }

  #otherwise check for primitive   
  if(!length(myexpr)){
    return(expression());
  }
  
  #check if it is a boolean, number or string 
  if(identical(1L, length(myexpr))) {
    if(is.character(myexpr[[1]]) || is.logical(myexpr[[1]]) || is.numeric(myexpr[[1]]) || is.name(myexpr[[1]])) {
      return(myexpr);
    }
  }
  
  #failed to parse argument
  stop("Invalid argument: ", x, ".\nThis server has disabled posting R code in arguments.");    
}
