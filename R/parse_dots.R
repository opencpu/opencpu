parse_dots <- function(query){
  # First, create a string that represents a function call
  string <- paste0("c(", query, ")")
  
  # Next, parse it, and extract the function call
  call <- parse(text = string)[[1]]

  # Finally, remove the first element (`c`) and convert to a list
  as.list(call[-1])  
}
