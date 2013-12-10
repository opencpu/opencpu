email <- function(to, ...){
  sendmail <- from("sendmailR", "sendmail");
  lapply(to, function(rcpt){
    sendmail(to = rcpt, ...);
  })
}

address <- function(name, mail){
  paste0('"', name, '"<', mail, '>');
}