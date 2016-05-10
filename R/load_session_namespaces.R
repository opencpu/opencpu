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
    unloadNamespace(key)
  })
}

env2ns <- function(name, env, lib){
  env <- force(env)
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

# This function is contained within from base::loadNamespace.
# It is also available in devtools and namespace. Initially we
# were importing it from the namespace package to avoid 
# warnings, but that seems a bit silly. Lets try this.
makeNamespace <- function(name, version = NULL, lib = NULL) {
  impenv <- new.env(parent = .BaseNamespaceEnv, hash = TRUE)
  attr(impenv, "name") <- paste("imports", name, sep = ":")
  env <- new.env(parent = impenv, hash = TRUE)
  name <- as.character(as.name(name))
  version <- as.character(version)
  info <- new.env(hash = TRUE, parent = baseenv())
  assign(".__NAMESPACE__.", info, envir = env)
  assign("spec", c(name = name, version = version), envir = info)
  setNamespaceInfo(env, "exports", new.env(hash = TRUE, parent = baseenv()))
  dimpenv <- new.env(parent = baseenv(), hash = TRUE)
  attr(dimpenv, "name") <- paste("lazydata", name, sep = ":")
  setNamespaceInfo(env, "lazydata", dimpenv)
  setNamespaceInfo(env, "imports", list(base = TRUE))
  setNamespaceInfo(env, "path", normalizePath(file.path(lib, name), "/", TRUE))
  setNamespaceInfo(env, "dynlibs", NULL)
  setNamespaceInfo(env, "S3methods", matrix(NA_character_, 0L, 3L))
  assign(".__S3MethodsTable__.", new.env(hash = TRUE, parent = baseenv()), envir = env)
  eval(as.call(list(quote(.Internal), quote(registerNamespace(name, env)))))
  env
}
