<%-- This JSP is generated by com.intland.codebeamer.taglib.TagFileWrapperGenerator, DO NOT_EDIT, your changes will be lost! --%>
<%-- generated on --%>
<%-- Copyright by Intland Software --%>

<%-- JSP wrapper for .tag file '/WEB-INF/tags/bugs/displaytagTrackerItems.tag' --%>
<%@ taglib uri="bugstaglib" prefix="gen" %>

<%@ page session="false" import="com.intland.codebeamer.taglib.tagwrappers.bugs.DisplaytagTrackerItemsWrapper" %>

<% DisplaytagTrackerItemsWrapper a = ((DisplaytagTrackerItemsWrapper) request.getAttribute("tagFileWrapper")); %>

<gen:displaytagTrackerItems
	items="<%=a.items%>"
	reportId="<%=a.reportId%>"
	layoutList="<%=a.layoutList%>"
	decorator="<%=a.decorator%>"
	includeBaselineInTtId="<%=a.includeBaselineInTtId%>"
	showContextMenu="<%=a.showContextMenu%>"
	forceOpenInNewWindow="<%=a.forceOpenInNewWindow%>"
	selection="<%=a.selection%>"
	selectionFieldName="<%=a.selectionFieldName%>"
	multiSelect="<%=a.multiSelect%>"
	allowSelectionPredicate="<%=a.allowSelectionPredicate%>"
	selectedItems="<%=a.selectedItems%>"
	defaultsort="<%=a.defaultsort%>"
	defaultorder="<%=a.defaultorder%>"
	requestURI="<%=a.requestURI%>"
	pagesize="<%=a.pagesize%>"
	excludedParams="<%=a.excludedParams%>"
	export="<%=a.export%>"
	clearNavigationList="<%=a.clearNavigationList%>"
	paginationParamPrefix="<%=a.paginationParamPrefix%>"
	htmlId="<%=a.htmlId%>"
	exportTypes="<%=a.exportTypes%>"
	exportMode="<%=a.exportMode%>"
	extraColumn="<%=a.extraColumn%>"
	extraColumnLabel="<%=a.extraColumnLabel%>"
	extraColumnClass="<%=a.extraColumnClass%>"
	hideIconColumn="<%=a.hideIconColumn%>"
	globalSortable="<%=a.globalSortable%>"
	isReview="<%=a.isReview%>"
	hideItemChildrenHandler="<%=a.hideItemChildrenHandler%>"
	plannerMode="<%=a.plannerMode%>"
	inlineEdit="<%=a.inlineEdit%>"
	inlineEditBuildTransitionMenu="<%=a.inlineEditBuildTransitionMenu%>"
	showHeaderIfEmpty="<%=a.showHeaderIfEmpty%>"
	resizableColumns="<%=a.resizableColumns%>"
	disableResizableColumns="<%=a.disableResizableColumns%>"
	browseTrackerMode="<%=a.browseTrackerMode%>"
></gen:displaytagTrackerItems>
