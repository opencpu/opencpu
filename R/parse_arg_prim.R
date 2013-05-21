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
  
  #try if is number
  if(x == gsub("[^0-9eE:.*/%+-]","", x)){
    num <- as.numeric(x);
    if(!(is.na(num))){
      return(num);
    }
  }  
  
  #default to no changes
  return(x);
}