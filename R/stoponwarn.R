stoponwarn <- function(...){
  tryCatch(eval(...), warning=function(w){
    stop("warning! ", w$message)
  });
}
