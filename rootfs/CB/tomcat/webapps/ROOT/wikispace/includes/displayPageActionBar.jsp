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

<%@ taglib uri="taglib" prefix="tag" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>

<%-- JSP fragment shows action menubar and links for a WIKI page
	This expects following params:
	actionMenuKeys		: the list of keys for actions displayed in actionmenu
	actionLinkKeys		: the list of keys for actions displayed in action link bar
	showRating			: if the rating-widget is shown, defaults to false
	showActionMenuBar	: if the action-menu-bar (rounded borders) is shown, defaults to true.
	showActionBar		: if the action-bar is shown. Defaults to true
	showMoreMenu		: if the "more" menu is shown. Defaults to true
	Both can be omitted, then the default actions shown
--%>
<c:set var="actionMenuKeys" value="${param.actionMenuKeys}" />
<c:set var="actionLinkKeys" value="${param.actionLinkKeys}" />
<c:set var="showRating" value="${(not empty param.showRating) and param.showRating eq true}"/>
<c:set var="propertiesPage" value="${param.propertiesPage}"/>
<%-- set defaults: --%>
<c:if test="${empty actionMenuKeys}">
	<c:set var="actionMenuKeys">
		officeedit, properties, ---, comment, label, Favourite, addBaseline, ----, viewInOtherFormat, -----, importOneWikiPage, exportOneWikiPage, exportRtf, exportWikiPages, ExportToTracker, ------, projectWikiPermissions, Follow, lock, unlock, delete, copyWiki, paste, showParent
	</c:set>

	<c:if test="${wikiPage.trackerHomePage}">
		<c:set var="actionMenuKeys" value="${actionMenuKeys}, ---, createNewTracker"/>
	</c:if>
</c:if>
<c:if test="${empty actionLinkKeys}">
	<c:set var="defaultActionLinksUsed" value="true"/>
</c:if>

<ui:pageTitle printBody="false">
	<c:out value="${wikiPage.name}"/>
	<c:if test="${!empty pageRevision.baseline}">
		(<c:out value='${pageRevision.baseline.root.name}'/>)
	</c:if>
</ui:pageTitle>

<%-- action bars --%>
<ui:actionGenerator builder="wikiPageActionMenuBuilder" actionListName="wikiPageActions" subject="${wikiPage}">

	<c:if test="${empty param.showActionMenuBar || param.showActionMenuBar}">
		<c:set var="actionMenuBodyPart">
				<tag:versionUrl var="commentsVersionLink" urlLink="${pageRevision.simplePropertiesLink}" revisionNumber="${pageRevision.dto.version}" appendRequestParameters="true" requestParametersUrlFragment="orgDitchnetTabPaneId=wiki-page-comments"></tag:versionUrl>
				<c:url value="${commentsVersionLink}" var="commentsUrl"/>
				<tag:versionUrl var="historyVersionLink" urlLink="${pageRevision.simplePropertiesLink}" revisionNumber="${pageRevision.dto.version}" appendRequestParameters="true" requestParametersUrlFragment="orgDitchnetTabPaneId=wiki-page-history"></tag:versionUrl>
				<c:url value="${historyVersionLink}" var="historyUrl"/>
				<ui:breadcrumbs projectAware="${pageRevision.dto}" showProjects="false" commentsUrl="${commentsUrl}" historyUrl="${historyUrl}">
				<c:set var="Artifact" scope="request" value="${wikiPage}" />
				<ui:actionUrl var="unlockArtifactUrl" actions="${wikiPageActions}" key="unlock" />
				<jsp:include page="/docs/includes/docMetaData.jsp" flush="true">
					<jsp:param name="infoURL" value="${pageRevision.propertiesLink}"/>
					<jsp:param name="ditchnetPrefix" value="wiki-page" />
					<jsp:param name="unlockArtifactUrl" value="${unlockArtifactUrl}" />
				</jsp:include>
				</ui:breadcrumbs>
		</c:set>
		<c:set var="actionMenuRightPart">
			<c:if test="${not empty pageRevision.baseline}">
				<ui:branchBaselineBadge baseline="${pageRevision.baseline}"/>
			</c:if>
			<c:if test="${showRating}">
				<ui:rating entity="${wikiPage}" />
			</c:if>
		</c:set>
		<ui:actionMenuBar>
			<jsp:attribute name="rightAligned">${actionMenuRightPart}</jsp:attribute>
			<jsp:body>${actionMenuBodyPart}</jsp:body>
		</ui:actionMenuBar>
	</c:if>

	<c:set var="actionBarContents">
		<%-- action links --%>
		<script type="text/javascript">
			function deleteWikiPage(deleteWikiPageUrl) {
				var msg = '<spring:message javaScriptEscape="true" code="wiki.page.delete.confirm" />';
				showFancyConfirmDialogWithCallbacks(msg, function() { document.location.href = deleteWikiPageUrl; });
			}
		</script>

		<c:if var="pageIsEditable" test="${!empty wikiPageActions['edit']}" />

		<ui:rightAlign>
			<jsp:attribute name="filler">
				<c:if test="${empty param.showMoreMenu || param.showMoreMenu}">
					<ui:actionMenu cssClass="dpMoreMenu actionLink" title="more" actions="${wikiPageActions}" keys="${actionMenuKeys}" />
				</c:if>
			</jsp:attribute>

			<jsp:attribute name="fillerCSSStyle3">
				width: 80%;
				padding-left: 40px;
			</jsp:attribute>

			<jsp:attribute name="rightAligned">
				<c:choose>
					<c:when test="${wikiPage.projectHomePage}">
						<%-- When this is a project home page it, then star will go to the project, and not the wiki page --%>
						<jsp:include page="/includes/notificationBox.jsp" >
							<jsp:param name="entityTypeId" value="${GROUP_OBJECT}" />
							<jsp:param name="entityId" value="${wikiPage.id}" />

							<jsp:param name="starEntityTypeId" value="${GROUP_PROJECT}" />
							<jsp:param name="starEntityId" value="${wikiPage.project.id}" />
							<jsp:param name="showNotificationBox" value="${empty simpleWikiPage || ! simpleWikiPage}" />
						</jsp:include>
					</c:when>
					<c:otherwise>
						<spring:message var="openLabel" code="cb.wiki.navigation.open.label" text="Open" />
						<spring:message var="closeLabel" code="cb.wiki.navigation.close.label" text="Close" />
						<jsp:include page="/includes/notificationBox.jsp" >
							<jsp:param name="entityTypeId" value="${GROUP_OBJECT}" />
							<jsp:param name="entityId" value="${wikiPage.id}" />
							<jsp:param name="showNotificationBox" value="${empty simpleWikiPage || ! simpleWikiPage}" />
						</jsp:include>
						<span style="display: none; top: 0;" id="opener-east" title="${openLabel}"></span>
						<span style="display: none; top: 0;" id="closer-east" title="${closeLabel}"></span>
					</c:otherwise>
				</c:choose>
			</jsp:attribute>
			<jsp:body>
				<c:choose>
					<c:when test="${defaultActionLinksUsed }">
						<ui:actionLink actions="${wikiPageActions}" keys="edit, rtf" />
						<ui:actionLink actions="${wikiPageActions}" keys="addChildPage, addChildDashboard" />
						<c:if test="${empty PAGE_LOCKER && (wikiPageActions.containsKey('addChildPage') || wikiPageActions.containsKey('addChildDashboard'))}">
							<span class="menu-separator"></span>
						</c:if>
					</c:when>
					<c:otherwise>
						<ui:actionLink actions="${wikiPageActions}" keys="${actionLinkKeys}" />
					</c:otherwise>
				</c:choose>

			</jsp:body>
		</ui:rightAlign>
	</c:set>

	<c:if test="${(empty param.showActionBar && empty showActionBar) || param.showActionBar || showActionBar}">
		<c:choose>
			<c:when test="${param.unwrapContents}">${actionBarContents}</c:when>
			<c:otherwise><ui:actionBar id="middleHeaderDiv" cssClass="${wikiPage.dashboard && empty propertiesPage ? 'dashboard-actionbar' : '' }">${actionBarContents}</ui:actionBar></c:otherwise>
		</c:choose>
	</c:if>

</ui:actionGenerator>
