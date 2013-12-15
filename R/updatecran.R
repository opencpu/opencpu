#this function is called by a cronjob
#not used by the API
updatecran <- function(){
  #make sure config is initiated
  loadconfigs();
  
  #Get the lib
  cranpath <- file.path(gettmpdir(), "cran_library");
  .libPaths(cranpath)
  
  #CRAN packages
  update.packages(lib.loc = cranpath, repos = "http://cran.r-project.org", ask = FALSE, checkBuilt=TRUE);
  if(length(list.files(cranpath))){
    system2("touch", paste0(cranpath, "/*"));
  }
  
}