load_session_namespaces <- function(expr){
  all_sessions <- unique(grep("^x[0-9a-f]{4,18}$", findnamespaces(expr), value = TRUE))
  lapply(all_sessions, function(key){
    filepath <- file.path(session$sessiondir(key), ".RData");
    errorifnot(file.exists(filepath), paste("Session not found:", key));
    myenv <- new.env();
    load(filepath, envir=myenv);
    env2ns(key, myenv)
  })
  all_sessions
}

#' @importFrom namespace makeNamespace
env2ns <- function(name, env){
  env <- force(env)
  ns <- makeNamespace(name)
  lapply(ls(env), function(x){assign(x, get(x, env, inherits = FALSE), ns)})
  setNamespaceInfo(ns, "exports", as.environment(structure(as.list(ls(env)), names=ls(env))))
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
