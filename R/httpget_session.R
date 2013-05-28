httpget_session <- function(filepath, requri){
  
  #make sure it exists
  res$checkfile(filepath);
  
  #reqhead is package api
  reqhead <- head(requri, 1);
  reqtail <- tail(requri, -1);    
  
  #dirlist
  if(!length(reqhead)){
    res$checkmethod();
    res$setheader("Location", req$uri());
    res$sendlist(session$list(filepath));
    
    myfiles <- vector();
    if(file.exists(file.path(filepath, ".RData"))){
      myfiles <- c(myfiles, "R");
    }
    if(file.exists(file.path(filepath, ".REval"))){
      myfiles <- c(myfiles, c("graphics", "report", "console", "source", "warnings", "messages", "stdout"));
    }
    if(file.exists(file.path(filepath, ".RInfo"))){
      myfiles <- c(myfiles, c("info"));
    }    
    if(length(list.files())){
      myfiles <- c(myfiles, "files")
    }
    res$setheader("Location", req$uri());
    res$sendlist(myfiles)
  }

  switch(reqhead,
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
     "report" = httpget_session_report(filepath, reqtail),
     stop("invalid session api: /session/",reqhead)
  );  
  
  #dispatch to regular methods:
  
}