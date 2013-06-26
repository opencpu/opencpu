cmd_exists <- function(command){
  iswin <- identical(.Platform$OS.type, "windows"); 
  if(iswin){
    test <- suppressWarnings(try(system(command, intern=TRUE, show.output.on.console=FALSE), silent=TRUE));
  } else {
    test <- suppressWarnings(try(system(command, intern=TRUE, ignore.stdout=TRUE, ignore.stderr=TRUE), silent=TRUE));    
  }
  !is(test, "try-error")
}
