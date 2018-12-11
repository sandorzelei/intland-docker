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
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<%@ taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>

<%@ taglib uri="tracker" prefix="tracker" %>
<%@ taglib uri="taglib" prefix="tag" %>
<%@ taglib uri="uitaglib" prefix="ui" %>

<%@ page import="com.intland.codebeamer.manager.TrackerViewManager"%>

<%
	pageContext.getRequest().setAttribute("ROOT_VIEW", TrackerViewManager.ATV_OPEN_TOPLEVEL_ITEMS);
	pageContext.getRequest().setAttribute("OPEN_VIEW", TrackerViewManager.ATV_OPEN);
	pageContext.getRequest().setAttribute("ALL_ITEMS_VIEW", TrackerViewManager.ATV_ALL_ITEMS);
	pageContext.getRequest().setAttribute("ASSIGNED_TO_ME_VIEW", TrackerViewManager.ATV_ASSIGNED_TO_ME);
	pageContext.getRequest().setAttribute("SUBMITTED_BY_ME_VIEW", TrackerViewManager.ATV_SUBMITTED_BY_ME);
	pageContext.getRequest().setAttribute("UPDATED_RECENTLY_VIEW", TrackerViewManager.ATV_UPDATED_RECENTLY);
	pageContext.getRequest().setAttribute("RESOLVED_RECENTLY_VIEW", TrackerViewManager.ATV_RESOLVED_RECENTLY);
	pageContext.getRequest().setAttribute("MOST_IMPORTANT_VIEW", TrackerViewManager.ATV_MOST_IMPORTANT);
%>

<tracker:itemsStat var="items" proj_id="${proj_id}" trackerIds="${trackerIds}" />

<c:set var="sumOpenItems" value="0" />
<c:set var="sumTotalItems" value="0" />
<c:set var="sumAssignedToMeItems" value="0" />
<c:set var="sumSubmittedByMeItems" value="0" />

<c:set var="provideLinksInSummary" value="false" />

<c:if test="${empty requestURI}">
	<c:set var="requestURI" value="/proj/tracker.do" />
</c:if>

<style type="text/css">
	#summaryRow td {
		color: white !important;
		font-weight: bold;
	}
</style>

<ui:UserSetting var="alwaysDisplayContextMenuIcons" setting="ALWAYS_DISPLAY_CONTEXT_MENU_ICONS" defaultValue="true" />

<display:table requestURI="${requestURI}" name="${items}" id="item" cellpadding="0" sort="external">

	<c:set var="tracker_id" value="${item.tracker.id}" />

	<c:set var="browseAllURI" value="/proj/tracker/browseAllTrackers.do" />
	<c:set var="browseURI" value="/proj/tracker/browseTracker.do" />

	<c:url var="trackerLink" value="${browseURI}">
		<c:param name="tracker_id" value="${tracker_id}" />
		<c:param name="view_id" value="${ROOT_VIEW}" />
		<c:param name="reset" value="open" />
	</c:url>

	<c:url var="trackerLinkForOpenItems" value="${browseURI}">
		<c:param name="tracker_id" value="${tracker_id}" />
		<c:param name="view_id" value="${OPEN_VIEW}" />
		<c:param name="reset" value="open" />
	</c:url>

	<c:url var="trackerLinkForAllItems" value="${browseURI}">
		<c:param name="tracker_id" value="${tracker_id}" />
		<c:param name="view_id" value="${ALL_ITEMS_VIEW}" />
		<c:param name="reset" value="all" />
	</c:url>

	<c:url var="assignedToUserLink" value="${browseURI}">
		<c:param name="tracker_id" value="${tracker_id}" />
		<c:param name="view_id" value="${ASSIGNED_TO_ME_VIEW}" />
		<c:param name="onlyAssignedToUser" value="true" />
		<%-- Pass proj_id only, that we know that we are in project scope --%>
		<c:param name="proj_id" value="${proj_id}" />
	</c:url>

	<c:url var="submittedByUserLink" value="${browseURI}">
		<c:param name="tracker_id" value="${tracker_id}" />
		<c:param name="view_id" value="${SUBMITTED_BY_ME_VIEW}" />
		<c:param name="onlySubmittedByUser" value="true" />
		<%-- Pass proj_id only, that we know that we are in project scope --%>
		<c:param name="proj_id" value="${proj_id}" />
	</c:url>

	<jsp:include page="includes/initTrackerContextMenu.jsp" flush="true">
		<jsp:param name="isCategoryTracker" value="${item.tracker.category}" />
	</jsp:include>
	<c:set var="actionKeys" value="newTrackerItem,[---],${actionKeys}" />

	<display:column title="" class="status-icon-minwidth">
		<c:set var="entitySubscription" scope="request" value="${entitySubscriptions[item.tracker.id]}" />
		<jsp:include page="/includes/notificationBox.jsp" >
			<jsp:param name="entityTypeId" value="${GROUP_TRACKER}" />
			<jsp:param name="entityId" value="${item.tracker.id}" />
		</jsp:include>
	</display:column>

	<spring:message var="trackerTitle" code="tracker.label.general" text="Tracker" />
	<display:column title="${trackerTitle}" headerClass="textData" class="textSummaryData" sortable="true" sortProperty="tracker.name">
		<html:link href="${trackerLink}"><c:out value="${item.tracker.name}"/></html:link>
		<div class="subtext">
			<tag:transformText value="${item.tracker.description}" format="${item.tracker.descriptionFormat}" />
		</div>
	</display:column>

	<display:column title="" decorator="com.intland.codebeamer.ui.view.table.TrimmedColumnDecorator" media="html" class="action-column-minwidth columnSeparator">
		<ui:actionMenu builder="trackerListContextActionMenuBuilder" subject="${item.tracker}" keys="${actionKeys}" alwaysDisplayContextMenuIcons="${alwaysDisplayContextMenuIcons}" />
	</display:column>

	<spring:message var="trackerKeyTitle" code="tracker.key.label" text="Key" />
	<display:column title="${trackerKeyTitle}" headerClass="textData" class="textData columnSeparator" property="tracker.keyName" sortable="true" />

	<spring:message var="trackerOpenTitle" code="tracker.openItems.label" text="Open" />
	<display:column title="${trackerOpenTitle}" headerClass="numberData" class="numberData columnSeparator"	sortProperty="openItems" sortable="true">
		<c:set var="sumOpenItems" value="${sumOpenItems + item.openItems}" />
		<html:link href="${trackerLinkForOpenItems}">
			<fmt:formatNumber value="${item.openItems}" />
		</html:link>
	</display:column>

	<spring:message var="trackerTotalTitle" code="tracker.allItems.label" text="Total" />
	<display:column title="${trackerTotalTitle}" headerClass="numberData" class="numberData columnSeparator" sortProperty="allItems" sortable="true">
		<c:set var="sumTotalItems" value="${sumTotalItems + item.allItems}" />

		<html:link href="${trackerLinkForAllItems}"><fmt:formatNumber value="${item.allItems}" /></html:link>
	</display:column>

	<spring:message var="trackerAssignedTitle" code="tracker.assignedToUser.label" text="Assigned to Me" />
	<display:column title="${trackerAssignedTitle}" headerClass="numberData" class="numberData columnSeparator" sortable="true"	sortProperty="assignedToUser">
		<c:set var="sumAssignedToMeItems" value="${sumAssignedToMeItems + item.assignedToUser}" />

		<html:link href="${assignedToUserLink}">
			<fmt:formatNumber value="${item.assignedToUser}" />
		</html:link>
	</display:column>

	<spring:message var="trackerSubmittedTitle" code="tracker.submittedByUser.label" text="Submitted by Me" />
	<display:column title="${trackerSubmittedTitle}" headerClass="numberData" class="numberData columnSeparator" sortable="true" sortProperty="submittedByUser">
		<c:set var="sumSubmittedByMeItems" value="${sumSubmittedByMeItems + item.submittedByUser}" />

		<html:link href="${submittedByUserLink}">
			<fmt:formatNumber value="${item.submittedByUser}" />
		</html:link>
	</display:column>

	<spring:message var="trackerSubscribersTitle" code="tracker.subscribers.label" text="Subscribers" />
	<display:column title="${trackerSubscribersTitle}" headerClass="numberData" class="numberData columnSeparator" sortable="true" property="subscribers" />

	<spring:message var="trackerModifiedTitle" code="tracker.modifiedAt.label" text="Modified at" />
	<display:column title="${trackerModifiedTitle}" headerClass="dateData" class="dateData columnSeparator" sortable="true"	sortProperty="modifiedAt">
		<tag:formatDate value="${item.modifiedAt}" />
	</display:column>

	<spring:message var="trackerProjectTitle" code="project.label" text="Project" />
	<display:column title="${trackerProjectTitle}" headerClass="textData" class="textData columnSeparator" sortable="true" sortProperty="tracker.project.name">
		<html:link page="/project/${item.tracker.project.id}"><c:out value="${item.tracker.project.name}" /></html:link>
	</display:column>

	<display:footer>
		<c:url var="projectTrackerLinkForOpenItems" value="${browseAllURI}">
			<c:param name="proj_id" value="${proj_id}" />
			<c:param name="onlyOpen" value="true" />
		</c:url>

		<c:url var="projectTrackerLinkForAllItems" value="${browseAllURI}">
			<c:param name="proj_id" value="${proj_id}" />
			<c:param name="onlyOpen" value="false" />
		</c:url>

		<c:url var="allAssignedToUserLink" value="${browseAllURI}">
			<c:param name="proj_id" value="${proj_id}" />
			<c:param name="onlyAssignedToUser" value="true" />
		</c:url>

		<c:url var="allSubmittedByUserLink" value="${browseAllURI}">
			<c:param name="proj_id" value="${proj_id}" />
			<c:param name="onlySubmittedByUser" value="true" />
		</c:url>

		<TR id="summaryRow" CLASS="head">
			<TD/>

			<TD CLASS="textData" COLSPAN="3"><spring:message code="tracker.summary.label" text="Summary" />:</TD>

			<TD CLASS="numberData">
				<c:choose>
					<c:when test="${provideLinksInSummary}">
						<html:link href="${projectTrackerLinkForOpenItems}">
							<fmt:formatNumber value="${sumOpenItems}" /></html:link>
					</c:when>

					<c:otherwise>
						<fmt:formatNumber value="${sumOpenItems}" />
					</c:otherwise>
				</c:choose>
			</TD>

			<TD CLASS="numberData">
				<c:choose>
					<c:when test="${provideLinksInSummary}">
						<html:link href="${projectTrackerLinkForAllItems}">
							<fmt:formatNumber value="${sumTotalItems}" /></html:link>
					</c:when>

					<c:otherwise>
						<fmt:formatNumber value="${sumTotalItems}" />
					</c:otherwise>
				</c:choose>
			</TD>

			<TD CLASS="numberData">
				<c:choose>
					<c:when test="${provideLinksInSummary}">
						<html:link href="${allAssignedToUserLink}">
							<fmt:formatNumber value="${sumAssignedToMeItems}" /></html:link>
					</c:when>

					<c:otherwise>
						<fmt:formatNumber value="${sumAssignedToMeItems}" />
					</c:otherwise>
				</c:choose>
			</TD>

			<TD CLASS="numberData">
				<c:choose>
					<c:when test="${provideLinksInSummary}">
						<html:link href="${allSubmittedByUserLink}">
							<fmt:formatNumber value="${sumSubmittedByMeItems}" /></html:link>
					</c:when>

					<c:otherwise>
						<fmt:formatNumber value="${sumSubmittedByMeItems}" />
					</c:otherwise>
				</c:choose>
			</TD>

			<TD COLSPAN="6"/>
		</TR>
	</display:footer>
</display:table>
