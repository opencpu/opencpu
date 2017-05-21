# same as iptools::ip_in_range()
ip_in_range <- function(ip, range){
  ipval <- ip_value(ip)
  rangeval <- ip_range(range)
  return(ipval >= rangeval[1] && ipval <= rangeval[2])
}

ip_value <- function(ip){
  stopifnot(grepl("^(\\d{1,3})(\\.\\d{1,3}){3}$", ip))
  values <- as.numeric(strsplit(ip, ".", fixed = TRUE)[[1]])
  stopifnot(all(values < 256))
  sum(values * 256^(3:0))
}

ip_range <- function(range){
  parts <- strsplit(range, "/", fixed = TRUE)[[1]]
  stopifnot(length(parts) == 2)
  start <- ip_value(parts[1])
  mask <- as.numeric(parts[[2]])
  end <- start + 2^(32 - mask) - 1
  c(start, end)
}
