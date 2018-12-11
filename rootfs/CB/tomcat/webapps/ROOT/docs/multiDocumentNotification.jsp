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
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>

<%-- JSP for editing multiple document's notification --%>
<meta name="decorator"      content="main"/>
<meta name="module"         content="${module}"/>
<meta name="moduleCSSClass" content="newskin ${moduleCSSClass}"/>

<ui:actionMenuBar>
	<ui:breadcrumbs showProjects="false">
		<span class='breadcrumbs-separator'>&raquo;</span>
		<c:if test="${empty artifact}">
			<spring:message code="${artifactType}" text="${artifactType}"/> &raquo;
		</c:if>
		<ui:pageTitle><spring:message code="documents.notifications.title" text="Access Notifications"/></ui:pageTitle>
	</ui:breadcrumbs>
</ui:actionMenuBar>

<ui:showErrors />

<c:set var="showDescriptionBox" value="true" scope="request" />

<c:set var="referrer" ><spring:escapeBody htmlEscape="true" javaScriptEscape="true">${referrer}</spring:escapeBody></c:set>

<%-- include the fragment contains the form and the table for editing notifications--%>
<jsp:include page="./includes/documentNotification.jsp" >
	<jsp:param name="onSuccess" value="document.location.href='${referrer}'"/>
</jsp:include>
<spring:escapeBody htmlEscape="true" javaScriptEscape="true"></spring:escapeBody>

<script type="text/javascript">

	$('#documentNotificationsForm > div.actionBar').append($('<input>', { type : 'submit', "class" : 'cancelButton', name : '_cancel', value : '<spring:message code="button.cancel" text="Cancel" javaScriptEscape="true"/>', style : 'margin-left: 1em;' }).click(function(event) {
	    event.preventDefault();
	    document.location.href='${referrer}';
		return false;
	}));

</script>
