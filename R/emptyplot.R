emptyplot <- local({
  isR3 = getRversion() >= '3.0.0';
  
  plot_calls = if (isR3) {
    function(plot) {
      el = lapply(plot[[1]], '[[', 2)
      if (length(el) == 0) return()
      sapply(el, function(x) {
        x = x[[1]];
        if(is.null(x[['name']])){
          return(deparse(x));
        } else {
          return(x[['name']]);
        };
      });
    }
  } else evaluate:::plot_calls
  
  nonempty_plot <- if (isR3) {
    function(myplot) {
      pc <- plot_calls(myplot);  
      empty_calls <- c('C_par', 'C_layout', 'palette', 'palette2');
      !all(pc %in% empty_calls);
    }
  } else {
    function(myplot) {
      pc <- plot_calls(myplot); 
      empty_calls <- c('layout', 'par');
      identical(pc, 'recordGraphics') || identical(pc, 'persp') || (length(pc) > 1L && !all(pc %in% empty_calls));
    }
  }
  function(myplot){
    if(!inherits(myplot, "recordedplot")) return(FALSE);
    identical(FALSE, try(nonempty_plot(myplot), silent=TRUE));
  }
});

#test run:
#library(evaluate)
#out <- evaluate("plot(iris)\n");
#lapply(out, is);
#lapply(out, emptyplot);
