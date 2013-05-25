eval_session <- function(input, args){
  #setup evaluation
  sessionpath <- session$init();
  sessionenv <- new.env(parent=globalenv());
  
  #in case if file executions
  if(missing(args)){
    args <- sessionenv;
  }
  
  #setup handler
  myhandler <- evaluate::new_output_handler(value=function(myval){
    assign(".value", myval, sessionenv);
    evaluate:::render(myval);
  });
  
  #run evaluation
  pdf(tempfile(), width=11.69, height=8.27, paper="A4r")
  dev.control(displaylist="enable");    
  par("bg" = "white");  
  output <- evaluate::evaluate(input=input, envir=args, sessionenv, stop_on_error=2, new_device=FALSE, output_handler=myhandler);
  dev.off();
  
  #temp fix for evaluate bug
  output <- Filter(function(x){!emptyplot(x)}, output);
  
  #save
  save(list=ls(sessionenv, all.names=TRUE), file=".RData", envir=sessionenv);
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