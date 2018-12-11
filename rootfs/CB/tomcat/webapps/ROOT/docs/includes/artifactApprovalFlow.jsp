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
 * $Revision: 18092:5935af41a9fd $ $Date: 2008-07-08 11:33 +0000 $
--%>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>

<%--
	JSP fragment shows the actual approval state on an artifact together with the steps (flow) of the workflow
	Expected input parameters:
	- request.artifactToApprove      - The ArtifactDto being shown
	- request.approvalState	         - The list of history entries showing the full flow of the approval workflow. Use the artifactApprovalManager.findApprovalStateByArtifact() method for generating this
	- request.canApprovePendingStep  - If the user can approve the pending step
	- param.enabled 				 - If the flow is enabled (clicking will execute the actions). Defaults to true

	As output this fragment sets the
	request.currentStep to be the current step of the flow
--%>
<c:set var="enabled" value="${param.enabled}" />
<c:if test="${empty param.enabled}">
	<c:set var="enabled" value="true" />
</c:if>
<c:set var="enabled" value="${enabled && (canApprovePendingStep || canRejectDocumentInWorkflow)}" />

<%-- managing all workflows: /proj/admin.spr?orgDitchnetTabPaneId=project-admin-approvals --%>
<c:url var="workflowURL" value="/editArtifactApproval.spr?approvalworkflow_id=${artifactToApprove.additionalInfo.approvalWorkflow.id}"/>

<%-- approval state --%>
<spring:message var="viewWorkflowTitle" code="artifact.approval.workflow.tooltip" text="View Workflow"/>
<b><a href="${workflowURL}" title="${viewWorkflowTitle}"><c:out value='${artifactToApprove.additionalInfo.approvalWorkflow.name}'/></a>:</b>&nbsp;&nbsp;
<c:choose>
	<c:when test="${!empty approvalState}">
		<c:set var="previousStepApproved" value="true" />
		<c:forEach items="${approvalState}" var="artifactApprovalHistoryEntry" varStatus="status">
			<c:choose>
				<c:when test="${artifactApprovalHistoryEntry.approved == null}">
					<%-- pending step --%>
					<c:choose>
						<c:when test="${previousStepApproved}">
							<%-- pending approvable step --%>
							<c:choose>
								<c:when test="${enabled}">
									<spring:message var="approveOrRejectTitle" code="artifact.approval.workflow.step.approveOrReject.tooltip" text="Approve or Reject"/>

									<a href="#" class="currentStep" onclick="javascript: return showApproveArtifactForm();" title="${approveOrRejectTitle}"><c:out value="${artifactApprovalHistoryEntry.step.name}" /></a>
									<c:set var="currentStep" value="${artifactApprovalHistoryEntry.step}" />
								</c:when>
								<c:otherwise>
									<spring:message var="pendingStepTitle" code="artifact.approval.workflow.step.pending.tooltip" text="Pending Step"/>
									<span class="currentStep" title="${pendingStepTitle}"><c:out value="${artifactApprovalHistoryEntry.step.name}" /></span>
								</c:otherwise>
							</c:choose>
						</c:when>
						<c:otherwise>
							<%-- future or unapprovable step --%>
							<span class="futureStep"><c:out value="${artifactApprovalHistoryEntry.step.name}" /></span>
						</c:otherwise>
					</c:choose>
					<c:set var="previousStepApproved" value="false" />
				</c:when>
				<c:when test="${artifactApprovalHistoryEntry.approved}">
					<%-- approved step --%>
					<spring:message var="commentAndApproverTitle" code="artifact.approval.workflow.step.commentAndApprover.tooltip" text="{0} by {1}" arguments="${artifactApprovalHistoryEntry.comment},${artifactApprovalHistoryEntry.approver.name}" htmlEscape="true"/>
					<span class="approvedStep" title="${commentAndApproverTitle}"><c:out value="${artifactApprovalHistoryEntry.stepName}" /></span>
					<c:set var="previousStepApproved" value="true" />
				</c:when>
				<c:otherwise>
					<%-- rejected step --%>
					<spring:message var="commentAndApproverTitle" code="artifact.approval.workflow.step.commentAndApprover.tooltip" text="{0} by {1}" arguments="${artifactApprovalHistoryEntry.comment},${artifactApprovalHistoryEntry.approver.name}" htmlEscape="true"/>
					<span class="rejectedStep" title="${commentAndApproverTitle}"><c:out value="${artifactApprovalHistoryEntry.stepName}" /></span>
					<c:set var="previousStepApproved" value="false" />
				</c:otherwise>
			</c:choose>
			<c:if test="${!status.last}"> &rarr; </c:if>
		</c:forEach>
	</c:when>
	<c:otherwise>
		<spring:message code="artifact.approval.workflow.steps.none" text="No approval steps specified." />
	</c:otherwise>
</c:choose>

<%-- output varibales --%>
<c:set var="currentStep" scope="request" value="${currentStep}" />
