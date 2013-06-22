cmd_exists <- function(command){
  test <- suppressWarnings(try(system(command, intern=TRUE, ignore.stdout=TRUE, ignore.stderr=TRUE, show.output.on.console=FALSE), silent=TRUE));
  !is(test, "try-error")
}
