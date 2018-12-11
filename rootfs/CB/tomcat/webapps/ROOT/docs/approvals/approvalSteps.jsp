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
 * $Revision$ $Date$
--%>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@ taglib uri="taglib" prefix="tag" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags" %>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>

<c:set var="dragDropDeleteEnabled" value="${canEditApprovalWorkflow && !isApprovalWorkflowInUse && fn:length(artifactApprovalSteps) > 1}" />

<c:set var="DEBUG" value="false"/>
<c:if test="${canEditApprovalWorkflow && isApprovalWorkflowInUse}">
	<c:url value='/listArtifactsInApproval.spr?approvalworkflow_id=${artifactApproval.id}' var="listDocumentsURL"/>
	<spring:message var="appliedToTitle" code="artifact.approval.workflow.appliedTo.tooltip" text="View the wiki pages and documents this approval workflow is applied to"/>
	<div class="warning">
		<spring:message code="artifact.approval.workflow.appliedTo.warning" text="Steps can not be modified, because this approval workflow is in use by {0} wiki pages and documents." arguments="${numberOfArtifactsUseThisWorkflow}"/>
		<a href="${ui:removeXSSCodeAndHtmlEncode(listDocumentsURL)}" title="${ui:removeXSSCodeAndHtmlEncode(appliedToTitle)}"><spring:message code="artifact.approval.workflow.appliedTo.link" text="See them..." /></a>
	</div>
</c:if>

<spring:message var="approvalSteps" code="artifact.approval.workflow.steps.label" text="Approval Steps"/>
<ui:title style="top-sub-headline-decoration" bottomMargin="5" separatorGapHeight="2" titleStyle="" topMargin="5" header="${approvalSteps}" />

<display:table requestURI="" defaultsort="1" defaultorder="ascending" export="false" class="expandTable dragReorder" htmlId="artifactApprovalStepsTable"
	cellpadding="0" name="${artifactApprovalSteps}" id="step" >

	<ui:actionGenerator builder="artifactApprovalStepListContextActionMenuBuilder" subject="${step}" actionListName="actionsForStep" >

    <spring:message var="approvalStep" code="artifact.approval.workflow.step.label" text="Step"/>
	<display:column title="${approvalStep}" headerClass="numberData" class="numberData ordinalNumber columnSeparator" sortProperty="ordinal">
		<spring:bind path="approvalStepOrdering['${step.id}']">
			<c:set var="orderValue" value="${status.value}" />
		</spring:bind>

		<c:if test="${dragDropDeleteEnabled}">
			<%--
			<form:radiobutton id="selectedStep_${step.id}" path="selectedStep" value="${step.id}" />
			--%>
			<input name="approvalStepOrdering['${step.id}']" value="${orderValue}" title='ordinal number for step.id=${step.id}'
				<c:if test="${! DEBUG}"> type='hidden' </c:if>
			/>
		</c:if>
		<span class="ordinalNumberLabel">${step_rowNum}</span>
	</display:column>

    <spring:message var="stepName" code="artifact.approval.workflow.step.name.label" text="Name"/>
	<display:column title="${stepName}" headerClass="textData" class="textData">
		<c:set var="editArtifactApprovalStepAction" value="${actionsForStep['editArtifactApprovalStep']}" />
		<c:choose>
			<c:when test="${!empty editArtifactApprovalStepAction}">
				<a href="#" onclick="${editArtifactApprovalStepAction.onClick}"><c:out value="${step.name}"/></a>
			</c:when>
			<c:otherwise>
				<c:out value="${step.name}"/>
			</c:otherwise>
		</c:choose>
		<%-- TODO: (Final) text is not is not printed, because it would be invalid when reordering
		<c:if test="${step.finalStep}"><span class="subtext">(Final)</span></c:if>
		--%>
	</display:column>

	<display:column media="html" class="action-column-minwidth columnSeparator">
		<c:if test="${!readOnly}">
			<ui:actionMenu actions="${actionsForStep}" />
		</c:if>
	</display:column>

   <spring:message var="stepApprovers" code="artifact.approval.workflow.step.approvers.label" text="Approvers"/>
	<display:column title="${stepApprovers}" headerClass="textData expand" class="textData">
		<c:set var="approvers" value="${step.approvers}" />
		<c:choose>
			<c:when test="${!empty approvers}">
				<%--first the Users: --%>
				<c:set var="approverUsers" value="${step.approverUsers}"/>
				<c:forEach var="approverUser" items="${approverUsers}" varStatus="varStatus">
					<c:choose>
						<c:when test="${approverUser.id lt 0}">
   							<spring:message code="${approverUser.name}" htmlEscape="true"/>
						</c:when>
						<c:otherwise>
							<tag:userLink user_id="${approverUser.id}" />
						</c:otherwise>
					</c:choose>
					<c:if test="${!varStatus.last}">,</c:if>
				</c:forEach>
				<c:if test="${! empty approverUsers}">
					<br/>
				</c:if>
				<%-- followed by the roles --%>
				<c:set var="approverRoles" value="${step.approverRoles}" />
				<c:if test="${! empty approverRoles}">
					<c:forEach var="approverRole" items="${approverRoles}" varStatus="varStatus">
						<c:if test="${!empty approverRole}">
							<b><spring:message code="role.${approverRole.name}.label" text="${approverRole.name}" htmlEscape="true"/></b>
						</c:if>
						<c:if test="${!varStatus.last}">,</c:if>
					</c:forEach>
				</c:if>
			</c:when>
			<c:otherwise>
				<span class="warningtext"><spring:message code="artifact.approval.workflow.step.approvers.none" text="No approvers defined."/></span>
			</c:otherwise>
		</c:choose>
	</display:column>

	</ui:actionGenerator>
</display:table>

<div style="margin-top: 5px" class="subtext">
	<c:if test="${dragDropDeleteEnabled}">
		<spring:message code="artifact.approval.workflow.steps.dragAndDrop.tooltip" text="(Hint: drag and drop the lines above to reorder the steps.)"/>
	</c:if>
</div>

<c:if test="${dragDropDeleteEnabled}">
	<ui:delayedScript>
	<script type="text/javascript">
		// debug function to print orders
		function printOrders() {
			var form = document.getElementById("createUpdateArtifactApprovalForm");
			var msg = "";
			for (var i=0; i<form.elements.length;i++) {
				var elem = form.elements[i];
				msg += elem.name +"=" + elem.value +", ";
			}
			console.log("form elements:" + msg);
		}

		$(function() {
			$("#artifactApprovalStepsTable tbody").sortable({
				update: function(event, ui) {
					// reorder values
					$("#artifactApprovalStepsTable tbody tr").each(function(index) {
						$(this).find(".ordinalNumber input").val(index + 1);
						$(this).find(".ordinalNumber .ordinalNumberLabel").text(index + 1);
					});
					GlobalMessages.showWarningMessage(i18n.message("artifact.approval.workflow.steps.order.changed.warning"));
				}
			});
		});
	</script>
	</ui:delayedScript>

	<c:if test="${DEBUG}">
		<div class="debug">
			<input type='button' class='button' onclick="printOrders();" value="print form elements" />
		</div>
	</c:if>
</c:if>

<script type="text/javascript" src="<ui:urlversioned value="/docs/approvals/approvalSteps.js" />"></script>
