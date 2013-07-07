config <- function(x){
  switch(x,
    "job.timeout" = 60,
    "time.limit" = 90,
    "gist.cache" = 5*60,
    "github.cache" = 60*60,
    "httpcache.post" = 5*60,
    "httpcache.lib" = 60*60*24,  
    "httpcache.git" = 60*60,
    "httpcache.tmp" = 60*60*24,        
    "httpcache.pages" = 60*60*24,          
    "session.prefix" = "ocpu_tmp_",
    "appspaths" = c("/usr/local/lib/opencpu/apps-library"),
    "repos" = "http://cran.rstudio.com",
    "tmpdir" = "/tmp",
    "libpaths" = list(),
    "preload" = list(),
    stop("invalid config entry: ", x)
  );
}
