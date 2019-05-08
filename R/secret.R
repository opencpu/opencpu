gitsecret <- function(){
  tryCatch({
    secretfile <- "/etc/opencpu/secret.conf";
    as.list(fromJSON(secretfile));
  }, error=function(e){
    return(NULL)
  })
}

github_token <- function(){
  # Method 1: secret file
  token <- gitsecret()$auth_token
  if(length(token) && nchar(token)){
    return(token)
  }
  # Method 2: env var
  pat <- Sys.getenv("GITHUB_PAT")
  if(nchar(pat))
    return(pat)
  NULL
}
