evaluate <- local({
  # Stringr code
  
  # Check that string is of the correct type for stringr functions
  check_string <- function(string) {
    if (!is.atomic(string))
      stop("String must be an atomic vector", call. = FALSE)
    if (!is.character(string))
      string <- as.character(string)
    string
  }
  # Check that pattern is of the correct type for stringr functions
  check_pattern <- function(pattern, string, replacement = NULL) {
    if (!is.character(pattern))
      stop("Pattern must be a character vector", call. = FALSE)
    if (!recyclable(string, pattern, replacement)) {
      stop("Lengths of string and pattern not compatible")
    }
    pattern
  }
  str_count <- function(string, pattern) {
    if (length(string) == 0) return(character())
    string <- check_string(string)
    pattern <- check_pattern(pattern, string)
    if (length(pattern) == 1) {
      matches <- re_call("gregexpr", string, pattern)
    } else {
      matches <- unlist(re_mapply("gregexpr", string, pattern),
                        recursive = FALSE)
    }
    match_length <- function(x) {
      len <- length(x)
      if (len > 1) return(len)
      if (identical(c(x), -1L)) 0L else 1L
    }
    vapply(matches, match_length, integer(1))
  }
  str_c <- str_join <- function(..., sep = "", collapse = NULL) {
    strings <- Filter(function(x) length(x) > 0, list(...))
    atomic <- vapply(strings, is.atomic, logical(1))
    if (!all(atomic)) {
      stop("Input to str_c should be atomic vectors", call. = FALSE)
    }
    do.call("paste", c(strings, list(sep = sep, collapse = collapse)))
  }
  str_detect <- function(string, pattern) {
    string <- check_string(string)
    pattern <- check_pattern(pattern, string)
    if (length(pattern) == 1) {
      results <- re_call("grepl", string, pattern)
    } else {
      results <- unlist(re_mapply("grepl", string, pattern))
    }
    is.na(results) <- is.na(string)
    results
  }
  str_dup <- function(string, times) {
    string <- check_string(string)
    # Use data frame to do recycling
    data <- data.frame(string, times)
    n <- nrow(data)
    string <- data$string
    times <- data$times
    output <- vapply(seq_len(n), function(i) {
      paste(rep.int(string[i], times[i]), collapse = "")
    }, character(1))
    names(output) <- names(string)
    output
  }
  str_extract <- function(string, pattern) {
    string <- check_string(string)
    pattern <- check_pattern(pattern, string)
    positions <- str_locate(string, pattern)
    str_sub(string, positions[, "start"], positions[, "end"])
  }
  str_extract_all <- function(string, pattern) {
    string <- check_string(string)
    pattern <- check_pattern(pattern, string)
    positions <- str_locate_all(string, pattern)
    lapply(seq_along(string), function(i) {
      position <- positions[[i]]
      str_sub(string[i], position[, "start"], position[, "end"])
    })
  }
  str_length <- function(string) {
    string <- check_string(string)
    nc <- nchar(string, allowNA = TRUE)
    is.na(nc) <- is.na(string)
    nc
  }
  #
  str_locate <- function(string, pattern) {
    string <- check_string(string)
    pattern <- check_pattern(pattern, string)
    if (length(pattern) == 1) {
      results <- re_call("regexpr", string, pattern)
      match_to_matrix(results)
    } else {
      results <- re_mapply("regexpr", string, pattern)
      out <- t(vapply(results, match_to_matrix, integer(2)))
      colnames(out) <- c("start", "end")
      out
    }
  }
  str_locate_all <- function(string, pattern) {
    string <- check_string(string)
    pattern <- check_pattern(pattern, string)
    if (length(pattern) == 1) {
      matches <- re_call("gregexpr", string, pattern)
    } else {
      matches <- unlist(re_mapply("gregexpr", string, pattern),
                        recursive = FALSE)
    }
    lapply(matches, match_to_matrix, global = TRUE)
  }
  # Convert annoying regexpr format to something more useful
  match_to_matrix <- function(match, global = FALSE) {
    if (global && length(match) == 1 && (is.na(match) || match == -1)) {
      null <- matrix(0, nrow = 0, ncol = 2)
      colnames(null) <- c("start", "end")
      return(null)
    }
    start <- as.vector(match)
    start[start == -1] <- NA
    end <- start + attr(match, "match.length") - 1L
    cbind(start = start, end = end)
  }
  invert_match <- function(loc) {
    cbind(
      start = c(0L, loc[, "end"] + 1L),
      end = c(loc[, "start"] - 1L, -1L)
    )
  }
  str_match <- function(string, pattern) {
    string <- check_string(string)
    pattern <- check_pattern(pattern, string)
    if (length(string) == 0) return(character())
    matcher <- re_call("regexec", string, pattern)
    matches <- regmatches(string, matcher)
    # Figure out how many groups there are and coerce into a matrix with
    # nmatches + 1 columns
    tmp <- str_replace_all(pattern, "\\\\\\(", "")
    n <- str_length(str_replace_all(tmp, "[^(]", "")) + 1
    len <- vapply(matches, length, integer(1))
    matches[len == 0] <- rep(list(rep(NA_character_, n)), sum(len == 0))
    do.call("rbind", matches)
  }
  str_match_all <- function(string, pattern) {
    matches <- str_extract_all(string, pattern)
    lapply(matches, function(match) {
      str_match(match, pattern)
    })
  }
  fixed <- function(string) {
    if (is.perl(string)) message("Overriding Perl regexp matching")
    structure(string, fixed = TRUE)
  }
  is.fixed <- function(string) {
    fixed <- attr(string, "fixed")
    if (is.null(fixed)) FALSE else fixed
  }
  ignore.case <- function(string) {
    structure(string, ignore.case = TRUE)
  }
  case.ignored <- function(string) {
    ignore.case <- attr(string, "ignore.case")
    if (is.null(ignore.case)) FALSE else ignore.case
  }
  perl <- function(string) {
    if (is.fixed(string)) message("Overriding fixed matching")
    structure(string, perl = TRUE)
  }
  is.perl <- function(string) {
    perl <- attr(string, "perl")
    if (is.null(perl)) FALSE else perl
  }
  str_pad <- function(string, width, side = "left", pad = " ") {
    string <- check_string(string)
    stopifnot(length(width) == 1)
    stopifnot(length(side) == 1)
    stopifnot(length(pad) == 1)
    if (str_length(pad) != 1) {
      stop("pad must be single character single")
    }
    side <- match.arg(side, c("left", "right", "both"))
    needed <- pmax(0, width - str_length(string))
    left <- switch(side,
                   left = needed, right = 0, both = floor(needed / 2))
    right <- switch(side,
                    left = 0, right = needed, both = ceiling(needed / 2))
    # String duplication is slow, so only do the absolute necessary
    lengths <- unique(c(left, right))
    padding <- str_dup(pad, lengths)
    str_c(padding[match(left, lengths)], string, padding[match(right, lengths)])
  }
  str_trim <- function(string, side = "both") {
    string <- check_string(string)
    stopifnot(length(side) == 1)
    side <- match.arg(side, c("left", "right", "both"))
    pattern <- switch(side, left = "^\\s+", right = "\\s+$",
                      both = "^\\s+|\\s+$")
    str_replace_all(string, pattern, "")
  }
  str_replace <- function(string, pattern, replacement) {
    string <- check_string(string)
    pattern <- check_pattern(pattern, string, replacement)
    if (length(pattern) == 1 && length(replacement) == 1) {
      re_call("sub", string, pattern, replacement)
    } else {
      unlist(re_mapply("sub", string, pattern, replacement))
    }
  }
  str_replace_all <- function(string, pattern, replacement) {
    string <- check_string(string)
    pattern <- check_pattern(pattern, string, replacement)
    if (length(pattern) == 1 && length(replacement) == 1) {
      re_call("gsub", string, pattern, replacement)
    } else {
      unlist(re_mapply("gsub", string, pattern, replacement))
    }
  }
  str_split_fixed <- function(string, pattern, n) {
    if (length(string) == 0) {
      return(matrix(character(), nrow = 0, ncol = n))
    }
    string <- check_string(string)
    pattern <- check_pattern(pattern, string)
    if (!is.numeric(n) || length(n) != 1) {
      stop("n should be a numeric vector of length 1")
    }
    if (n == Inf) {
      stop("n must be finite", call. = FALSE)
    } else if (n == 1) {
      matrix(string, ncol = 1)
    } else {
      locations <- str_locate_all(string, pattern)
      do.call("rbind", lapply(seq_along(locations), function(i) {
        location <- locations[[i]]
        string <- string[i]
        pieces <- min(n - 1, nrow(location))
        cut <- location[seq_len(pieces), , drop = FALSE]
        keep <- invert_match(cut)
        padding <- rep("", n - pieces - 1)
        c(str_sub(string, keep[, 1], keep[, 2]), padding)
      }))
    }
  }
  str_split <- function(string, pattern, n = Inf) {
    if (length(string) == 0) return(list())
    string <- check_string(string)
    pattern <- check_pattern(pattern, string)
    if (!is.numeric(n) || length(n) != 1) {
      stop("n should be a numeric vector of length 1")
    }
    if (n == 1) {
      as.list(string)
    } else {
      locations <- str_locate_all(string, pattern)
      pieces <- function(mat, string) {
        cut <- mat[seq_len(min(n - 1, nrow(mat))), , drop = FALSE]
        keep <- invert_match(cut)
        str_sub(string, keep[, 1], keep[, 2])
      }
      mapply(pieces, locations, string,
             SIMPLIFY = FALSE, USE.NAMES = FALSE)
    }
  }
  str_sub <- function(string, start = 1L, end = -1L) {
    if (length(string) == 0L || length(start) == 0L || length(end) == 0L) {
      return(vector("character", 0L))
    }
    string <- check_string(string)
    n <- max(length(string), length(start), length(end))
    string <- rep(string, length = n)
    start <- rep(start, length = n)
    end <- rep(end, length = n)
    # Convert negative values into actual positions
    len <- str_length(string)
    neg_start <- !is.na(start) & start < 0L
    start[neg_start] <- start[neg_start] + len[neg_start] + 1L
    neg_end <- !is.na(end) & end < 0L
    end[neg_end] <- end[neg_end] + len[neg_end] + 1L
    substring(string, start, end)
  }
  #
  "str_sub<-" <- function(string, start = 1L, end = -1L, value) {
    str_c(
      str_sub(string, end = start - 1L),
      value,
      ifelse(end == -1L, "", str_sub(string, start = end + 1L)))
  }
  compact <- function(l) Filter(Negate(is.null), l)
  # General wrapper around sub, gsub, regexpr, gregexpr, grepl.
  # Vectorises with pattern and replacement, and uses fixed and ignored.case
  # attributes.
  re_call <- function(f, string, pattern, replacement = NULL) {
    args <- list(pattern, replacement, string,
                 fixed = is.fixed(pattern), ignore.case = case.ignored(pattern),
                 perl = is.perl(pattern))
    if (!("perl" %in% names(formals(f)))) {
      if (args$perl) message("Perl regexps not supported by ", f)
      args$perl <- NULL
    }
    do.call(f, compact(args))
  }
  re_mapply <- function(f, string, pattern, replacement = NULL) {
    args <- list(
      FUN = f, SIMPLIFY = FALSE, USE.NAMES = FALSE,
      pattern, replacement, string,
      MoreArgs = list(
        fixed = is.fixed(pattern),
        ignore.case = case.ignored(pattern))
    )
    do.call("mapply", compact(args))
  }
  # Check if a set of vectors is recyclable.
  # Ignores zero length vectors.  Trivially TRUE if all inputs are zero length.
  recyclable <- function(...) {
    lengths <- vapply(list(...), length, integer(1))
    lengths <- lengths[lengths != 0]
    if (length(lengths) == 0) return(TRUE)
    all(max(lengths) %% lengths == 0)
  }
  word <- function(string, start = 1L, end = start, sep = fixed(" ")) {
    n <- max(length(string), length(start), length(end))
    string <- rep(string, length = n)
    start <- rep(start, length = n)
    end <- rep(end, length = n)
    breaks <- str_locate_all(string, sep)
    words <- lapply(breaks, invert_match)
    # Convert negative values into actual positions
    len <- vapply(words, nrow, integer(1))
    neg_start <- !is.na(start) & start < 0L
    start[neg_start] <- start[neg_start] + len[neg_start] + 1L
    neg_end <- !is.na(end) & end < 0L
    end[neg_end] <- end[neg_end] + len[neg_end] + 1L
    # Extract locations
    starts <- mapply(function(word, loc) word[loc, "start"], words, start)
    ends <-   mapply(function(word, loc) word[loc, "end"], words, end)
    str_sub(string, starts, ends)
  }
  str_wrap <- function(string, width = 80, indent = 0, exdent = 0) {
    string <- check_string(string)
    pieces <- strwrap(string, width, indent, exdent, simplify = FALSE)
    unlist(lapply(pieces, str_c, collapse = "\n"))
  }
  
  
  local({
    #evaluate code

    evaluate <- function(input, envir = parent.frame(), enclos = NULL, debug = FALSE,
                         stop_on_error = 0L, new_device = TRUE,
                         output_handler = new_output_handler()) {
      parsed <- parse_all(input)
      
      stop_on_error <- as.integer(stop_on_error)
      stopifnot(length(stop_on_error) == 1)
      
      if (is.null(enclos)) {
        enclos <- if (is.list(envir) || is.pairlist(envir)) parent.frame() else baseenv()
      }
      
      if (new_device) {
        # Start new graphics device and clean up afterwards
        dev.new()
        dev <- dev.cur()
        on.exit(dev.off(dev))
      }
      
      out <- vector("list", nrow(parsed))
      for (i in seq_along(out)) {
        expr <- parsed$expr[[i]]
        if (!is.null(expr))
          expr <- as.expression(expr)
        out[[i]] <- evaluate_call(
          expr, parsed$src[[i]],
          envir = envir, enclos = enclos, debug = debug, last = i == length(out),
          use_try = stop_on_error != 2L,
          output_handler = output_handler)
        
        if (stop_on_error > 0L) {
          errs <- vapply(out[[i]], is.error, logical(1))
          
          if (!any(errs)) next
          if (stop_on_error == 1L) break
          
          err <- out[[i]][errs][[1]]
          stop(err)
        }
      }
      
      unlist(out, recursive = FALSE, use.names = FALSE)
    }
    
    evaluate_call <- function(call, src = NULL,
                              envir = parent.frame(), enclos = NULL,
                              debug = FALSE, last = FALSE, use_try = FALSE,
                              output_handler = new_output_handler()) {
      if (debug) message(src)
      
      if (is.null(call)) {
        return(list(new_source(src)))
      }
      stopifnot(is.call(call) || is.language(call) || is.atomic(call))
      
      # Capture output
      w <- watchout(debug)
      on.exit(w$close())
      source <- new_source(src)
      output_handler$source(source)
      output <- list(source)
      
      handle_output <- function(plot = FALSE, incomplete_plots = FALSE) {
        out <- w$get_new(plot, incomplete_plots)
        if (!is.null(out$text))
          output_handler$text(out$text)
        if (!is.null(out$graphics))
          output_handler$graphics(out$graphics)
        output <<- c(output, out)
      }
      
      # Hooks to capture plot creation
      capture_plot <- function() {
        handle_output(TRUE)
      }
      old_hooks <- set_hooks(list(
        persp = capture_plot,
        before.plot.new = capture_plot,
        before.grid.newpage = capture_plot))
      on.exit(set_hooks(old_hooks, "replace"), add = TRUE)
      
      handle_condition <- function(cond) {
        handle_output()
        output <<- c(output, list(cond))
      }
      
      # Handlers for warnings, errors and messages
      wHandler <- function(wn) {
        handle_condition(wn)
        output_handler$warning(wn)
        invokeRestart("muffleWarning")
      }
      eHandler <- function(e) {
        handle_condition(e)
        output_handler$error(e)
      }
      mHandler <- function(m) {
        handle_condition(m)
        output_handler$message(m)
        invokeRestart("muffleMessage")
      }
      
      ev <- list(value = NULL, visible = FALSE)
      
      if (use_try) {
        handle <- function(f) try(f, silent = TRUE)
      } else {
        handle <- force
      }
      handle(ev <- withCallingHandlers(
        withVisible(eval(call, envir, enclos)),
        warning = wHandler, error = eHandler, message = mHandler))
      handle_output(TRUE)
      
      # If visible, process and capture output
      if (ev$visible) {
        pv <- list(value = NULL, visible = FALSE)
        handle(pv <- withCallingHandlers(withVisible(output_handler$value(ev$value)),
                                         warning = wHandler, error = eHandler, message = mHandler))
        handle_output(TRUE)
        # If return value visible, print and capture output
        if (pv$visible) {
          handle(withCallingHandlers(print(pv$value),
                                     warning = wHandler, error = eHandler, message = mHandler))
          handle_output(TRUE)
        }
      }
      
      # Always capture last plot, even if incomplete
      if (last) {
        handle_output(TRUE, TRUE)
      }
      
      output
    }
    
    #" Capture snapshot of current device.
    #"
    #" There"s currently no way to capture when a graphics device changes,
    #" except to check its contents after the evaluation of every expression.
    #" This means that only the last plot of a series will be captured.
    #"
    #" @return \code{NULL} if plot is blank or unchanged, otherwise the output of
    #"   \code{\link[grDevices]{recordPlot}}.
    plot_snapshot <- local({
      last_plot <- NULL
      
      function(incomplete = FALSE) {
        if (is.null(dev.list())) return(NULL)
        
        pos <- par("mfg")[1:2]
        size <- par("mfg")[3:4]
        if (!incomplete && !identical(pos, size)) return(NULL)
        
        plot <- recordPlot()
        if (is_par_change(last_plot, plot) || identical(last_plot, plot)) {
          return(NULL)
        }
        
        if (is.empty(plot)) return(NULL)
        last_plot <<- plot
        plot
      }
    })
    
    is_par_change <- function(p1, p2) {
      calls1 <- plot_calls(p1)
      calls2 <- plot_calls(p2)
      
      n1 <- length(calls1)
      n2 <- length(calls2)
      
      if (n2 <= n1) return(FALSE)
      if (!identical(calls1, calls2[1:n1])) return(FALSE)
      
      last <- calls2[(n1 + 1):n2]
      all(last %in% c("layout", "par"))
    }
    
    
    par_added <- function(a, b) {
      n_a <- length(a[[1]])
      n_b <- length(b[[1]])
      
      # Has more than one additional element
      if (n_a != n_b - 1) return(FALSE)
      
      
      
      lapply(plot[[1]], "[[", 1)
    }
    
    is.empty <- function(x) {
      if(is.null(x)) return(TRUE)
      
      drawing <- setdiff(plot_calls(x), c("plot.new", "plot.window", "par"))
      length(drawing) == 0
    }
    
    plot_calls <- function(plot) {
      prims <- lapply(plot[[1]], "[[", 1)
      if (length(prims) == 0) return()
      
      chars <- sapply(prims, deparse)
      str_replace_all(chars, ".Primitive\\(\"|\"\\)", "")
    }
    set_hooks <- function(hooks, action = "append") {
      stopifnot(is.list(hooks))
      stopifnot(!is.null(names(hooks)) && all(names(hooks) != ""))
      
      old <- list()
      for (hook_name in names(hooks)) {
        old[[hook_name]] <- getHook(hook_name)
        setHook(hook_name, hooks[[hook_name]], action = action)
      }
      
      invisible(old)
    }
    is.message <- function(x) inherits(x, "message")
    is.warning <- function(x) inherits(x, "warning")
    is.error <- function(x) inherits(x, "error")
    is.value <- function(x) inherits(x, "value")
    is.source <- function(x) inherits(x, "source")
    is.recordedplot <- function(x) inherits(x, "recordedplot")
    
    new_value <- function(value, visible = TRUE) {
      structure(list(value = value, visible = visible), class = "value")
    }
    
    new_source <- function(src) {
      structure(list(src = src), class = "source")
    }
    
    classes <- function(x) vapply(x, function(x) class(x)[1], character(1))
    
    render <- function(x) if (isS4(x)) show(x) else print(x)
    
    new_output_handler <- function(source = identity,
                                   text = identity, graphics = identity,
                                   message = identity, warning = identity,
                                   error = identity, value = render) {
      source <- match.fun(source)
      stopifnot(length(formals(source)) >= 1)
      text <- match.fun(text)
      stopifnot(length(formals(text)) >= 1)
      graphics <- match.fun(graphics)
      stopifnot(length(formals(graphics)) >= 1)
      message <- match.fun(message)
      stopifnot(length(formals(message)) >= 1)
      warning <- match.fun(warning)
      stopifnot(length(formals(warning)) >= 1)
      error <- match.fun(error)
      stopifnot(length(formals(error)) >= 1)
      value <- match.fun(value)
      stopifnot(length(formals(value)) >= 1)
      
      structure(list(source = source, text = text, graphics = graphics,
                     message = message, warning = warning, error = error,
                     value = value),
                class = "output_handler")
    }
    parse_all <- function(x) UseMethod("parse_all")
    
    parse_all.character <- function(x) {
      x <- unlist(str_split(x, "\n"), recursive = FALSE, use.names = FALSE)
      src <- srcfilecopy("<text>", x)
      
      expr <- parse(text = x, srcfile = src)
      # No code, all comments
      if (length(expr) == 0) {
        n <- length(x)
        return(data.frame(
          x1 = seq_along(x), x2 = seq_along(x),
          y1 = rep(0, n), y2 = nchar(x),
          src = x, text = rep(TRUE, n),
          expr = I(rep(list(NULL), n)), visible = rep(FALSE, n),
          stringsAsFactors = FALSE
        ))
      }
      
      srcref <- attr(expr, "srcref")
      srcfile <- attr(srcref[[1]], "srcfile")
      
      # Create data frame containing each expression and its
      # location in the original source
      src <- sapply(srcref, function(src) str_c(as.character(src), collapse="\n"))
      pos <- t(sapply(srcref, unclass))[, 1:4, drop = FALSE]
      colnames(pos) <- c("x1", "y1", "x2", "y2")
      pos <- as.data.frame(pos)[c("x1","y1","x2","y2")]
      
      parsed <- data.frame(
        pos, src=src, expr=I(as.list(expr)), text = FALSE,
        stringsAsFactors = FALSE
      )
      # Extract unparsed text ----------------------------------------------------
      # Unparsed text includes:
      #  * text before first expression
      #  * text between expressions
      #  * text after last expression
      #
      # Unparsed text does not contain any expressions, so can
      # be split into individual lines
      
      get_region <- function(x1, y1, x2, y2) {
        string <- getSrcRegion(srcfile, x1, x2, y1, y2)
        lines <- strsplit(string, "(?<=\n)", perl=TRUE)[[1]]
        n <- length(lines)
        if (n == 0) {
          lines <- ""
          n <- 1
        }
        
        data.frame(
          x1 = x1 + seq_len(n) - 1, y1 = c(y1, rep(1, n - 1)),
          x2 = x1 + seq_len(n), y2 = rep(1, n),
          src = lines,
          expr = I(rep(list(NULL), n)),
          stringsAsFactors=FALSE
        )
      }
      breaks <- data.frame(
        x1 = c(1, parsed[, "x2"]),
        y1 = c(1, parsed[, "y2"] + 1),
        x2 = c(parsed[1, "x1"], parsed[-1, "x1"], Inf),
        y2 = c(parsed[, "y1"], Inf)
      )
      unparsed <- do.call("rbind",
                          apply(breaks, 1, function(row) do.call("get_region", as.list(row)))
      )
      unparsed <- subset(unparsed, src != "")
      
      if (nrow(unparsed) > 0) {
        unparsed$text <- TRUE
        all <- rbind(parsed, unparsed)
      } else {
        all <- parsed
      }
      all <- all[do.call("order", all[,c("x1","y1", "x2","y2")]), ]
      
      all$eol <- FALSE
      all$eol[grep("\n$", all$src)] <- TRUE
      
      # Join lines ---------------------------------------------------------------
      # Expressions need to be combined to create a complete line
      # Some expressions already span multiple lines, and these should be
      # left alone
      
      join_pieces <- function(df) {
        clean_expr <- Filter(Negate(is.null), as.list(df$expr))
        if (length(clean_expr) == 0) {
          clean_expr <- list(NULL)
        } else {
          clean_expr <- list(clean_expr)
        }
        
        with(df, data.frame(
          src = str_c(src, collapse = ""),
          expr = I(clean_expr),
          stringsAsFactors = FALSE
        ))
      }
      block <- c(0, cumsum(all$eol)[-nrow(all)])
      lines <- split(all, block)
      do.call("rbind", lapply(lines, join_pieces))
    }
    
    
    parse_all.connection <- function(x) {
      if (!isOpen(x, "r")) {
        open(x, "r")
        on.exit(close(x))
      }
      text <- readLines(x)
      parse_all(text)
    }
    
    parse_all.function <- function(x) {
      src <- attr(x, "source")
      # Remove first, function() {,  and last lines, }
      n <- length(src)
      parse_all(src[-c(1, n)])
    }
    
    parse_all.default <- function(x) {
      parse_all(deparse(x))
    }
    replay <- function(x) UseMethod("replay", x)
    
    replay.list <- function(x) {
      invisible(lapply(x, replay))
    }
    
    replay.character <- function(x) {
      cat(x)
    }
    
    replay.source <- function(x) {
      cat(line_prompt(x$src))
    }
    
    replay.warning <- function(x) {
      message("Warning message:\n", x$message)
    }
    
    replay.message <- function(x) {
      message(str_replace(x$message, "\n$", ""))
    }
    
    replay.error <- function(x) {
      if (is.null(x$call)) {
        message("Error: ", x$message)
      } else {
        call <- deparse(x$call)
        message("Error in ", call, ": ", x$message)
      }
    }
    
    replay.value <- function(x) {
      if (x$visible) print(x$value)
    }
    
    replay.recordedplot <- function(x) {
      print(x)
    }
    
    line_prompt <- function(x, prompt = getOption("prompt"), continue = getOption("continue")) {
      lines <- strsplit(x, "\n")[[1]]
      n <- length(lines)
      
      lines[1] <- str_c(prompt, lines[1])
      if (n > 1)
        lines[2:n] <- str_c(continue, lines[2:n])
      
      str_c(lines, "\n", collapse = "")
    }
    getSrcRegion <- function(srcfile, x1, x2, y1, y2) {
      if (is.infinite(x2)) x2 <- 1e6
      if (is.infinite(y2)) y2 <- 1e6
      
      lines <- getSrcLines(srcfile, x1, x2)
      
      text <- if (length(lines) == 1) {
        str_sub(lines[1], y1, y2 - 1)
      } else {
        c(
          str_sub(lines[1], y1, 1e6),
          lines[-c(1, length(lines))],
          str_sub(lines[length(lines)], 0, y2 - 1)
        )
      }
      str_c(text, collapse="\n")
    }
    create_traceback <- function(callstack) {
      if (length(callstack) == 0) return()
      
      # Convert to text
      calls <- lapply(callstack, deparse, width = 500)
      calls <- sapply(calls, str_c, collapse = "\n")
      
      # Number and indent
      calls <- str_c(seq_along(calls), ": ", calls)
      calls <- str_replace(calls, "\n", "\n   ")
      calls
    }
    
    try_capture_stack <- function(quoted_code, env) {
      capture_calls <- function(e) {
        # Capture call stack, removing last two calls from end (added by
        # withCallingHandlers), and first frame + 7 calls from start (added by
        # tryCatch etc)
        e$calls <- head(sys.calls()[-seq_len(frame + 7)], -2)
        signalCondition(e)
      }
      frame <- sys.nframe()
      
      tryCatch(
        withCallingHandlers(eval(quoted_code, env), error = capture_calls),
        error = identity
      )
    }
    watchout <- function(debug = FALSE) {
      output <- vector("character")
      prev   <- vector("character")
      
      con <- textConnection("output", "wr", local=TRUE)
      sink(con, split = debug)
      
      list(
        get_new = function(plot = FALSE, incomplete_plots = FALSE) {
          incomplete <- isIncomplete(con)
          if (incomplete) cat("\n")
          
          out <- list()
          
          if (plot) {
            out$graphics <- plot_snapshot(incomplete_plots)
          }
          
          if (length(output) != length(prev)) {
            new <- output[setdiff(seq_along(output), seq_along(prev))]
            prev <<- output
            
            out$text <- str_c(new, collapse = "\n")
            if (!incomplete) out$text <- str_c(out$text, "\n")
          }
          
          unname(out)
        },
        pause = function() sink(),
        unpause = function() sink(con, split = debug),
        close = function() {
          sink()
          close(con)
          output
        }
      )
    }
      
    environment();
  });
});