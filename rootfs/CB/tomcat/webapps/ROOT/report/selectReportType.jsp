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
<%@ taglib uri="uitaglib" prefix="ui" %>

<meta name="decorator" content="main"/>
<meta name="module" content="queries"/>
<meta name="moduleCSSClass" content="newskin reportModule"/>


<c:set var="doc_id" value="-1" />
<spring:message var="title" code="report.create.title" text="New Report"/>
<c:if test="${!empty param.doc_id}">
	<c:set var="doc_id" value="${param.doc_id}" />
	<spring:message var="title" code="report.edit.title" text="Edit Report"/>
</c:if>

<ui:actionMenuBar>
		<ui:breadcrumbs showProjects="false"><span class="breadcrumbs-separator">&raquo;</span>
			<ui:pageTitle prefixWithIdentifiableName="false"><spring:message code="report.step1.title" text="{0} - Step 1" arguments="${title}"/></ui:pageTitle>
		</ui:breadcrumbs>
</ui:actionMenuBar>

<html:form action="/proj/report/selectReportType">

<ui:actionBar>
	<html:submit styleClass="button" property="NEXT">
		<spring:message code="button.goOn" text="Next &gt;"/>
	</html:submit>

	&nbsp;&nbsp;
	<html:cancel styleClass="cancelButton">
		<spring:message code="button.cancel" text="Cancel"/>
	</html:cancel>
</ui:actionBar>

<ui:showErrors />

<html:hidden property="page" value="1" />
<html:hidden property="proj_id" />
<html:hidden property="dir_id" />

<c:if test="${doc_id != -1}">
	<html:hidden property="doc_id" value="${doc_id}" />
</c:if>

<logic:messagesNotPresent>
	<c:set target="${addUpdateTrackerReportForm}" property="initialValues" value="${doc_id}" />
</logic:messagesNotPresent>

<fieldset>
	<legend><spring:message code="report.input.label" text="Input"/></legend>
	<TABLE border="0" cellpadding="0" cellspacing="10" >
		<TR>
			<TD>
				<html:radio property="CMDB" value="false" /><spring:message code="report.input.issues" text="Tracker Issues"/><BR />
			</TD>
		</TR>
		<TR>
			<TD>
				<html:radio property="CMDB" value="true" /><spring:message code="report.input.items" text="Configuration items"/><BR />
			</TD>
		</TR>
	</TABLE>
</fieldset>
<br/>
<fieldset>
   <legend><spring:message code="report.output.label" text="Output"/></legend>
	<TABLE border="0" cellpadding="0" cellspacing="10" >
		<TR>
			<TD VALIGN="top">
				<html:radio property="merged" value="false" />
				<spring:message code="report.output.separate" text="Separate result list per tracker"/>
			</TD>
			<TD>
				<A HREF="#" ONCLICK="document.addUpdateTrackerReportForm.merged[0].checked=true;return false;"><html:img page="/images/simple_report.gif" alt="Simple Report" width="255" height="105" border="0"/></A>
			</TD>
		</TR>
		<TR>
			<TD VALIGN="top">
				<html:radio property="merged" value="true" />
				<spring:message code="report.output.merged" text="Merged result list over all trackers/categories"/>
			</TD>
			<TD>
				<A HREF="#" ONCLICK="document.addUpdateTrackerReportForm.merged[1].checked=true;return false;"><html:img page="/images/merged_report.gif" alt="Merged Report" width="255" height="105" border="0"/></A>
			</TD>
		</TR>
	</TABLE>
</fieldset>

</html:form>
