packagename = "";

.onLoad <- function(lib, pkg){
  packagename <<- pkg;
  
  if(isTRUE(getOption("rapache"))){
    is_rapache(TRUE)
  }
  
  if(isTRUE(getOption("apparmor"))){
    use_apparmor(TRUE)
  }
  
  if(isTRUE(getOption("no_rapparmor"))){
    no_rapparmor(TRUE)
  }
}
