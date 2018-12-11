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
 *
 * $Revision:13091 $ $Date:2006-05-03 14:06:25 +0000 (Mi, 03 Mai 2006) $
--%>

<%@page import="com.intland.codebeamer.controller.ControllerUtils"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="uitaglib" prefix="ui" %>

<html>

<head>
	<title>Intland - ${licenseCode.type}</title>

	<script type="text/javascript">

		<c:choose>
			<c:when test="${!empty param.jsCallback}">
				window.opener.${param.jsCallback}();
				window.close();
			</c:when>
			<c:otherwise>
				<c:if test="${!empty param.targetURL}">
					<c:url var="targetURL" value="${param.targetURL}" />
					<%
						String targetURL = (String) pageContext.findAttribute("targetURL");
						String safe = ControllerUtils.safeReferrerURL(targetURL, request);	// use a safe-target url, only go back to CB site!
						pageContext.setAttribute("targetURL", safe);
					%>
					<c:choose>
						<c:when test="${!empty targetURL}">
							if (window.opener) {
								try {
									window.opener.location.replace('<c:out value="${targetURL}" escapeXml="false" />');
								} catch (ex) {
									console.error(ex);
								}
							} else {
							    window.parent.location.href = '<c:out value="${targetURL}" escapeXml="false" />';
							}
						</c:when>
						<c:otherwise>
							if (window.opener) {
								window.opener.location.reload();
							} else {
								window.close();
							}
							return;
						</c:otherwise>
					</c:choose>
				</c:if>

				<%--
				Original version: jumps to the right location, but does not reload the page, so an F5 is needed
				New version: jumps to strange places sometimes, the browser address bar shows weird urls
				<c:if test="${!empty param.targetURL}">
					<c:url var="targetURL" value="${param.targetURL}" />
					window.opener.location = '<c:out value="${targetURL}" escapeXml="false" />';
					window.opener.location.reload();
				</c:if>
				--%>
				<c:if test="${!empty param.reloadtask}">
					// it's from AddattachmentController.onSubmit
					<c:set var="taskId" value="${param.reloadtask}" />
					if (window.opener) {
						// documentview.js -> refreshProperties()
						if (window.opener.refreshProperties){
							window.opener.refreshProperties("${taskId}");
						}
					}
				</c:if>
			</c:otherwise>
		</c:choose>

		<%--
		If the opener window is the Release Planner, reload the right plane (issue propetries, comments, etc.)
		--%>
		try {
			if ((typeof window.opener.codebeamer != "undefined") && ("planner" in window.opener.codebeamer)) {
				window.opener.codebeamer.planner.reloadSelectedIssue();
			}
		} catch (ignored) {
			console.log("Failed to call callback on the opener page:" + ignored);
		}

		window.close();
	</script>

</head>

<body></body>

</html>
