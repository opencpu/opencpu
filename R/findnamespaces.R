findnamespaces <- function(expr){
  namespaces <- character()
  if(is.call(expr) && identical(expr[[1]], as.name("::"))){
    namespaces <- deparse(expr[[2]])
  }
  if(!is.name(expr) && !is.atomic(expr)){
    for(i in seq_along(expr)){
      namespaces <- c(namespaces, findnamespaces(expr[[i]]))     
    }
  }
  return(unique(namespaces))
}

#example:    
#findnamespaces(parse(text="foo::test(bar::test)\n function(x){return(baz::test)}"))
