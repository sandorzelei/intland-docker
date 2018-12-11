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

<%@ taglib uri="tracker"  prefix="tracker" %>
<%@ taglib uri="taglib"   prefix="tag" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="callTag"  prefix="ct" %>

<%@ page import="com.intland.codebeamer.manager.TrackerViewManager"%>

<%
	request.setAttribute("OPEN_VIEW", TrackerViewManager.ATV_OPEN);
	request.setAttribute("ALL_ITEMS_VIEW", TrackerViewManager.ATV_ALL_ITEMS);
	request.setAttribute("ASSIGNED_TO_ME_VIEW", TrackerViewManager.ATV_ASSIGNED_TO_ME);
	request.setAttribute("SUBMITTED_BY_ME_VIEW", TrackerViewManager.ATV_SUBMITTED_BY_ME);
	request.setAttribute("UPDATED_RECENTLY_VIEW", TrackerViewManager.ATV_UPDATED_RECENTLY);
	request.setAttribute("RESOLVED_RECENTLY_VIEW", TrackerViewManager.ATV_RESOLVED_RECENTLY);
	request.setAttribute("MOST_IMPORTANT_VIEW", TrackerViewManager.ATV_MOST_IMPORTANT);
%>

<style type="text/css">
#item {
	width: 98% !important;
	border-bottom: 0px;
}
label {
	font-weight: normal !important;
}
.displaytag th {
	padding-right: 0px !important;
}
.numberData {
	text-align: center;
}
.favouriteWidget {
	margin-left: 0px !important;
}
input[name="selectedArtifactIds"] {
	margin-top: 3px;
}
.summaryTable td {
	padding-top: 0px !important;
	padding-left: 0px !important;
}
</style>


<tracker:itemsStat var="items" proj_id="${proj_id}" trackerIds="${trackerIds}" cmdb="true" showAll="${param.showAll eq 'true'}"/>

<c:set var="provideLinksInSummary" value="false" />

<c:if test="${empty requestURI}">
	<c:set var="requestURI" value="/proj/cmdb.do" />
	<c:set var="provideLinksInSummary" value="true" />
</c:if>

<display:table requestURI="${requestURI}" name="${items}" id="item" cellpadding="0" sort="external" decorator="com.intland.codebeamer.ui.view.table.DocumentListDecorator">
	<c:set var="tracker_id" value="${item.tracker.id}" />

	<c:set var="browseAllURI" value="/proj/cmdb/browseAllCategories.do" />

	<c:url var="trackerLinkForAllItems" value="${item.tracker.urlLink}">
		<c:param name="tracker_id" value="${tracker_id}" />
		<c:param name="view_id" value="${ALL_ITEMS_VIEW}" />
		<c:param name="reset" value="all" />
	</c:url>

	<display:column title="" decorator="com.intland.codebeamer.ui.view.table.TrimmedColumnDecorator" media="html" headerClass="checkbox-column-minwidth" class="checkbox-column-minwidth">
		<ct:call return="itemId"     object="${listDocumentForm}" method="getItemId"  param1="${item.tracker}" />
		<ct:call return="isSelected" object="${listDocumentForm}" method="isSelected" param1="${item.tracker}" />
		<input type="checkbox" name="selectedArtifactIds" value="${itemId}"	<c:if test="${isSelected}">checked="checked"</c:if>/>
	</display:column>

	<display:column title="" class="rawData status-icon-minwidth" media="html">
		<c:set var="entitySubscription" scope="request" value="${entitySubscriptions[item.tracker.id]}" />
		<jsp:include page="/includes/notificationBox.jsp" >
			<jsp:param name="showNotificationBox" value="false" />
			<jsp:param name="entityTypeId" value="${GROUP_TRACKER}" />
			<jsp:param name="entityId" value="${item.tracker.id}" />
		</jsp:include>
	</display:column>

	<display:column title="" class="status-icon-minwidth"  media="html">
		<ui:coloredEntityIcon subject="${item.tracker}" iconUrlVar="imgUrl" iconBgColorVar="iconBgColor"/>
		<img style="background-color:${iconBgColor}" src='<c:url value="${imgUrl}"/>'/>
	</display:column>

	<spring:message var="categoryTitle" code="cmdb.category.label" text="Category"/>
	<display:column title="${categoryTitle}" headerClass="textData" class="textSummaryData" sortable="false" sortProperty="tracker.name">
		<table class="summaryTable">
			<tr>
				<td>
					<html:link page="${item.tracker.urlLink}"><c:out value="${item.tracker.name}"/></html:link>
				</td>
				<td class="subtext">
					<c:set var="itemSubscription" scope="request" value="${entitySubscriptions[item.tracker.id]}" />
					<ui:subscriptionInfo entitySubscription="${itemSubscription}" hideUnsubscribed="hide" />
				</td>
			</tr>
		</table>
		<div class="subtext">
			<tag:transformText value="${item.tracker.description}" format="${item.tracker.descriptionFormat}" />
		</div>
	</display:column>

	<display:column title="" decorator="com.intland.codebeamer.ui.view.table.TrimmedColumnDecorator" media="html" class="action-column-minwidth columnSeparator">
		<ui:actionMenu builder="categoryListContextActionMenuBuilder" subject="${item.tracker}"	keys="Follow, --, newTrackerItem, customizeTracker, transitionsGraph, Properties, Lock, Unlock"	/>
	</display:column>

	<spring:message var="keyTitle" code="tracker.key.label" text="Key"/>
	<display:column title="${keyTitle}" headerClass="textData" class="textData columnSeparator" property="tracker.keyName" sortable="false" style="width: 5%"/>

	<spring:message var="itemsTitle" code="cmdb.category.items.label" text="Items"/>
	<display:column title="${itemsTitle}" headerClass="numberData" class="numberData columnSeparator" sortProperty="allItems" sortable="false" style="width: 5%;text-align: center;">
		<html:link href="${trackerLinkForAllItems}"><fmt:formatNumber value="${item.allItems}" /></html:link>
	</display:column>

	<spring:message var="subscribersTitle" code="tracker.subscribers.label" text="Subscribers"/>
	<display:column title="${subscribersTitle}" headerClass="numberData" class="numberData columnSeparator" sortable="false"	property="subscribers" style="width: 5%;text-align: center;"/>

	<spring:message var="modifiedTitle" code="tracker.modifiedAt.label" text="Modified at"/>
	<display:column title="${modifiedTitle}" headerClass="dateData" class="dateData columnSeparator" sortable="false"	sortProperty="modifiedAt" style="width: 10%">
		<tag:formatDate value="${item.modifiedAt}" />
	</display:column>

	<c:choose>
		<c:when test="${!empty proj_id}">
		<%-- TODO: when will the otherwise? happen--%>
		</c:when>

		<c:otherwise>
			<c:url var="openProject" value="${item.tracker.project.urlLink}" />
			<spring:message var="projectTitle" code="project.label" text="Project"/>
			<display:column title="${projectTitle}" headerClass="textData" class="textData"	sortable="false" sortProperty="project.name">
				<html:link href="${openProject}"><c:out value="${item.tracker.project.name}" /></html:link>
			</display:column>
		</c:otherwise>
	</c:choose>

</display:table>
