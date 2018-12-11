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
<meta name="decorator" content="main"/>
<meta name="module" content="admin"/>
<meta name="moduleCSSClass" content="adminModule"/>

<%--
	Page shows the artifacts in approval.
--%>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://displaytag.sf.net" prefix="display" %>

<%@ taglib uri="taglib" prefix="tag" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags" %>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
<%@ taglib uri="callTag" prefix="ct" %>

<c:set var="DEBUG" value="false"/>

<c:set var="onlyActive" value="${param.onlyActive eq 'true'}" />
<%-- If only the artifacts with active workflow are shown --%>
<c:set var="artifacts" value="${artifactApprovalAppliedTo[artifactApproval.id]}"/>
<c:set var="activeArtifacts" value="${artifactApprovalActiveInstances[artifactApproval.id]}" />

<c:if test="DEBUG">
	<pre class='debug'>
		artifacts: ${artifacts}
		activeArtifacts: ${activeArtifacts}
	</pre>
</c:if>


<c:if test="${onlyActive}">
	<c:set var="artifacts" value="${activeArtifacts}"/>
</c:if>

<ui:actionMenuBar>
		<ui:breadcrumbs showProjects="false"><span class='breadcrumbs-separator'>&raquo;</span>
		<span><spring:message code="artifact.approval.workflow.appliedTo.title" text="Artifacts in Approval Workflow: {0}" arguments="${artifactApproval.name}" htmlEscape="true" /></span>
		</ui:breadcrumbs>
</ui:actionMenuBar>

<ui:actionBar>
	<ui:actionGenerator builder="artifactApprovalListContextActionMenuBuilder" actionListName="actions" subject="${artifactApproval}">

		<a href="<c:url value='/proj/admin.spr?orgDitchnetTabPaneId=project-admin-approvals'/>" title='View Approval Workflows'>Go Back</a>

		<%--
		<c:set var="editApprovalAction" value='${actions["editApproval"]}'/>
		<c:if test="${! empty editApprovalAction}">
			<a href="${editApprovalAction.url}" title="${editApprovalAction.toolTip}">Edit Approval workflow</a>
		</c:if>
		--%>
	</ui:actionGenerator>

	<c:if test="${! empty activeArtifacts}">
		<spring:message var="restartConfirm" code="artifact.approval.workflow.restart.confirm" text="Are you sure to restart all workflow on all active artifacts?\nThis will delete all history entries of these pending workflows!" />

		<a href="<c:url value='/restartWorkflowOnActiveArtifactsInApproval.spr?approvalworkflow_id=${artifactApproval.id}'/>" onclick="return confirm('${restartConfirm}');">
			<spring:message code="artifact.approval.workflow.restart.label" text="Restart Workflow on Active Artifacts" />
		</a>
	</c:if>
</ui:actionBar>

<display:table requestURI="" defaultsort="1" defaultorder="descending" export="false" cellpadding="0" name="${artifacts}" id="artifact" >
	<spring:message var="artifactTitle" code="artifact.approval.workflow.artifact.label" text="Artifact" />
	<spring:message var="artifactLink" code="artifact.approval.workflow.artifact.tooltip" text="Click to view artifact version waiting for approval" />
	<display:column title="${artifactTitle}" headerClass="textData" class="textData columnSeparator" sortProperty="name" sortable="true" >
		<c:url var="link" value='${artifact.urlLink}'>
			<c:param name="revision" value="${artifact.version}" />
		</c:url>
		<a href="${link}" title="${artifactLink}"><c:out value="${artifact.name}"/></a>
	</display:column>

	<c:if test="${!onlyActive}">
		<c:set var="isActive" value="false"/>
		<c:if test="${! empty activeArtifacts}">
			<ct:call return="isActive" object="${activeArtifacts}" method="contains" param1="${artifact}" />
		</c:if>
		<spring:message var="workflowActive" code="artifact.approval.workflow.active.label" text="Active" />
		<display:column title="${workflowActive}" headerClass="textData" class="textData columnSeparator" style="width:1%;" sortable="true" >
			<strong><spring:message code="button.${isActive ? 'yes' : 'no'}" /></strong>
		</display:column>
	</c:if>

	<spring:message var="artifactLastModifiedBy" code="document.lastModifiedBy.label" text="Last modified by" />
	<display:column title="${artifactLastModifiedBy}" style="width:10%;" headerClass="textData" class="textData columnSeparator"
			sortProperty="lastModifiedBy.name" sortable="true" >
		<tag:userLink user_id="${artifact.lastModifiedBy}" />
	</display:column>

	<spring:message var="artifactLastModifiedAt" code="document.lastModifiedAt.label" text="Last modified at" />
	<display:column title="${artifactLastModifiedAt}" style="width:10%;" headerClass="dateData" class="dateData" sortProperty="lastModifiedAt" sortable="true" >
		<tag:formatDate value="${artifact.lastModifiedAt}" />
	</display:column>
</display:table>
