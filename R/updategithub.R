#this function is called by a cronjob
#not used by the API
updategithub <- function(){
  #make sure config is initiated
  loadconfigs();
    
  #Get the lib
  githublib <- file.path(gettmpdir(), "github_library");
  
  #cleanup blockers (should not be necesssary)
  unlink(list.files(githublib, full.names=TRUE, pattern="_block$"))
  
  #check current packages
  allpkgs <- list.files(githublib, pattern="^ocpu_github_");
  
  #nothing to update
  if(!length(allpkgs)){
    message("Github library does not exist or is empty. Done.")
    return(invisible());
  }
  
  #update all packages
  results <- lapply(allpkgs, function(x){
    try({
      pkg <- strsplit(x, "_", fixed=TRUE)[[1]];
      github_install(pkg[4], pkg[3]);
    });
  });
  
  #do something with results
  ###
}
