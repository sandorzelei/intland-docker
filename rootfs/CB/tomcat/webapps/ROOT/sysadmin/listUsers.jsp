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
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="taglib"   prefix="tag" %>
<%@ taglib uri="uitaglib" prefix="ui" %>

<%@ taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>

<%-- set exportAccounts="true" to export accounts --%>
<c:set var="exportAccounts" value="true" />
<c:url var="excelExportUri" value="/sysadmin/excelExport.spr" />

<SCRIPT language="JavaScript" type="text/javascript">
<!--
function filterAccount(event) {
	// consume the event to prevent default behaviour.
	var evt = new org.ditchnet.event.Event(event);
	evt.consume();

	var filterBtn = document.getElementById('filterBtn');
	filterBtn.click();
}
// -->

function submitExcelExport(){
	var form = $("#filter-form");
	var originalUrl = form.attr("action");
	form.attr("action", "${excelExportUri}");
	form.submit();
	form.attr("action", originalUrl)
}

</SCRIPT>

<style type="text/css">
.importResultLinks {
	display: block !important;
}
</style>

<ui:pageTitle printBody="false">
	<spring:message code="useradmin.title" text="User Accounts"/>
</ui:pageTitle>

<c:url var="requestURI" value="/sysadmin/users.spr" />

<form:form action="${requestURI}" method="get" id="filter-form">
	<ui:actionMenuBar verticalMiddleAlign="false">
		<table height="100%">
			<tr valign="middle">
				<td valign="middle" width="100%" height="100%">
					<span class="titlenormal">
						<c:choose>
							<c:when test="${licenseCode.enabled.userGroups}">
								<select id="groupSelector" name="groupId" onchange="$('#filterBtn').click();">
									<option value="">
										<spring:message code="useradmin.users.label" text="Accounts"/> (<c:out value="${userCount}"/>)
									</option>
									<c:forEach items="${groups}" var="group">
										<c:choose>
											<c:when test="${group.name eq 'sysadmin' or empty group.shortDescription}">
												<spring:message var="groupTitle" code="group.${group.name}.tooltip" text="" htmlEscape="true"/>
											</c:when>
											<c:otherwise>
												<c:set var="groupTitle">
													<c:out value="${group.shortDescription}" />
												</c:set>
											</c:otherwise>
										</c:choose>

										<option value="${group.id}" title="${groupTitle}" <c:if test="${groupId eq group.id}">selected="selected"</c:if>>
											<spring:message code="group.${group.name}.label" text="${group.name}"/> (<c:out value="${groupMembers[group.id]}"/>)
										</option>
									</c:forEach>
								</select>
							</c:when>
							<c:otherwise>
								<spring:message code="useradmin.users.label" text="Accounts"/> (<c:out value="${userCount}"/>)
							</c:otherwise>
						</c:choose>

						<spring:message var="title" code="useradmin.user.active.filter.title" text="Filter by activation" />
						<form:select path="activeFilter" onchange="$('#filterBtn').click();" title="${title}">
							<form:option value=""><spring:message code="useradmin.user.active.filter.all" text="All"/></form:option>
							<form:option value="active"><spring:message code="useradmin.user.active.filter.active" text="Active"/></form:option>
							<form:option value="inactive"><spring:message code="useradmin.user.active.filter.inactive" text="Inactive"/></form:option>
						</form:select>
					</span>
				</td>
				<td valign="middle" nowrap>
					<form:select path="listType">
						<form:option value="short">
							<spring:message code="useradmin.briefList" text="Brief list" />
						</form:option>
						<form:option value="long">
							<spring:message code="useradmin.detailedList" text="Detailed list" />
						</form:option>
					</form:select>

					<label>
						<spring:message code="useradmin.filter.label" text="Filter" />
						<form:input type="text" path="userFilter" size="30" title="${filter_tooltip}" onkeydown="if(enterBtnPressed(event)) filterAccount(event);" />
					</label>

					<spring:message var="filterLabel"   code="search.submit.label" text="GO" />
					<spring:message var="filterTooltip" code='account.filter.title' />
					<input id="filterBtn" type="submit" class="button" value="${filterLabel}" title="${filterTooltip}"/>
				</td>
			</tr>
		</table>
	</ui:actionMenuBar>
</form:form>

<ui:actionBar>
	<c:url var="newAccountURL" value="/createUser.spr" />
	<a class="actionLink" href='${newAccountURL}'><spring:message code="useradmin.newUser.label" text="New Account" /></a>

	<c:if test="${not empty groupId && licenseCode.enabled.userGroups}">
		<c:url var="assignMembersToGroupsURL" value="/sysadmin/assignMembersToGroup.spr?groupId=${groupId}" />
		<a class="actionLink" href="#" onclick="showPopupInline('${assignMembersToGroupsURL}', { height: 600 }); return false;">
			<spring:message code="project.role.assign.label" text="Assign Members"></spring:message>
		</a>
	</c:if>

	<spring:message var="importTitle" code="useradmin.importUsers.tooltip" text="Import accounts from CVS file" />
	<a class="actionLink" href="<c:url value='/importAccount.spr' />" title="${importTitle}" >
		<spring:message code="useradmin.importUsers.label" text="Import Accounts" />
	</a>

	<a class="actionLink" href="#" onclick="submitExcelExport(); return false;">
		<spring:message code="tracker.traceability.browser.export" text="Export to Excel" />
	</a>

	<c:if test="${licenseCode.enabled.userGroups}">
		<c:url var="userGroupsURL" value="/sysadmin/userGroups.spr" />
		<a class="actionLink" href="${userGroupsURL}"><spring:message code="sysadmin.userGroups.label" text="User Groups" /></a>
	</c:if>

	<c:url var="cancelUrl" value="/sysadmin.do"/>
	<spring:message code="button.cancel" text="Cancel" var="cancelLabel"/>
	<input type="button" class="cancelButton" value="${cancelLabel}" onclick="location.href = '${cancelUrl}';"/>

</ui:actionBar>

<div class="contentWithMargins">
<ui:showErrors/>

<c:if var="isShortList" test="${listType ne 'long'}" />

<ui:UserSetting var="alwaysDisplayContextMenuIcons" setting="ALWAYS_DISPLAY_CONTEXT_MENU_ICONS" defaultValue="true" />
<ui:displaytagPaging defaultPageSize="${pagesize}" items="${users}" excludedParams="page"/>

<display:table class="expandTable" requestURI="${requestURI}" excludedParams="page" name="${users}" id="user" cellpadding="0"
				export="${exportAccounts}" sort="external" decorator="com.intland.codebeamer.ui.view.table.UserDecorator">

	<display:setProperty name="basic.msg.empty_list_row">
		<tr class="empty">
			<td colspan="{0}">
				<div class="explanation">
					<spring:message code="account.filter.no.matching.account" />
				</div>
			</td>
		</tr>
	</display:setProperty>

	<display:setProperty name="paging.banner.some_items_found" value="${allItems}" />
	<display:setProperty name="paging.banner.all_items_found"><spring:message code="paging.all.banner"/></display:setProperty>
	<display:setProperty name="paging.banner.onepage" value="" />
	<display:setProperty name="paging.banner.placement" value="${empty users.list ? 'none' : 'bottom'}"/>

	<spring:message var="userAccount" code="user.account.label" text="Account" />
	<display:column title="${userAccount}" property="name" sortable="true" headerClass="textData" class="textData" />

	<display:column headerClass="action-column-minwidth" class="action-column-minwidth columnSeparator" media="html">
		<ui:actionMenu title="" builder="userAccountsPageUsersContextMenuBuilder" subject="${user}" alwaysDisplayContextMenuIcons="${alwaysDisplayContextMenuIcons}" />
	</display:column>

	<spring:message var="userGroups" code="user.groups.label" text="Groups" />
	<display:column title="${userGroups}" property="groups" headerClass="textData" class="textDataWrap columnSeparator" />

	<c:if test="${fn:length(licenseCode.licensedProducts) gt 1 or fn:length(licenseCode.productLicense.userLicenseTypes) gt 1}">
		<spring:message var="userLicenseType" code="user.licenseType.label" text="License Type"/>
		<display:column title="${userLicenseType}" property="licenseType" headerClass="textData" class="textDataWrap columnSeparator" />
	</c:if>

	<spring:message var="userFirstName" code="user.firstName.label" text="First Name" />
	<display:column title="${userFirstName}" property="firstName" sortable="true" headerClass="textData" class="textData columnSeparator" />

	<spring:message var="userLastName" code="user.lastName.label" text="Last Name" />
	<display:column title="${userLastName}" property="lastName" sortable="true" headerClass="textData" class="textData columnSeparator" />

	<spring:message var="userEMail" code="user.email.label" text="E-Mail" />
	<display:column title="${userEMail}" property="email" sortable="true" headerClass="textData" class="textData columnSeparator" comparator="com.intland.codebeamer.ui.view.table.EmailComparator" />

	<c:if test="${canViewCompany}">
		<spring:message var="userCompany" code="user.company.label" text="Company" />
		<display:column title="${userCompany}" property="company" sortable="true" headerClass="textData" class="textDataWrap columnSeparator" />
	</c:if>

	<c:if test="${!isShortList}">
		<spring:message var="userPhone" code="user.phone.label" text="Phone" />
		<display:column title="${userPhone}" property="phone" sortable="true" headerClass="dateData" class="dateData columnSeparator" />
	</c:if>

	<spring:message var="userLastLogin" code="user.lastLogin.label" text="Last Login" />
	<display:column title="${userLastLogin}" property="lastLogin" sortable="true" headerClass="dateData" class="dateData columnSeparator" />

	<c:if test="${!isShortList}">
		<spring:message var="userRegistered" code="user.registryDate.label" text="Registered" />
		<display:column title="${userRegistered}" property="registryDate" sortable="true" headerClass="dateData" class="dateData columnSeparator" />

		<display:column title="Account Expiry" property="accountExpiryString" sortProperty="accountExpiry" sortable="true" headerClass="dateData" class="dateData columnSeparator" />
	</c:if>

	<spring:message var="userStatus" code="user.status.label" text="Status" />
	<display:column title="${userStatus}" property="status" sortable="true" headerClass="textData" class="textData columnSeparator" />

	<c:if test="${!isShortList}">
		<spring:message var="userLimit" code="user.downloadLimit.label" text="Upload Limit" />
		<display:column title="${userLimit}" property="user.downloadLimit" sortable="false" headerClass="numberData" class="numberData columnSeparator" />
	</c:if>
</display:table>
</div>