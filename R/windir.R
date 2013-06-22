windir <- function(path){
  #dont do anything for non-windows
  if(!identical(.Platform$OS.type, "windows")){
    return(path)
  }
  gsub("\\", "/", path, fixed=TRUE);
}
