execute_file <- function(filepath){
  res$checkfile(filepath);
  ext <- tail(strsplit(filepath, ".", fixed=TRUE)[[1]], 1);
  
  switch(ext,
    "R" = httppost_rscript(filepath),
    "Rnw" = httppost_knitr(filepath),
    "Rmd" = httppost_knitr(filepath),
    "brew" = httppost_brew(filepath),
    "pdr" = httppost_pander(filepath),
    "tex" = httppost_latex(filepath),     
    stop("Unsupported script type: ", ext)
  );
}