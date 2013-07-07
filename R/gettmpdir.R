gettmpdir <- local({
  mytmpdir <- NULL;
  
  function(){
    if(is.null(mytmpdir)){
      myusername <- Sys.info()[["effective_user"]];
      newtmpdir <- file.path(roottmpdir(), paste("ocpu", myusername, sep="-"));
      if(!file.exists(newtmpdir)){
        dir.create(newtmpdir, recursive=TRUE);
      }
      mytmpdir <<- newtmpdir;
    }
    mytmpdir
  }
});

roottmpdir <- function() {
  tm <- Sys.getenv(c('TMPDIR', 'TMP', 'TEMP'))
  d <- which(file.info(tm)$isdir & file.access(tm, 2) == 0)
  if (length(d) > 0)
    tm[[d[1]]]
  else if (.Platform$OS.type == 'windows')
    Sys.getenv('R_USER')
  else
    '/tmp'
}
