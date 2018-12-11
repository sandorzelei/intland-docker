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
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>

<%@ taglib uri="acltaglib" prefix="acl" %>

<%@ taglib uri="log" prefix="log" %>
<%@ taglib uri="uitaglib" prefix="ui" %>

<%@ page import="com.intland.codebeamer.persistence.dto.TrackerLayoutLabelDto" %>

<meta name="decorator" content="main"/>
<meta name="module" content="tracker"/>
<meta name="moduleCSSClass" content="trackersModule newskin ${importForm.tracker.isBranch() ? 'tracker-branch' : ''}" />

<ui:actionMenuBar>
	<jsp:attribute name="rightAligned">
		<c:if test="${importForm.tracker.isBranch()}">
			<ui:branchBaselineBadge branch="${importForm.branch}"/>
		</c:if>
	</jsp:attribute>
	<jsp:body>
		<ui:breadcrumbs showProjects="false" projectAware="${importForm.tracker}"><span class='breadcrumbs-separator'>&raquo;</span>
			<ui:pageTitle prefixWithIdentifiableName="false"><spring:message code="issue.import.preview.title" text="Preview of Imported Data"/></ui:pageTitle>
		</ui:breadcrumbs>
	</jsp:body>
</ui:actionMenuBar>

<form:form commandName="importForm" action="${flowUrl}">
<form:hidden path="trackerId"/>

<ui:actionBar>
	<jsp:include page="./includes/nextPrevButtons.jsp?finish=true"/>
</ui:actionBar>

<div style="margin: 15px;">
	<spring:message code="issue.import.tag.label" text="Tag created/updated issues with:"/>:&nbsp; <form:input path="tag"/>
	<span class="dataChanged" style="margin-left: 20px; padding: 5px;">
		<spring:message code="tracker.issues.import.changed.highlight.hint" text="Changed properties are highlighted in yellow"/>
		<%--
		<a style="margin-left:20px;" href="#" onclick="selectOnlyChangedRows(); return false;"><spring:message code="tracker.issues.import.select.only.changed" text="Select only rows changed"/></a>

		<label for="toggleHideNoDataChanged" style="margin-left: 20px;">
			<input type="checkbox" id="toggleHideNoDataChanged" checked="checked"/>
			<spring:message code="tracker.issues.import.hide.data.without.change" text="Hide import data without any change" />
		</label>
		--%>
	</span>
	<span id="notUpdateableDataExplanation" class="dataChanged" style="margin-left: 20px; padding: 5px;">
		<spring:message code="tracker.issues.import.not.updatable.hint" text="Not updateable data"/>
	</span>
	<br/>

	<jsp:include page="/bugs/importing/includes/importPreviewFragment.jsp"/>
</div>

</form:form>
