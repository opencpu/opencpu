library(parallel)
library(httpuv)

runServer("0.0.0.0", 12345, list(call=function(req){
  myfork <- mcparallel({
    library(RCurl);
    getURL("https://api.github.com")
  })
  
  out <- mccollect()[[1]];
  
  list(
    status = 200,
    headers = c("Content-Type"="text/plain"),
    body = out
  );
  
}));

#open browser to http://localhost:12345/
#press ESC to terminate server

