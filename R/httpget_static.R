httpget_static <- function(requri){
  #only GET
  res$checkmethod()

  #set cache value
  res$setcache("static")

  #send it
  testapp <- system.file('test', package = 'opencpu')
  res$sendfile(do.call(file.path, as.list(c(testapp, requri))))
}
