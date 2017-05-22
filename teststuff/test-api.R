# Generic client
ocpu <- function(path, ..., server = 'http://localhost:5656/ocpu'){
  url <- file.path(server, path, fsep = "/")
  curl::curl_fetch_memory(url, handle = curl::new_handle(...))
}


# Test post
req <- ocpu('/library/base/R/identity/print', postfields = 'x=rnorm(10)')
cat(rawToChar(req$content))

# Test empty post
req <- ocpu('/library/utils/R/sessionInfo/print', customrequest = 'POST')
cat(rawToChar(req$content))
