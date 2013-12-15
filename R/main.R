main <- function(REQDATA){
  #load config (in case of eval_psock)
  loadconfigs();
  
  #set a seed
  myseed <- floor(runif(1,1e8, 1e9));
  set.seed(myseed);

  #To be sure. Note that POST requests will eventually switch to a session dir.
  setwd(tempdir()); 
  
  #Parse request body if needed
  if(is.list(REQDATA$RAW)){
    RAWPOST <- parse_post(REQDATA$RAW$body, REQDATA$RAW$ctype);
    fileindex <- vapply(RAWPOST, function(x){isTRUE(is.list(x) && !is(x, "AsIs"));}, logical(1));
    REQDATA$FILES <- RAWPOST[fileindex];
    REQDATA$POST <- RAWPOST[!fileindex];     
  }
  
  #initiate the request object
  res$reset();
  req$init(REQDATA);
  
  #start processing
  httpget();
}
