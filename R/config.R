config <- function(x){
	switch(x,
		"job.timeout" = 60,
		"time.limit" = 90,
    "gist.cache" = 120,
    "github.cache" = 60*60,
    "session.prefix" = "ocpu_session_",
    "appspaths" = c("/usr/local/lib/opencpu/apps-library"),
		"repos" = "http://cran.r-project.org",
    "tmpdir" = "/tmp",
		"libpaths" = list(),
		"preload" = list(),
		stop("invalid config entry: ", x)
	);
}