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
--%><%@
        taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<c:set var="out">
<%--

	Simple error handler page, will just print out the error message in plain text.
	This error page is only used when an exception happens on a request which is not
	handled by ErrorHandlerFilter. Such pages are the ajax requests and few others.

--%>
<%@ page import="java.io.StringWriter"%>
<%@ page import="java.io.PrintWriter"%>
<%@ page import="com.intland.codebeamer.Config" %>
<%@ page import="com.intland.codebeamer.security.AccessLogFilter" %>

<c:set var="checkLogs">Check log files for details as Request #<%=AccessLogFilter.getRequestId(request)%>.</c:set>

<%
    response.setContentType("text/plain");

 boolean developmentMode = Config.isDevelopmentMode();
 if (developmentMode) {
%>
Unexpected system error: '<%=request.getAttribute("javax.servlet.error.message")%>'
Request to '<%=request.getAttribute("javax.servlet.error.request_uri")%>' has failed.
${checkLogs}

<%
Throwable throwable = (Throwable) request.getAttribute("javax.servlet.error.exception");
if (throwable != null) {
	StringWriter sw = new StringWriter();
	throwable.printStackTrace(new PrintWriter(sw));
	out.println(sw.toString());
}
%>

<% } else { %>

Request to '<%=request.getAttribute("javax.servlet.error.request_uri")%>' has failed.
${checkLogs}

<% } %>
</c:set>${out.trim()}