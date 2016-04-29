#this function is called by a cronjob
#not used by the API
updatecran <- function(){
  #make sure config is initiated
  loadconfigs();
  
  #Get the lib
  cranpath <- file.path(gettmpdir(), "cran_library");
  
  #cleanup blockers (should not be necesssary)
  unlink(list.files(cranpath, full.names=TRUE, pattern="_block$"));    

  #nothing to update
  if(!length(list.files(cranpath))){
    message("CRAN library does not exist or is empty. Done.")
    return();
  }
  
  #set lib
  .libPaths(cranpath)
  
  #CRAN packages
  RAppArmor::eval.secure({
    utils::update.packages(lib.loc = cranpath, repos = "http://cran.r-project.org", ask = FALSE, checkBuilt=TRUE);
    if(length(list.files(cranpath))){
      system2("touch", paste0(cranpath, "/*"));
    }
  }, timeout=60*60*4, RLIMIT_CPU=60*60*4, RLIMIT_AS = 2e9, profile="opencpu-main");
}
