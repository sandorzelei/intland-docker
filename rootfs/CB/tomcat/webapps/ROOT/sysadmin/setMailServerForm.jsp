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

<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="uitaglib" prefix="ui" %>

<ui:actionMenuBar>
	<ui:pageTitle><spring:message code="sysadmin.setupEmail.label" text="Outgoing Email Connection"/></ui:pageTitle>
</ui:actionMenuBar>

<form:form autocomplete="off">

<ui:actionBar>
	<spring:message var="saveButton" code="button.save" text="Save"/>
	<spring:message var="cancelButton" code="button.cancel" text="Cancel"/>

	&nbsp;&nbsp;<input type="submit" class="button" value="${saveButton}" />
	&nbsp;&nbsp;<input type="submit" class="cancelButton button" value="${cancelButton}" name="_cancel" />
</ui:actionBar>

<div class="contentWithMargins">
<spring:hasBindErrors name="command">
	<ui:showSpringErrors errors="${errors}" />
</spring:hasBindErrors>

<style type="text/css">
	#formTable td._labelCell {
		white-space: nowrap;
		padding-left: 0.5em;
		padding-right: 0.5em;
	}

	.newskin input[type="checkbox"], .newskin input[type="radio"] {
	    vertical-align: text-bottom;
	}
</style>

<script type="text/javascript">

	$(document).ready(function() {
		codebeamer.prefill.prevent($("input[type=password]"), getBrowserType());
	});

</script>

<TABLE BORDER="0" CELLPADDING="2" class="formTableWithSpacing" WIDTH="600" id="formTable">

<TR>
	<TD COLSPAN="2">
		<c:set var="hostname"><spring:escapeBody htmlEscape="true" >${command.locationURL.hostName}</spring:escapeBody></c:set>
		<spring:message argumentSeparator="|" code="sysadmin.setupEmail.hint" arguments="${licenseCode.type}|${hostname}"/>
	</TD>
</TR>

<spring:nestedPath path="mailServerConfig">
<TR style="margin-top: 4px;">
	<TD CLASS="mandatory _labelCell"><spring:message code="sysadmin.setupEmail.mailServer.label" text="Outgoing SMTP Mail Server"/>:</TD>
	<TD NOWRAP>
		<form:input path="host" size="40" />
		<spring:message code="sysadmin.setupEmail.mailServer.tooltip" text="Enter <STRONG><TT>#</TT></STRONG> to disable Email sending."/>
	</TD>
</TR>

<TR>
	<TD CLASS="optional _labelCell"><spring:message code="sysadmin.setupEmail.user.label" text="Username"/>:</TD>
	<TD><form:input path="user" size="40" /></TD>
</TR>

<TR>
	<TD CLASS="optional _labelCell"><spring:message code="sysadmin.setupEmail.password.label" text="Password"/>:</TD>
	<TD><ui:password path="password" size="40" autocomplete="off" /></TD>
</TR>

<TR>
	<TD CLASS="optional _labelCell"><spring:message code="sysadmin.setupEmail.ssl.label" text="Connection"/>:</TD>
	<TD><form:radiobutton path="connection" id="SSL" value="SSL" />
		<label for="SSL">
			<spring:message code="sysadmin.setupEmail.ssl.connection.label" text="SSL"/>
		</label>

		<form:radiobutton path="connection" id="startTLS" value="startTLS" cssStyle="margin-left:10px;" />
		<label for="startTLS">
			<spring:message code="sysadmin.setupEmail.starttls.connection.label" text="TLS" />
		</label>

		<form:radiobutton path="connection" id="Unsecured" value="Unsecured" cssStyle="margin-left:10px;" />
		<label for="Unsecured">
		    <spring:message code="sysadmin.setupEmail.unsecured.connection.label" text="Unsecured" />
		</label>
	</TD>
</TR>

<TR>
	<TD CLASS="mandatory _labelCell"><spring:message code="sysadmin.setupEmail.port.label" text="Port"/>:</TD>
	<TD><form:input path="port" size="40" /></TD>
</TR>
</spring:nestedPath>

<TR>
	<TD CLASS="optional _labelCell"><spring:message code="sysadmin.setupEmail.checkConnection.label" text="Check"/>:</TD>
	<TD><label for="checkConnection">
        <form:checkbox path="checkConnection" id="checkConnection" /><spring:message code="sysadmin.setupEmail.checkConnection.tooltip" text="Check server connection."/>
        </label>
    </TD>
</TR>

<TR>
	<TD COLSPAN="2">
		<spring:message code="sysadmin.setupEmail.from.tooltip" text="Some Email servers allow only one permanent Email address in 'From' Email header of sent messages from the same host."/>
	</TD>
</TR>

<TR>
	<TD CLASS="optional _labelCell"><spring:message code="sysadmin.setupEmail.from.label" text="Email From"/>:</TD>
	<TD><form:input path="mailServerConfig.fromAddress" size="40" /></TD>
</TR>

<TR>
	<TD CLASS="optional _labelCell"><spring:message code="sysadmin.setupEmail.to.label" text="Test email to"/></TD>
	<TD NOWRAP>
		<spring:message var="testMailButton" code="sysadmin.setupEmail.test.label" text="Send Test Email"/>
		<spring:message var="testMailTitle" code="sysadmin.setupEmail.test.tooltip" text="Test configuration by sending an email to your email address"/>

		<form:input path="testEmailAddress" size="60" />
		<input type="submit" class="button" name="sendTestEmail" value="${testMailButton}" title="${testMailTitle}" />
	</TD>
</TR>

<TR style="margin-top: 1em;">
	<TD COLSPAN="2">
		<spring:message code="sysadmin.setupEmail.locationURL.tooltip" text="Email notifications include links with references to this server."/>
	</TD>
</TR>

<spring:nestedPath path="locationURL">
<TR style="margin-top:4px;">
	<TD CLASS="mandatory _labelCell"><spring:message code="sysadmin.setupEmail.locationURL.hostName.label" text="Server Name"/>:</TD>
	<TD><form:input path="hostName" size="40" /></TD>
</TR>

<TR>
	<TD CLASS="mandatory _labelCell"><spring:message code="sysadmin.setupEmail.locationURL.scheme.label" text="Scheme"/>:</TD>
	<TD>
		<form:select path="scheme">
			<form:option value="http"><spring:message code="sysadmin.setupEmail.locationURL.scheme.http" text="http"/></form:option>
			<form:option value="https"><spring:message code="sysadmin.setupEmail.locationURL.scheme.https" text="https"/></form:option>
		</form:select>
	</TD>
</TR>

<TR>
	<TD CLASS="mandatory _labelCell"><spring:message code="sysadmin.setupEmail.locationURL.port.label" text="Port"/>:</TD>
	<TD><form:input path="port" size="40" /></TD>
</TR>
</spring:nestedPath>

</TABLE>
</div>

</form:form>
