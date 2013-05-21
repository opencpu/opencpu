function showParamHeaders() {
	if ($("#allparameters").find(".realinputvalue").length > 0) {
		$("#allparameters").show();
	} else {
		$("#allparameters").hide();
	}
}

$(".fakeinputname").blur(
		function() {
			var newparamname = $(this).val();
			$(this).parent().parent().parent().parent().find(".realinputvalue")
					.attr("name", newparamname);
		});

$(".close").click(function() {
	$(this).parent().remove();
	showParamHeaders();
});

$("#addprambutton").click(function() {
	$('.httpparameter:first').clone(true).appendTo("#allparameters");
	showParamHeaders();
	return false;
});

$("#addfilebutton").click(function() {
	$('.httpfile:first').clone(true).appendTo("#allparameters");
	showParamHeaders();
	return false;
});

$("#httpmethod").change(function() {
	var method = $("#httpmethod").val();
	if (method == "GET" || method == "POST") {
		$("#submitform").removeClass("disabled")
	} else {
		$("#submitform").addClass("disabled")
	}
})

function postToIframe(target) {
	var paramform = $("#paramform");
	if ($("#httpmethod").val() == "POST") {
		var hasfiles = $("#paramform").find(".input-file").length > 0;
		paramform.attr("enctype", hasfiles ? "multipart/form-data" : "application/x-www-form-urlencoded");		
	} else {
		paramform.attr("enctype", "");
	}
	paramform.attr("target", target);
	paramform.attr("action", $("#urlvalue").val());
	paramform.attr("method", $("#httpmethod").val());
	if (target == "_blank") {
		$("#outputframe").hide();
		$("#ajaxoutput").hide();
	} else {
		$("#outputframe").show();
		$("#ajaxoutput").hide();
		$("#formspinner").show();
	}
	paramform.submit();
	return false;
}

function postWithAjax() {
	var mydata = {};
	var parameters = $("#allparameters").find(".realinputvalue");
	for (i = 0; i < parameters.length; i++) {
		name = $(parameters).eq(i).attr("name");
		if (name == undefined || name == "undefined") {
			continue;
		}
		value = $(parameters).eq(i).val();
		mydata[name] = value
	}

	var myajax = {
		url : $("#urlvalue").val(),
		type : $("#httpmethod").val(),
		complete : function(jqXHR) {
			$("#statuspre").text(
					"HTTP " + jqXHR.status + " " + jqXHR.statusText);
			if (jqXHR.status == 0) {
				httpZeroError();
			} else if (jqXHR.status >= 200 && jqXHR.status < 300) {
				$("#statuspre").addClass("alert-success");
			} else if (jqXHR.status >= 400) {
				$("#statuspre").addClass("alert-error");
			} else {
				$("#statuspre").addClass("alert-warning");
			}
			$("#outputpre").text(jqXHR.responseText);
			$("#headerpre").text(jqXHR.getAllResponseHeaders());
		}
	};

	if (jQuery.isEmptyObject(mydata)) {
		myajax.contentType = 'application/x-www-form-urlencoded';
	} else {
		myajax.data = mydata;
	}

	$("#outputframe").hide();
	$("#outputpre").empty();
	$("#headerpre").empty();
	$("#outputframe").attr("src", "")
	$("#ajaxoutput").show();
	$("#statuspre").text("0");
	$("#statuspre").removeClass("alert-success");
	$("#statuspre").removeClass("alert-error");
	$("#statuspre").removeClass("alert-warning");

	$.ajax(myajax);
}

$('#ajaxspinner').ajaxStart(function() {
	$(this).show();
});

$('#ajaxspinner').ajaxStop(function() {
	$(this).hide();
});

$("#submitform,#submitblank")
		.click(
				function() {
					$(this).focus();
					var method = $("#httpmethod").val();
					if (method != "GET" && method != "POST") {
						alert("Form method only supports GET and POST");
						return;
					}
					checkForFormFiles();
					if ($(this).attr("data-targetframe") == "_blank") {
						postToIframe("_blank");
						return false;
					} else {
						$("#outputframe")
								.replaceWith(
										'<iframe name="outputframe" id="outputframe" class="input-xxlarge"></iframe>');
						$('#outputframe').load(function() {
							$("#formspinner").hide();
						});

						postToIframe("outputframe");
						return false;
					}
				});

$("#submitajax").click(function() {
	checkForAjaxFiles();
	postWithAjax();
	return false;
});

function checkForAjaxFiles() {
	if ($("#paramform").find(".input-file").length > 0) {
		$("#errordiv")
				.append(
						'<div class="alert alert-error"> <a class="close" data-dismiss="alert">&times;</a> <strong>Alert!</strong> You are trying to do an Ajax request with posting files. This will not work on most browsers. Use the form request method instead to upload files. </div>');
	}
}

function checkForFormFiles() {
	var method = $("#httpmethod").val();
	if (method == "POST")
		return;
	if ($("#paramform").find(".input-file").length > 0) {
		$("#errordiv")
				.append(
						'<div class="alert alert-error"> <a class="close" data-dismiss="alert">&times;</a> <strong>Alert!</strong> You are posting a form using method '
								+ method
								+ ' but your request contains files. You can only upload files using HTTP POST method. </div>');
	}
}

$(document).ready(
		function() {
			// something for open mHealth
			if (document.location.hostname.slice(-6) == "omh.io") {
				$("#urlvalue").val(
						document.location.protocol + "//"
								+ document.location.hostname
								+ "/app/config/read");
			} else if (document.location.hostname.slice(-11) == "opencpu.org") {
				$("#urlvalue").val(
						document.location.protocol + "//"
								+ document.location.hostname + "/R/pub");
			} else {
				$("#urlvalue").val(document.location.href);
			}
			populateCookieTable();
			updateCookieWarning();

		});

function httpZeroError() {
	$("#errordiv")
			.append(
					'<div class="alert alert-error"> <a class="close" data-dismiss="alert">&times;</a> <strong>Oh no!</strong> Javascript returned an HTTP 0 error. One common reason this might happen is that you requested a cross-domain resource from a server that did not include the appropriate CORS headers in the response. Better open up your Firebug...</div>');
}

function getAllCookies() {
	var cookies = {}
	if (document.cookie && document.cookie != '') {
		var split = document.cookie.split(';');
		for ( var i = 0; i < split.length; i++) {
			var name_value = split[i].split("=");
			name_value[0] = name_value[0].replace(/^ /, '');
			cookies[decodeURIComponent(name_value[0])] = decodeURIComponent(name_value[1]);
		}
	}
	return cookies;
}

function createCookie(name, value, days, path) {
	if (days) {
		var date = new Date();
		date.setTime(date.getTime() + (days * 24 * 60 * 60 * 1000));
		var expires = "; expires=" + date.toGMTString();
	} else {
		var expires = "";
	}

	if (path) {
		document.cookie = name + "=" + value + expires + "; path=" + path;
	} else {
		document.cookie = name + "=" + value + expires;
	}
}

function readCookie(name) {
	var nameEQ = name + "=";
	var ca = document.cookie.split(';');
	for ( var i = 0; i < ca.length; i++) {
		var c = ca[i];
		while (c.charAt(0) == ' ')
			c = c.substring(1, c.length);
		if (c.indexOf(nameEQ) == 0)
			return c.substring(nameEQ.length, c.length);
	}
	return null;
}

function eraseCookie(name) {
	createCookie(name, "", -1);
	createCookie(name, "", -1, "/");
}

function populateCookieTable() {
	$("#cookietablebody").empty();
	var allcookies = getAllCookies();
	for (cookie in allcookies) {
		// not displaying google analytics cookies;
		if (cookie.substring(0, 5) == "__utm")
			continue;
		$("#cookietablebody")
				.append(
						'<tr><td><tt>'
								+ cookie
								+ "="
								+ allcookies[cookie]
								+ '; </tt> <button onclick="eraseCookie(\''
								+ cookie
								+ '\'); populateCookieTable();" class="btn-mini btn-danger cookiebutton">Remove</button></td></tr>');
	}
	if ($("#cookietablebody").find("tr").length == 0) {
		$("#cookietablebody").append('<tr><td><tt> No cookies </tt></td></tr>');
	}
}

function updateCookieWarning() {
	$("#cookiewarningdiv").empty();
	var patharray = window.location.pathname.split("/");
	var patharray = patharray.slice(0, patharray.length - 1);
	var newpath = patharray.join("/")
	$("#cookiewarningdiv")
			.append(
					"<p>Note: Table only shows cookies stored under <tt>"
							+ window.location.hostname
							+ newpath
							+ "</tt>. Cookies on other domains/paths cannot be displayed, but will still be included in Ajax requests to those domains/paths. </p>");
}
