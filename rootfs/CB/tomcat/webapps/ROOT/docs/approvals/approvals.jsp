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
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="taglib" prefix="tag" %>
<%@ taglib uri="uitaglib" prefix="ui" %>

<style type="text/css">
	#approval .textData {
		text-align: center;
	}
	#approval .tdName {
		text-align: left;
	}
	#approval .tdCreatedAt {
		text-align: right;
	}
	.displaytag {
		border-bottom: 0px !important;
	}
</style>

<div class="actionBar">
	<ui:actionLink builder="artifactApprovalActionMenuBuilder"/>
	<span class="rightAlignedDescription">
		<spring:message code="project.administration.approvalWorkflow.tooltip" text="You can configure approval workflows for the wiki pages and documents in this project."/>
	</span>
</div>

<display:table requestURI="" defaultsort="1" export="false" class="expandTable" cellpadding="0" name="${artifactApprovals}" id="approval">
	<spring:message var="workflowName" code="artifact.approval.workflow.name.label" text="Name" />
	<display:column title="${workflowName}" sortProperty="name" sortable="true" headerClass="textData tdName" class="textData tdName">
		<c:url var="approvalDetailsUrl" value="/editArtifactApproval.spr" >
			<c:param name="approvalworkflow_id">${approval.id}</c:param>
		</c:url>
		<spring:message var="workflowSteps" code="artifact.approval.workflow.steps.tooltip" text="View the steps of this approval workflow" />
		<a href="${approvalDetailsUrl}" title="${workflowSteps}"><c:out value="${approval.name}" escapeXml="true"/></a>
	</display:column>

	<display:column media="html" class="action-column-minwidth columnSeparator">
		<ui:actionMenu builder="artifactApprovalListContextActionMenuBuilder" subject="${approval}" />
	</display:column>

	<c:url var="listArtifactsApprovalLink" value='/listArtifactsInApproval.spr?approvalworkflow_id=${approval.id}&onlyActive=false' />

	<spring:message var="workflowAppliedTo" code="artifact.approval.workflow.appliedTo.label" text="Applied To" />
	<display:column title="${workflowAppliedTo}" headerClass="textData" class="textData columnSeparator">
		<c:choose>
			<c:when test="${!empty artifactApprovalAppliedTo[approval.id]}">
				<spring:message var="appliedToTitle" code="artifact.approval.workflow.appliedTo.tooltip" text="View the wiki pages and documents this approval workflow is applied to" />
				<a href="${listArtifactsApprovalLink}" title="${appliedToTitle}">${fn:length(artifactApprovalAppliedTo[approval.id])}</a>
			</c:when>
			<c:otherwise>
				<spring:message code="artifact.approval.workflow.unused.label" text="Unused" />
			</c:otherwise>
		</c:choose>
	</display:column>

	<spring:message var="workflowInstances" code="artifact.approval.workflow.instances.label" text="Active Instances" />
	<display:column title="${workflowInstances}" headerClass="textData" class="textData columnSeparator">
		<c:choose>
			<c:when test="${!empty artifactApprovalActiveInstances[approval.id]}">
				<spring:message var="instancesTitle" code="artifact.approval.workflow.instances.tooltip" text="View the wiki pages and documents this approval workflow has active instance on" />
				<a href="${listArtifactsApprovalLink}" title="${instancesTitle}">${fn:length(artifactApprovalActiveInstances[approval.id])}</a>
			</c:when>
			<c:otherwise>
				<spring:message code="artifact.approval.workflow.instances.none" text="None" />
			</c:otherwise>
		</c:choose>
	</display:column>

	<spring:message var="workflowSteps" code="artifact.approval.workflow.steps.label" text="Steps" />
	<display:column title="${workflowSteps}" headerClass="textData" class="textData columnSeparator">
		<c:choose>
			<c:when test="${!empty artifactApprovalSteps[approval.id]}">
				${fn:length(artifactApprovalSteps[approval.id])}
			</c:when>
			<c:otherwise>
				<span class="warningtext"><spring:message code="artifact.approval.workflow.steps.none" text="No steps defined." /></span>
			</c:otherwise>
		</c:choose>
	</display:column>

	<spring:message var="workflowCreated" code="artifact.approval.workflow.createdAt.label" text="Created" />
	<display:column title="${workflowCreated}" sortProperty="createdAt" sortable="true" headerClass="textData tdCreatedAt" class="textData tdCreatedAt">
		<tag:formatDate value="${approval.createdAt}" />
		<spring:message code="artifact.approval.workflow.createdBy.label" text="by" />
		<tag:userLink user_id="${approval.createdBy.id}" />
	</display:column>
</display:table>

<%-- because this page has no SiteMesh decoration, we must flush the scripts here --%>
<ui:delayedScript flush="true"/>
