#very simple function that recognizes numbers and booleans
parse_arg_prim <- function(x){
  
  #in case of null we keep null
  if(!length(x) || !nchar(x)){
    return(x);
  }

  #for json compatibility
  if(x == "true" || x == "TRUE"){
    return(TRUE);
  }
  
  if(x == "false" || x == "FALSE"){
    return(FALSE);
  }
  
  #check for boolean, number, string 
  myexpr <- parse(text=x);
  if(identical(1L, length(myexpr)) && is.atomic(myexpr[[1]])) {
    return(myexpr[[1]])
  } else {
    return(x)
  }
}