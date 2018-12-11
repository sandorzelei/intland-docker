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
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%@ taglib uri="http://displaytag.sf.net" prefix="display" %>

<%@ taglib uri="taglib" prefix="tag" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="bugstaglib" prefix="bugs" %>
<%@ taglib uri="callTag" prefix="ct" %>

<%@ page import="com.intland.codebeamer.Config"%>
<%@ page import="com.intland.codebeamer.chatops.ChatOpsPlatformImplHelper" %>
<%@ page import="com.intland.codebeamer.controller.ControllerUtils" %>
<%@ page import="com.intland.codebeamer.chatops.notifications.ChatOpsNotificationCreator" %>

<%
	pageContext.setAttribute("chatOpsEnabled", false);
	ChatOpsPlatformImplHelper chatOpsPlatformImplHelper = ControllerUtils.getSpringBean(request, null, ChatOpsPlatformImplHelper.class);
	ChatOpsNotificationCreator chatOpsNotificationCreator = chatOpsPlatformImplHelper.getNotificationCreator();
	if (chatOpsNotificationCreator != null) {
		pageContext.setAttribute("chatOpsEnabled", chatOpsNotificationCreator.isNotificationsEnabled());
	}
%>

<c:url var="actionURL"  value="/proj/scm/repository.spr?repositoryId=${repository.id}&module=notifications"/>
<form:form action="${actionURL}" >

	<c:if test="${canUpdate}">
		<div class="actionBar actionBarWithButtons" style="margin-bottom: 15px;">
			&nbsp; <input type="submit" class="button" name="submit" value="<spring:message code='button.save'/>"></input>
			&nbsp; <input type="submit" class="button" name="__cancel" value="<spring:message code='button.reset'/>"></input>
		</div>
	</c:if>

	<div class="hint" style="margin-bottom:5px;">
		<spring:message code="scm.repository.notifications.explanation" />
	</div>

	<%-- chatOps notification channel setting --%>
	<h2>
		<spring:message code="slack.notifications.notificationChannel.title"></spring:message>
		<span class="subtext">
			<spring:message code="slack.notifications.notificationChannel.pullrequest.hint"></spring:message>
		</span>
		<table class="displaytag notifications">
		<thead>
			<tr>
				<th class="textData columnSeparator">
					<spring:message code="slack.notifications.notificationChannel.subtitle"></spring:message>
				</th>
			</tr>
		</thead>
		<tbody>
			<tr>
				<td>
					<div id="chatOpsNotificationConfigurationDiv"></div>
				</td>
			</tr>
		</tbody>
	</table>
	</h2>

	<%-- roles... --%>
	<h2><spring:message code="project.roles.label" text="Roles" /></h2>
	<ui:selectRolesTable selectedRoleRefs="${subscriberIds}" fieldName="roleIds"
			scope="${repository}" roles="${roles}" disabled="${!canUpdate}"
	/>

	<%-- users... --%>
	<div class="actionBar actionBarWithButtons" style="margin-top: 10px;">
		<spring:message var="filterTitle" code="account.filter.title"/>
		<spring:message var="filterHint" code="filter.input.box.hint" text="Filter..."/>

		<input type="text" width="30" name="userFilter" id="userFilter" value="<c:out value='${param.userFilter}'/>" class="searchFilterBox"/>
		<script type="text/javascript">
			applyHintInputBox("#userFilter", "${filterHint}");
			// submit the form if the enter pressed inside the filter
			$('#userFilter').keypress(function(e) {
				if (e.which == 13) {
					$(this).blur();
					// use the hidden field to differentiate the search submits
					$('#searchSubmit').val("go!");
				}
			});
		</script>
		<input type="hidden" name="SEARCH" id="searchSubmit" />
	</div>

	<h2><spring:message code="project.members.label" text="Members" arguments="${fn:length(users)}" /></h2>
	<c:if test="${canUpdate}">
		<c:set var="checkAllUsers">
			<INPUT TYPE="CHECKBOX" TITLE="${toggleButton}" NAME="SELECT_ALL" VALUE="on"	ONCLICK="setAllStatesFrom(this, 'userIds')"/>
		</c:set>
	</c:if>

	<display:table name="${users}" id="user" cellpadding="0" defaultsort="2">

		<display:setProperty name="basic.msg.empty_list_row">
			<tr class="empty">
				<td colspan="{0}">
					<div class="explanation">
						<spring:message code="account.filter.no.matching.account" />
					</div>
				</td>
			</tr>
		</display:setProperty>

		<display:column title="${checkAllUsers}" media="html" class="checkbox-column-minwidth" headerClass="checkbox-column-minwidth">
			<c:set var="ref" value="<%=com.intland.codebeamer.remoting.GroupType.USER_ACCOUNT%>" />
			<c:set var="ref" value="${ref}-${user.id}" />
			<ct:call object="${subscriberIds}" method="contains" param1="${ref}" return="userSelected"/>
			<input type="checkbox" name="userIds" value="${ref}"
				${userSelected ? "checked='checked'" : "" }
				${!canUpdate ? 'disabled="disabled"' : "" }
			/>
		</display:column>

		<spring:message var="accountTitle" code="user.account.label" text="Account"/>
		<display:column title="${accountTitle}" sortProperty="name" sortable="true"	headerClass="textData" class="textData columnSeparator">
			<tag:userLink user_id="${user.id}" />
		</display:column>

		<spring:message var="nameTitle" code="user.realName.label" text="Name"/>
		<display:column title="${nameTitle}" sortProperty="lastName" sortable="true" headerClass="textData" class="textData columnSeparator">
			<c:out value="${user.firstName} ${user.lastName}" />
		</display:column>

		<c:if test="${canViewCompany}">
			<spring:message var="companyTitle" code="user.company.label" text="Company"/>
			<display:column title="${companyTitle}" sortProperty="company" sortable="true"	headerClass="textData" class="textDataWrap">
				<c:out value="${user.company}" />
			</display:column>
		</c:if>
	</display:table>

</form:form>
<script type="text/javascript" src="<ui:urlversioned value='/chatops/chatOpsNotificationConfiguration.js'/>"></script>
<script type="text/javascript">
	$('#chatOpsNotificationConfigurationDiv').chatOpsNotificationChannelSelector({
		id : ${repository.id},
		name : "<spring:escapeBody javaScriptEscape="true">${repository.name}</spring:escapeBody>" },
	{
		chatOpsEnabled: ${chatOpsEnabled},
		formSubmitButton: $('div.actionBar.actionBarWithButtons > input[name="submit"]')
	});
</script>