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
<meta name="decorator" content="popup" />
<meta name="module" content="tracker" />
<meta name="moduleCSSClass" content="newskin" />

<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="taglib" prefix="tag" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>

<spring:message var="saveLabel" code="button.save" text="Save" />
<spring:message var="clearSuspectLabel" code="diffTool.resetSuspected.label" text="Clear Suspected" />
<spring:message var="cancelLabel" code="button.cancel" text="Cancel" />

<c:if test="${param.noActionMenuBar != 'true' }">
	<ui:actionMenuBar>
		<jsp:body>
			<ui:breadcrumbs showProjects="false" projectAware="${copy}"><span class='breadcrumbs-separator'>&raquo;</span>
				<span><spring:message code="diffTool.pageTitle" text="Differences" arguments="${copy.name},${original.name}" htmlEscape="true" /></span>
				<ui:pageTitle prefixWithIdentifiableName="false" printBody="false" >
					<spring:message code="diffTool.pageTitle" text="Differences" arguments="${copy.name},${original.name}" htmlEscape="true" />
				</ui:pageTitle>
			</ui:breadcrumbs>
		</jsp:body>
	</ui:actionMenuBar>
</c:if>

<ui:actionBar>
	<c:if test="${clearSuspect and !showMergePage}">
		<input type="button" class="button" name="clearSuspect" value="${clearSuspectLabel}" />
	</c:if>
	<c:if test="${!justView}">
		<input type="submit" class="button" name="submit" value="${saveLabel}" />
	</c:if>
	<input type="submit" class="cancelButton" name="cancel" value="${cancelLabel}" />
</ui:actionBar>

<c:if test="${clearSuspect}">
	<input type="hidden" id="isReference" value="${isReference}">
	<c:if test="${not empty associationTaskId}">
		<input type="hidden" id="associationTaskId" value="${associationTaskId}">
	</c:if>
	<input type="hidden" id="taskId" value="${taskId}">
</c:if>

<c:choose>
	<c:when test="${noDiff}">
		<div class="warning"><spring:message code="diffTool.no.differences" text="No differences found."/></div>
	</c:when>
	<c:otherwise>
		<form id="diffDataForm" action="${pageContext.request.contextPath}/ajax/issuediff/diff.spr" method="post">
			<input type="hidden" name="copyId" value="${copy.id}">
			<input type="hidden" name="originalId" value="${original.id}">
			<input type="hidden" name="copyToOriginalFieldIds" value=""> <!-- filled by JS on save -->
			<input type="hidden" name="originalToCopyFieldIds" value=""> <!-- filled by JS on save -->
			<input type="hidden" id="associationId" name="associationId" value="${associationId}">

			<c:if test="${not empty copyVersion && not empty originalVersion}">
				<input type="hidden" name="copyVersionId" value="${copyVersion}">
				<input type="hidden" name="originalVersionId" value="${originalVersion}">
			</c:if>

			<c:if test="${not empty isRevert && isRevert}">
				<input type="hidden" name="isRevert" value="${true}">
			</c:if>

			<c:if test="${editable && (empty hideSuspected || !hideSuspected)}">
				<spring:message code="diffTool.resetSuspected.title" var="resetSuspectedTitle"/>
				<label for="resetSuspected" title="${resetSuspectedTitle }">
					<input type="checkbox" name="resetSuspected" checked="checked" id="resetSuspected" style="margin-bottom: 0px; margin: 13px;">
					<strong>${clearSuspectLabel }</strong>
				</label>
				<span class="hint">
					<spring:message code="diffTool.clearSuspected.hint"/>
				</span>
			</c:if>
		</form>
		<jsp:include page="diffTable.jsp"/>
	</c:otherwise>
</c:choose>

<script src="<ui:urlversioned value='/js/diff.js' />"></script>
