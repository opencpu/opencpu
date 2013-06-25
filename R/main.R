main <- function(REQDATA){
  #set a seed
  myseed <- floor(runif(1,1e8, 1e9));
  set.seed(myseed);

  #To be sure. Note that POST requests will eventually switch to a session dir.
  setwd(tempdir()); 
  
  #initiate the request object
  res$reset();
  req$init(REQDATA);
  
  #start processing
  httpget();
}
