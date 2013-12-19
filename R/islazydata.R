islazydata <- function(x, ns){
  exists(x, ns, inherits=FALSE) && 
  identical("lazyLoadDBfetch", deparse(eval(call("substitute", as.name(x), ns))[[1]]))
}
