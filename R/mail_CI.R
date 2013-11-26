mail_CI <- function(success, output, gituser, gitrepo, gitemail, after) {
  success <- isTRUE(success);
  output <- paste(c("BUILD LOG:", output), sep="\n", collapse="\n");
  what <- paste(gituser, gitrepo, sep="/");
  from <- "noreply@opencpu.org";
  to <- gitemail;
  after <- substring(after, 1, 10);
  
  #compose subject
  subject <- paste0("[OpenCPU CI] ", what, " (", after, ") ", ifelse(success, "successful", "failed"));
  
  if(success){
    msg <- paste0("Build ", after, " successful: ", config("public.url"), "/github/", what, "/");
  } else {
    msg <- paste("Build", after, "of", what, "failed. Either an error occured during package installation, or the package name does not match the name of the Github repository.");
  }
  
  #creat the body
  body <- paste(msg, output, sep="\n\n")
  
  #try to send email
  sendmail <- from("sendmailR", "sendmail");
  sendmail(from, to, subject, body, control=list(smtpServer=config("smtp.server")))
}
