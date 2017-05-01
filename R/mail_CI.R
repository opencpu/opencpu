mail_CI <- function(success, output, payload) {
  #get some fields from the payload
  gituser <- payload$repository$owner$name;
  gitrepo <- payload$repository$name;
  gitemail <- payload$repository$owner$email;
  after <- substring(payload$after, 1, 10);

  #email fields
  success <- isTRUE(success);
  output <- paste(c("BUILD LOG:", output), sep="\n", collapse="\n");
  what <- paste(gituser, gitrepo, sep="/");
  from <- "\"OpenCPU CI\"<noreply@opencpu.org>";

  #who to send the mail to
  ownermail <- address(payload$repository$owner$name, payload$repository$owner$email);
  pushermail <- address(payload$pusher$name, payload$pusher$email);

  #send email to pusher and owner (but not twice if the same)
  to <- if(is.null(payload$pusher$email)){
    ownermail;
  } else if(identical(payload$repository$owner$email, payload$pusher$email)) {
    pushermail;
  } else {
    c(pushermail, ownermail);
  }

  #also mail to mailing list
  to <- c(to, address("OpenCPU CI Mailing List", "opencpu-ci@googlegroups.com"))

  #compose subject
  subject <- paste0("Build ", ifelse(success, "successful", "failed"), ": ", what);

  #create commit(s) info
  ids <- paste0("[", substring(payload$commits$id, 1, 10), "]")
  authors <- paste("Author:", payload$commits$author$name)
  timestamps <- paste("Time:", strptime(payload$commits$timestamp, format="%Y-%m-%dT%H:%M:%S"));
  messages <- paste0("Message: \"", payload$commits$message, "\"");
  urls <- paste("URL:", payload$commits$url);
  commitinfo <- paste("NEW COMMITS:", paste(ids, timestamps, authors, messages, urls, "", collapse="\n", sep="\n  "), sep="\n")

  #create sessionInfo
  mysession <- paste("SESSION INFO", paste0(utils::capture.output(utils::sessionInfo()), collapse="\n"), sep="\n")
  commitname <- paste0(gituser, "/", gitrepo, "@", after)

  #format first line
  msg <- if(success){
    if(identical("dev.opencpu.org", try(system("hostname", intern=TRUE)))){
      paste0("Build ", commitname, " successful: https://", gituser, ".ocpu.io/", gitrepo, "/");
    } else {
      paste0("Build ", commitname, " successful: ", config("public.url"), "/github/", what, "/");
    }
  } else {
    paste("Build", commitname, "failed. Either an error occured during package installation, or the package name does not match the name of the Github repository.");
  }

  #creat the body
  msg <- paste(msg, commitinfo, output, mysession, sep="\n\n")

  #try to send email
  email(to = to, from = from, subject = subject, msg = msg, control = list(smtpServer=config("smtp.server")))
}
