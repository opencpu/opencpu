# Placeholder for logging callbacks
log <- function(fmt, ...){
  if(interactive())
    cat(sprintf(paste0("[%s] ", fmt, "\n"), as.character(Sys.time()), ...))
}
