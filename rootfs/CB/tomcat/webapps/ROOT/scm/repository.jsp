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
<meta name="module" content="sources"/>
<meta name="moduleCSSClass" content="sourceCodeModule newskin"/>
<meta name="stylesheet" content="sources.css"/>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="taglib" prefix="tag" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%@ taglib uri="http://ditchnet.org/jsp-tabs-taglib" prefix="tab" %>

<style type="text/css">
	#files {
		margin: 0px;
	}
</style>

<ui:actionMenuBar>
		<ui:breadcrumbs showProjects="false">
		<ui:pageTitle prefixWithIdentifiableName="false" printBody="false" >
			<spring:message code="scm.repository.page.title" arguments="${repository.name}" htmlEscape="true"/>
		</ui:pageTitle>
		</ui:breadcrumbs>
</ui:actionMenuBar>

<ui:actionGenerator builder="scmRepositoryActionMenuBuilder" subject="${repository}"
		actionListName="actions" allowedKeys="pullRequest, fork">

<ui:actionBar>
		<ui:actionLink actions="${actions}" />
</ui:actionBar>

<div class="contentWithMargins" >
<%-- shows general info about repository --%>
<jsp:include page="./includes/repository-card.jsp?showForks=false&showParent=true" />

<c:choose>
	<c:when test="${! empty repoSynchState }">
		<jsp:include page="./includes/synchInProgress.jsp"/>
	</c:when>
	<c:when test="${empty visibleModulesMap}">
		<div class="warning">
			<spring:message code="scm.repository.no.permission.to.view" text="You don't have permission to view details of this repository"/>
		</div>
	</c:when>
	<c:otherwise>

	<%--ditchnet tabs showing each module --%>
	<script type="text/javascript">
		function onTabChange(evt) {
			// must reload the page, because only the current tab contains data, the other tabs are empty
			var baseurl = '<c:url value="${repository.urlLink}"/>';
			var selectedTabPane = evt.getTabPane(); // HTMLDivElement reference to  the div containing the tab pane.
			var newurl = baseurl +"/" + selectedTabPane.id;
					window.location = newurl;
		}
	</script>

	<%-- note: the tab ids must be same as the url of the same page--%>
	<tab:tabContainer id="repository" skin="cb-box" jsTabListener="onTabChange" selectedTabPaneId="${module}">
		<c:if test='${! empty visibleModulesMap["forks"]}'>
		<spring:message var="tabTitle" code="scm.repository.forks" text="Forks" />
		<ui:lazyTabPane id="forks" tabTitle="${tabTitle}" selectedTabId="${module}">
			<c:set var="actions" scope="request" value="${actions}"/>
			<jsp:include page="./includes/forks.jsp"/>
		</ui:lazyTabPane>
		</c:if>

		<c:if test='${! empty visibleModulesMap["changesets"]}'>
		<spring:message var="tabTitle" code="scm.repository.tabs.changes.title" text="Changes" />
		<ui:lazyTabPane id="changesets" tabTitle="${tabTitle}" selectedTabId="${module}" >
			<jsp:include page="./includes/changesets.jsp"/>
		</ui:lazyTabPane>
		</c:if>

		<c:if test='${! empty visibleModulesMap["files"]}'>
		<spring:message var="tabTitle" code="scm.repository.tabs.files.title" text="Files" />
		<ui:lazyTabPane id="files" tabTitle="${tabTitle}" selectedTabId="${module}">
			<jsp:include page="./includes/files.jsp"/>
		</ui:lazyTabPane>
		</c:if>

		<c:if test='${! empty visibleModulesMap["pullrequests"]}'>
		<spring:message var="tabTitle" code="scm.repository.tabs.pullrequests.title" text="Pull Requests" />
		<ui:lazyTabPane id="pullrequests" tabTitle="${tabTitle}" selectedTabId="${module}" >
			<jsp:include page="./includes/pullrequests.jsp"/>
		</ui:lazyTabPane>
		</c:if>

		<c:if test='${! empty visibleModulesMap["branchesAndTags"]}'>
		<spring:message var="tabTitle" code="scm.repository.tabs.branches-and-tags.title" text="Permissions &amp;Tags" />
		<ui:lazyTabPane id="branchesAndTags" tabTitle="${tabTitle}" selectedTabId="${module}" >
			<jsp:include page="./includes/branchesAndTags.jsp"/>
		</ui:lazyTabPane>
		</c:if>

		<c:if test='${! empty visibleModulesMap["permissions"]}'>
		<spring:message var="tabTitle" code="scm.repository.tabs.permissions.title" text="Permissions" />
		<ui:lazyTabPane id="permissions" tabTitle="${tabTitle}" selectedTabId="${module}" >
			<jsp:include page="./includes/permissions.jsp"/>
		</ui:lazyTabPane>
		</c:if>

		<c:if test='${! empty visibleModulesMap["notifications"]}'>
		<spring:message var="tabTitle" code="scm.repository.tabs.notifications.title" text="Notifications" />
		<ui:lazyTabPane id="notifications" tabTitle="${tabTitle}" selectedTabId="${module}" >
			<jsp:include page="./includes/notifications.jsp"/>
		</ui:lazyTabPane>
		</c:if>

		<c:if test='${! empty visibleModulesMap["statistics"]}'>
		<spring:message var="tabTitle" code="scm.repository.tabs.statistics.title" text="Statistics" />
		<ui:lazyTabPane id="statistics" tabTitle="${tabTitle}" selectedTabId="${module}" >
			<jsp:include page="./includes/statistics.jsp"/>
		</ui:lazyTabPane>
		</c:if>
	</tab:tabContainer>

	</c:otherwise>
</c:choose>
</div>
</ui:actionGenerator>
