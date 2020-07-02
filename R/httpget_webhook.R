httpget_webhook <- function(){
  if(req$method() == "GET"){
    res$sendtext(paste0(
      "To enable CI, add the following URL as a 'WebHook' in your Github repository:\n\n  ",
      public_url(), "/webhook?sendmail=true\n\nSee also https://help.github.com/articles/post-receive-hooks."));
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
    res$sendtext(sprintf("Ignoring non-master: %s (default/master branch is '%s')", gitref, gitmaster))
  }

  #Check for gihtub
  if(!grepl("^https://github.com", giturl)){
    stop("Currently only Github CI is supported.");
  }

  #trigger install and email
  do.call(webhook_install, c(list(payload = payload), repo = gitrepo, username = gituser, ref = gitmaster, req$get()))
}


webhook_install <- function(payload = NULL, sendmail = TRUE, mail_owner = TRUE, ...){

  #install the package
  result <- github_install(...)

  #Send email results
  if(isTRUE(sendmail)) {

    #formulate email message
    email_args <- create_email(result$success, result$output, payload, mail_owner)
    email_args$smtp_server = config("smtp.server")
    email_args$use_ssl <- tryCatch({
      config("smtp.use.ssl")
    }, error = function(e){'no'})

    # try to send it
    tryCatch(do.call(send_email, email_args), error = function(e){
      errmsg <- sprintf("Build successful but error when sending email to %s (bcc: %s) (check SMTP server): %s",
                        collapse(email_args$to), collapse(email_args$bcc), collapse(e$message))
      res$setbody(errmsg)
      res$finish(503)
    })
  }

  #success
  res$sendtext(paste("CI Done. Build", ifelse(result$success, "successful", "failed")))
}

trigger_webhook <- function(repo = 'rwebapps/appdemo', url = 'http://localhost:5656/ocpu/webhook', email = 'jeroen@opencpu.org'){
  info <- parse_git_repo(repo)
  payload <- list(
    ref = url_path("refs/heads", info$ref),
    repository = list(
      after = "0000000000",
      url = url_path("https://github.com", info$username, info$repo),
      name = info$repo,
      master_branch = info$ref,
      owner = list(
        name = info$username
      )
    ),
    pusher = list(
      name = "test pusher",
      email = email
    ),
    commits = data.frame()
  )
  postdata <- jsonlite::toJSON(payload, auto_unbox = TRUE)
  handle <- curl::new_handle(copypostfields = postdata)
  curl::handle_setheaders(handle, "Content-Type" = "application/json")
  req <- curl::curl_fetch_memory(url, handle = handle)
  list(
    status = req$status,
    body = rawToChar(req$content)
  )
}
