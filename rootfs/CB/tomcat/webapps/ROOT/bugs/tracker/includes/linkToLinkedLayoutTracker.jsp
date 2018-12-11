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
 * $Revision: 16885:01f04343ff4c $ $Date: 2008-03-21 11:05 +0000 $
--%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>

<%-- small JSP fragment renders link to edit linked-template-tracker --%>
<c:set var="orgDitchnetTabPaneId" value="${param.orgDitchnetTabPaneId}" />
<c:set var="title" value="${param.title}" />
<c:set var="negativeMargin" value="${param.negativeMargin}" />
<c:set var="divClass" value="linkToTemlateDiv" />
<c:if test="${negativeMargin}">
	<c:set var="divClass" value="linkToTemlateDivNegative" />
</c:if>

<style type="text/css">
.linkToTemlateDivNegative {
	background-color: #f5f5f5;
	height: 16px;
	margin: 0px -15px;
}

.linkToTemlateDiv {
	background-color: #f5f5f5;
	height: 16px;
}

.linkToTemlateText {
	position: absolute;
	right: 0;
	top: 0;
	margin-top: 0.5em;
	margin-right: 2em;
}
</style>

<c:url var="editURL" value="/proj/tracker/configuration.spr">
	<c:param name="tracker_id" value="${param.tracker_id}" />
	<c:param name="revision"   value="${param.revision}" />
	<c:param name="orgDitchnetTabPaneId" value="${orgDitchnetTabPaneId}" />
</c:url>

<div class="${divClass}">
	<span class="linkToTemlateText">
		<%--
		<input type="button" class="button" value="Edit template's ${title}" onclick="launch_url('${editURL}');">
		--%>
		<spring:message code="tracker.template.config.link" arguments="${title},${editURL}"/>
	</span>
</div>


