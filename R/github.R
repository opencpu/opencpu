github_prefix <- "ocpu_github"

getlocaldir <- function(){
  return("/usr/local/lib/opencpu")
}

github_rootpath <- function(){
  githublib <- file.path(getlocaldir(), "github_library")
  if(!file.exists(githublib))
    stopifnot(dir.create(githublib, recursive = TRUE))
  return(githublib)
}

github_userlib <- function(gituser, gitrepo){
  file.path(github_rootpath(), paste(github_prefix, gituser, gitrepo, sep="_"))
}
