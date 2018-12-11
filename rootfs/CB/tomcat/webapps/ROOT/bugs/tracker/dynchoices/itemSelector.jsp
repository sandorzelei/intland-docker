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

<%@ page import="com.intland.codebeamer.manager.TrackerManager" %>
<%@ page import="com.intland.codebeamer.persistence.dto.UserDto" %>
<%@ page import="java.util.Locale" %>
<%@ page import="com.intland.codebeamer.persistence.dto.TrackerItemDto" %>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@ taglib prefix="ui" uri="uitaglib" %>

<style type="text/css">

#itemSelector {
  margin-bottom: 6px;
}

#itemSelector th {
	padding-top: 1;
	padding-bottom: 1;
}

#itemSelector td {
	padding-top: 1;
	padding-bottom: 0;
}

#itemSelector tr {
	border-top: 0;
	padding-top: 1;
	padding-bottom: 0;
}

#itemSelector td.idColumn {
	width: 5%;
}

#itemSelector td.trackerColumn,
#itemSelector td.projectColumn {
	width: 10%;
}

#itemSelector td.branchTrackerColumn .wikiLink {
	color: #005c50;
}

.referenceSelectName {
	padding-top: 10px !important;
	padding-bottom: 2px !important;
}

.Chrome .itemName {
	margin-left: 10px;
}

.IE .itemName{
	margin-left: 15px;
}

.FF .itemName {
	margin-left: 18px;
}
.indenter {
	position: relative;
	top: 5px;
}
.statusImage {
	display: inline-block;
}

table.treetable span.indenter a {
	position: relative;
	top: -4px;
}

.itemUrlLink {
	color: #d1d1d1 !important;
	font-weight: bold;
}

.itemUrlLink:hover {
	text-decoration: none !important;
	color: #0093b8 !important;
}

.FF .wikiLinkContainer .wikiLink,
.Chrome .wikiLinkContainer .wikiLink {
	padding-left: 5px;
	text-indent: -7px;
	cursor: pointer;
}

.IE .wikiLinkContainer .wikiLink {
	padding-left: 5px;
	text-indent: -9px;
	cursor: pointer;
}

.link-width-short .wikiLinkContainer {
	max-width: 80%;
}

.referenceSelectName .indenterPlaceholder {
	width: 19px;
	display: inline-block;
}

</style>

<%! private static final TrackerManager trackerManager = TrackerManager.getInstance(); %>

<display:table htmlId="itemSelector" name="${filterResult}" id="item" requestURI="" sort="external" cellpadding="0" decorator="decorator">
	<display:setProperty name="paging.banner.items_name"><spring:message code="tracker.reference.choose.items" text="Projects"/></display:setProperty>
	<display:setProperty name="paging.banner.some_items_found" value="${allItems}" />
	<display:setProperty name="paging.banner.all_items_found" value=""/>
	<display:setProperty name="paging.banner.onepage" value="" />
	<display:setProperty name="paging.banner.placement" value="${empty filterResult.list ? 'none' : 'bottom'}"/>

	<display:column title="${selectColumnTitle}" headerClass="checkbox-column-minwidth" class="checkbox-column-minwidth">
		<c:set var="selectionValue" value="9-${item.id}" />
		<input id="${selectionValue}-selector" type="${selectInputType}" name="searchItem" value="${selectionValue}"
			<c:if test="${! empty selectedItems[selectionValue]}">checked="checked"</c:if> data-tracker-item-id="${item.id}"
		/>
		<input type="hidden" name="visibleItem" value="${selectionValue}" data-tracker-item-id="${item.id}" />
	</display:column>

	<c:if test="${showID}">
		<spring:message var="itemId" code="issue.id.label" text="Id"/>
		<display:column title="${itemId}" property="id" sortable="${isDataSortable}" headerClass="textData" class="textData columnSeparator referenceSelectLessImportant idColumn"/>
	</c:if>

	<spring:message var="openLabel" code="tracker.openItems.label" text="Open"/>
	<display:column title="${refFldName}" sortProperty="name" sortable="${isDataSortable}" headerClass="textDataWrap referenceSelectHeader" class="textDataWrap columnSeparator referenceSelectName ${item.tracker.branch ? ' branchTrackerColumn' : ''}">
        <span class="indenterPlaceholder"></span>
        <label for="${selectionValue}-selector" class="itemName link-width-short"><ui:wikiLink item="${item}" hideBadges="${true}" excludeLink="true"/></label>
	</display:column>

	<display:column class="textData">
 		<a class="itemUrlLink" href="<c:url value="${item.urlLink}"></c:url>" target="_blank" title="${openLabel}">↗</a>
		<c:if test="${item.isBranchItem() && ((not empty branch && item.branch.id != branch.id) || empty branch)}">
			<span class="referenceSettingBadge branchBadge">${item.branch.name}</span>
		</c:if>
		<c:if test="${not empty branch && item.tracker.id == branch.getTrackerIdOfBranch()}">
			<span class="referenceSettingBadge branchBadge masterBranchBadge"><spring:message code="tracker.branching.master.label"/></span>
		</c:if>
	</display:column>

	<spring:message var="trackerName" code="tracker.label.general" text="Tracker"/>
	<display:column title="${trackerName}" sortable="${isDataSortable}" headerClass="textData" class="textData columnSeparator referenceSelectLessImportant trackerColumn">
		<a href="<c:url value="${item.tracker.urlLink}"/>" target="_blank"><%= trackerManager.getBranchNameWithMasterTracker((UserDto) pageContext.getAttribute("user"), ((TrackerItemDto) pageContext.getAttribute("item")).getTracker(), (Locale) pageContext.getAttribute("locale")) %></a>
	</display:column>

	<spring:message var="projectName" code="project.label" text="Project"/>
	<display:column title="${projectName}" sortable="${isDataSortable}" headerClass="textData" class="textData referenceSelectLessImportant projectColumn">
		<a href="<c:url value="${item.project.urlLink}"/>" target="_blank"><c:out value="${item.project.name}"/></a>
	</display:column>
</display:table>

