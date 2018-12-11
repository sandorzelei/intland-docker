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

<ui:actionMenuBar>
	<ui:breadcrumbs showProjects="false">
		<span class='breadcrumbs-separator'>&raquo;</span>
		<c:set var="pageTitleLabel"
			value="${showParam eq 'groups' ? 'project.newMember.assign.group.label' : (showParam eq 'members' ? 'project.newMember.assign.member.label' : 'project.newMember.title')}"></c:set>
		<ui:pageTitle>
			<spring:message code="${pageTitleLabel}" />
		</ui:pageTitle>
	</ui:breadcrumbs>
</ui:actionMenuBar>

<c:choose>
	<c:when test="${!canCreateNewAccount or inviteOnly or showParam eq 'groups'}">
		<jsp:include page="addMembers.jsp" />
	</c:when>
	<c:otherwise>
		<tab:tabContainer id="addInviteMemberTabContainer" skin="cb-box" selectedTabPaneId="${empty selectedTabId ? 'addMemberTab' : selectedTabId}">

			<%-- add members tab --%>
			<c:set var="tabTitleCode" value="${showParam eq 'groups' ? 'project.newMember.assign.group.label' : 'project.newMember.add.new.label'}"></c:set>
			<spring:message var="label" code="${tabTitleCode}" />
			<tab:tabPane id="addMemberTab" tabTitle='${label}'>
				<jsp:include page="addMembers.jsp" />
			</tab:tabPane>


			<%-- invite members from LDAP tab --%>
			<spring:message var="label" code="project.newMember.invite.ldap.label" />
			<tab:tabPane id="inviteLdapMembers" tabTitle='${label}'>
				<jsp:include page="inviteLdapMembers.jsp" />
			</tab:tabPane>

			<%-- invite members via email tab --%>
			<spring:message var="label" code="project.newMember.invite.email.label" />
			<tab:tabPane id="inviteEmailMembers" tabTitle='${label}'>
				<jsp:include page="inviteEmailMembers.jsp" />
			</tab:tabPane>
		</tab:tabContainer>
	</c:otherwise>
</c:choose>

