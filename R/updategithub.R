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
    #get the git username and repo
    pkg <- strsplit(x, "_", fixed=TRUE)[[1]];
    
    #Update github packages
    result <- RAppArmor::eval.secure(github_install(pkg[4], pkg[3]), timeout=30*60, RLIMIT_CPU=30*60, RLIMIT_AS = 2e9, profile="opencpu-main");  
  
    #cat some output
    try(cat("Github update of", pkg[3], "/", pkg[4], ": ", ifelse(result$success, "successful.\n", "failed.\n")));
  });
  
  #do something with results
  ###
}
