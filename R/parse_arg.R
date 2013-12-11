parse_arg <- local({
  main <- function(x){
    
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
    
    #otherwise its probably an R snippet
    if(isTRUE(config("enable.post.code"))){
      return(parsewithbrackets(x));
    }
    
    #Below only happens when config("enable.post.code") == FALSE.
    #This will never be used in the default configuration.
    
    #check if it is an object
    if(exists(x)){
      return(parse(text=x));
    }    
    
    #try to detect strings    
    if(nchar(x) > 1 && substr(x, 1, 1) == "\"" && substr(x, nchar(x), nchar(x)) =="\""){
      #looks like a character string wrapped in double quotes
      return(parse(text=x))
      #this fails for esape sequences
      #return(as.expression(substr(x, 2, nchar(x)-1)));
    }
    if(nchar(x) > 1 && substr(x, 1, 1) == "\'" && substr(x, nchar(x), nchar(x)) =="\'"){
      #chracter string with single quotes
      return(parse(text=x))
      #this fails for escape sequences
      #return(as.expression(substr(x, 2, nchar(x)-1)));
    }    
    
    #try if is number
    if(x == gsub("[^0-9eE:.*/%+-]","", x)){
      return(parse(text=x));
    }
    
    stop("Invalid argument: ", x, ". This server has disabled posting of R snippets.");
  }
  
  #This code parses text and automatically wraps it in curly brackets when needed.  
  parsewithbrackets <- function(text){    
    #try to parse code
    mycode <- tryCatch(parse(text=text, keep.source=FALSE), error = function(e){
      stop("Unparsable argument: ", text);
    });
    
    #check length
    if(length(mycode) > 1){
      mycode <- parse(text = paste("{", text, "}"), keep.source=FALSE);
    }
    
    return(mycode);
  }  
  
  main;
});