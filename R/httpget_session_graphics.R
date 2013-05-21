httpget_session_graphics <- function(filepath, requri){
  
  #reqhead is function/object name
  reqplot <- requri[1];
  reqformat <- requri[2];   
  
  #load data
  myeval <- readRDS(sessionfile <- file.path(filepath, ".REval"));
  myplots <- extract(myeval, "graphics");
  
  #list available plots
  if(is.na(reqplot)){
    if(!length(myplots)){
      res$setbody("");
      res$finish();
    } else {
      res$sendlist(c(1:length(myplots), "last"));
    }
  }
  
  #last shortcut
  if(reqplot == "last"){
    reqplot <- length(myplots);
  }
  
  #get the plot
  index <- as.numeric(reqplot);
  if(is.na(index)){
    stop("Plot must either be numeric value or 'last'");
  }
  myobject <- myplots[[index]];
    
  #default to PNG
  if(is.na(reqformat)){
    res$redirect(paste(req$uri(), "/png", sep=""))
  }
  
  newfilename <- paste(tail(strsplit(basename(filepath), "_", fixed=TRUE)[[1]], 1), reqplot, sep="_plot");
  httpget_object(myobject, reqformat, newfilename);
}