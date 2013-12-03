execute_function <- function(object, requri, objectname="FUN"){
  
  #test for executability
  if(!is.function(object)){
    stop(objectname, "is not a function.")
  }   
  
  #build the function call
  fnargs <- lapply(req$post(), parse_arg);
  fileargs <- structure(lapply(req$files(), function(x){as.expression(x$name)}), names=names(req$files()));
  fnargs <- c(fnargs, fileargs);
  
  argn <- lapply(names(fnargs), as.name);
  names(argn) <- names(fnargs);  
  
  #insert expressions
  exprargs <- sapply(fnargs, is.expression);
  if(length(exprargs) > 0){
    argn[names(fnargs[exprargs])] <-lapply(fnargs[exprargs], function(z){if(length(z)) z[[1]] else substitute()});
  }  

  #construct call
  mycall <- as.call(c(list(as.name(objectname)), argn));
  fnargs <- c(fnargs, structure(list(object), names=objectname));		
  
  #perform evaluation
  session$eval(mycall, fnargs, storeval=TRUE, format=requri[1])
}