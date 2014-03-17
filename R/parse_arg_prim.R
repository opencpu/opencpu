#very simple function that recognizes numbers and booleans
parse_arg_prim <- function(x){
  
  #in case of null we keep null
  if(is.null(x)){
    return(NULL);
  }
  
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
  
  #check if it is a boolean, number or string 
  myexpr <- parse(text=x);
  if(identical(1L, length(myexpr))) {
    obj <- myexpr[[1]];
    if(is.character(obj) || is.logical(obj) || is.numeric(obj)) {
      return(obj);
    }
  }
  
  #default to no changes
  return(x);
}