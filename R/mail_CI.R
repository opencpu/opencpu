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
  subject <- paste0("Build ", ifelse(success, "successful", "failed"), ": ", what, " (", after, ") ");
  
  #create commit(s) info
  timestamps <- strptime(payload$commits$timestamp, format="%Y-%m-%dT%H:%M:%S");
  messages <- payload$commits$message;
  commitinfo <- paste0(" - ", messages, " (", timestamps, ")", collapse="\n")
  
  #format first line
  if(success){
    msg <- paste0("Build ", after, " successful: ", config("public.url"), "/github/", what, "/");
  } else {
    msg <- paste("Build", after, "of", what, "failed. Either an error occured during package installation, or the package name does not match the name of the Github repository.");
  }
  
  #creat the body
  msg <- paste(msg, output, commitinfo, sep="\n\n")
  
  #try to send email
  email(to = to, from = from, subject = subject, msg = msg, control = list(smtpServer=config("smtp.server")))
}
