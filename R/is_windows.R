is_windows <- function(){
  grepl("mingw", R.Version()$platform)
}

is_mac <- function(){
  grepl("darwin", R.Version()$platform)
}
