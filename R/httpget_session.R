httpget_session <- function(filepath, requri){
  
  #make sure it exists
  res$checkfile(filepath);
  
  #enter the session path
  setwd(filepath);
  
  #reqhead is package api
  reqhead <- head(requri, 1);
  reqtail <- tail(requri, -1);    
  
  #list the session contents
  if(!length(reqhead)){
    res$checkmethod();
    res$sendlist(session$index(filepath));
  }

  switch(reqhead,
     #"report" = httpget_session_report(filepath, reqtail),         
     "R" = httpget_session_r(filepath, reqtail),
     "graphics" = httpget_session_graphics(filepath, reqtail),
     "files" = httpget_session_files(filepath, reqtail),
     "source" = httpget_session_source(filepath, reqtail),
     "console" = httpget_session_console(filepath, reqtail),
     "warnings" = httpget_session_warnings(filepath, reqtail),
     "messages" = httpget_session_messages(filepath, reqtail),   
     "stdout" = httpget_session_stdout(filepath, reqtail),
     "info" = httpget_session_info(filepath, reqtail),
     "zip" = httpget_session_zip(filepath, reqtail),
     "tar" = httpget_session_tar(filepath, reqtail),
     stop("invalid session api: /session/",reqhead)
  );  
}