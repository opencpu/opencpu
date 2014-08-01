send_index <- function(data){
  #Check of trailing path
  res$checktrail();
  
  #Check type
  stopifnot(is.data.frame(data) || is.matrix(data))
  
  #cast matrix
  data <- as.data.frame(data)
  stopifnot(ncol(data) >= 1)
  stopifnot(ncol(data) <= 6)
  
  #check if client wants HTML
  if(!grepl("text/html", req$accept())){
    #In case of text/plain, use first column only
    vector <- sort(unique(data[[1]]));
    res$sendtext(paste(vector, sep="\n", collapse="\n"));
  } else {
    #Sort
    data <- data[order(data[[1]]), , drop=FALSE]
    res$sendhtml(makepage(data))
  }
}

makepage <- function(data){
  paste(
'<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=yes">',
maketitle(),
'<link rel="stylesheet" href="https://netdna.bootstrapcdn.com/bootstrap/3.1.1/css/bootstrap.min.css" />
  <style type="text/css">th{cursor:pointer}</style>
</head>
<body>
  <div class="container">',
makebreadcrumb(),
maketable(data),
'</div>
  <script type="text/javascript" src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.0/jquery.min.js"></script>
  <script type="text/javascript">(function(c){c.fn.stupidtable=function(b){return this.each(function(){var a=c(this);b=b||{};b=c.extend({},c.fn.stupidtable.default_sort_fns,b);a.on("click.stupidtable","th",function(){var d=c(this),f=0,g=c.fn.stupidtable.dir;a.find("th").slice(0,d.index()).each(function(){var a=c(this).attr("colspan")||1;f+=parseInt(a,10)});var e=d.data("sort-default")||g.ASC;d.data("sort-dir")&&(e=d.data("sort-dir")===g.ASC?g.DESC:g.ASC);var l=d.data("sort")||null;null!==l&&(a.trigger("beforetablesort",{column:f, direction:e}),a.css("display"),setTimeout(function(){var h=[],m=b[l],k=a.children("tbody").children("tr");k.each(function(a,b){var d=c(b).children().eq(f),e=d.data("sort-value"),d="undefined"!==typeof e?e:d.text();h.push([d,b])});h.sort(function(a,b){return m(a[0],b[0])});e!=g.ASC&&h.reverse();k=c.map(h,function(a){return a[1]});a.children("tbody").append(k);a.find("th").data("sort-dir",null).removeClass("sorting-desc sorting-asc");d.data("sort-dir",e).addClass("sorting-"+e);a.trigger("aftertablesort", {column:f,direction:e});a.css("display")},10))})})};c.fn.stupidtable.dir={ASC:"asc",DESC:"desc"};c.fn.stupidtable.default_sort_fns={"int":function(b,a){return parseInt(b,10)-parseInt(a,10)},"float":function(b,a){return parseFloat(b)-parseFloat(a)},string:function(b,a){return b<a?-1:b>a?1:0},"string-ins":function(b,a){b=b.toLowerCase();a=a.toLowerCase();return b<a?-1:b>a?1:0}}})(jQuery);$("#bs-table").stupidtable();</script>
</body>
</html>')
}

maketitle <- function(){
  paste0("<title>Index of ", req$mount(), URLdecode(req$path_info()), "</title>")
}

maketable <- function(data){
  paste(
    '<div class="table-responsive">',
    '<table id="bs-table" class="table table-hover">',
    '<thead>', makehead(data), '</thead>',
    '<tbody>', makebody(data), '</tbody>',
    '</table>',
    '</div>',
    sep="\n"
  )
}

makehead <- function(data){
  output <- character(length(data));
  output[1] <- paste0('<th class="col-lg-', 14-2 * ncol(data), '" data-sort="', 
    switch(class(data[[1]])[1], integer = "int", numeric = "float", "string") ,
    '"><span class="glyphicon glyphicon-sort"></span>&nbsp;', names(data)[1] ,'</th>')
  
  if(length(data) >= 2){
    for(i in 2:length(data)) {
      output[i] <- paste0('<th class="col-lg-2 text-right" data-sort="',
        switch(class(data[[i]])[1], integer = "int", numeric = "float", "string"),
        '">', names(data)[i] ,'</th>')
    }
  }

  paste(c("<tr>", output, "</tr>"), collapse = "\n")
}

makebody <- function(data){
  output <- character(nrow(data))
  for(i in 1:nrow(data)){
    output[i] <- makerow(unname(unlist(data[i,])))
  }
  paste(output, collapse = "\n")
}

makerow <- function(input){
  output <- character(length(input));
  output[1] <- paste0('<td data-sort-value="', input[1], '"><span class="glyphicon glyphicon-file"></span>&nbsp;<a href="', input[1], '">', input[1], '</a></td>');
  if(length(input) >= 2){
    for(i in 2:length(input)) {
      output[i] <- paste0('<td class="text-right" data-sort-value="', input[i], '">', input[i], '</td>')
    }
  }
  paste(c("<tr>", output, "</tr>"), collapse = "\n")
}

makebreadcrumb <- function(){
  template1 <- '<li><a href="{{path}}"><span class="glyphicon glyphicon-home"></span></a></li>'
  template2 <- '<li><a href="{{path}}">{{name}}</a></li>'
  
  fullpath <- strsplit(URLdecode(req$path_info()), "/")[[1]]
  output <- character(length(fullpath));
  output[1] <- paste0('<li><a href="', req$mount() ,'/"><span class="glyphicon glyphicon-home"></span></a></li>')
  if(length(fullpath) >= 1){
    for(i in 2:length(fullpath)){
      output[i] <- paste0('<li><a href="', paste0(req$mount(), paste(c(fullpath[1:i], ""), collapse="/")) ,'">', fullpath[i],'</a></li>')
    }
  }
  paste(c('<ol class="breadcrumb">', output, '</ol>'), collapse = "\n")
}

