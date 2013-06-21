gist_load <- function(gistuser, gistid){
  gistpath <- file.path(gettmpdir(), paste("ocpu_gist", gistuser, gistid, sep="_"));
  blockpath <-file.path(gettmpdir(), paste("ocpu_gist", gistuser, gistid, "block", sep="_"));
  maxage <- config("gist.cache");
  
  #is there is a blocker but its old, we remove it. This should not happen.
  if(isTRUE(difftime(Sys.time(), file.info(blockpath)$mtime, units="secs") > 120)){
    stopifnot(unlink(blockpath, recursive=TRUE, force=TRUE));    
  }
  
  #wait for the block to disappear
  while(file.exists(blockpath)){
    Sys.sleep(1);
  }
  
  #see if it exists
  if(file.exists(gistpath)){
    dirage <- difftime(Sys.time(), file.info(gistpath)$mtime, units="secs");
    if(dirage < maxage){
      return(gistpath);      
    } else {
      unlink(gistpath, recursive=TRUE, force=TRUE);
    }
  }
  
  #setup a blocker (for concurrent requests to the same gist)
  stopifnot(file.create(blockpath));
  on.exit(unlink(blockpath, force=TRUE));

  #init the gist
  gisturl <- paste("https://gist.github.com", gistuser, gistid, "download", sep="/");
  out <- GET(gisturl, add_headers("User-Agent" = "OpenCPU"));
  stop_for_status(out);
  gisttmpfile <- tempfile("gistfile");
  writeBin(out$content, gisttmpfile);
  #download.file(gisturl, gisttmpfile, method="curl", quiet=TRUE);
  
  gisttmpdir <- tempfile("gistdir");
  stopifnot(dir.create(gisttmpdir));
  untar(gisttmpfile, exdir=gisttmpdir, restore_times=FALSE);
  
  #a gist archive contains exactly one dir
  gistcommitname <- list.files(gisttmpdir, include.dirs=TRUE, full.names=TRUE);
  stopifnot(length(gistcommitname) == 1);
  
  #move to final destination
  stopifnot(file.rename(gistcommitname, gistpath));
  file.remove(blockpath);
  
  #return the path 
  return(gistpath)
}