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

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="acltaglib" prefix="acl" %>
<%@ taglib uri="taglib" prefix="tag" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="bugstaglib" prefix="bugs" %>

<style>
	.userSelector {
		display: inline-block;
		width: 300px;
	}

	.userSelector > table {
		margin: 0px;
		border: 1px solid #d1d1d1;
	}

</style>

<ui:actionMenuBar>
	<ui:pageTitle><spring:message code="sysadmin.userRegistration.title" text="User Registration" /></ui:pageTitle>
</ui:actionMenuBar>

<html:form action="/sysadmin/miscAction">

<ui:actionBar>
	<spring:message var="saveButton" code="button.save" text="Save"/>
	<spring:message var="cancelButton" code="button.cancel" text="Cancel"/>

	&nbsp;&nbsp;&nbsp;&nbsp;<html:submit styleClass="button" property="SAVE" value="${saveButton}" />
	&nbsp;&nbsp;<html:cancel styleClass="button cancelButton" value="${cancelButton}" />
</ui:actionBar>

<div class="contentWithMargins">
<ui:showErrors />

<TABLE BORDER="0" CELLPADDING="2" class="formTableWithSpacing">

<TR VALIGN="top">
	<TD class="mandatory" valign="middle"><spring:message code="sysadmin.userRegistration.registration.label" text="New Account" />:</TD>

	<TD>
		<html:radio property="registration" value="${SYSADMIN_REGISTRATION}" />
		<spring:message code="sysadmin.userRegistration.registration.adminOnly" text="Only accounts with account administration permission can create new accounts." />
		<BR>
		<html:radio property="registration" value="${IMMEDIATE_REGISTRATION}" />
		<spring:message code="sysadmin.userRegistration.registration.immediate" text="Anybody can create a new Account. Immediate account activation." />
		<BR>
		<html:radio property="registration" value="${EMAIL_REGISTRATION}" />
		<spring:message code="sysadmin.userRegistration.registration.validEmail" text="Anybody can create a new Account. The email address will be verified by email before the account gets activated." />
	</TD>
</TR>

<acl:isUserInRole value="account_admin">
	<TR>
		<TD class="optional"><spring:message code="sysadmin.userRegistration.defaultAccountType.label" text="Default Type of new Accounts" />:</TD>

		<TD NOWRAP>&nbsp;
			<html:select property="defaultAccountType">
				<html:optionsCollection property="availableAccountTypes" />
			</html:select>
		</TD>
	</TR>
	<TR>
		<TD class="mandatory"><spring:message code="sysadmin.userRegistration.defaultAccountGroup.label" text="Assign new Accounts to Groups" />:</TD>

		<TD valign="middle">
			<c:forEach items="${userGroups}" var="userGroup">
                <spring:message var="groupTitle" code="group.${userGroup.name}.tooltip" text="${userGroup.shortDescription}" htmlEscape="true"/>
                <label title="${groupTitle}">
                    <html:multibox property="role" value="${userGroup.id}" />
                    <spring:message code="group.${userGroup.name}.label" text="${userGroup.name}"/>
                </label>
			</c:forEach>
		</TD>
	</TR>
</acl:isUserInRole>

<TR>
	<TD class="optional"><spring:message code="sysadmin.userRegistration.anonymousUser.label" text="Anonymous User" />:</TD>

	<TD CLASS="expandTextArea">
		<bugs:userSelector htmlId="userSelector" singleSelect="true" allowRoleSelection="false" title=""
														setToDefaultLabel="" defaultValue="" ids="${anonymousUser}" fieldName="anonymousUser"
														searchOnAllUsers="true" showPopupButton="false" onlyMembers="false" allowUserSelection="true"
														useAllProjects="true" ignoreCurrentProject="true" includeDisabledUsers="false" acceptEmail="true"/>

	</TD>
</TR>

<TR>
	<TD class="mandatory"><spring:message code="sysadmin.userRegistration.notificationFrom.label" text="Registration Message Sender" />:</TD>

	<TD CLASS="expandTextArea"><html:text size="70" styleClass="expandText" property="notificationFrom" /></TD>
</TR>

<TR>
	<TD class="mandatory"><spring:message code="sysadmin.userRegistration.notificationAddress.label" text="Notify after Account Activation" />:</TD>

	<TD CLASS="expandTextArea"><html:text size="70" styleClass="expandText" property="notificationAddress" /></TD>
</TR>

<TR VALIGN="top">
	<TD class="optional"><spring:message code="sysadmin.userRegistration.disallowedAddresses.label" text="Disallowed User Email Addresses" />:</TD>

	<TD CLASS="expandTextArea"><html:textarea styleClass="expandTextArea" property="disallowedAddresses" rows="2" cols="70" /></TD>
</TR>

<TR VALIGN="top">
	<TD class="optional"><spring:message code="sysadmin.userRegistration.registrationConfirmationSubject.label" text="Registration confirmation mail subject" /></TD>
	<TD CLASS="expandTextArea"><html:textarea styleClass="expandTextArea" property="registrationEmailSubject" rows="3" cols="70" /></TD>
</TR>

<TR VALIGN="top">
	<TD class="optional"><spring:message code="sysadmin.userRegistration.registrationConfirmationText.label" text="Registration confirmation mail" /></TD>
	<TD CLASS="expandTextArea"><html:textarea styleClass="expandTextArea" property="registrationConfirmationText" rows="12" cols="70" /></TD>
</TR>

<TR>
	<TD class="optional"><spring:message code="sysadmin.userRegistration.cookiesAllowed.label" text="Automatic Login" />:</TD>

	<TD>
		<html:checkbox property="cookiesAllowed" />
		<spring:message code="sysadmin.userRegistration.cookiesAllowed.tooltip" text="Login Cookies Allowed" />
	</TD>
</TR>

<TR>
	<TD class="optional"><spring:message code="sysadmin.userRegistration.accountAutoLoginFromRequestHeader.label" text="Single Sign-on by HTTP Request Header" />:</TD>

	<TD CLASS="expandTextArea">
		<html:checkbox property="accountAutoLoginFromRequestHeaderEnabled" />
		<spring:message code="sysadmin.userRegistration.accountAutoLoginFromRequestHeaderEnabled.label" text="Enabledr" />
	</TD>
</TR>

<TR>
	<TD/>

	<TD CLASS="expandTextArea">
		<html:text size="70" styleClass="expandText" property="accountAutoLoginFromRequestHeader" />
	</TD>
</TR>

<TR>
	<TD class="optional"><spring:message code="sysadmin.userRegistration.displayLastAccountActivityDate.label" text="Account Activity Date" />:</TD>
	<TD>
		<html:checkbox property="displayLastAccountActivityDate" />
		<spring:message code="sysadmin.userRegistration.displayLastAccountActivityDate.tooltip" text="Providing Accounts Last Activity Date" />
	</TD>
</TR>

</TABLE>

</html:form>
</div>