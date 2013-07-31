\docType{data}
\name{opencpu}
\alias{opencpu}
\title{The httpuv based single-user OpenCPU server.}
\format{Control object}
\description{
  This object controls the httpuv based OpenCPU server.
  This is the preferred method of running OpenCPU inside an
  R session. The server runs in a parallel process and does
  not interact with the current session.
}
\details{
  Note that this is a single user server. It is inteneded
  to be used by the local user, for running and developing
  apps. Because R is single-threaded, there is no support
  for concurrent http requests (but httpuv does a great job
  in queueing them). Also there are no security
  restrictions being enforced, as is the case for the
  OpenCPU cloud server.

  The OpenCPU server will automatically be started when the
  OpenCPU packge is attached. The OpenCPU API will be
  available at the root of the web server. For example:
  \url{http://localhost:12345/library/stats}.

  Once apps are working on the local OpenCPU server, they
  can easily be published using the OpenCPU cloud server.
}
\examples{
\dontrun{
opencpu$start(12345);
opencpu$restart()
opencpu$url()
opencpu$browse('library/stats/man/glm')
opencpu$stop()
}
}
\references{
  \url{www.opencpu.org}
}
\seealso{
  Other opencpu: \code{\link{rhttpd}}
}
\keyword{datasets}

