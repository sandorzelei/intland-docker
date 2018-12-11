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
<meta name="moduleCSSClass" content="adminModule newskin"/>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags" %>
<%@ taglib uri="uitaglib" prefix="ui" %>

<c:set var="readOnly" scope="request" value="${!canEditApprovalWorkflow}"/>
<form:form commandName="createUpdateArtifactApprovalForm" id="createUpdateArtifactApprovalForm" >
<form:hidden path="artifactApproval.id"/>

<form:errors/>

<c:set var="creatingNewApproval" value="${createUpdateArtifactApprovalForm.newArtifactApproval}" />

<ui:actionMenuBar>
		<ui:breadcrumbs showProjects="false"><span class='breadcrumbs-separator'>&raquo;</span>
		<ui:pageTitle>
			<c:choose>
				<c:when test="${readOnly}"><spring:message code="artifact.approval.workflow.viewing.title" text="Approval Workflow {0}" arguments="${artifactApproval.name}" htmlEscape="true"/></c:when>
				<c:when test="${creatingNewApproval}"><spring:message code="artifact.approval.workflow.creating.title" text="Creating new Approval Workflow"/></c:when>
				<c:otherwise><spring:message code="artifact.approval.workflow.editing.title" text="Editing Approval Workflow {0}" arguments="${artifactApproval.name}" htmlEscape="true"/></c:otherwise>
			</c:choose>
		</ui:pageTitle>
		</ui:breadcrumbs>
</ui:actionMenuBar>

<ui:actionBar>
	<c:if test="${!readOnly}">
		<c:choose>
			<c:when test="${creatingNewApproval}">
				<spring:message var="createButton" code="button.create" text="Create"/>
				<spring:message var="createTitle" code="artifact.approval.workflow.creating.tooltip" text="Create the workflow with the provided steps"/>

				&nbsp;&nbsp;<input type="submit" class="button" value="${createButton}" title="${createTitle}" />
			</c:when>
			<c:otherwise>
				<spring:message var="saveButton" code="button.save" text="Save"/>
				&nbsp;&nbsp;<input type="submit" class="button" value="${saveButton}" />
			</c:otherwise>
		</c:choose>

		<spring:message var="cancelButton" code="button.cancel" text="Cancel"/>
		&nbsp;&nbsp;<input type="submit" class="button cancelButton" name="_cancel" value="${cancelButton}" />

		<c:if test="${!isApprovalWorkflowInUse}">
			<spring:message var="newStepButton" code="artifact.approval.workflow.newStep.label" text="New Step"/>
			<spring:message var="newStepTitle" code="artifact.approval.workflow.newStep.tooltip" text="Create a new workflow step"/>
			&nbsp;&nbsp;<input type="submit" class="button" name="addNewStepSubmit" value="${newStepButton}" title="${newStepTitle}" />
			<%--
			<c:if test="${! empty artifactApprovalSteps}" >
				&nbsp;&nbsp;<input type="submit" class="button" name="editStepSubmit" value="Edit Selected Step" onclick="return hasSelectedStep();" />
				&nbsp;&nbsp;<input type="submit" class="button" name="deleteStepSubmit" value="Delete Selected Step" onclick="return confirmDeleteStep();" />
			</c:if>
			--%>
		</c:if>
	</c:if>
	<c:if test="${readOnly}">
		<spring:message var="backButton" code="button.back" text="Go back"/>
		&nbsp;&nbsp;<input type="button" class="button" value="${backButton}" onclick="history.back()" />
	</c:if>

	<c:if test="${(! creatingNewApproval) && isApprovalWorkflowInUse}">
		&nbsp;&nbsp;<ui:actionLink builder="artifactApprovalListContextActionMenuBuilder" subject="${artifactApproval}" keys="viewArtifactsInActiveWorkflow"/>
	</c:if>
</ui:actionBar>

<%-- hidden fields for submitting via edit/delete actions --%>
<form:hidden id="selectedStep" path="selectedStep" />
<input type="hidden" id="editStepSubmit" name="editStepSubmit" value="" />
<input type="hidden" id="deleteStepSubmit" name="deleteStepSubmit" value="" />

<%--
<ui:delayedScript>
	<script type="text/javascript">
		// check If has a selected step
		function hasSelectedStep() {
			var form = document.getElementById("createUpdateArtifactApprovalForm");
			if (hasSelectedCheckbox(form, "selectedStep")) {
				return true;
			} else {
				alert('<spring:message code="Please select some Steps first!" />');
			}
			return false;
		}

		// confirm deletion of the selected approval-step
		function confirmDeleteStep() {
			if (hasSelectedStep()) {
				if (confirm('<spring:message code="approval.editor.delete.step.confirm"/>')) {
					return true;
				}
			}
			return false;
		}
	</script>
</ui:delayedScript>

--%>

<div class="contentWithMargins">
<table width="100%" border="0" cellpadding="0" class="formTableWithSpacing">

<tr>
	<TD <c:choose><c:when test="${!readOnly}">class="mandatory"</c:when><c:otherwise>class="optional"</c:otherwise></c:choose> >
		<spring:message code="artifact.approval.workflow.name.label" text="Approval Workflow Name" />:
	</TD>

	<td nowrap width="80%">
		<form:input path="artifactApproval.name" id="artifactApproval.name" size="60" tabindex="0" /><br/><form:errors path="artifactApproval.name" cssClass="invalidfield"	/>
	</td>
</tr>

</table>

<jsp:include page="./approvalSteps.jsp"/>
</div>

</form:form>

<script type="text/javascript">
<!--
	var nameInput = document.getElementById("artifactApproval.name");
	$(nameInput).focus();
	<c:if test="${readOnly}">
		nameInput.disabled = true;
	</c:if>
//-->
</script>
