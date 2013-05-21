execute_function <- function(object, requri, objectname="FUN"){
  
  #test for executability
  if(!is.function(object)){
    stop(objectname, "is not a function.")
  }   
  
  #build the function call
  fnargs <- lapply(req$post(), parse_arg);
  argn <- lapply(names(fnargs), as.name);
  names(argn) <- names(fnargs);  
  
  #insert expressions
  exprargs <- sapply(fnargs, is.expression);
  if(length(exprargs) > 0){
    argn[names(fnargs[exprargs])] <-lapply(fnargs[exprargs], "[[", 1);
  }  

  #construct call
  mycall <- as.call(c(list(as.name(objectname)), argn));
  fnargs <- c(fnargs, structure(list(object), names=objectname));		
  
  #setup evaluation
  sessionpath <- session$init();
  sessionenv <- new.env(parent=globalenv());
  handler <- evaluate::new_output_handler(value=function(myval){
    assign("value", myval, sessionenv);
    evaluate$render(myval);
  });
  
  #run evaluation
  pdf(tempfile(), width=11.69, height=8.27, paper="A4r")
  dev.control(displaylist="enable");    
  par("bg" = "white");  
  output <- evaluate::evaluate(mycall, fnargs, sessionenv, stop_on_error=2, new_device=FALSE, output_handler=handler);
  dev.off();
  
  #save
  save(list=ls(sessionenv), file=".RData", envir=sessionenv);
  saveRDS(output, file=".REval");
  saveRDS(sessionInfo(), file=".RInfo");
  
  #add warning headers
  #lapply(extract(output, "message"), function(x){res$setheader("X-ocpu-message", x$message);});
  #lapply(extract(output, "warning"), function(x){res$setheader("X-ocpu-warning", x$message);});  
  
  #output
  outputpath <- paste(req$mount(), sessionpath, "/", sep="");
  res$setheader("Location", outputpath);
  res$setbody(outputpath);
  res$finish(303);  
}