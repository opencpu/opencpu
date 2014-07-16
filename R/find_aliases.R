find_aliases <- function(pkgpath, pkgname) {
  all_topics <- sort(readRDS(file.path(pkgpath, "help", "aliases.rds")))
  topic_names <- unique(all_topics)
  aliasstring = character(length(topic_names))
  for(i in 1:length(topic_names)) {
    aliasstring[i] <- paste(names(which(topic_names[i] == all_topics & topic_names[i] != names(all_topics))), collapse=", ")
  }
  data.frame(name=topic_names, alias=aliasstring, stringsAsFactors = FALSE)  
}

#links <- names(all_topics)[match(unique(all_topics), all_topics)]