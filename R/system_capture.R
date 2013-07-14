system_capture <- function(cmd, args){
  #Note: stdout=FALSE doesn't work in rstudio-win. stdout=file doesn't work on win at all.  
  outdata <- system2(cmd, args, stdout=TRUE, stderr=TRUE);
  
  #status should be available as an attribute. If it is not there, then assume success.
  status <- attr(outdata, "status");
  status <- if(is.null(status)) 0 else status;
  
  #return
  list(
    status = status,
    text = outdata
  );  
}
