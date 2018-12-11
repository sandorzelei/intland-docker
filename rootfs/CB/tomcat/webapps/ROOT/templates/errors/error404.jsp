<%--
 * Copyright by Intland Software
 *
 * All rights reserved.
 *
 * This software is the confidential and proprietary information
 * of Intland Software. ("Confidential Information"). You
 * shall not disclose such Confidential Information and shall use
 * it only in accordance with the terms of the license agreement
 * you entered into with Intland.
--%><%-- DO NOT PUT anything before this, because IE6 will otherwise switch to QUIRKS mode! --%><%=com.intland.codebeamer.servlet.IWebConstants.HTML_DOCTYPE%>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%
	response.setContentType("text/html");
%>

<html>
<head>
	<title>codeBeamer Error Page</title>
</head>
<body>
<h2>The page <tt><c:out value='<%=request.getAttribute("javax.servlet.error.request_uri")%>' /></tt> does not exist.</h2>
<p>
	Suggestions:
	<ol>
		<li>Check that the you spelled the address correctly.</li>
		<li>Return to the start page of the application.</li>
	</ol>
	<p>
	If you are still having problem, please report this on the <a href="http://codebeamer.com">Codebeamer support site</a>.<br />
	We will respond as promptly as possible.<br>
	Thank you!
	</p>
</p>
</body>
</html>
