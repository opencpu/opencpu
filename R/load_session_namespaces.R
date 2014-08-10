load_session_namespaces <- function(expr){
  all_sessions <- unique(grep(session_regex(), findnamespaces(expr), value = TRUE))
  lapply(all_sessions, function(key){
    filepath <- file.path(session$sessiondir(key), ".RData");
    errorifnot(file.exists(filepath), paste("Session not found:", key));
    myenv <- new.env();
    load(filepath, envir=myenv);
    env2ns(key, myenv, lib=dirname(dirname(filepath)))
  })
  all_sessions
}

unload_session_namespaces <- function(){
  all_sessions <- unique(grep(session_regex(), loadedNamespaces(), value = TRUE))
  lapply(all_sessions, function(key){
    unloadNamespace(.getNamespace(key))
  })
}

env2ns <- function(name, env, lib){
  env <- force(env)
  #NOTE: there is also an exported copy of makeNamespace in the 'namespace' package
  makeNamespace <- getFromNamespace("makeNamespace", "devtools")
  ns <- makeNamespace(name, lib = lib)
  exports <- getNamespaceInfo(ns, "exports")
  object_names <- ls(env, all.names=TRUE)
  lapply(object_names, function(x){
    assign(x, get(x, env, inherits = FALSE), ns)
    assign(x, x, exports)
  })
}

#env2ns("test", iris); test::Species

findnamespaces <- function(expr){
  namespaces <- character()
  if(is.call(expr) && identical(expr[[1]], as.name("::"))){
    namespaces <- deparse(expr[[2]])
  }
  if(!is.name(expr) && !is.atomic(expr)){
    for(i in seq_along(expr)){
      namespaces <- c(namespaces, findnamespaces(expr[[i]]))     
    }
  }
  return(unique(namespaces))
}

#example:    
#findnamespaces(parse(text="foo::test(bar::test)\n function(x){return(baz::test)}"))
