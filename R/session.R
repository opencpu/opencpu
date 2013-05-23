session <- local({
  prefix = "ocpu_session_";

  remove <- function(hash){
    mydir <- sessiondir(hash);
    stopifnot(file.remove(mydir, recursive=TRUE));
  }
  
  save <- function(hash, envir){
    setwd(sessiondir(hash));    
    save(file=".RData", list=ls(envir), envir);
  }
  
  init <- function(){
    characters <- c(0:9, letters[1:6]);
    hash <- paste(c("0x0", sample(characters, 7, replace=TRUE)), collapse="")
    stopifnot(dir.create(sessiondir(hash)));
    setwd(sessiondir(hash));
    sessionpath(hash);
  }
  
  list <- function(filepath){
    setwd(filepath);
    outlist <- vector();
    
    #list data files
    if(file.exists(".RData")){
      myenv <- new.env();
      load(".RData", myenv);
      if(length(ls(myenv))){
        outlist <- c(outlist, paste("R", ls(myenv), sep="/"));        
      }
    }
    
    #list eval files
    if(file.exists(".REval")){
      myeval <- readRDS(".REval");
      if(length(extract(myeval, "graphics"))){
        outlist <- c(outlist, paste("graphics", seq_along(extract(myeval, "graphics")), sep="/"));        
      }
      if(length(extract(myeval, "message"))){
        outlist <- c(outlist, "messages");        
      }    
      if(length(extract(myeval, "warning"))){
        outlist <- c(outlist, "warnings");        
      }        
      if(length(extract(myeval, "source"))){
        outlist <- c(outlist, "source");        
      }   
      if(length(extract(myeval, "console"))){
        outlist <- c(outlist, "console");        
      }        
      #outlist <- c(outlist, "report");
    }
    
    #list eval files
    if(file.exists(".RInfo")){
      outlist <- c(outlist, "info");
    }    
    
    #other files
    if(length(list.files())){
      outlist <- c(outlist, "files")
    }    
    
    return(outlist);
  }
  
  sessiondir <- function(hash){
    file.path(gettmpdir(), paste(prefix, hash, sep=""));
  }
  
  sessionpath <- function(hash){
    sub(prefix, "", sessiondir(hash));
  }
  
  environment();
})

