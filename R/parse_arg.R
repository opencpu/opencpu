parse_arg <- local({
  main <- function(x){
    
    #in case of null we keep null
    if(is.null(x)){
      return(NULL);
    }
    
    #special for json obj
    if(is(x, "AsIs")){
      class(x) <- tail(class(x), -1);
      return(x);
    }
    
    #cast for security
    x <- as.character(x);
    
    #empty string
    if(nchar(x) == 0){
      return(x);
    }
    
    if(x == "true" || x == "TRUE"){
      return(TRUE);
    }
    
    if(x == "false" || x == "FALSE"){
      return(FALSE);
    }  
    
    if(nchar(x) > 1 && substr(x, 1, 1) == "\"" && substr(x, nchar(x), nchar(x)) =="\""){
      #looks like a character string wrapped in double quotes
      return(substr(x, 2, nchar(x)-1));
    }
    
    if(nchar(x) > 1 && substr(x, 1, 1) == "\'" && substr(x, nchar(x), nchar(x)) =="\'"){
      #chracter string with single quotes
      return(substr(x, 2, nchar(x)-1));
    }    
    
    #try if is number
    if(x == gsub("[^0-9eE:.*/%+-]","", x)){
      return(eval(parse(text=x)));
    }
    
    #if string starts with { or [ we test for json
    if(substr(x, 1, 1) %in% c("{", "[")) {
      if(RJSONIO::isValidJSON(x, TRUE)) {
        return(RJSONIO::fromJSON(x));
      }
    }	
    
    if(exists(x)){
      return(parse(text=x));
    }
    
    if(grepl("^x[0-9a-f]{6,12}$", x)){
      filepath <- file.path(ocpu:::session$tmpsession(x), ".RData");
      errorifnot(file.exists(filepath), paste("Session not found:", x));
      myenv <- new.env();
      load(filepath, envir=myenv);
      errorifnot(exists(".value", myenv), "Session did not contain a .value");
      return(myenv$.value);
    }

    return(parsewithbrackets(x));
  }
  
  #This code parses text and automatically wraps it in curly brackets when needed.  
  parsewithbrackets <- function(text){
    
    #strip trailing space
    text <- sub('[[:space:]]+$', '', text);
    text <- sub('^[[:space:]]+', '', text);
    
    #fix non unix eol
    text <- gsub("\r\n", "\n", text);
    text <- gsub("\r", "\n", text);
    
    #The case where code is already wrapped in brackets
    if(substring(text, 1,1) == "{" && substring(text, nchar(text)) == "}"){
      mycode <- try(parse(text=text), silent=TRUE);
      if(class(mycode) == "try-error"){
        stop("Unparsable argument: ", text);
      }
      return(mycode);
    } 
    
    #Else, first try to parse with brackets.
    parsed <- try(parse(text=paste("{",text, "}")), silent=TRUE);
    if(class(parsed) == "try-error"){
      stop("Unparsable argument: ", text);
    }  
    
    #From this we infer if the brackets were needed.
    if(length(deparse(parsed[[1]])) > 3) return(parsed);
    return(parse(text=text));
  }  
  
  main;
});