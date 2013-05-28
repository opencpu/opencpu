main <- function(REQDATA){
  #set a seed
  myseed <- floor(runif(1,1e8, 1e9));
  set.seed(myseed);
  
  #switch to a temporary working dir
  systmp <- gettmpdir();
  workdir <- file.path(systmp, paste("ocpu_tmp_", myseed, sep=""));
  dir.create(workdir)
  setwd(workdir);	    
  
  #initiate the request object
  res$reset();
  req$init(REQDATA);
  
  #start processing
  httpget();
}
