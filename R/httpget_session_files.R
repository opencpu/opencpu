httpget_session_files <- function(filepath, requri){
  path <- do.call("file.path", as.list(c(filepath, requri)))
  assert_subdir(path, filepath)
  httpget_file(path)
}
