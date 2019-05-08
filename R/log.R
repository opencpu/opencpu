# Placeholder for logging callbacks
log <- function(fmt, ...){
  if(!is_rapache()){
    cat(sprintf(paste0("[%s] ", fmt, "\n"), as.character(Sys.time()), ...))
    utils::flush.console()
  }
}
