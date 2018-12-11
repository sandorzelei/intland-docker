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
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@ taglib uri="http://ditchnet.org/jsp-tabs-taglib" prefix="tab" %>

<%@ taglib uri="taglib" prefix="tag" %>
<%@ taglib uri="acltaglib" prefix="acl" %>
<%@ taglib uri="uitaglib" prefix="ui" %>

<%--
	JSP fragment renders search results.
	Parameters, etc:
	param.showAssoc=true 	- when included on association page
	param.selectionAllowed=true/false	- if the selection of the results are allowed, so checkbox/radio button is shown before each hit
	param.multipleSelection=true/false	- if single (radiobuttons) or multi-selection (checkboxes) are used
	param.showFooter=true/false	- whether to show the search footer (total results and search time)

	requestScope.searchResults	- The SearchResult object contains the hits.
	requestScope.selectedItems	- Collection for the values of selected items: it contaings "<grouptype>-<id>" strings.
--%>
<%@ page import="com.intland.codebeamer.persistence.dao.impl.EntityCache"%>
<%@ page import="java.util.Collection"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.HashMap"%>
<%@ page import="java.util.Map"%>
<%@ page import="java.util.Iterator"%>

<style type="text/css">
#searchResults {
	margin: 20px;
}

.newskin .displaytag {
	border-bottom: none;
}
.displaytag +.pagelinks {
	border-top: solid 1px #d1d1d1;
}

#searchReportsItem .documentLink,
#searchTrackers .documentLink,
#searchBaselines .documentLink,
#searchDocumentItem .documentLink,
#searchWikipageItem .documentLink,
#searchTrackerItem .trackerItemLink,
#searchBranchItems .trackerItemLink {
	position: relative;
	top: -3px;
}

#searchLabelItem .wikiLinkContainer {
	margin-bottom: 5px;
}

pre {
	margin: 0 !important;
}
</style>

<ui:UserSetting var="alwaysDisplayContextMenuIcons" setting="ALWAYS_DISPLAY_CONTEXT_MENU_ICONS" defaultValue="true" />

<div id="searchResults">

<spring:hasBindErrors name="searchForm">
	<ui:showSpringErrors errors="${errors}" />
</spring:hasBindErrors>

<c:set var="USER_ACCOUNT" value="<%=EntityCache.USER_TYPE%>" />
<c:set var="TRACKER_ITEM" value="<%=EntityCache.TRACKER_ITEM_TYPE%>" />
<c:set var="ARTIFACT"     value="<%=EntityCache.ARTIFACT_TYPE%>" />
<c:set var="PROJECT"      value="<%=EntityCache.PROJECT_TYPE%>" />

<c:set var="isExport" value="false" />

<c:set var="bannerPosition" value="bottom" />
<c:set var="bannerPositionList" value="bottom" />
<c:set var="bannerOnePage" value="" />
<c:set var="bannerOneItem" value="" />
<c:set var="bannerAllItems" value="" />
<c:set var="bannerSomeItems" value="" />
<c:set var="bannerGroupSize" value="5" />

<acl:isUserInRole var="canViewCompany" value="account_company_view" />
<acl:isUserInRole var="canViewEmail"   value="account_email_view" />
<acl:isUserInRole var="canViewPhone"   value="account_phone_view" />
<acl:isUserInRole var="canViewSkills"  value="account_skills_view" />

<c:set var="requestURI" value="" />

<%-- if the selection is allowed --%>
<c:set var="selectionAllowed" value="${param.selectionAllowed}" />

<%-- if in show association mode --%>
<c:choose>
	<c:when test="${param.showAssoc}">
		<c:set var="from_assoc" value="true" />
		<c:set var="selectionAllowed" value="true" />
	</c:when>
	<c:otherwise>
		<c:set var="from_assoc" value="false" />
	</c:otherwise>
</c:choose>

<%-- single or multi selection?, defined by the parameter: multipleSelection,
	put the checkbox or radio to check-all/clear-all into header --%>
<c:choose>
	<c:when test="${param.multipleSelection || from_assoc}">
		<spring:message var="searchScopeToggle" code="search.what.toggle" text="Select/Clear All"/>
		<c:set var="selectInputType" value="checkbox" />
		<c:set var="selectColumnTitle">
<%--
			<input TYPE="CHECKBOX" TITLE="${searchScopeToggle}" id="selectColumnTitle"
				NAME="SELECT_ALL" VALUE="on"
				ONCLICK="setAllStatesFrom(this, 'searchItem', new InSameTableClosure(this))">
			</input>
--%>
		</c:set>
	</c:when>
	<c:otherwise>
		<c:set var="selectInputType" value="radio" />
		<c:set var="selectColumnTitle" >
			<input type="radio" name='searchItem' title="Clear selection" value="" id="selectColumnTitle" />
		</c:set>
	</c:otherwise>
</c:choose>

<c:set var="showFooter" value="${empty param.showFooter or param.showFooter}"/>

<%
	// selected-items may arrive in "selectedItems" request parameter
	Collection selectedItems = (Collection) request.getAttribute("selectedItems");
	if (selectedItems == null) {
		selectedItems = new ArrayList();
	}

	// convert to map, so jstl can use it with [] operator
	Map selectedItemsMap = new HashMap();
	for (Iterator iItems = selectedItems.iterator(); iItems.hasNext();) {
		Object selectedItem = iItems.next();
		selectedItemsMap.put(selectedItem, selectedItem);
	}

	pageContext.setAttribute("selectedItems", selectedItemsMap);
%>

<c:set var="showProject" value="true" />


<c:choose>
<c:when test="${searchResults.hitCount gt 0}">
<tab:tabContainer id="search-result" skin="cb-box" >

<!-- All hits -->
<c:if test="${not from_assoc and showAll}">
<spring:message var="allResultsTitle" code="search.results.all" text="All"/>
<tab:tabPane id="search-all" tabTitle="${allResultsTitle} (${all.fullListSize})">
	<div style="overflow:auto; margin-top: 10px; margin-bottom: -10px;">
	<c:if test="${!empty all.list}">
		<style type="text/css">
			#searchAll thead {
				display: none;	/* IE: empty table header is causing a gray line: hide it */
			}
		</style>

		<display:table id="searchAll" name="${all}" requestURI="${requestURI}" sort="external" cellpadding="0" cellspacing="0" export="false"  >
			<display:setProperty name="pagination.pagenumber.param"    	value="allPage" />
			<display:setProperty name="pagination.sort.param"          	value="allSort" />
			<display:setProperty name="pagination.sortdirection.param" 	value="allDir" />
			<display:setProperty name="paging.banner.placement" 		value="${bannerPositionList}"/>
			<display:setProperty name="paging.banner.onepage" 			value="${bannerOnePage}" />
			<display:setProperty name="paging.banner.one_item_found" 	value="${bannerOneItem}" />
			<display:setProperty name="paging.banner.all_items_found" 	value="${bannerAllItems}" />
			<display:setProperty name="paging.banner.some_items_found" 	value="${bannerSomeItems}" />
			<display:setProperty name="paging.banner.group_size" 		value="${bannerGroupSize}" />
			<display:setProperty name="css.tr.even" 					value="search_item" />
			<display:setProperty name="css.tr.odd" 						value="search_item" />
			<display:setProperty name="css.table" 						value="search_item_table" />

			<display:column class="search_item" style="search_item" sortable="false" >
				<tag:searchResultItem resultDto="${searchAll}" itemClass="search_item" useDivForItemBlockTag="true"
				searchParams="${searchResults.searchParams}" query="${searchResults.searchQuery}"/>
			</display:column>
		</display:table>
	</c:if>
	</div>
</tab:tabPane>
</c:if>



<%-- Tags --%>
<c:if test="${showLabels and labels.fullListSize gt 0}">
<spring:message var="tagsResultsTitle" code="Tags" text="Tags"/>
<tab:tabPane id="search-labels" tabTitle="${tagsResultsTitle} (${labels.fullListSize})">
	<div style="overflow:auto;">
	<display:table id="searchLabelItem" name="${labels}" sort="external" requestURI="${requestURI}" cellpadding="0" export="${isExport}" class="search_table"
		decorator="com.intland.codebeamer.ui.view.table.search.LabelSearchDecorator" >

		<display:setProperty name="pagination.pagenumber.param"    	value="labelsPage" />
		<display:setProperty name="pagination.sort.param"          	value="labelsSort" />
		<display:setProperty name="pagination.sortdirection.param" 	value="labelsDir" />
		<display:setProperty name="paging.banner.placement" 		value="${bannerPosition}"/>
		<display:setProperty name="paging.banner.onepage" 			value="${bannerOnePage}" />
		<display:setProperty name="paging.banner.one_item_found" 	value="${bannerOneItem}" />
		<display:setProperty name="paging.banner.all_items_found" 	value="${bannerAllItems}" />
		<display:setProperty name="paging.banner.some_items_found" 	value="${bannerSomeItems}" />
		<display:setProperty name="paging.banner.group_size" 		value="${bannerGroupSize}" />

		<spring:message var="tagName" code="tag.name.label" text="Label"/>
		<display:column title="${tagName}" property="name" sortProperty="displayName" sortable="false" headerClass="textData" class="textData columnSeparator" />

		<spring:message var="tagEntities" code="tag.entities.label" text="Related Entities"/>
		<display:column title="${tagEntities}" property="entities" headerClass="textData" class="textData columnSeparator" sortable="false" />

		<spring:message var="tagCreatedBy" code="tag.createdBy.label" text="Created by"/>
		<display:column title="${tagCreatedBy}" sortProperty="createdBy.name" sortable="false" headerClass="textData columnSeparator" class="textData">
			<tag:userLink user_id="${searchLabelItem.createdBy.id}" />
		</display:column>

		<spring:message var="tagCreatedAt" code="tag.createdAt.label" text="Created at"/>
		<display:column title="${tagCreatedAt}" sortProperty="createdAt" sortable="false" headerClass="dateData" class="dateData">
			<tag:formatDate value="${searchLabelItem.createdAt}" />
		</display:column>
	</display:table>
	</div>
</tab:tabPane>
</c:if>

<%-- Tracker Items --%>
<c:if test="${showTrackerItems and trackerItems.fullListSize gt 0}">
<spring:message var="issuesResultsTitle" code="Issues" text="Issues"/>
<tab:tabPane id="search-issues" tabTitle="${issuesResultsTitle} (${trackerItems.fullListSize})">
	<div style="overflow:auto;">
	<display:table id="searchTrackerItem" name="${trackerItems}" sort="external" requestURI="${requestURI}" cellpadding="0" export="${isExport}" class="search_table"
		decorator="com.intland.codebeamer.ui.view.table.search.TrackerSearchDecorator" >

		<display:setProperty name="pagination.pagenumber.param"    	value="trackerItemsPage" />
		<display:setProperty name="pagination.sort.param"          	value="trackerItemsSort" />
		<display:setProperty name="pagination.sortdirection.param" 	value="trackerItemsDir" />
		<display:setProperty name="paging.banner.placement" 		value="${bannerPosition}"/>
		<display:setProperty name="paging.banner.onepage" 			value="${bannerOnePage}" />
		<display:setProperty name="paging.banner.one_item_found" 	value="${bannerOneItem}" />
		<display:setProperty name="paging.banner.all_items_found" 	value="${bannerAllItems}" />
		<display:setProperty name="paging.banner.some_items_found" 	value="${bannerSomeItems}" />
		<display:setProperty name="paging.banner.group_size" 		value="${bannerGroupSize}" />

		<c:if test="${selectionAllowed}">
			<display:column title="${selectColumnTitle}" headerClass="checkbox-column-minwidth">
				<c:set var="selectionValue" value="${TRACKER_ITEM}-${searchTrackerItem.id}" />
				<input type="${selectInputType}" name="searchItem" value="${selectionValue}"
					<c:if test="${! empty selectedItems[selectionValue]}">checked="checked"</c:if>
				/>
				<input type="hidden" name="visibleItem" value="${selectionValue}" />
			</display:column>
		</c:if>

		<spring:message var="issueSummary" code="issue.summary.label" text="Summary"/>
		<display:column title="${issueSummary}" property="summary" headerClass="textData" class="textSummaryData columnSeparator" sortable="false" />

		<spring:message var="issueModifiedAt" code="issue.modifiedAt.label" text="Modified"/>
		<display:column title="${issueModifiedAt}" property="modifiedAt" headerClass="dateData" class="dateData columnSeparator" sortable="false" />

		<spring:message var="issueSubmitter" code="issue.submitter.label" text="Submitted by"/>
		<c:if test="${empty param.showSubmitter || param.showSubmitter}">
			<display:column title="${issueSubmitter}" property="submitter" headerClass="textData" class="textData columnSeparator" sortable="false" />
		</c:if>

		<spring:message var="issueAssignedTo" code="issue.assignedTo.label" text="Assigned to"/>
		<display:column title="${issueAssignedTo}" property="assignedTo" headerClass="textData" class="textDataWrap columnSeparator" sortable="false" />

		<spring:message var="issueStatus" code="issue.status.label" text="Status"/>
		<display:column title="${issueStatus}" property="status" headerClass="textData StatusHeaderClass" class="textData columnSeparator StatusClass" sortable="false" />

		<spring:message var="issueTracker" code="issue.tracker.label.general" text="Tracker"/>
		<c:if test="${empty param.showTracker || param.showTracker}">
			<display:column title="${issueTracker}" property="trackerName" sortProperty="sortTrackerName" headerClass="textData" class="textData columnSeparator" sortable="false" />
		</c:if>

		<c:if test="${showProject}">
			<spring:message var="issueProject" code="issue.project.label" text="Project"/>
			<display:column title="${issueProject}" property="project" sortProperty="projectName" headerClass="textData" class="textDataWrap" sortable="false" />
		</c:if>

	</display:table>
	</div>
</tab:tabPane>
</c:if>

<%-- Branch Items --%>
<c:if test="${branchItems.fullListSize gt 0}">
<spring:message var="branchItemsTitle" code="Branched Work Items" text="Branched Work Items"/>
<tab:tabPane id="searchBranchItems" tabTitle="${branchItemsTitle} (${branchItems.fullListSize})">
	<div style="overflow:auto;">
	<display:table id="searchBranchTrackerItem" name="${branchItems}" sort="external" requestURI="${requestURI}" cellpadding="0" export="${isExport}" class="search_table"
		decorator="com.intland.codebeamer.ui.view.table.search.TrackerSearchDecorator" >

		<display:setProperty name="pagination.pagenumber.param"    	value="branchItemsPage" />
		<display:setProperty name="pagination.sort.param"          	value="branchItemsSort" />
		<display:setProperty name="pagination.sortdirection.param" 	value="branchItemsDir" />
		<display:setProperty name="paging.banner.placement" 		value="${bannerPosition}"/>
		<display:setProperty name="paging.banner.onepage" 			value="${bannerOnePage}" />
		<display:setProperty name="paging.banner.one_item_found" 	value="${bannerOneItem}" />
		<display:setProperty name="paging.banner.all_items_found" 	value="${bannerAllItems}" />
		<display:setProperty name="paging.banner.some_items_found" 	value="${bannerSomeItems}" />
		<display:setProperty name="paging.banner.group_size" 		value="${bannerGroupSize}" />

		<c:if test="${selectionAllowed}">
			<display:column title="${selectColumnTitle}" headerClass="checkbox-column-minwidth">
				<c:set var="selectionValue" value="${TRACKER_ITEM}-${searchBranchTrackerItem.id}" />
				<input type="${selectInputType}" name="searchItem" value="${selectionValue}"
					<c:if test="${! empty selectedItems[selectionValue]}">checked="checked"</c:if>
				/>
				<input type="hidden" name="visibleItem" value="${selectionValue}" />
			</display:column>
		</c:if>

		<spring:message var="issueSummary" code="issue.summary.label" text="Summary"/>
		<display:column title="${issueSummary}" property="summary" headerClass="textData" class="textSummaryData columnSeparator" sortable="false" />

		<spring:message var="issueModifiedAt" code="issue.modifiedAt.label" text="Modified"/>
		<display:column title="${issueModifiedAt}" property="modifiedAt" headerClass="dateData" class="dateData columnSeparator" sortable="false" />

		<spring:message var="issueSubmitter" code="issue.submitter.label" text="Submitted by"/>
		<c:if test="${empty param.showSubmitter || param.showSubmitter}">
			<display:column title="${issueSubmitter}" property="submitter" headerClass="textData" class="textData columnSeparator" sortable="false" />
		</c:if>

		<spring:message var="issueAssignedTo" code="issue.assignedTo.label" text="Assigned to"/>
		<display:column title="${issueAssignedTo}" property="assignedTo" headerClass="textData" class="textDataWrap columnSeparator" sortable="false" />

		<spring:message var="issueStatus" code="issue.status.label" text="Status"/>
		<display:column title="${issueStatus}" property="status" headerClass="textData StatusHeaderClass" class="textData columnSeparator StatusClass" sortable="false" />

		<spring:message var="branch" code="issue.branch.title" text="Branch"/>
		<display:column title="${branch}" property="branchLink" headerClass="textData" class="textData columnSeparator" sortable="false" />

		<c:if test="${showProject}">
			<spring:message var="issueProject" code="issue.project.label" text="Project"/>
			<display:column title="${issueProject}" property="project" sortProperty="projectName" headerClass="textData" class="textDataWrap" sortable="false" />
		</c:if>

	</display:table>
	</div>
</tab:tabPane>
</c:if>

<%-- Wikipages --%>
<c:if test="${showWikipages and wikipages.fullListSize gt 0}">
<spring:message var="wikipagesResultsTitle" code="Wikis/Dashboards" text="Wikis/Dashboards"/>
<tab:tabPane id="search-wikipages" tabTitle="${wikipagesResultsTitle} (${wikipages.fullListSize})">
	<div style="overflow:auto;">
	<display:table id="searchWikipageItem" name="${wikipages}" sort="external" requestURI="${requestURI}" cellpadding="0" export="${isExport}" class="search_table"
		decorator="com.intland.codebeamer.ui.view.table.search.DocumentSearchDecorator" >

		<ui:actionGenerator builder="artifactListContextActionMenuBuilder" subject="${searchWikipageItem}" actionListName="actions"
			deniedKeys="Lock, Unlock, Delete..., Undelete, New Version"
		>

		<display:setProperty name="pagination.pagenumber.param"    	value="wikipagesPage" />
		<display:setProperty name="pagination.sort.param"          	value="wikipagesSort" />
		<display:setProperty name="pagination.sortdirection.param" 	value="wikipagesDir" />
		<display:setProperty name="paging.banner.placement" 		value="${bannerPosition}"/>
		<display:setProperty name="paging.banner.onepage" 			value="${bannerOnePage}" />
		<display:setProperty name="paging.banner.one_item_found" 	value="${bannerOneItem}" />
		<display:setProperty name="paging.banner.all_items_found" 	value="${bannerAllItems}" />
		<display:setProperty name="paging.banner.some_items_found" 	value="${bannerSomeItems}" />
		<display:setProperty name="paging.banner.group_size" 		value="${bannerGroupSize}" />

		<c:if test="${selectionAllowed && showSelection}">
			<display:column title="${selectColumnTitle}" headerClass="checkbox-column-minwidth">
				<c:set var="selectionValue" value="${ARTIFACT}-${searchWikipageItem.id}" />
				<input type="${selectInputType}" name="searchItem" value="${selectionValue}"
					<c:if test="${! empty selectedItems[selectionValue]}">checked="checked"</c:if>
				/>
				<input type="hidden" name="visibleItem" value="${selectionValue}" />
			</display:column>
		</c:if>

		<spring:message var="documentName" code="document.name.label" text="Document"/>
		<display:column title="${documentName}" property="name" headerClass="textData" class="textData" sortable="false" />

		<display:column title="" decorator="com.intland.codebeamer.ui.view.table.TrimmedColumnDecorator" media="html" class="action-column-minwidth columnSeparator">
			<ui:actionMenu actions="${actions}" alwaysDisplayContextMenuIcons="${alwaysDisplayContextMenuIcons}" />
		</display:column>

		<spring:message var="documentModified" code="document.lastModifiedAt.label" text="Modified"/>
		<display:column title="${documentModified}" property="lastModifiedAt" headerClass="dateData" class="dateData columnSeparator" sortable="false" />

		<spring:message var="documentStatus" code="document.status.label" text="Status"/>
		<display:column title="${documentStatus}" property="status" headerClass="textData" class="textData columnSeparator" sortable="false" />

		<c:if test="${showProject}">
			<spring:message var="documentProject" code="document.project.label" text="Project"/>
			<display:column title="${documentProject}" property="project" sortProperty="projectName" headerClass="textData" class="textDataWrap" sortable="false" />
		</c:if>

		</ui:actionGenerator>
	</display:table>
	</div>
</tab:tabPane>
</c:if>

<%-- Branches --%>
<c:if test="${showTrackers and trackers.fullListSize gt 0}">
<spring:message var="branchesResultsTitle" code="Trackers/Branches" text="Trackers / Branches"/>
<tab:tabPane id="search-trackers" tabTitle="${branchesResultsTitle} (${trackers.fullListSize})">
	<div style="overflow:auto;">
	<display:table id="searchTrackers" name="${trackers}" sort="external" requestURI="${requestURI}" cellpadding="0" export="${isExport}" class="search_table"
		decorator="com.intland.codebeamer.ui.view.table.search.DocumentSearchDecorator" >

		<ui:actionGenerator builder="artifactListContextActionMenuBuilder" subject="${searchDocumentItem}" actionListName="actions"
			deniedKeys="Lock, Unlock, Delete..., Undelete, New Version"
		>

		<display:setProperty name="pagination.pagenumber.param"    	value="trackersPage" />
		<display:setProperty name="pagination.sort.param"          	value="trackersSort" />
		<display:setProperty name="pagination.sortdirection.param" 	value="trackersDir" />
		<display:setProperty name="paging.banner.placement" 		value="${bannerPosition}"/>
		<display:setProperty name="paging.banner.onepage" 			value="${bannerOnePage}" />
		<display:setProperty name="paging.banner.one_item_found" 	value="${bannerOneItem}" />
		<display:setProperty name="paging.banner.all_items_found" 	value="${bannerAllItems}" />
		<display:setProperty name="paging.banner.some_items_found" 	value="${bannerSomeItems}" />
		<display:setProperty name="paging.banner.group_size" 		value="${bannerGroupSize}" />

		<c:if test="${selectionAllowed}">
			<display:column title="${selectColumnTitle}" headerClass="checkbox-column-minwidth">
				<c:set var="selectionValue" value="${ARTIFACT}-${searchDocumentItem.id}" />
				<input type="${selectInputType}" name="searchItem" value="${selectionValue}"
					<c:if test="${! empty selectedItems[selectionValue]}">checked="checked"</c:if>
				/>
				<input type="hidden" name="visibleItem" value="${selectionValue}" />
			</display:column>
		</c:if>

		<spring:message var="documentName" code="document.name.label" text="Document"/>
		<display:column title="${documentName}" property="name" headerClass="textData" class="textData" sortable="false" />

		<display:column title="" decorator="com.intland.codebeamer.ui.view.table.TrimmedColumnDecorator" media="html" class="action-column-minwidth columnSeparator">
			<ui:actionMenu actions="${actions}" alwaysDisplayContextMenuIcons="${alwaysDisplayContextMenuIcons}" />
		</display:column>

		<spring:message var="documentModified" code="document.lastModifiedAt.label" text="Modified"/>
		<display:column title="${documentModified}" property="lastModifiedAt" headerClass="dateData" class="dateData columnSeparator" sortable="false" />

		<spring:message var="documentStatus" code="document.status.label" text="Status"/>
		<display:column title="${documentStatus}" property="status" headerClass="textData" class="textData columnSeparator" sortable="false" />

		<spring:message var="documentDirectory" code="document.directory.label" text="Directory"/>
		<display:column title="${documentDirectory}" property="directory" headerClass="textData" class="textDataWrap columnSeparator" sortable="false" />

		<c:if test="${showProject}">
			<spring:message var="documentProject" code="document.project.label" text="Project"/>
			<display:column title="${documentProject}" property="project" sortProperty="projectName" headerClass="textData" class="textDataWrap" sortable="false" />
		</c:if>

		</ui:actionGenerator>
	</display:table>
	</div>
</tab:tabPane>
</c:if>

<%-- Baselines --%>
<c:if test="${showBaselinesResult and baselinesResult.fullListSize gt 0}">
<spring:message var="baselinesResultsTitle" code="Baselines" text="Baselines"/>
<tab:tabPane id="search-baselines" tabTitle="${baselinesResultsTitle} (${baselinesResult.fullListSize})">
	<div style="overflow:auto;">
	<display:table id="searchBaselines" name="${baselinesResult}" sort="external" requestURI="${requestURI}" cellpadding="0" export="${isExport}" class="search_table"
		decorator="com.intland.codebeamer.ui.view.table.search.DocumentSearchDecorator" >

		<ui:actionGenerator builder="artifactListContextActionMenuBuilder" subject="${searchDocumentItem}" actionListName="actions"
			deniedKeys="Lock, Unlock, Delete..., Undelete, New Version"
		>

		<display:setProperty name="pagination.pagenumber.param"    	value="baselinesResultPage" />
		<display:setProperty name="pagination.sort.param"          	value="baselinesResultSort" />
		<display:setProperty name="pagination.sortdirection.param" 	value="baselinesResultDir" />
		<display:setProperty name="paging.banner.placement" 		value="${bannerPosition}"/>
		<display:setProperty name="paging.banner.onepage" 			value="${bannerOnePage}" />
		<display:setProperty name="paging.banner.one_item_found" 	value="${bannerOneItem}" />
		<display:setProperty name="paging.banner.all_items_found" 	value="${bannerAllItems}" />
		<display:setProperty name="paging.banner.some_items_found" 	value="${bannerSomeItems}" />
		<display:setProperty name="paging.banner.group_size" 		value="${bannerGroupSize}" />

		<c:if test="${selectionAllowed}">
			<display:column title="${selectColumnTitle}" headerClass="checkbox-column-minwidth">
				<c:set var="selectionValue" value="${ARTIFACT}-${searchDocumentItem.id}" />
				<input type="${selectInputType}" name="searchItem" value="${selectionValue}"
					<c:if test="${! empty selectedItems[selectionValue]}">checked="checked"</c:if>
				/>
				<input type="hidden" name="visibleItem" value="${selectionValue}" />
			</display:column>
		</c:if>

		<spring:message var="documentName" code="document.name.label" text="Document"/>
		<display:column title="${documentName}" property="name" headerClass="textData" class="textData" sortable="false" />

		<display:column title="" decorator="com.intland.codebeamer.ui.view.table.TrimmedColumnDecorator" media="html" class="action-column-minwidth columnSeparator">
			<ui:actionMenu actions="${actions}" alwaysDisplayContextMenuIcons="${alwaysDisplayContextMenuIcons}" />
		</display:column>

		<spring:message var="documentModified" code="document.lastModifiedAt.label" text="Modified"/>
		<display:column title="${documentModified}" property="lastModifiedAt" headerClass="dateData" class="dateData columnSeparator" sortable="false" />

		<spring:message var="documentStatus" code="document.status.label" text="Status"/>
		<display:column title="${documentStatus}" property="status" headerClass="textData" class="textData columnSeparator" sortable="false" />

		<spring:message var="documentDirectory" code="document.directory.label" text="Directory"/>
		<display:column title="${documentDirectory}" property="directory" headerClass="textData" class="textDataWrap columnSeparator" sortable="false" />

		<c:if test="${showProject}">
			<spring:message var="documentProject" code="document.project.label" text="Project"/>
			<display:column title="${documentProject}" property="project" sortProperty="projectName" headerClass="textData" class="textDataWrap" sortable="false" />
		</c:if>

		</ui:actionGenerator>
	</display:table>
	</div>
</tab:tabPane>
</c:if>

<%-- Documents --%>
<c:if test="${showDocuments and documents.fullListSize gt 0}">
<spring:message var="documentsResultsTitle" code="Documents" text="Documents"/>
<tab:tabPane id="search-documents" tabTitle="${documentsResultsTitle} (${documents.fullListSize})">
	<div style="overflow:auto;">
	<display:table id="searchDocumentItem" name="${documents}" sort="external" requestURI="${requestURI}" cellpadding="0" export="${isExport}" class="search_table"
		decorator="com.intland.codebeamer.ui.view.table.search.DocumentSearchDecorator" >

		<ui:actionGenerator builder="artifactListContextActionMenuBuilder" subject="${searchDocumentItem}" actionListName="actions"
			deniedKeys="Lock, Unlock, Delete..., Undelete, New Version"
		>

		<display:setProperty name="pagination.pagenumber.param"    	value="documentsPage" />
		<display:setProperty name="pagination.sort.param"          	value="documentsSort" />
		<display:setProperty name="pagination.sortdirection.param" 	value="documentsDir" />
		<display:setProperty name="paging.banner.placement" 		value="${bannerPosition}"/>
		<display:setProperty name="paging.banner.onepage" 			value="${bannerOnePage}" />
		<display:setProperty name="paging.banner.one_item_found" 	value="${bannerOneItem}" />
		<display:setProperty name="paging.banner.all_items_found" 	value="${bannerAllItems}" />
		<display:setProperty name="paging.banner.some_items_found" 	value="${bannerSomeItems}" />
		<display:setProperty name="paging.banner.group_size" 		value="${bannerGroupSize}" />

		<c:if test="${selectionAllowed}">
			<display:column title="${selectColumnTitle}" headerClass="checkbox-column-minwidth">
				<c:set var="selectionValue" value="${ARTIFACT}-${searchDocumentItem.id}" />
				<input type="${selectInputType}" name="searchItem" value="${selectionValue}"
					<c:if test="${! empty selectedItems[selectionValue]}">checked="checked"</c:if>
				/>
				<input type="hidden" name="visibleItem" value="${selectionValue}" />
			</display:column>
		</c:if>

		<spring:message var="documentName" code="document.name.label" text="Document"/>
		<display:column title="${documentName}" property="name" headerClass="textData" class="textData" sortable="false" />

		<display:column title="" decorator="com.intland.codebeamer.ui.view.table.TrimmedColumnDecorator" media="html" class="action-column-minwidth columnSeparator">
			<ui:actionMenu actions="${actions}" alwaysDisplayContextMenuIcons="${alwaysDisplayContextMenuIcons}" />
		</display:column>

		<spring:message var="documentModified" code="document.lastModifiedAt.label" text="Modified"/>
		<display:column title="${documentModified}" property="lastModifiedAt" headerClass="dateData" class="dateData columnSeparator" sortable="false" />

		<spring:message var="documentStatus" code="document.status.label" text="Status"/>
		<display:column title="${documentStatus}" property="status" headerClass="textData" class="textData columnSeparator" sortable="false" />

		<spring:message var="documentDirectory" code="document.directory.label" text="Directory"/>
		<display:column title="${documentDirectory}" property="directory" headerClass="textData" class="textDataWrap columnSeparator" sortable="false" />

		<c:if test="${showProject}">
			<spring:message var="documentProject" code="document.project.label" text="Project"/>
			<display:column title="${documentProject}" property="project" sortProperty="projectName" headerClass="textData" class="textDataWrap" sortable="false" />
		</c:if>

		</ui:actionGenerator>
	</display:table>
	</div>
</tab:tabPane>
</c:if>

<%-- Reports --%>
<c:if test="${showReports and reports.fullListSize gt 0}">
<spring:message var="reportsResultsTitle" code="Queries" text="Reports"/>
<tab:tabPane id="search-reports" tabTitle="${reportsResultsTitle} (${reports.fullListSize})">
	<div style="overflow:auto;">
	<display:table id="searchReportsItem" name="${reports}" sort="external" requestURI="${requestURI}" cellpadding="0" export="${isExport}" class="search_table"
		decorator="com.intland.codebeamer.ui.view.table.search.DocumentSearchDecorator" >

		<ui:actionGenerator builder="artifactListContextActionMenuBuilder" subject="${searchReportsItem}" actionListName="actions"
			deniedKeys="Lock, Unlock, Delete..., Undelete, New Version"
		>

		<display:setProperty name="pagination.pagenumber.param"    	value="reportsPage" />
		<display:setProperty name="pagination.sort.param"          	value="reportsSort" />
		<display:setProperty name="pagination.sortdirection.param" 	value="reportsDir" />
		<display:setProperty name="paging.banner.placement" 		value="${bannerPosition}"/>
		<display:setProperty name="paging.banner.onepage" 			value="${bannerOnePage}" />
		<display:setProperty name="paging.banner.one_item_found" 	value="${bannerOneItem}" />
		<display:setProperty name="paging.banner.all_items_found" 	value="${bannerAllItems}" />
		<display:setProperty name="paging.banner.some_items_found" 	value="${bannerSomeItems}" />
		<display:setProperty name="paging.banner.group_size" 		value="${bannerGroupSize}" />

		<c:if test="${selectionAllowed}">
			<display:column title="${selectColumnTitle}" headerClass="checkbox-column-minwidth">
				<c:set var="selectionValue" value="${ARTIFACT}-${searchReportsItem.id}" />
				<input type="${selectInputType}" name="searchItem" value="${selectionValue}"
					<c:if test="${! empty selectedItems[selectionValue]}">checked="checked"</c:if>
				/>
				<input type="hidden" name="visibleItem" value="${selectionValue}" />
			</display:column>
		</c:if>

		<spring:message var="documentName" code="document.name.label" text="Document"/>
		<display:column title="${documentName}" property="name" headerClass="textData" class="textData" sortable="false" />

		<display:column title="" decorator="com.intland.codebeamer.ui.view.table.TrimmedColumnDecorator" media="html" class="action-column-minwidth columnSeparator">
			<ui:actionMenu actions="${actions}" alwaysDisplayContextMenuIcons="${alwaysDisplayContextMenuIcons}" />
		</display:column>

		<spring:message var="documentModified" code="document.lastModifiedAt.label" text="Modified"/>
		<display:column title="${documentModified}" property="lastModifiedAt" headerClass="dateData" class="dateData columnSeparator" sortable="false" />

		<spring:message var="documentStatus" code="document.status.label" text="Status"/>
		<display:column title="${documentStatus}" property="status" headerClass="textData" class="textData columnSeparator" sortable="false" />

		<spring:message var="documentDirectory" code="document.directory.label" text="Directory"/>
		<display:column title="${documentDirectory}" property="directory" headerClass="textData" class="textDataWrap columnSeparator" sortable="false" />

		<c:if test="${showProject}">
			<spring:message var="documentProject" code="document.project.label" text="Project"/>
			<display:column title="${documentProject}" property="project" sortProperty="projectName" headerClass="textData" class="textDataWrap" sortable="false" />
		</c:if>

		</ui:actionGenerator>
	</display:table>
	</div>
</tab:tabPane>
</c:if>

<%-- Repositories --%>
<c:if test="${showRepositories and repositories.fullListSize gt 0}">
	<spring:message var="repositoriesTitle" code="Repositories" text="Repositories"/>
	<tab:tabPane id="search-repositories" tabTitle="${repositoriesTitle} (${repositories.fullListSize})">
		<div style="overflow:auto;">
			<display:table id="searchRepository" name="${repositories}" sort="external" requestURI="${requestURI}" cellpadding="0" export="${isExport}" class="search_table"
				decorator="com.intland.codebeamer.ui.view.table.search.ScmRepositorySearchDecorator">

				<display:setProperty name="pagination.pagenumber.param"    	value="repositoriesPage" />
				<display:setProperty name="pagination.sort.param"          	value="repositoriesSort" />
				<display:setProperty name="pagination.sortdirection.param" 	value="repositoriesDir" />
				<display:setProperty name="paging.banner.placement" 		value="${bannerPosition}"/>
				<display:setProperty name="paging.banner.onepage" 			value="${bannerOnePage}" />
				<display:setProperty name="paging.banner.one_item_found" 	value="${bannerOneItem}" />
				<display:setProperty name="paging.banner.all_items_found" 	value="${bannerAllItems}" />
				<display:setProperty name="paging.banner.some_items_found" 	value="${bannerSomeItems}" />
				<display:setProperty name="paging.banner.group_size" 		value="${bannerGroupSize}" />

				<spring:message var="nameTitle" code="repository.name.label" text="Repository Name"/>
				<display:column title="${nameTitle}" property="name" sortProperty="id" headerClass="textData" class="textData columnSeparator" sortable="false" />

				<spring:message var="descriptionTitle" code="repository.description.label" text="Description"/>
				<display:column title="${descriptionTitle}" property="description" headerClass="textData" class="textData columnSeparator" sortable="false" />

				<spring:message var="createdAtTitle" code="repository.createdAt.label" text="Created"/>
				<display:column title="${createdAtTitle}" property="createdAt" headerClass="dateData" class="dateData" sortable="false" />

				<spring:message var="typeTitle" code="repository.type.label" text="Repository type"/>
				<display:column title="${typeTitle}" property="type" headerClass="dateData" class="dateData" sortable="false" />

				<c:if test="${showProject}">
					<spring:message var="projectTitle" code="repository.project.label" text="Project"/>
					<display:column title="${projectTitle}" property="project" sortProperty="projectName" headerClass="textData" class="textDataWrap" sortable="false" />
				</c:if>

			</display:table>
		</div>
	</tab:tabPane>
</c:if>

<%-- Projects --%>
<c:if test="${showProjects and projects.fullListSize gt 0}">
<spring:message var="projectsResultsTitle" code="Projects" text="Projects"/>
<tab:tabPane id="search-projects" tabTitle="${projectsResultsTitle} (${projects.fullListSize})">
	<div style="overflow:auto;">
	<display:table id="searchProjectItem" name="${projects}" sort="external" requestURI="${requestURI}" cellpadding="0" export="${isExport}" class="search_table"
		decorator="com.intland.codebeamer.ui.view.table.search.ProjectSearchDecorator" >

		<display:setProperty name="pagination.pagenumber.param"    	value="projectsPage" />
		<display:setProperty name="pagination.sort.param"          	value="projectsSort" />
		<display:setProperty name="pagination.sortdirection.param" 	value="projectsDir" />
		<display:setProperty name="paging.banner.placement" 		value="${bannerPosition}"/>
		<display:setProperty name="paging.banner.onepage" 			value="${bannerOnePage}" />
		<display:setProperty name="paging.banner.one_item_found" 	value="${bannerOneItem}" />
		<display:setProperty name="paging.banner.all_items_found" 	value="${bannerAllItems}" />
		<display:setProperty name="paging.banner.some_items_found" 	value="${bannerSomeItems}" />
		<display:setProperty name="paging.banner.group_size" 		value="${bannerGroupSize}" />

		<c:if test="${selectionAllowed}">
			<display:column title="${selectColumnTitle}" headerClass="checkbox-column-minwidth">
				<c:set var="selectionValue" value="${PROJECT}-${searchProjectItem.id}" />
				<input type="${selectInputType}" name="searchItem" value="${selectionValue}"
					<c:if test="${! empty selectedItems[selectionValue]}">checked="checked"</c:if>
				/>
				<input type="hidden" name="visibleItem" value="${selectionValue}" />
			</display:column>
		</c:if>

		<spring:message var="projectName" code="project.name.label" text="Name"/>
		<display:column title="${projectName}" property="name" sortName="projectName" headerClass="textData" class="textData columnSeparator" sortable="false" />

		<spring:message var="projectDescription" code="project.description.label" text="Description"/>
		<display:column title="${projectDescription}" property="description" headerClass="textData" class="textData columnSeparator" sortable="false" />

		<spring:message var="projectCategory" code="project.category.label" text="Category"/>
		<display:column title="${projectCategory}" property="category" headerClass="textData" class="textData columnSeparator" sortable="false" />

		<spring:message var="projectStatus" code="project.status.label" text="Status"/>
		<display:column title="${projectStatus}" property="status" headerClass="textData" class="textData columnSeparator" sortable="false" />

		<spring:message var="projectCreatedAt" code="project.createdAt.label" text="Created"/>
		<display:column title="${projectCreatedAt}" property="createdAt" headerClass="dateData" class="dateData" sortable="false" />

	</display:table>
	</div>
</tab:tabPane>
</c:if>


<%-- Commits --%>
<c:if test="${showCommits and commits.fullListSize gt 0}">
<spring:message var="commitsResultsTitle" code="SCM commits" text="SCM commits"/>
<tab:tabPane id="search-commits" tabTitle="${commitsResultsTitle} (${commits.fullListSize})">
	<div style="overflow:auto;">
	<display:table id="searchCommitItem" name="${commits}" sort="external" requestURI="${requestURI}" cellpadding="0" export="${isExport}" class="search_table"
		decorator="com.intland.codebeamer.ui.view.table.search.CommitSearchDecorator" >

		<display:setProperty name="pagination.pagenumber.param"    	value="commitsPage" />
		<display:setProperty name="pagination.sort.param"          	value="commitsSort" />
		<display:setProperty name="pagination.sortdirection.param" 	value="commitsDir" />
		<display:setProperty name="paging.banner.placement" 		value="${bannerPosition}"/>
		<display:setProperty name="paging.banner.onepage" 			value="${bannerOnePage}" />
		<display:setProperty name="paging.banner.one_item_found" 	value="${bannerOneItem}" />
		<display:setProperty name="paging.banner.all_items_found" 	value="${bannerAllItems}" />
		<display:setProperty name="paging.banner.some_items_found" 	value="${bannerSomeItems}" />
		<display:setProperty name="paging.banner.group_size" 		value="${bannerGroupSize}" />

		<spring:message var="commitComment" code="scm.commit.comment.label" text="Comment"/>
		<display:column title="${commitComment}" property="comment" headerClass="textData" class="textData columnSeparator" />

		<spring:message var="commitDate" code="scm.commit.date.label" text="Date"/>
		<display:column title="${commitDate}" property="date" headerClass="dateData" class="dateData columnSeparator" sortable="false" />

		<spring:message var="commitTasks" code="scm.commit.tasks.label" text="Tasks"/>
		<display:column title="${commitTasks}" property="tasks" headerClass="textData" class="textData columnSeparator" sortable="false" />

		<spring:message var="commitFile" code="scm.commit.file.label" text="File"/>
		<display:column title="${commitFile}" property="file" headerClass="textData" class="textData columnSeparator" sortable="false" />

		<spring:message var="commitAuthor" code="scm.commit.author.label" text="Author"/>
		<display:column title="${commitAuthor}" property="author" headerClass="textData" class="textData columnSeparator" sortable="false" />

		<spring:message var="commitRepository" code="scm.repository.node.label" text="Repository"/>
		<display:column title="${commitRepository}" property="repository" headerClass="textData" class="textData columnSeparator" sortable="false" />

		<c:if test="${showProject}">
			<spring:message var="commitProject" code="scm.commit.project.label" text="Project"/>
			<display:column title="Project" property="project" sortProperty="projectName" headerClass="textData" class="textDataWrap" sortable="false" />
		</c:if>

	</display:table>
	</div>
</tab:tabPane>
</c:if>

<%-- Users --%>
<c:if test="${showUsers and users.fullListSize gt 0}">
<spring:message var="accountsResultsTitle" code="Accounts" text="Accounts"/>
<tab:tabPane id="search-users" tabTitle="${accountsResultsTitle} (${users.fullListSize})">
	<div style="overflow:auto;">

	<display:table id="searchUser" name="${users}" sort="external" requestURI="${requestURI}" cellpadding="0" export="${isExport}" class="search_table"
		decorator="com.intland.codebeamer.ui.view.table.search.UserSearchDecorator">

		<display:setProperty name="pagination.pagenumber.param"    	value="usersPage" />
		<display:setProperty name="pagination.sort.param"          	value="usersSort" />
		<display:setProperty name="pagination.sortdirection.param" 	value="usersDir" />
		<display:setProperty name="paging.banner.placement" 		value="${bannerPosition}"/>
		<display:setProperty name="paging.banner.onepage" 			value="${bannerOnePage}" />
		<display:setProperty name="paging.banner.one_item_found" 	value="${bannerOneItem}" />
		<display:setProperty name="paging.banner.all_items_found" 	value="${bannerAllItems}" />
		<display:setProperty name="paging.banner.some_items_found" 	value="${bannerSomeItems}" />
		<display:setProperty name="paging.banner.group_size" 		value="${bannerGroupSize}" />

		<c:if test="${selectionAllowed}">
			<display:column title="${selectColumnTitle}" headerClass="checkbox-column-minwidth">
				<c:set var="selectionValue" value="${USER_ACCOUNT}-${searchUser.id}" />
				<input type="${selectInputType}" name="searchItem" value="${selectionValue}"
					<c:if test="${! empty selectedItems[selectionValue]}">checked="checked"</c:if>
				/>
				<input type="hidden" name="visibleItem" value="${selectionValue}" />
			</display:column>
		</c:if>

		<spring:message var="accountTitle" code="user.account.label" text="Account"/>
		<display:column title="${accountTitle}" property="name" headerClass="textData" class="textData columnSeparator" sortable="false" />

		<spring:message var="realNameTitle" code="user.realName.label" text="Real Name"/>
		<display:column title="${realNameTitle}" property="realName" headerClass="textData" class="textData columnSeparator" sortable="false" />

		<spring:message var="emailTitle" code="user.email.label" text="Email"/>
		<display:column title="${emailTitle}" property="email" headerClass="textData" class="textData columnSeparator"
			comparator="com.intland.codebeamer.ui.view.table.EmailComparator" sortable="false" />

		<c:if test="${canViewCompany}">
			<spring:message var="companyTitle" code="user.company.label" text="Company"/>
			<display:column title="${companyTitle}" property="company" headerClass="textData" class="textDataWrap columnSeparator" sortable="false" />
		</c:if>

		<c:if test="${canViewPhone}">
			<spring:message var="phoneTitle" code="user.phone.label" text="Phone"/>
			<display:column title="${phoneTitle}" property="phone" headerClass="textData" class="textData columnSeparator" sortable="false" />

			<spring:message var="mobileTitle" code="user.mobile.label" text="Mobile/IP Voice"/>
			<display:column title="${mobileTitle}" property="mobile" headerClass="textData" class="textData columnSeparator" sortable="false" />
		</c:if>

		<c:if test="${canViewSkills}">
			<spring:message var="skillsTitle" code="user.skills.label" text="Skills"/>
			<display:column title="${skillsTitle}" property="skills" headerClass="textData" class="textDataWrap columnSeparator" sortable="false" />
		</c:if>
	</display:table>
	</div>
</tab:tabPane>
</c:if>

</tab:tabContainer>
<script type="text/javascript">
	$("#search-all").focus();
</script>
</c:when>
<c:otherwise>
	<spring:message code="table.nothing.found" text="No matching found"/>
<script type="text/javascript">
	$("#searchFilterPattern").focus();
</script>
</c:otherwise>
</c:choose>

</div>
