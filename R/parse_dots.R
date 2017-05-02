parse_dots <- function(query){
  # First, create a string that represents a function call
  string <- paste0("c(", query, ")")

  # Next, parse it, and extract the function call
  call <- parse(text = string)[[1]]

  # Finally, remove the first element (`c`) and convert to a list
  expressions <- as.list(call[-1])

  # Translate session shorthands
  expressions <- lapply(expressions, function(expr){
    if(is.name(expr) && grepl(session_regex(), deparse(expr))){
      return(parse(text=paste0(deparse(expr), "::.val"))[[1]])
    } else {
      return(expr)
    }
  })

  # Look for session namespaces
  lapply(expressions, collect_session_keys)

  # Return expressions to be appended to function call
  return(expressions)
}
