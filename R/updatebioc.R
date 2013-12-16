#this function is called by a cronjob
#not used by the API
updatebioc <- function(){
  #import
  eval.secure <- from("RAppArmor", "eval.secure");  
  
  #make sure config is initiated
  loadconfigs();
  
  #load library
  biocpath <- file.path(gettmpdir(), "bioc_library");
  
  #cleanup blockers (should not be necesssary)
  unlink(list.files(biocpath, full.names=TRUE, pattern="_block$"));
  
  #nothing to update
  if(!length(list.files(biocpath))){
    message("BIOC library does not exist or is empty. Done.")
    return();
  }
  
  #set path  
  .libPaths(biocpath);
  
  #load BIOC packages
  source("http://bioconductor.org/biocLite.R");
  
  #Update bioc packages
  eval.secure({
    update.packages(lib.loc=biocpath, repos=eval(call("biocinstallRepos")), ask = FALSE, checkBuilt=TRUE);
    if(length(list.files(biocpath))){
      system2("touch", paste0(biocpath, "/*"));
    }  
  }, timeout=60*60*4, RLIMIT_CPU=60*60*4, RLIMIT_AS = 2e9, profile="opencpu-main");  
}
