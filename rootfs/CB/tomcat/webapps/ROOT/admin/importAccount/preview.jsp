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
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>

<%@ taglib uri="uitaglib" prefix="ui" %>

<meta name="decorator" content="main"/>
<meta name="module" content="sysadmin"/>
<meta name="moduleCSSClass" content="sysadminModule newskin"/>

<ui:actionMenuBar>
 	<ui:pageTitle><spring:message code="useradmin.importUsers.preview.title" text="Importing Accounts - Preview"/></ui:pageTitle>
</ui:actionMenuBar>

<style type="text/css">
input[type="checkbox"], input[type="radio"] {
  vertical-align: text-bottom;
}

.newskin tr.highlighted-row td.optional {
	min-width: 10em;
}
</style>

<form:form commandName="importForm" action="${flowUrl}">

<ui:actionBar>
	<spring:message var="nextButton" code="button.save" text="Next &gt;"/>
	<spring:message var="cancelButton" code="button.cancel" text="Cancel"/>

	&nbsp;&nbsp;<input type="submit" class="button" name="_eventId_next" value="${nextButton}" />

	<spring:message var="backButton" code="button.back" text="&lt; Back"/>
	<input type="submit" class="button" name="_eventId_back" value="${backButton}" />

	<input type="submit" class="button linkButton cancelButton" name="_eventId_cancel" value="${cancelButton}" />
</ui:actionBar>

<div class="contentWithMargins">

<form:errors cssClass="error"/>

<TABLE BORDER="0" class="formTableWithSpacing displaytag" CELLPADDING="0" style="width:auto;">

<TR class="highlighted-row">
	<TD class="optional"><spring:message code="useradmin.importUsers.overwrite.label" text="Overwrite"/>:</TD>

	<TD NOWRAP>
		<label for="overwriteCheckbox">
			<form:checkbox path="overwrite" id="overwriteCheckbox"/>
			<spring:message code="useradmin.importUsers.overwrite.tooltip" text="Overwrite/Update existing Accounts."/>
		</label>
	</TD>
</TR>

<TR class="highlighted-row">
	<TD class="optional"><spring:message code="useradmin.importUsers.sendEmails.label" text="Send emails"/>:</TD>

	<TD NOWRAP>
		<label for="sendEmails">
			<form:checkbox path="sendEmails" id="sendEmails"/>
			<spring:message code="useradmin.importUsers.sendEmails.tooltip" />
		</label>
	</TD>
</TR>

<TR class="highlighted-row">
	<TD class="optional"><spring:message code="useradmin.importUsers.roleId.label" text="Assign to Group"/>:</TD>

	<TD NOWRAP>
		<form:select path="groupId" >
			<c:forEach var="userGroup" items="${importForm.userGroups}">
				<spring:message var="groupTitle" code="group.${userGroup.name}.tooltip" text="${userGroup.description}" htmlEscape="true"/>
				<form:option value="${userGroup.id}" title="${groupTitle}" >
					<spring:message code="group.${userGroup.name}.label" text="${userGroup.name}"/>
				</form:option>
			</c:forEach>
		</form:select>
	</TD>
</TR>

<TR>
	<TD class="optional"><spring:message code="useradmin.importUsers.defaultUserType.label" text="Account Type"/>:</TD>

	<TD NOWRAP>
		<form:select path="defaultUserType">
		<c:forEach var="userType" items="${importForm.availableUserTypes}">
			<form:option value="${userType.value}" label="${userType.label}"/>
		</c:forEach>
		</form:select>
	</TD>
</TR>

<TR>
	<TD class="optional"><spring:message code="useradmin.importUsers.defaultStatus.label" text="Set status to"/>:</TD>

	<TD NOWRAP>
		<form:select path="defaultStatus">
			<form:option value="activated"><spring:message code="user.activated" text="activated"/></form:option>
			<form:option value="disabled"><spring:message code="user.disabled" text="disabled"/></form:option>
		</form:select>
	</TD>
</TR>

</TABLE>

<jsp:include page="/bugs/importing/includes/importPreviewFragment.jsp"/>
</div>

</form:form>


