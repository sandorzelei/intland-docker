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
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<%@ taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="taglib" prefix="tag" %>

<%@ page import="com.intland.codebeamer.controller.admin.errorhandling.ErrorHandlerFilterContext"%>
<%@ page import="org.apache.log4j.PatternLayout"%>
<%@ page import="org.apache.log4j.spi.LoggingEvent"%>
<%
	ErrorHandlerFilterContext errorHandlerContext = (ErrorHandlerFilterContext) request.getAttribute("errorHandlerContext");
	if (errorHandlerContext == null) {
		// Necessary to prevent NPE.
		errorHandlerContext = new ErrorHandlerFilterContext(request, null, null);
		request.setAttribute("errorHandlerContext", errorHandlerContext);
	}
%>
<html>

<head>
	<title>codeBeamer Error Page</title>

<style type="text/css">
	.codeblock {
		background: #DDD;
		border: 1px solid #AAA;
	}

	.LEVEL_DEBUG {
		color: gray;
	}
	.LEVEL_INFO {
		color: black;
	}
	.LEVEL_WARN {
		color: brown;
	}
	.LEVEL_ERROR {
		color: red;
	}
</style>


</head>
<body>
<h2>Sorry, an unexpected system error has occurred.</h2>

<div>
	Please report this problem on the <a href="http://codebeamer.com">Codebeamer support site</a> with as much detail as possible so we know how to reproduce it:
	<ol>
		<li>On which page did you experience the problem? What happened?</li>
		<li>Copy and paste the error and system information below.</li>
		<li>Attach the application server log file to your report (if possible).</li>
	</ol>
	We will respond as promptly as possible.<br>
	Thank you!
</div>

<h3>Date and Time</h3>
<p>${errorHandlerContext.timestamp}</p>

<h3>Cause</h3>
<%-- TODO: confluence does not print out the whole stack trace, just the major here, and then a switchable bigger stack trace--%>
<pre class="codeblock"><c:out value="${errorHandlerContext.stackTrace}"/></pre>

<h3>Server Information</h3>
<p>
${serverInfo}
</p>

<h3>Request</h3>
<p>
URL: <tt><c:out value="${errorHandlerContext.requestURL}"/></tt><br>
Scheme: <tt><c:out value="${errorHandlerContext.scheme}"/></tt><br>
Server: <tt><c:out value="${errorHandlerContext.serverName}"/></tt><br>
Port: <tt><c:out value="${errorHandlerContext.serverPort}"/></tt><br>
URI: <tt><c:out value="${errorHandlerContext.requestURI}"/></tt><br>
Context Path: <tt><c:out value="${errorHandlerContext.contextPath}"/></tt><br>
Servlet Path: <tt><c:out value="${errorHandlerContext.servletPath}"/></tt><br>
Path Info: <tt><c:out value="${errorHandlerContext.pathInfo}"/></tt><br>
Query String: <tt><c:out value="${errorHandlerContext.queryString}"/></tt><br>
Referer URL: <tt><c:out value="${errorHandlerContext.refererURL}"/></tt><br>
</p>

<c:if test="${!empty errorHandlerContext.requestAttributes}">
<h3>Request Attributes</h3>
<b><c:out value="${fn:length(errorHandlerContext.requestAttributes)}" /></b> request attributes found.
<pre>
<c:forEach var="attr" items="${errorHandlerContext.requestAttributes}"><c:out value="${attr.key}"/> = <c:out value="${attr.value}"/>
</c:forEach>
</pre>
</c:if>

<c:if test="${!empty errorHandlerContext.requestParameters}">
<h3>Request Parameters</h3>
<b><c:out value="${fn:length(errorHandlerContext.requestParameters)}" /></b> request parameters found.
<pre>
<c:forEach var="par" items="${errorHandlerContext.requestParameters}"><c:out value="${par.key}"/> = <c:out value="${par.value}"/>
</c:forEach>
</pre>
</c:if>

<h3>User</h3>
<p>
Signed in: &lt;<c:out value="${errorHandlerContext.user}"/>&gt;
</p>

<c:if test="${!empty errorHandlerContext.loggingEvents}">
<h3>Logging</h3>
<b><%=errorHandlerContext.getLoggingEvents().size()%></b> log statements generated by this request.
<%
	PatternLayout layout = new PatternLayout();
	layout.setConversionPattern("%d %-5p %c{3} %3x - %m [%t]");
%>
<pre class="codeblock">
<c:forEach var="loggingEvent" items="${errorHandlerContext.loggingEvents}"><tag:joinLines>
	<c:set var="logline" value="<%=layout.format((LoggingEvent)pageContext.getAttribute(\"loggingEvent\"))%>" />
	<jsp:useBean id="loggingEvent" type="org.apache.log4j.spi.LoggingEvent" />
	<%-- print out the stack trace, as the PatternLayout won't do this--%>
	<c:set var="stackTrace"><%
		// using commons' execeptionutils because it will print out the full stacktraces including root causes (even for ServletException)
		if (loggingEvent.getThrowableInformation() != null) {
			out.println(ErrorHandlerFilterContext.getStackTrace(loggingEvent.getThrowableInformation().getThrowable()));
		}
	%></c:set>
</tag:joinLines><span class="LEVEL_${loggingEvent.level}"><c:out value='${logline}'/><c:if test="${! empty stackTrace}">
<c:out value="${stackTrace}"/></c:if></span>
</c:forEach>
</pre>
</c:if>

</body>

</html>