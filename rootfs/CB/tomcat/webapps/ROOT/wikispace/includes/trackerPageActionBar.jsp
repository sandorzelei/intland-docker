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
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>

<%@ taglib uri="taglib" prefix="tag" %>
<%@ taglib uri="uitaglib" prefix="ui" %>

<%-- JSP fragment shows action menubar and links for a WIKI page
	This expects following params:
	actionMenuKeys	: the list of keys for actions displayed in actionmenu
	actionLinkKeys	: the list of keys for actions displayed in action link bar
	showRating		: if the rating-widget is shown, defaults to false
	Both can be omitted, then the default actions shown
--%>
<c:set var="actionMenuKeys" value="${param.actionMenuKeys}" />
<c:set var="actionLinkKeys" value="${param.actionLinkKeys}" />
<%-- set defaults: --%>
<c:if test="${empty actionMenuKeys}">
    <c:choose>
        <c:when test="${wikiPage.trackerHomePage}">
            <c:set var="actionMenuKeys">configTrackersDefaults, changeLayout, exportOneWikiPage, pasteWidget</c:set>
        </c:when>
        <c:otherwise>
            <c:set var="actionMenuKeys">Follow, --, properties, comment, exportOneWikiPage, exportRtf, exportWikiPages, ------, projectWikiPermissions, lock, unlock, copyWiki, paste</c:set>
        </c:otherwise>
    </c:choose>
</c:if>

<c:set var="actionLinkKeys" value="" />
<c:if test="${empty actionLinkKeys}">
    <c:choose>
        <c:when test="${wikiPage.trackerHomePage}">
			<c:if test="${empty param.revision}">
            	<c:set var="actionLinkKeys" value="createNewTracker, classDiagram, traceabilityBrowser" />
			</c:if>
        </c:when>
        <c:otherwise>
            <c:set var="actionLinkKeys" value="createNewTracker, traceabilityBrowser, edit" />
        </c:otherwise>
    </c:choose>
</c:if>

<%-- action bars --%>
<ui:actionGenerator builder="dashboardActionMenuBuilder" actionListName="wikiPageActions" subject="${wikiPage}">
	<ui:rightAlign>
		<jsp:attribute name="filler">
			<div style="padding-left: 10px;">
			<ui:actionMenu title="more" actions="${wikiPageActions}" keys="${actionMenuKeys}" />
			</div>
		</jsp:attribute>
		<jsp:attribute name="rightAligned">
			<jsp:include page="/includes/notificationBox.jsp" >
				<jsp:param name="entityTypeId" value="${GROUP_OBJECT}" />
				<jsp:param name="entityId" value="${wikiPage.id}" />
			</jsp:include>
		</jsp:attribute>
		<jsp:body>
			<c:if test="${not empty actionLinkKeys}">
				<ui:actionLink actions="${wikiPageActions}" keys="${actionLinkKeys}" />
				<ui:actionLink actions="${wikiPageActions}" keys="addWidget" />
				<c:if test="${editable }">
					<spring:message code="dashboard.select.layout.label" text="Select Layout" var="selectLayoutLabel"/>
					<ui:actionMenu cssClass="selectLayoutAction" actionIconMode="true" iconUrl="/images/newskin/actionIcons/icon-layout.png" title="${selectLayoutLabel }" actions="${wikiPageActions }" keys="selectLayout*" inline="true"/>
				</c:if>

				<spring:message code="tracker.action.createBranch.label" text="Create Branch" var="createBranchLabel"></spring:message>
				<ui:actionLink actions="${wikiPageActions }" keys="createMultiBranch"></ui:actionLink>
				<%-- <ui:actionMenu cssClass="createBranchAction" actionIconMode="true" iconUrl="/images/newskin/actionIcons/icon-create-branch.png" title="${createBranchLabel }" actions="${wikiPageActions }" keys="createMultiBranch" inline="true"/>--%>

				<c:if test="${editable and wikiPageActions.containsKey('addWidget')}">
					<span class="menu-separator"></span>
				</c:if>
			</c:if>
		</jsp:body>
	</ui:rightAlign>
</ui:actionGenerator>

<ui:inProgressDialog imageUrl="${pageContext.request.contextPath}/images/newskin/branch_create_in_progress.gif" height="235" attachTo="body" triggerOnClick="false" />

