httpget_session_graphics <- function(filepath, requri){
  
  #reqhead is function/object name
  reqplot <- requri[1];
  reqformat <- requri[2];   
  
  #try to use old libraries
  libfile <- file.path(filepath, ".Rlibs");
  if(file.exists(libfile)){
    customlib <- readRDS(libfile);
  } else {
    customlib <- NULL;
  }        

  #graphics packages sometimes need to be reloaded  
  inlib(customlib, {  
    infofile <- file.path(filepath, ".RInfo");
    if(file.exists(infofile)){
      myinfo <- readRDS(infofile);
      allpackages <- c(names(myinfo$otherPkgs), names(myinfo$loadedOnly));
      if("ggplot2" %in% allpackages){
        getNamespace("ggplot2");
      }
      if("lattice" %in% allpackages){
        getNamespace("lattice");
      }    
    }
  });
  
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
  
  #check out of bounds
  if(index > length(myplots)){
    res$notfound(message = "Graphic not found (out of bounds)")  
  }
  
  myobject <- myplots[[index]];
    
  #default to PNG
  if(is.na(reqformat)){
    res$redirectpath("/png")
  }
  
  newfilename <- paste(utils::tail(strsplit(basename(filepath), "_", fixed=TRUE)[[1]], 1), reqplot, sep="_plot");
  httpget_object(myobject, reqformat, newfilename);
}