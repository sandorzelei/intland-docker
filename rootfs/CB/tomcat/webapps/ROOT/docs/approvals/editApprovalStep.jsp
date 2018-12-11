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
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags" %>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
<%@ taglib uri="bugstaglib" prefix="bugs" %>
<%@ taglib uri="taglib" prefix="tag" %>
<%@ taglib uri="uitaglib" prefix="ui" %>

<c:set var="DEBUG" value="false"/>

<form:form commandName="createUpdateArtifactApprovalStepForm">
<form:hidden path="artifactApprovalStep.id"/>
<form:hidden path="artifactApprovalStep.approvalWorkflow.id"/>
<form:hidden path="artifactApprovalStep.ordinal"/>

<ui:actionMenuBar>
		<ui:breadcrumbs showProjects="false">
		<span class="breadcrumbs-separator">&raquo;</span>
		<span><spring:message code="artifact.approval.workflows.label" text="Approval Workflows"/></span>
		<span class="breadcrumbs-separator">&raquo;</span>
		<span><c:out value="${createUpdateArtifactApprovalStepForm.artifactApprovalStep.approvalWorkflow.name}"/></span>
		<span class="breadcrumbs-separator">&raquo;</span>
		<ui:pageTitle>
			<c:choose>
				<c:when test="${createUpdateArtifactApprovalStepForm.newArtifactApprovalStep}">
					<spring:message code="artifact.approval.workflow.step.creating.title" text="Creating new step"/>
				</c:when>
				<c:otherwise>
					<spring:message code="artifact.approval.workflow.step.editing.title" text="Step {0}" arguments="${createUpdateArtifactApprovalStepForm.artifactApprovalStep.name}" htmlEscape="true"/>
				</c:otherwise>
			</c:choose>
		</ui:pageTitle>
		</ui:breadcrumbs>
</ui:actionMenuBar>

<ui:actionBar>
	<spring:message var="okButton" code="button.ok" text="OK"/>
	&nbsp;&nbsp;<input type="submit" class="button" value="${okButton}" />

	<spring:message var="cancelButton" code="button.cancel" text="Cancel"/>
	&nbsp;&nbsp;<input type="submit" class="button cancelButton" name="_cancel" value="${cancelButton}" />

	<c:if test="${! createUpdateArtifactApprovalStepForm.newArtifactApprovalStep}">
		<spring:message var="deleteButton" code="button.delete" text="Delete..."/>
		&nbsp;&nbsp;<input type="submit" class="button" name="deleteStepSubmit" value="${deleteButton}" onclick="return confirm('<spring:message code="approval.editor.delete.step.confirm"/>');" />
	</c:if>
</ui:actionBar>

<div class="contentWithMargins">
<table width="100%" border="0" cellpadding="0" class="formTableWithSpacing">

<tr>
	<TD class="mandatory" width="10%">
		<spring:message code="artifact.approval.workflow.step.name.label" text="Approval Step Name" />:
		<br/><form:errors path="artifactApprovalStep.name" cssClass="invalidfield"/>
	</td>

	<td nowrap >
		<form:input path="artifactApprovalStep.name" size="60" />
	</td>
</tr>
<tr>
	<TD class="mandatory" width="10%">
		<spring:message code="artifact.approval.workflow.step.approvers.label" text="Approvers" />:
		<br/>
		<form:errors path="approverReferenceIds" cssClass="invalidfield"/>
	</td>

	<td nowrap >
		<spring:message var="approversTitle" code="artifact.approval.workflow.step.approvers.tooltip" text="Select Approvers" />
		<c:if test="${DEBUG}" >
			<pre>
				${createUpdateArtifactApprovalStepForm}
				createUpdateArtifactApprovalStepForm.approverReferenceIds: ${createUpdateArtifactApprovalStepForm.approverReferenceIds}
			</pre>
		</c:if>
		<tag:joinLines>
			<bugs:userSelector ids="${createUpdateArtifactApprovalStepForm.approverReferenceIds}" fieldName="approverReferenceIds"
					onlyCurrentProject="true"
					singleSelect="false" allowRoleSelection="true" title="${approversTitle}"
					setToDefaultLabel="Unset" defaultValue="" showCurrentUser="true"
					specialValueResolver="com.intland.codebeamer.servlet.bugs.selectusers.UserSelectorSpecialValues"
					/>
		</tag:joinLines>
	</td>
</tr>

</table>
</div>

</form:form>
