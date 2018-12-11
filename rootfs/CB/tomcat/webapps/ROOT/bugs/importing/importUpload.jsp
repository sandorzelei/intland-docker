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
<%@ page import="com.intland.codebeamer.flow.form.ImportForm"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>

<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="bugstaglib" prefix="bugs" %>

<meta name="decorator" content="main"/>
<meta name="module" content="tracker"/>
<meta name="moduleCSSClass" content="trackersModule newskin ${importForm.tracker.isBranch() ? 'tracker-branch' : '' }" />

<ui:actionMenuBar>
	<jsp:attribute name="rightAligned">
		<c:if test="${importForm.tracker.isBranch()}">
			<ui:branchBaselineBadge branch="${importForm.branch}"/>
		</c:if>
	</jsp:attribute>
	<jsp:body>
		<ui:breadcrumbs showProjects="false" projectAware="${importForm.tracker}" ><span class='breadcrumbs-separator'>&raquo;</span>
			<ui:pageTitle prefixWithIdentifiableName="false"><spring:message code="issue.import.title" text="Importing Items"/></ui:pageTitle>
		</ui:breadcrumbs>
	</jsp:body>
</ui:actionMenuBar>

<c:choose>
	<c:when test="${importForm.trackerId gt 0}">
		<jsp:include page="./includes/importUploadFragment.jsp">
			<jsp:param name="nextEnabled" value="true"/>
		</jsp:include>
	</c:when>

	<c:otherwise>
		<spring:message code="errors.import.tracker.notfound" />
	</c:otherwise>
</c:choose>

