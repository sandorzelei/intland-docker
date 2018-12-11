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
<meta name="decorator" content="popup" />
<meta name="module" content="members" />
<meta name="moduleCSSClass" content="newskin membersModule" />

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt"%>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="http://ditchnet.org/jsp-tabs-taglib" prefix="tab"%>
<%@ taglib uri="uitaglib" prefix="ui"%>
<%@ taglib uri="http://displaytag.sf.net" prefix="display" %>

<style type="text/css">

	.fieldNotMapped {
		background: url('../images/newskin/action/permission-alert.png') no-repeat left center;
    	padding-left: 16px !important;
    }

</style>

<div class="ldapUsers">
	<display:table name="ldapUsers" id="ldapUser" requestURI="${requestURI}" cellpadding="0" defaultorder="descending" sort="list">
		<display:setProperty name="paging.banner.some_items_found" value="${ldapUsers}" />

		<display:column title="" decorator="com.intland.codebeamer.ui.view.table.TrimmedColumnDecorator" headerClass="checkbox-column-minwidth"	class="checkbox-column-minwidth">
			<input type="checkbox" name="userSelected" id="${checkboxId}" value="<c:out value='${ldapUser.name}'/>" ${isChecked ? 'checked="checked"' : ''} />
		</display:column>

		<display:column titleKey="project.newMember.invite.ldap.account.label" headerClass="textData" class="expand textDataWrap columnSeparator">
			<span class="small-interwiki-link"><c:out value="${ldapUser.name}" /></span>
		</display:column>

		<display:column titleKey="tracker.field.State.label" headerClass="textData" class="expand textDataWrap columnSeparator">
			<c:if test="${empty ldapUser.id}">
				<span class="issueStatus"><spring:message code="project.newMember.invite.ldap.account.notexist"/></span>
			</c:if>
			<c:if test="${not empty ldapUser.id}">
				<span class="issueStatus issueStatusResolved"><spring:message code="project.newMember.invite.ldap.account.exist"/></span>
			</c:if>
		</display:column>

		<display:column titleKey="user.email.label" headerClass="textData ${emailMapped ? '' : 'fieldNotMapped'}" class="expand textDataWrap columnSeparator">
			<span class="small-interwiki-link"><c:out value="${ldapUser.email}" /></span>
		</display:column>

		<display:column titleKey="login.username" headerClass="textData ${firstNameMapped && lastNameMapped? '' : 'fieldNotMapped'}" class="expand textDataWrap columnSeparator">
			<span class="small-interwiki-link"><c:out value="${ldapUser.firstName} ${ldapUser.lastName}" /></span>
		</display:column>

		<display:column titleKey="project.newMember.invite.ldap.distinguish.label" headerClass="textData" class="expand textDataWrap columnSeparator">
			<c:set var="distinguishName">${ldapUser.ldapName}</c:set>
			<c:if test="${fn:length(distinguishName) gt 20}">
			 	<c:set value="..." var="ellipsis" />
 				<c:set value="${fn:substring(distinguishName, 0, (20 - fn:length(ellipsis)))}${ellipsis}" var="distinguishName" />
			</c:if>
			<span class="small-interwiki-link" title="${ldapUser.ldapName}"><c:out value="${distinguishName}" /></span>
		</display:column>
	</display:table>
</div>