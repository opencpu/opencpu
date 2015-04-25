httpget_webhook <- function(){
  if(req$method() == "GET"){
    res$sendtext(paste0(
      "To enable CI, add the following URL as a 'WebHook' in your Github repository:\n\n  ",
      config("public.url"), "/webhook?sendmail=true\n\nSee also https://help.github.com/articles/post-receive-hooks."));
  }

  #make sure it's POST
  res$checkmethod("POST")

  #webhook payload can either be pure json or url-encoded
  if(isTRUE(grepl("application/json", req$ctype()))){
    #reparse JSON to avoid the deparsing of primitives from RPC post requests
    payload <- req$rawbody()
    if(is.raw(payload)){
      payload <- rawToChar(payload)
    }
  } else {
    #extract hook payload
    payload <- req$post()$payload;
    if(is.null(payload)){
      stop("No argument 'payload' posted.")
    }
  }

  #convert from JSON
  payload <- fromJSON(payload);

  #Post-Receive data
  gitref <- payload$ref;
  giturl <- payload$repository$url;
  gitrepo <- payload$repository$name;
  gitmaster <- payload$repository$master_branch;
  gituser <- tolower(payload$repository$owner$name);

  #Ignore all but master
  if(is.null(gitref) || is.na(gitref) || !length(gitref) || gitref != paste0("refs/heads/", gitmaster)){
    res$sendtext("Ignoring non-master branch.");
  }

  #Check for gihtub
  if(!grepl("^https://github.com", giturl)){
    stop("Currently only Github CI is supported.");
  }

  #trigger install and email
  do.call(webhook_install, c(list(payload = payload), repo = gitrepo, username = gituser, ref = gitmaster, req$get()))
}


webhook_install <- function(payload = NULL, sendmail = TRUE, ...){

  #install the package
  result <- github_install(...);

  #Send email results
  if(isTRUE(sendmail)) {
    tryCatch(mail_CI(result$success, result$output, payload), error = function(e){
      stop("Build successful but error when sending email (check SMTP server): ", e$message);
    });
  }

  #success
  res$sendtext(paste("CI Done. Build", ifelse(result$success, "successful", "failed")));
}
