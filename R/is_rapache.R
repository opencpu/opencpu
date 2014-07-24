is_rapache <- function(){
  isTRUE(getOption("rapache"))
}

has_apparmor <- function(){
  isTRUE(getOption("apparmor"))
}

is_windows <- function(){
  grepl("mingw", R.Version()$platform)
}

is_mac <- function(){
  grepl("darwin", R.Version()$platform)
}
