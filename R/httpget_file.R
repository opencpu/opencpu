httpget_file <- function(path){
  if(file.exists(path)){
    respond(200, asfile(path));
  } else {
    respond(404, "This file did not exist.")
  }
}