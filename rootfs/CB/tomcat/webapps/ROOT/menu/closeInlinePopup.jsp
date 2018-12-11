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
--%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>

<%--
	Page for closing an inline popup. Use together with the showPopupInline() javascript function to show and close an inline popup.
	Expects the "targetURL" parameter, which will be loaded in the main window after the inline popup is closed.
 --%>
<html>
	<head>
		<c:set var="targetURL"><spring:escapeBody htmlEscape="true"><c:url value='${param.targetURL}'/></spring:escapeBody></c:set>
		<meta name="noReload" content="<c:out value='${param.noReload}'/>" >
		<meta name="taskId" content="<c:out value='${param.taskId}'/>" >
		<meta name="callback" content="<c:out value='${param.callback}'/>" >
		<meta name="closeInlinePopup" content="${targetURL}" >
		<meta name="executeJS" content="<c:out value='${not empty executeJS ? executeJS : param.executeJS}'/>" >

		<style type="text/css">
			body * {
				color: silver !important;
				font-size: 12px;
			}
		</style>
	</head>
	<body>
		<script type="text/javascript">
			function closeMe() {
				var targetUrl = '<spring:escapeBody javaScriptEscape="true">${targetURL}</spring:escapeBody>';
				var doc = window.parent.document;
				if (targetUrl != null && targetUrl != '') {
					doc.location.href = targetUrl;
				} else {
					doc.location.reload();
				}
			}
			
			setTimeout(function() {
				document.write('<spring:message code="close.inline.popup.refreshing.label" text="Refreshing... If page would not load" />' + 
								' <a href="#" onclick="closeMe(); return false;">' + 
								'<spring:message code="close.inline.popup.refreshing.click.here.label" text="click here" /></a>');
			}, 1000);
		</script>		
	</body>
</html>
