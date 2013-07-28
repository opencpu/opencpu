check.enabled <- function(what){
  if(isTRUE(config(paste0("enable.", what)))){
    return(TRUE);
  }
  stop('The ', what, ' feature has not been enabled on this server.\nAdmin needs to set: {"enable.', what,'":true}');
}