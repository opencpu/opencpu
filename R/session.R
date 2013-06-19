session <- local({
  prefix <- config("session.prefix");

  #initiates a new tmp session
  init <- function(){
    characters <- c(0:9, letters[1:6]);
    hash <- paste(c("x0", sample(characters, 7, replace=TRUE)), collapse="")
    mydir <- tmpsession(hash);
    stopifnot(dir.create(mydir));
    setwd(mydir);
    hash;
  }  
  
  #copies files from an existing session into a new tmp session
  fork <- function(olddir){
    olddir <- olddir; #force eval
    hash <- init();
    newdir <- tmpsession(hash);
    setwd(olddir)
    file.copy(".", newdir, recursive=TRUE);
    setwd(newdir);
    unlink(".RData")
    unlink(".REval");
    unlink(".RInfo");
    hash
  }
  
  #evaluates something inside a session
  eval <- function(input, args, storeval=FALSE){
    
    #verify current session
    if(issession(getwd())){
      hash <- fork(getwd());
    } else {
      hash <- init();
    }
    
    #setup handler
    myhandler <- evaluate::new_output_handler(value=function(myval){
      if(isTRUE(storeval)){
        assign(".val", myval, sessionenv);
      }
      evaluate:::render(myval);
    });
    
    #save dir
    olddir <- getwd();
    
    #create session for output objects
    if(missing(args)){
      args <- new.env(parent=globalenv())
    } else {
      args <- as.environment(args);
      parent.env(args) <- globalenv();
    }
    sessionenv <- new.env(parent=args);
    
    #note: we don't load or attach "old" R objects from a previous session.
    #In case of a function call, scoping will find objects anyway.
    
    #run evaluation
    pdf(tempfile(), width=11.69, height=8.27, paper="A4r")
    dev.control(displaylist="enable");    
    par("bg" = "white");  
    output <- evaluate::evaluate(input=input, envir=sessionenv, stop_on_error=2, new_device=FALSE, output_handler=myhandler);
    dev.off();   
    
    #temp fix for evaluate bug
    output <- Filter(function(x){!emptyplot(x)}, output); 
    
    #in case code changed dir
    setwd(olddir);
    
    #store output
    save(file=".RData", envir=sessionenv, list=ls(sessionenv, all.names=TRUE));
    saveRDS(output, file=".REval");
    saveRDS(sessionInfo(), file=".RInfo");  
    
    #redirect client
    send(hash);
  }
  
  #redirects the client to the session location
  send <- function(hash){
    tmppath <- sessionpath(hash);
    outputpath <- paste(req$mount(), tmppath, "/", sep="");
    res$redirect(outputpath, 303);    
  }
  
  #get a list of the contents of the current session
  index <- function(filepath){
    
    #verify session exists
    stopifnot(issession(filepath))
    
    #set the dir
    setwd(filepath)
    
    #outputs
    outlist <- vector();
    
    #list data files
    if(file.exists(".RData")){
      myenv <- new.env();
      load(".RData", myenv);
      if(length(ls(myenv, all.names=TRUE))){
        outlist <- c(outlist, paste("R", ls(myenv, all.names=TRUE), sep="/"));        
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
      if(length(extract(myeval, "text"))){
        outlist <- c(outlist, "stdout");        
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
    }
    
    #list eval files
    if(file.exists(".RInfo")){
      outlist <- c(outlist, "info");
    }    
    
    #other files
    sessionfiles <- file.path("files", list.files(recursive=TRUE))
    if(length(sessionfiles)){
      outlist <- c(outlist, sessionfiles)
    }    
    
    return(outlist);
  }
  
  tmpsession <- function(hash){
    file.path(gettmpdir(), paste(prefix, hash, sep=""));
  }
  
  issession <- function(mydir){
    any(file.exists(file.path(mydir, c(".RData", ".REval"))));
  }
  
  sessionpath <- function(hash){
    paste("/tmp/", hash, sep="");
  }
  
  environment();
});

