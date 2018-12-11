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
<%@ taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>

<meta name="decorator" content="main"/>
<meta name="module" content="project_browser"/>
<meta name="moduleCSSClass" content="newskin workspaceModule"/>

<ui:displaytagPaging defaultPageSize="25" items="${joinableProjects}" excludedParams="page"/>

<div class="contentWithMargins">
	<display:table class="expandTable" requestURI="" name="${joinableProjects}" id="entry" cellpadding="0"
	               sort="external" decorator="com.intland.codebeamer.ui.view.table.ProjectDecorator" pagesize="${pagesize}">

		<display:setProperty name="paging.banner.some_items_found" value="${allItems}" />
		<display:setProperty name="paging.banner.all_items_found"><spring:message code="paging.all.banner"/></display:setProperty>
		<display:setProperty name="paging.banner.onepage" value="" />
		<display:setProperty name="paging.banner.placement" value="${empty joinableProjects ? 'none' : 'bottom'}"/>

		<c:set var="projectId" value="${entry.project.id}"/>

		<c:if test="${!anonymous}">
			<spring:message var="projectAction" code="project.join" text="Join/Leave"/>
			<display:column title="${projectAction}" headerClass="textData" class="textData columnSeparator" style="max-width: 20px; width: 20px;">
				<c:set var="join" value="true" />
				<c:if test="${isAlreadyMember[projectId]}">
					<c:set var="join" value="false" />
				</c:if>
				<c:url var="joinOrRemoveMemberUrl" value="/proj/applyMembership.spr">
					<c:param name="targetProjectId" value="${projectId}" />
					<c:param name="join" value="${join}" />
				</c:url>
				<spring:message var="actionTitle" code="project.browser.link.${join ? 'join' : 'leave' }.title"/>
				<a href="#" title="${actionTitle}" onclick="showPopupInline('${joinOrRemoveMemberUrl}'); return false;">
					<spring:message code="project.browser.${join ? 'join' : 'leave' }.title" var="joinTitle"></spring:message>
					<span class="join-button ${join ? '' : 'leave' }" title="${joinTitle}"></span>
				</a>
			</display:column>
		</c:if>

		<spring:message var="projectNameLabel" code="project.label" text="Project"/>
		<c:choose>
			<c:when test="${!anonymous && !isAlreadyMember[projectId]}">
				<display:column title="${projectNameLabel}" sortable="true" headerClass="textData" class="textData columnSeparator">
					<c:url var="joinOrRemoveMemberUrl" value="/proj/applyMembership.spr">
						<c:param name="targetProjectId" value="${projectId}" />
						<c:param name="join" value="true" />
					</c:url>
					<spring:message var="actionTitle" code="project.browser.link.${join ? 'join' : 'leave' }.title"/>
					<a href="#" title="${actionTitle}" onclick="showPopupInline('${joinOrRemoveMemberUrl}'); return false;">
						<c:out value="${entry.project.name }"></c:out>
					</a>
				</display:column>
			</c:when>
			<c:otherwise>
				<display:column title="${projectNameLabel}" sortable="true" headerClass="textData" class="textData columnSeparator">
					<c:url var="projectUrl" value="${entry.project.urlLink }"/>
					<spring:message var="actionTitle" code="project.browser.link.${join ? 'join' : 'leave' }.title"/>
					<a title="${actionTitle}" href="${projectUrl}" target="_blank">
						<c:out value="${entry.project.name }"></c:out>
					</a>
				</display:column>
			</c:otherwise>
		</c:choose>

		<spring:message var="projectDescription" code="project.participationConditions.label" text="Participation Conditions"/>
		<display:column title="${projectDescription}" property="description" headerClass="textDataWrap expandTable" class="textDataWrap columnSeparator" />

		<spring:message var="projectCategory" code="project.category.label" text="Category"/>
		<display:column title="${projectCategory}" property="category" sortable="true" headerClass="textData" class="textData columnSeparator detailColumn" />

		<spring:message var="projectMembers" code="project.members.title" text="Members"/>
		<display:column title="${projectMembers}" property="memberCount" format="{0,number,#,###,###}" headerClass="numberData" class="textCenterData columnSeparator detailColumn" />

		<spring:message var="projectCreated" code="project.createdAt.label" text="Created"/>
		<display:column title="${projectCreated}" property="createdAt" sortable="true" headerClass="dateData lastHeader" class="dateData detailColumn" />
	</display:table>
</div>
