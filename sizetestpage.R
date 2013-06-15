testpage <- '<html>
	<body>
		<form name="test" action="/test" target="my_iframe" method="POST" enctype="multipart/form-data">
			A string: <input type="text" name="stringval"> <br />
			A file: <input type="file" name="fileval"> <br />
			<input type="submit" value="Submit">
		</form>
		
		<iframe name="my_iframe"></iframe>
	</body>
</html>'

rookhandler <- function(env){

	if(env[["REQUEST_METHOD"]] == "GET"){
		return(list(
			status=200,
			headers=list("Content-type" = "text/html"),
			body = testpage
		));
	}
	
	input <- env[["rook.input"]];
	postdata <- input$read();
	content_length <- env$CONTENT_LENGTH;
	
	mybody <- paste("Content length: ", content_length, ".\n\nActual length: ", length(postdata), ".", sep="");
	
	#for debugging we dump the data on the desktop
	try(writeBin(postdata, tempfile("postdata", "~/Desktop", ".tmp")));
	
	list(
		status=200,
		headers=list("Content-type" = "text/plain"),
		body=mybody
	)
}

library(httpuv)
runServer("0.0.0.0", 12345, list(call=rookhandler));
