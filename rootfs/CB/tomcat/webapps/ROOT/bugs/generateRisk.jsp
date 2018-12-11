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
--%>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="uitaglib" prefix="ui" %>

<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>

<meta name="decorator" content="popup"/>
<meta name="module" content="tracker"/>
<meta name="moduleCSSClass" content="newskin trackersModule"/>

<c:url var="actionUrl" value="/trackers/risk/create.spr" />

<style type="text/css">
	.suspectLabel {
		font-weight: bold;
		margin-left: 20px;
		margin-right: 5px;
	}
</style>

<div class="container">
	<c:if test="${!locked }">
		<form:form action="${actionUrl}" enctype="multipart/form-data" commandName="addUpdateTaskForm" method="POST" cssClass="ratingOnInlinedPopup">
			<form:hidden path="requirementId"/>
			<form:hidden path="fieldId"/>


			<jsp:include page="/bugs/addUpdateTask.jsp?layoutMode=mandatory&callback=reloadEditedIssue&noReload=true&noForm=true&nestedPath=null&noAssociation=true&noTrackerField=true&isPopup=${param.isPopup }&minimal=true&disableMitigationReqWarning=true" />
			<span class="suspectLabel"><spring:message code="association.propagatingSuspects.label" text="Propagate suspected"/>:</span><form:checkbox path="triggerSuspected"/>
		</form:form>
	</c:if>
	<c:if test="${locked }">
		<ui:actionBar>
			<button class="cancelButton" onclick="closePopupInline();"><spring:message code="button.cancel" text="Cancel"/></button>
		</ui:actionBar>
		<ui:globalMessages></ui:globalMessages>
	</c:if>

</div>