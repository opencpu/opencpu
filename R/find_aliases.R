find_aliases <- function(pkgpath, pkgname) {
  manlist <- names(from("tools", "fetchRdDB")(file.path(pkgpath, "help", pkgname)))
  aliases <- readRDS(file.path(pkgpath, "help", "aliases.rds"))
  aliasstring = character(length(manlist))
  for(i in 1:length(manlist)){
    aliasstring[i] <- paste(names(which(manlist[i] == aliases & manlist[i] != names(aliases))), collapse=", ")
  }
  data.frame(name=manlist, alias=aliasstring, stringsAsFactors = FALSE)  
}