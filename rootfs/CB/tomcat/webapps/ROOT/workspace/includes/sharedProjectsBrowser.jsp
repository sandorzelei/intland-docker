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
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%@ taglib uri="http://displaytag.sf.net" prefix="display" %>

<%@ taglib uri="taglib" prefix="tag" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="acltaglib" prefix="acl" %>

<SCRIPT LANGUAGE="JavaScript" type="text/javascript">
<!-- Hide script from old browsers
function confirmLeaving() {
	return confirm('<spring:message code="proj.membership.leave" />');
}
// -->
</SCRIPT>

<style type="text/css">
	#entry {
		margin-left: 0;
		margin-right: 0;
	}

	#entry >thead >tr >th, #entry >tbody >tr >td {
		padding-left: 15px;
		padding-right: 15px;
	}

<%--
	   Moving the last column to the very right, but it is not possible
	   to move to the position on the design because there is some space occupied by the "sorting" control added with the :after css class
--%>
	#entry th.lastHeader {
		margin-right: 0;
		padding-right: 0;
	}

	#entry td.detailColumn {
		font-size: 11px;
		color: #858585;
	}

	div.exportlinks {
		margin-left: 0px;
		padding-left: 0px;
	}

	.pagebanner {
		margin-left: 0px !important;
	}
</style>


<ui:displaytagPaging defaultPageSize="${pagesize}" items="${allProjects}" excludedParams="page"/>

<div class="contentWithMargins">

<display:table class="expandTable" requestURI="" name="${allProjects}" id="entry" cellpadding="0"
               sort="external" decorator="com.intland.codebeamer.ui.view.table.ProjectDecorator" export="true" >

	<display:setProperty name="paging.banner.some_items_found" value="${allItems}" />
	<display:setProperty name="paging.banner.all_items_found"><spring:message code="paging.all.banner"/></display:setProperty>
	<display:setProperty name="paging.banner.onepage" value="" />
	<display:setProperty name="paging.banner.placement" value="${empty allProjects.list ? 'none' : 'bottom'}"/>

	<c:if test="${userLoggedIn}">
		<spring:message var="projectAction" code="project.action" text="Action"/>
		<display:column title="${projectAction}" headerClass="textData" class="textData columnSeparator" media="html">
			<c:set var="projectId" value="${entry.project.id}"/>
			<c:set var="join" value="true" />
			<c:if test="${isAlreadyMember[projectId]}">
				<c:set var="label" value="leave" />
				<c:set var="join" value="false" />
			</c:if>

			<c:choose>
				<c:when test="${empty entry.project.propagation}">
					<spring:message code="project.${isProjectAdmin[projectId] ? 'admin' : (isAlreadyMember[projectId] ? 'member' : 'private')}"/>
				</c:when>

				<c:when test="${!empty isPendingApproval[projectId]}">
					<spring:message code="project.applied" text="pending approval"/>
				</c:when>

				<c:otherwise>
					<c:if test="${not join}">
						<c:url var="joinOrRemoveMemberUrl" value="/proj/applyMembership.spr">
							<c:param name="targetProjectId" value="${projectId}" />
							<c:param name="join" value="${join}" />
						</c:url>
						<spring:message var="actionTitle" code="project.${label}.tooltip" text="${label}" htmlEscape="true"/>
						<a href="#" title="${actionTitle}" onclick="showPopupInline('${joinOrRemoveMemberUrl}',{geometry : 'half_half'}); return false;">
							<spring:message code="project.${label}" text="${label}"/>
						</a>
					</c:if>
				</c:otherwise>
			</c:choose>
		</display:column>
	</c:if>

	<spring:message var="projectName" code="project.name.label" text="Name"/>
	<display:column title="${projectName}" property="name" sortable="true" headerClass="textData" class="textData columnSeparator" />

	<spring:message var="projectDescription" code="project.description.label" text="Description"/>
	<display:column title="${projectDescription}" property="description" headerClass="textDataWrap expandTable" class="textDataWrap columnSeparator" />

	<spring:message var="projectCategory" code="project.category.label" text="Category"/>
	<display:column title="${projectCategory}" property="category" sortable="true" headerClass="textData" class="textData columnSeparator detailColumn" />

	<spring:message var="projectMembers" code="project.members.title" text="Members"/>
	<display:column title="${projectMembers}" property="memberCount" format="{0,number,#,###,###}" headerClass="numberData" class="textCenterData columnSeparator detailColumn" />

	<spring:message var="projectCreated" code="project.createdAt.label" text="Created"/>
	<display:column title="${projectCreated}" property="createdAt" sortable="true" headerClass="dateData lastHeader" class="dateData detailColumn" />
</display:table>

</div>
