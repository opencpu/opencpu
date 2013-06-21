windir <- function(path){
  #dont do anything for non-windows
  if(!identical(OS, "windows")){
    return(path)
  }
  gsub("\\", "/", path);
}
