local({
  # Start background server
r <- file.path(R.home("bin"), "R")
on.exit(tools::pskill(pid, tools::SIGINT))
pid <- sys::exec_background(r, c("-e", "opencpu::ocpu_start_server()"))
Sys.sleep(3)

# Generic client
library(curl)
ocpu <- function(path, handle = new_handle(), server = 'http://localhost:5656/ocpu'){
  url <- file.path(server, path, fsep = "/")
  curl::curl_fetch_memory(url, handle = handle)
}

# Test post
req <- ocpu('/library/base/R/identity/print', new_handle(postfields = 'x=rnorm(10)'))
cat(rawToChar(req$content))

# Test post multipart
req <- ocpu('/library/base/R/identity/print', handle_setform(new_handle(), x = "rnorm(10)"))
cat(rawToChar(req$content))

# Test empty post
req <- ocpu('/library/utils/R/sessionInfo/print', new_handle(customrequest = 'POST'))
cat(rawToChar(req$content))

# Test multipart RDS object
handle <- handle_setform(new_handle(), object = form_data(serialize(iris, NULL), "application/rds"))
req <- ocpu('/library/base/R/summary/print', handle)
cat(rawToChar(req$content))

# Test multipart RProtoBuf object
handle <- handle_setform(new_handle(), object = form_data(protolite::serialize_pb(iris), "application/rprotobuf"))
req <- ocpu('/library/base/R/summary/print', handle)
cat(rawToChar(req$content))

# Test unspecified text types
handle <- handle_setform(new_handle(), x = form_data("some text blabla", "text/foobar"))
req <- ocpu('/library/base/R/identity/print', handle)
cat(rawToChar(req$content))

# Test unspecified binary types
handle <- handle_setform(new_handle(), x = form_data("some text blabla", "application/foobar"))
req <- ocpu('/library/base/R/identity/print', handle)
cat(rawToChar(req$content))

# Raw protobuf POST
buf <- protolite::serialize_pb(list(n = 3, mean = 100))
handle <- new_handle(postfields = buf)
handle_setheaders(handle, 'Content-Type' = 'application/rprotobuf')
req <- ocpu('/library/stats/R/rnorm/json', handle)
cat(rawToChar(req$content))



# Raw protobuf POST
con <- rawConnection(buf)
readfun <- function(n){readBin(con, raw(), n)}
handle <- new_handle(readfunction = readfun, upload = TRUE, customrequest = 'POST')
handle_setheaders(handle, 'Content-Type' = 'application/rprotobuf')
req <- ocpu('/library/stats/R/rnorm/json', handle)
cat(rawToChar(req$content))

})

