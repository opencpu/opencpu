main <- function(REQDATA){
  #randomize state within the forks
  set.seed(sum(256 ^ (0:2) * as.numeric(openssl::rand_bytes(3))))

  #To be sure. Note that POST requests will eventually switch to a session dir.
  setwd(tempdir());

  #Parse request body if needed
  if(is.list(REQDATA$RAW)){
    RAWPOST <- parse_post(REQDATA$RAW$body, REQDATA$RAW$ctype);
    fileindex <- vapply(RAWPOST, function(x){isTRUE(is.list(x) && !inherits(x, "AsIs"));}, logical(1));
    REQDATA$FILES <- RAWPOST[fileindex];
    REQDATA$POST <- RAWPOST[!fileindex];
  }

  #initiate the request object
  res$reset();
  req$init(REQDATA);

  #start processing
  httpget();
}
