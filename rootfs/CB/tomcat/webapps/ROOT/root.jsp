<%
/*
 *	Forward to main page.
 */
	final String targetApplication = "/cb";
	String targetPage = request.getScheme() + "://" + request.getServerName();
	int port = request.getServerPort();
	if (port != 80) {
		targetPage += ":" + port;
	}
	response.sendRedirect(targetPage + targetApplication);
%>
