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
<meta name="module" content="sysadmin"/>
<meta name="moduleCSSClass" content="sysadminModule newskin"/>

<%-- Spring based inbox administration jsp page --%>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>


<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>

<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="bugstaglib" prefix="bugs" %>

<%@ page import="com.intland.codebeamer.inbox.MailReceiver"%>
<%@ page import="com.intland.codebeamer.persistence.dto.InboxDto" %>

<SCRIPT type="text/javascript">
	function confirmDelete(form) {
		return confirm('<spring:message code="inbox.admin.delete.inbox.confirm" />');
	}

	$(document).ready(function() {
		codebeamer.prefill.prevent($("input[type=password]"), getBrowserType());
	});
</SCRIPT>

<style type="text/css">
	.validfield {
		margin-top: 4px;
	}

	.validfield {
		padding: 6px;
		background: #A9F5A9;
		color: #0B610B !important;
		font-size: 8pt;
		font-weight: bold;
	}

	textarea.code {
		font-family: monospace;
	}

	.CodeMirror{
		border: solid 1px #d1d1d1;
	}
</style>

<ui:actionMenuBar>
	<ui:pageTitle><spring:message code="sysadmin.inboxes.config.title" text="Email Inbox configuration"/></ui:pageTitle>
</ui:actionMenuBar>

<c:url var="actionURL" value="/sysadmin/configAnInbox.spr" />
<form:form action="${actionURL}" commandName="inboxForm" name="inboxForm" autocomplete="off">

<ui:actionBar>
	<spring:message var="saveButton" code="button.save" text="Save"/>
	<spring:message var="cancelButton" code="button.cancel" text="Cancel"/>
	<spring:message var="testButton" code="sysadmin.inboxes.test.button" text="Test Connection"/>
	<spring:message var="testTitle" code="sysadmin.inboxes.test.tooltip" text="Test if configured email server can be connected"/>

	&nbsp;&nbsp;
	<input type="submit" class="button" name="addOrSaveAction" value="${saveButton}" />

	<c:if test="${! inboxForm.newInbox}">
		<spring:message var="deleteButton" code="button.delete" text="Delete..."/>
		&nbsp;&nbsp;
		<input type="submit" class="button" name="deleteAction" value="${deleteButton}" onclick="return confirmDelete(this);"	/>
	</c:if>

	&nbsp;&nbsp;
	<input type="submit" class="button" name="testConnectionAction" value="${testButton}" title="${testTitle}" />

	&nbsp;&nbsp;
	<input type="submit" class="button cancelButton" name="_cancel" value="${cancelButton}" />
</ui:actionBar>

<div class="contentWithMargins">

<%-- global errors --%>
<p>
<c:if test="${! inboxForm.testConnectionSuccess}">
	<form:errors cssClass="invalidfield" />
</c:if>
<c:if test="${inboxForm.testConnectionSuccess}">
	<form:errors cssClass="validfield" />
</c:if>
</p>

<spring:nestedPath path="inboxDto">

<TABLE BORDER="0" CELLPADDING="2" style="border-collapse: separate;border-spacing: 1px;">
<TR>
	<TD CLASS="mandatory">
		<spring:message code="inbox.name.label" text="Name"/>:
		<form:errors path="name" cssClass="invalidfield2" element="div"/>
	</TD>

	<TD CLASS="expandText" valign="top">
		<form:input size="50" path="name" cssClass="expandText" />
	</TD>
</TR>

<TR>
	<TD CLASS="mandatory" VALIGN="top">
		<spring:message code="inbox.description.label" text="Description"/>:
		<form:errors path="description" cssClass="invalidfield2" element="div"/>
	</TD>

	<TD CLASS="expandTextArea" valign="top">
		<form:textarea rows="8" cols="80" path="description" cssClass="expandTextArea" />
	</TD>
</TR>

<%-- email is required for default/main inbox --%>
<c:set var="emailCSSClass" value="optional" />
<c:if test="${inboxForm.inboxDto.defaultInbox}">
	<c:set var="emailCSSClass" value="mandatory" />
</c:if>

<TR>
	<TD CLASS="${emailCSSClass}">
		<spring:message code="inbox.email.label" text="Email Address"/>:
		<form:errors path="email" cssClass="invalidfield2" element="div"/>
	</TD>

	<TD CLASS="expandText">
		<form:input size="50" path="email" cssClass="expandText" />
	</TD>
</TR>

<TR>
	<TD CLASS="mandatory" >
		<spring:message code="inbox.account.label" text="Account"/>:
		<form:errors path="account" cssClass="invalidfield2" element="div"/>
	</TD>

	<TD CLASS="expandText" valign="top">
		<form:input size="50" path="account" cssClass="expandText" />
	</TD>
</TR>

<TR>
	<TD CLASS="optional"><spring:message code="inbox.passwd.label" text="Password"/>:</TD>
	<TD CLASS="expandText">
		<ui:password size="50" path="passwd" cssClass="expandText" autocomplete="off" />
	</TD>
</TR>

<TR>
	<TD CLASS="mandatory">
		<spring:message code="inbox.server.label" text="Server"/>:
		<form:errors path="server" cssClass="invalidfield2" element="div"/>
	</TD>

	<TD CLASS="expandText" valign="top">
		<spring:message var="inboxServerTitle" code="inbox.server.tooltip" text="Enter host name for mail server (optionally add port as host:port)"/>
		<form:input size="50" path="server" cssClass="expandText" title="${inboxServerTitle}" />
	</TD>
</TR>

<TR>
	<TD CLASS="mandatory"><spring:message code="inbox.protocol.label" text="Protocol"/>:</TD>
	<TD>
		<form:select path="protocol">
			<form:option value="<%=MailReceiver.POP3%>"><spring:message code="inbox.protocol.pop3" text="POP3"/></form:option>
			<form:option value="<%=MailReceiver.IMAP%>"><spring:message code="inbox.protocol.imap" text="IMAP"/></form:option>
		</form:select>
	</TD>
</TR>

<TR>
	<TD CLASS="optional"><spring:message code="inbox.useSsl.label" text=">Connection"/>:</TD>
	<TD>
		<form:checkbox path="useSsl" id="useSsl" />
		<label for="useSsl">
			<spring:message code="inbox.useSsl.tooltip" text=">Secure connection (SSL)"/>
		</label>
		<input type="hidden" name="_inboxDto.useSsl" value="false" />
	</TD>
</TR>

<c:set var="tooltip"><spring:message code='inbox.folderName.tooltip'/></c:set>
<TR title="${tooltip}" >
	<TD CLASS="optional"><spring:message code="inbox.folderName.label" text=">Folder"/>:</TD>
	<TD>
		<form:input title="${tooltip}" path="folderName" maxlength="100"/>
	</TD>
</TR>

<TR VALIGN="top">
	<TD CLASS="optional"><spring:message code="inbox.allowedEmails.label" text=">Allowed Email Addresses"/>:</TD>
	<TD>
		<form:radiobutton path="allowedEmails" value="<%=InboxDto.ALLOWED_EMAILS_ALL%>" id="allowed_all" />
		<label for="allowed_all"><spring:message code="inbox.allowedEmails.all" text="All"/><BR></label>
		<form:radiobutton path="allowedEmails" value="<%=InboxDto.ALLOWED_EMAILS_ALL_CB%>" id="allowed_all_cb"/>
		<label for="allowed_all_cb"><spring:message code="inbox.allowedEmails.users" text="Only registered Users"/><BR></label>
		<form:radiobutton path="allowedEmails" value="<%=InboxDto.ALLOWED_EMAILS_PROJECT_MEMBERS%>" id="allowed_project_members" />
		<label for="allowed_project_members"><spring:message code="inbox.allowedEmails.members" text="Only Project Members"/><BR></label>
	</TD>
</TR>

<TR>
	<TD CLASS="optional"><spring:message code="inbox.extraAllowedEmails.label" text="Additional Email Addresses"/>:</TD>
	<TD CLASS="expandText">
		<spring:message code="email.multiple.tooltip" var="email_tooltip" />
		<form:input size="50" path="extraAllowedEmails" cssClass="expandText" title="${email_tooltip}" />
	</TD>
</TR>

<spring:message var="infoxDefaultUser" code="inboxForm.defaultUser.tooltip" text="Select a default user for unknown email addresses"/>
<TR title="${infoxDefaultUser}">
	<TD CLASS="mandatory" valign="middle">
		<spring:message code="inboxForm.defaultUser.label" text="Default user"/>:
	</TD>
	<TD CLASS="expandText">
		<c:set var="ids" value="${inboxForm.defaultUser}"/>
		<spring:message var="defaultUserTitle" code="inboxForm.defaultUser.title" text="Choose default user"/>
		<div style="width: 20em;">
			<bugs:userSelector ids="${ids}" fieldName="defaultUser" useAllProjects="true" singleSelect="true"
					allowRoleSelection="false" title="${defaultUserTitle}" />
		</div>
        <form:errors path="defaultUserId" cssClass="invalidfield2" element="div"/>
	</TD>
</TR>

<TR>
	<TD CLASS="optional"><spring:message code="inbox.enabled.label" text="Enabled"/>:</TD>
	<TD>
		<spring:message var="inboxEnabledTitle" code="inbox.enabled.tooltip" text="If the inbox is enabled and will be periodically polled."/>
		<form:checkbox path="enabled" title="${inboxEnabledTitle}"  />
		<input type="hidden" path="_inboxDto.enabled" value="false" />
	</TD>
</TR>

<c:if test="${! inboxForm.inboxDto.defaultInbox}">
<TR>
	<TD CLASS="optional" VALIGN="top">
		<spring:message code="issue.import.advanced.conversion.ScriptConverter.language" text="Script language"/>:
		<form:errors path="inboxScriptType" cssClass="invalidfield2" element="div"/>
	</TD>

	<TD CLASS="expandTextArea" valign="top">
		<form:select id="inboxScriptType" path="inboxScriptType" items="${inboxForm.scriptLanguages}" itemLabel="name" itemValue="value"
			onchange="initAdvancedEditor();"
		/>
	</TD>
</TR>

<TR>
	<TD CLASS="optional" VALIGN="top">
		<spring:message code="inbox.script.label" text="Inbox Processor Script"/>:
		<form:errors path="inboxProcessorScript" cssClass="invalidfield2" element="div"/>
	</TD>

	<TD CLASS="expandTextArea" valign="top">
		<form:textarea id="inboxProcessorScript" rows="20" cols="80" path="inboxProcessorScript" cssClass="expandTextArea code" />
	</TD>
</TR>
</c:if>

</TABLE>

</spring:nestedPath>
</div>

</form:form>

<head>
	<script src="<ui:urlversioned value="/wro/codemirror.js"/>"></script>
	<link rel="stylesheet" href="<ui:urlversioned value="/wro/codemirror.css"/>">
</head>

<script type="text/javascript">
// init codemirror syntax highlighting editor
var advancedEditor = null;

var initAdvancedEditor = function() {
	if (advancedEditor != null) {
		advancedEditor.off();
		advancedEditor.toTextArea();
		advancedEditor = null;
	}
	var $textarea = $("#inboxProcessorScript");
	var mode = "";
	var inboxScriptType = $("#inboxScriptType").val().toLowerCase();
	if (inboxScriptType == "groovy") {
		mode = "text/x-groovy";
	}
	if (inboxScriptType == "javascript") {
		mode = "text/javascript";
	}

	if (mode != "") {
		advancedEditor = CodeMirror.fromTextArea($textarea.get(0), {
			mode: mode,
			lineNumbers: true,
			matchBrackets: true,
			indentWithTabs: true,
			autofocus: true,
			lineWrapping: true
		});
	}
}

$(initAdvancedEditor);
</script>

