github_prefix <- "ocpu_github"

github_rootpath <- function(){
  githublib <- file.path(gettmpdir(), "github_library")
  if(!file.exists(githublib))
    stopifnot(dir.create(githublib, recursive = TRUE))
  return(githublib)
}

github_userlib <- function(gituser, gitrepo){
  file.path(github_rootpath(), paste(github_prefix, gituser, gitrepo, sep="_"))
}
