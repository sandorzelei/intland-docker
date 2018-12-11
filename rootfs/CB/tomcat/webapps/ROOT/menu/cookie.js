// $Revision$ $Date$

function readCookie(cookieName) {
	var theCookie=""+document.cookie;
	var ind=theCookie.indexOf(cookieName);
	if (ind==-1 || cookieName=="") return "";
	var ind1=theCookie.indexOf(';',ind);
	if (ind1==-1) ind1=theCookie.length;
	return unescape(theCookie.substring(ind+cookieName.length+1,ind1));
}

function setCookie(cookieName,cookieValue,nDays) {
	var today = new Date();
	var expire = new Date();
	if (nDays==null || nDays==0) nDays=1;
	expire.setTime(today.getTime() + 3600000*24*nDays);
	document.cookie = cookieName+"="+escape(cookieValue) + ";expires="+expire.toGMTString();
}

function checkCookie() {
	var cookieName = "CB_COOKIES_ENABLED";
	setCookie(cookieName,"anything");
	var mycookie = readCookie(cookieName);
	if (mycookie == null || mycookie == '') {
		document.write('<FONT SIZE="+3" COLOR="red"><STRONG>' + i18n.message("ajax.cookies.required") + '</STRONG></FONT><P>');
	} else {
		setCookie(cookieName, "");
	}
}
