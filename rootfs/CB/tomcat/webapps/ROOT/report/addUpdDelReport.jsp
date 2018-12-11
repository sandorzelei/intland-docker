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
<%@ taglib uri="http://struts.apache.org/tags-logic" prefix="logic" %>

<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>

<%@ taglib uri="acltaglib" prefix="acl" %>
<%@ taglib uri="wysiwyg" prefix="wysiwyg" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="bugstaglib" prefix="bugs" %>

<%@page import="com.intland.codebeamer.servlet.report.AddUpdateTrackerReportForm"%>

<wysiwyg:froalaConfig />

<meta name="decorator" content="main"/>
<meta name="module" content="${module}"/>
<meta name="moduleCSSClass" content="newskin ${moduleCSSClass}"/>

<head>
<style type="text/css">
	.editor-wrapper:not(.fr-fake-popup-editor) {
        margin-bottom: 10px;
	}
</style>
</head>

<c:set var="doc_id" value="-1" />
<spring:message var="title" code="report.create.${CMDB ? 'item' : 'issue'}.title"/>
<c:if test="${!empty param.doc_id}">
	<c:set var="doc_id" value="${param.doc_id}" />
	<spring:message var="title" code="report.edit.${CMDB ? 'item' : 'issue'}.title"/>
</c:if>
<spring:message var="anyButton" code="tracker.filter.any.button" htmlEscape="true"/>

<ui:actionMenuBar>
		<ui:breadcrumbs showProjects="false"><span class='breadcrumbs-separator'>&raquo;</span>
			<ui:pageTitle prefixWithIdentifiableName="false"><spring:message code="report.step4.title" text="{0} - Step 4" arguments="${title}"/></ui:pageTitle>
		</ui:breadcrumbs>
</ui:actionMenuBar>

<html:form action="/proj/report/addUpdateReport" focus="reportName" styleId="addUpdateTrackerReportForm">

<html:hidden property="page" value="4" />
<html:hidden property="proj_id" />
<html:hidden property="dir_id" />

<c:if test="${doc_id != -1}">
	<html:hidden property="doc_id" value="${doc_id}" />
</c:if>

<ui:actionBar>
	<html:submit styleClass="button" property="PREVIOUS">
		<spring:message code="button.back" text="&lt; Back"/>
	</html:submit>
	&nbsp;&nbsp;
	<html:submit styleClass="button" property="NEXT">
		<spring:message code="button.goOn" text="Next &gt;"/>
	</html:submit>
	&nbsp;&nbsp;
	<html:cancel styleClass="cancelButton">
		<spring:message code="button.cancel" text="Cancel"/>
	</html:cancel>
	&nbsp;&nbsp;
</ui:actionBar>

<ui:showErrors />

<%--
<logic:messagesNotPresent>
	<c:set target="${addUpdateTrackerReportForm}" property="initialValues" value="${doc_id}" />
</logic:messagesNotPresent>
--%>

<TABLE BORDER="0" class="formTableWithSpacing" CELLPADDING="2">

<TR>
	<TD class="mandatory"><spring:message code="document.name.label" text="Name"/>:</TD>
	<TD CLASS="expandText">
		<html:text styleClass="expandText" size="80" maxlength="255" property="reportName"/>
	</TD>
</TR>

<TR valign="top">
	<TD VALIGN="top" class="mandatory">
		<spring:message code="document.description.label" text="Description"/>:
	</TD>

	<TD CLASS="expandTextArea">
		<wysiwyg:editor editorId="editor" formatSelectorStrutsProperty="descriptionFormat" useAutoResize="false" height="110" overlayHeaderKey="wysiwyg.vintage.report.description.editor.overlay.header">
			<html:textarea rows="6" cols="90" property="reportDescription" styleId="editor" />
		</wysiwyg:editor>
	</TD>
</TR>

<TR valign="middle">
	<TD class="optional" ><spring:message code="tracker.field.Submitted at.label" text="Submitted"/>:</TD>

	<TD NOWRAP="nowrap">
		<ui:duration property="submittedAtDuration" value="${addUpdateTrackerReportForm.submittedAtDuration}">
			&nbsp;<spring:message code="duration.after.label" text="After"/>:
			<html:text property="submittedAtFrom" size="12" maxlength="30" styleId="submittedAtFrom" />&nbsp;
			<ui:calendarPopup textFieldId="submittedAtFrom" otherFieldId="submittedAtTo"/>

			&nbsp;<spring:message code="duration.before.label" text="Before"/>:
			<html:text property="submittedAtTo" size="12" maxlength="30" styleId="submittedAtTo" />&nbsp;
			<ui:calendarPopup textFieldId="submittedAtTo" otherFieldId="submittedAtFrom"/>
		</ui:duration>
	</TD>
</TR>

<TR valign="middle">
	<TD class="optional"><spring:message code="tracker.field.Start Date.label" text="Start Date"/>:</TD>

	<TD NOWRAP="nowrap">
		<ui:duration property="startDateDuration" value="${addUpdateTrackerReportForm.startDateDuration}">
			&nbsp;<spring:message code="duration.after.label" text="After"/>:
			<html:text property="startDateFrom" size="12" maxlength="30" styleId="startDateFrom" />&nbsp;
			<ui:calendarPopup textFieldId="startDateFrom" otherFieldId="startDateTo"/>

			&nbsp;<spring:message code="duration.before.label" text="Before"/>:
			<html:text property="startDateTo" size="12" maxlength="30" styleId="startDateTo" />&nbsp;
			<ui:calendarPopup textFieldId="startDateTo" otherFieldId="startDateFrom"/>
		</ui:duration>
	</TD>
</TR>

<TR valign="middle">
	<TD class="optional"><spring:message code="tracker.field.End Date.label" text="End Date"/>:</TD>

	<TD NOWRAP="nowrap">
		<ui:duration property="endDateDuration" value="${addUpdateTrackerReportForm.endDateDuration}">
			&nbsp;<spring:message code="duration.after.label" text="After"/>:
			<html:text property="endDateFrom" size="12" maxlength="30" styleId="endDateFrom" />&nbsp;
			<ui:calendarPopup textFieldId="endDateFrom" otherFieldId="endDateTo"/>

			&nbsp;<spring:message code="duration.before.label" text="Before"/>:
			<html:text property="endDateTo" size="12" maxlength="30" styleId="endDateTo" />&nbsp;
			<ui:calendarPopup textFieldId="endDateTo" otherFieldId="endDateFrom"/>
		</ui:duration>
	</TD>
</TR>

<TR valign="middle">
	<TD class="optional"><spring:message code="tracker.field.Closed at.label" text="Closed"/>:</TD>

	<TD NOWRAP="nowrap">
		<ui:duration property="closedAtDuration" value="${addUpdateTrackerReportForm.closedAtDuration}">
			&nbsp;<spring:message code="duration.after.label" text="After"/>:
			<html:text property="closedAtFrom" size="12" maxlength="30" styleId="closedAtFrom" />&nbsp;
			<ui:calendarPopup textFieldId="closedAtFrom" otherFieldId="closedAtTo"/>

			&nbsp;<spring:message code="duration.before.label" text="Before"/>:
			<html:text property="closedAtTo" size="12" maxlength="30" styleId="closedAtTo" />&nbsp;
			<ui:calendarPopup textFieldId="closedAtTo" otherFieldId="closedAtFrom"/>
		</ui:duration>
	</TD>
</TR>

<TR valign="middle">
	<TD class="optional"><spring:message code="tracker.field.Modified at.label" text="Last Modified"/>:</TD>

	<TD NOWRAP="nowrap">
		<ui:duration property="lastModifiedAtDuration" value="${addUpdateTrackerReportForm.lastModifiedAtDuration}">
			&nbsp;<spring:message code="duration.after.label" text="After"/>:
			<html:text property="lastModifiedAtFrom" size="12" maxlength="30" styleId="lastModifiedAtFrom" />&nbsp;
			<ui:calendarPopup textFieldId="lastModifiedAtFrom" otherFieldId="lastModifiedAtTo"/>

			&nbsp;<spring:message code="duration.before.label" text="Before"/>:
			<html:text property="lastModifiedAtTo" size="12" maxlength="30" styleId="lastModifiedAtTo" />&nbsp;
			<ui:calendarPopup textFieldId="lastModifiedAtTo" otherFieldId="lastModifiedAtFrom"/>
		</ui:duration>
	</TD>
</TR>

<TR>
	<TD class="optional" nowrap>
		<spring:message code="tracker.field.Submitted by.label" text="Submitted by"/>:<br/>
		<html:checkbox styleId="notSubmittedBy" property="negateSubmittedBy"/>
		<label for="notSubmittedBy"><spring:message code="tracker.view.not.label" text="Not"/></label>&nbsp;
	</TD>

	<TD CLASS="expandText" NOWRAP="nowrap" valign="middle">
		<c:set var="ids" value="${addUpdateTrackerReportForm.submittedByReferenceIds}" />
		<bugs:userSelector ids="${ids}" fieldName="submittedByReferenceIds" showCurrentUser="true" allowRoleSelection="true"
				projectList="${addUpdateTrackerReportForm.selectedProjectList}"
				setToDefaultLabel="${anyButton}" defaultValue="<%=AddUpdateTrackerReportForm.ANY_VALUE%>"
				specialValueResolver="com.intland.codebeamer.servlet.report.AddUpdateTrackerReportFormSpecialValues" />
	</TD>
</TR>

<TR>
	<TD class="optional" nowrap>
		<spring:message code="tracker.field.Modified by.label" text="Modified by"/>:<br/>
		<html:checkbox styleId="notModifiedBy" property="negateModifiedBy"/>
		<label for="notModifiedBy"><spring:message code="tracker.view.not.label" text="Not"/></label>&nbsp;
	</TD>

	<TD CLASS="expandText" NOWRAP="nowrap" valign="middle">
		<c:set var="ids" value="${addUpdateTrackerReportForm.modifiedByReferenceIds}" />
		<bugs:userSelector ids="${ids}" fieldName="modifiedByReferenceIds" showUnset="true" showCurrentUser="true" allowRoleSelection="true"
				projectList="${addUpdateTrackerReportForm.selectedProjectList}"
				setToDefaultLabel="${anyButton}" defaultValue="<%=AddUpdateTrackerReportForm.ANY_VALUE%>"
				specialValueResolver="com.intland.codebeamer.servlet.report.AddUpdateTrackerReportFormSpecialValues" />
	</TD>
</TR>

<TR>
	<TD class="optional" nowrap>
		<spring:message code="tracker.field.Assigned to.label" text="Assigned to"/>:<br/>
		<html:checkbox styleId="notAssignedTo" property="negateAssignedTo"/>
		<label for="notAssignedTo"><spring:message code="tracker.view.not.label" text="Not"/></label>&nbsp;
	</TD>

	<TD CLASS="expandText" NOWRAP="nowrap">
		<c:set var="ids" value="${addUpdateTrackerReportForm.assignedToReferenceIds}" />
		<bugs:userSelector ids="${ids}" fieldName="assignedToReferenceIds" showUnset="true" showCurrentUser="true" allowRoleSelection="true"
				projectList="${addUpdateTrackerReportForm.selectedProjectList}"
				setToDefaultLabel="${anyButton}" defaultValue="<%=AddUpdateTrackerReportForm.ANY_VALUE%>"
				specialValueResolver="com.intland.codebeamer.servlet.report.AddUpdateTrackerReportFormSpecialValues" />
	</TD>
</TR>

<TR>
	<TD class="optional" nowrap>
		<spring:message code="tracker.field.Supervisor.label" text="Supervised by"/>:<br/>
		<html:checkbox styleId="notSupervisor" property="negateSupervisor"/>
		<label for="notSupervisor"><spring:message code="tracker.view.not.label" text="Not"/></label>&nbsp;
	</TD>

	<TD CLASS="expandText" NOWRAP="nowrap">
		<c:set var="ids" value="${addUpdateTrackerReportForm.supervisorReferenceIds}" />
		<bugs:userSelector ids="${ids}" fieldName="supervisorReferenceIds" showUnset="true" showCurrentUser="true" allowRoleSelection="true"
				projectList="${addUpdateTrackerReportForm.selectedProjectList}"
				setToDefaultLabel="${anyButton}" defaultValue="<%=AddUpdateTrackerReportForm.ANY_VALUE%>"
				specialValueResolver="com.intland.codebeamer.servlet.report.AddUpdateTrackerReportFormSpecialValues" />
	</TD>
</TR>

</TABLE>

</html:form>
