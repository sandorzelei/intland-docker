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
<%@ tag language="java" pageEncoding="UTF-8" %>

<%@ tag import="com.intland.codebeamer.controller.support.InfoMessages"%>
<%@ tag import="com.intland.codebeamer.controller.support.GlobalMessages"%>
<%@ tag import="java.util.List"%>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="http://www.opensymphony.com/sitemesh/decorator" prefix="decorator" %>

<%--
	Tag include renders global messages added to GlobalMessages object in the previous request.
	Only renders the global-messages at that position except if the globalMessages is already rendered
--%>
<%--
<c:set var="globalMessagesAlreadyIncluded"><decorator:getProperty property="meta.globalMessagesAlreadyIncluded" /></c:set>
--%>
<!--
<pre class="debug">
globalMessagesAlreadyIncluded: ${globalMessagesAlreadyIncluded}
</pre>
-->
<%-- don't include globalMessages again if that is already included! --%>
<c:if test="${empty globalMessagesAlreadyIncluded}">
	<c:set var="globalMessagesAlreadyIncluded" value="true" scope="request" />

	<%
		GlobalMessages globalMessages = GlobalMessages.getInstance(request);

		InfoMessages infoMessages = globalMessages.getInfoMessages();
		GlobalMessages localMessages = GlobalMessages.getLocalMessages(request);

		if (localMessages != null) {
			infoMessages.addMessages(localMessages.getInfoMessages());
			localMessages.clear();
		}

		String notifications = "";
		for (String notification: infoMessages.getNotifications()) {
			notifications += notification + "<br/>";
		}
		jspContext.setAttribute("notifications", notifications);

		String autoDownloadURL = globalMessages.getAutoDownloadURL();
		jspContext.setAttribute("autoDownloadURL", autoDownloadURL);
	%>
	<ui:infoPanel infoMessages="<%=infoMessages%>" id="globalMessages"/>
	<c:if test="${! empty notifications}">
		<script type="text/javascript">
			showOverlayMessage('${ui:sanitizeHtml(notifications)}');
		</script>
	</c:if>

	<c:if test="${! empty autoDownloadURL}">
		<script type="text/javascript">
			console.log("auto download should start: ${autoDownloadURL}");
			$(function(){ window.location.href='${autoDownloadURL}'; });
		</script>
	</c:if>

	<%-- clear the messages already shown --%>
	<%globalMessages.clear();%>
</c:if>

