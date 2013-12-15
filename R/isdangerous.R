#a url is dangerous when it could load packages during HTTP GET.
isdangerous <- function(url){
  pattern1 <- "^/?(library|apps|cran|bioc|tmp)/[a-zA-Z0-9._-]*/(R|data|graphics)(/.*)?$";
  pattern2 <- "^/?(github|user)/[a-zA-Z0-9._-]*/(library|apps)/[a-zA-Z0-9._-]*/(R|data|graphics)(/.*)?$";
  
  if(grepl(pattern1, url) || grepl(pattern2, url)){
    return(TRUE);
  }
  
  return(FALSE)
}
