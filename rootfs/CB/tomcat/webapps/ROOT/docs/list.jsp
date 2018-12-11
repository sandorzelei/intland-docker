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
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="taglib" prefix="tag" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>

<meta name="decorator" content="main"/>
<meta name="module" content="docs"/>
<meta name="moduleCSSClass" content="documentsModule newskin ${not empty listDocumentForm.baseline ? "tracker-baseline" :""}"/>


<c:set var="actionMenuRightPart">
	<c:if test="${not empty listDocumentForm.baseline}">
		<ui:branchBaselineBadge baseline="${listDocumentForm.baseline}"/>
	</c:if>
</c:set>
<c:set var="actionMenuBodyPart">
	<ui:pageTitle printBody="false">${empty listDocumentForm.currentDirectory ? 'Documents' : listDocumentForm.currentDirectory.name}</ui:pageTitle>

	<c:if test="${!empty listDocumentForm.doc_id}">
		<tag:document var="document" doc_id="${listDocumentForm.doc_id}"
			revision="${listDocumentForm.revision}" scope="request"
			artifactRevisionVar="documentRevision" commentsVar="comments" />
		<c:url value="${documentRevision.propertiesLink}&orgDitchnetTabPaneId=document-comments" var="commentsUrl" />
		<c:url value="${documentRevision.propertiesLink}&orgDitchnetTabPaneId=document-history" var="historyUrl" />
	</c:if>

	<c:set var="strongBody"	value="${empty listDocumentForm.currentDirectory}" />
	<ui:breadcrumbs showProjects="false" commentsUrl="${commentsUrl}" historyUrl="${historyUrl}" strongBody="${strongBody}">
		<c:if test="${empty listDocumentForm.currentDirectory}">
			<spring:message code="Documents" text="Documents" />
		</c:if>
	</ui:breadcrumbs>
	<c:if test="${!empty listDocumentForm.baseline}">
		<c:url var="baselineUrl" value="${listDocumentForm.baseline.urlLink}" />
		<c:set var="baselineInfo">
			<spring:message code="baseline.createdBy.label" text="Created by" />: <c:out value="${listDocumentForm.baseline.createdBy}" />, <tag:formatDate	value="${listDocumentForm.baseline.createdAt}" />
		</c:set>
	</c:if>

</c:set>

<ui:actionMenuBar>
	<jsp:attribute name="rightAligned">${actionMenuRightPart}</jsp:attribute>
	<jsp:body>${actionMenuBodyPart}</jsp:body>
</ui:actionMenuBar>


<%-- TODO move from here
				<c:url var="generateMindmapURL" value="/proj/doc/generateMindmap.do">
					<c:param name="proj_id" value="${PROJECT_DTO.id}" />
				</c:url>
				&nbsp;&nbsp;<a href="${generateMindmapURL}">Generate Tracker Mindmap</a>

				<c:url var="generateTraceabilityMatrixURL" value="/proj/doc/generateTraceabilityMatrix.do">
					<c:param name="proj_id" value="${PROJECT_DTO.id}" />
				</c:url>
				&nbsp;&nbsp;<a href="${generateTraceabilityMatrixURL}">Generate Traceability Matrix</a>
--%>

<jsp:include page="/docs/listDocuments.jsp" flush="true" />
