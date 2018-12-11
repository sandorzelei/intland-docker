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

<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="acltaglib" prefix="acl" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>

<%-- JSP fragment shows action menubar and links for the projects' list --%>

<c:url var="listProjectsUrl" value="/listProjects.spr"/>

<script language="JavaScript" type="text/javascript">
function showDeletedProjects(checkbox) {
	if (checkbox != null) {
		location.href='${listProjectsUrl}?showDeleted=' + checkbox.checked;
		return false;
	}
}
</script>

<style type="text/css">
	.newskin .actionMenuBar label {
		color: #f4f4f4;
		font-size: 11px;
		font-weight: normal;
		margin: 0;
	}
</style>

<%-- action bars --%>
<ui:actionGenerator builder="projectListPageActionMenuBuilder" actionListName="projectActions" deniedKeys="currentWorkingSet" >
	
		<c:choose>
			<c:when test="${displayAllProjects}">
					<c:set var="actionMenuBodyPart">
							<ui:breadcrumbs strongBody="true"><ui:pageTitle><spring:message code="project.browser.title" text="Browse Projects"/></ui:pageTitle></ui:breadcrumbs>
					</c:set>
					<c:set var="actionMenuRightPart">
						<form:form commandName="projectSelectorForm" cssClass="filterForm">
						<label>
							<spring:message var="categoryFilter" code="project.category.filter" text="Filter projects by their category"/>
							<form:select path="category" items="${categories}" itemLabel="label" itemValue="value" title="${categoryFilter}"
								cssStyle="padding-top: 2px; padding-bottom: 2px;"
							/>
						</label>
						<label>
							<spring:message var="projectFilter" code="project.filter.tooltip" text="Filter projects by name, description"/>
							<form:input id="searchPattern" path="searchPattern" title="${projectFilter}" class="searchFilterBox" />
							<script type="text/javascript">
								applyHintInputBox("#searchPattern", "Type to filter...");	// TODO: i18n
							</script>
						</label>
						<c:if test="${userLoggedIn}">
							<label for="onlyPublic" >
								<spring:message var="publicFilter" code="project.onlyPublic.tooltip" text="Whether only the public projects are shown"/>
								<form:checkbox id="onlyPublic" path="onlyPublic" cssClass="checkbox" title="${publicFilter}"/> <spring:message code="project.onlyPublic.filter" text="only public projects"/>
							</label>
						</c:if>

						<spring:message var="searchButton" code="search.submit.label" text="GO"/>
						<spring:message var="searchTitle" code="search.submit.tooltip" text="Apply this filter"/>

						<input type="submit" value="${searchButton}" class="button" title="${searchTitle}"
							style="margin-left: 0.5em; min-width: auto; min-height: auto; padding: 2px 6px;" 
						/>
						</form:form>
					</c:set>
			</c:when>

			<c:otherwise>
				<c:set var="actionMenuBodyPart">
						<ui:breadcrumbs strongBody="true"><ui:pageTitle><spring:message code="project.selector.title" text="My Projects"/></ui:pageTitle>
						<c:out value="(${numberOfmyProjects})"/></ui:breadcrumbs>
				</c:set>
				<c:set var="actionMenuRightPart">
					<span class="filterForm">
						<jsp:include page="/workingset/workingsetSelector.jsp" >
							<jsp:param name="commandName" value="projectSelectorForm"/>
						</jsp:include>
					</span>
				</c:set>
			</c:otherwise>
		</c:choose>
	<ui:actionMenuBar>
		<jsp:attribute name="rightAligned">${actionMenuRightPart}</jsp:attribute>
		<jsp:body>${actionMenuBodyPart}</jsp:body>
	</ui:actionMenuBar>

	<ui:actionBar>
		<ui:rightAlign>
			<jsp:attribute name="filler">
				<ui:actionMenu title="More" actions="${projectActions}" keys="viewWorkingSets, newWorkingSet"  />
			</jsp:attribute>
			<jsp:attribute name="rightAligned">
				<acl:isAnonymousUser var="anonymous"/>
				<c:if test="${!(anonymous or displayAllProjects)}">
					<spring:message var="deletedTitle" code="project.show.deleted.tooltip" text="Check/Uncheck to show/hide deleted projects where the current user was a project admin" htmlEscape="true"/>
					<c:if test="${showDeleted}">
						<c:set var="deletedSelected" value="checked='checked'"/>
					</c:if>
					<input type="checkbox" ${deletedSelected} id="showDeleted" name="showDeleted" value="true" title="${deletedTitle}" onchange="showDeletedProjects(this)"
						style="vertical-align: bottom;" 
					/>
					<label title="${deletedTitle}" for="showDeleted"><spring:message code="project.show.deleted.label" text="Show deleted projects"/></label>
				</c:if>
			</jsp:attribute>
			<jsp:body>
				<ui:actionLink actions="${projectActions}" keys="createNewProject, listProjects"/>
			</jsp:body>
		</ui:rightAlign>
	</ui:actionBar>
</ui:actionGenerator>

