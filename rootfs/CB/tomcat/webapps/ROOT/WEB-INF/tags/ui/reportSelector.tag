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
<%@ tag language="java" pageEncoding="UTF-8" %>

<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags" %>
<%@ taglib prefix="html" uri="http://struts.apache.org/tags-html" %>

<%@ tag import="com.intland.codebeamer.persistence.dto.UserDto" %>
<%@ tag import="com.intland.codebeamer.controller.support.ReportSelectorSupport" %>
<%@ tag import="com.intland.codebeamer.persistence.dto.CbQLDto" %>

<%@ attribute name="resultContainerId" required="false" type="java.lang.String" description="DOM element ID of the result container in which the result should be displayed" %>
<%@ attribute name="resultRenderUrl" required="false" type="java.lang.String" description="URL (without contextPath) which is called if clicking GO button and renders the result into the resultContainer" %>
<%@ attribute name="resultJsCallback" required="false" type="java.lang.String" description="Js function which fires after getting result." %>
<%@ attribute name="projectId" required="false" type="java.lang.Integer" description="Project ID if you would like you use the taglib in project context" %>
<%@ attribute name="trackerId" required="false" type="java.lang.Integer" description="Tracker ID if you would like you use the taglib in tracker context" %>
<%@ attribute name="releaseId" required="false" type="java.lang.Integer" description="Release ID if you would like you use the taglib in Release context" %>
<%@ attribute name="releaseTrackerId" required="false" type="java.lang.Integer" description="ID of the Release tracker for release tracker context" %>
<%@ attribute name="viewId" required="false" type="java.lang.Integer" description="Current ID of view in tracker context." %>
<%@ attribute name="defaultViewId" required="false" type="java.lang.Integer" description="ID of the default view in tracker context." %>
<%@ attribute name="showGroupBy" required="false" type="java.lang.Boolean" description="If the Group by section should be displayed or not" %>
<%@ attribute name="showOrderBy" required="false" type="java.lang.Boolean" description="If the Order by section should be displayed or not" %>
<%@ attribute name="hideAndOr" required="false" type="java.lang.Boolean" description="If the Order by section should be displayed or not" %>
<%@ attribute name="maxGroupByElements" required="false" type="java.lang.Integer" description="Maximum number of elements in Group by section" %>
<%@ attribute name="maxOrderByElements" required="false" type="java.lang.Integer" description="Maximum number of elements in Order by section" %>
<%@ attribute name="isDocumentView" required="false" type="java.lang.Boolean" description="Whether the Report Selector used in Document View or nor." %>
<%@ attribute name="isDocumentExtendedView" required="false" type="java.lang.Boolean" description="Whether the Report Selector used in Document Extended View (Document Edit View) or nor." %>
<%@ attribute name="isPlanner" required="false" type="java.lang.Boolean" description="Whether the Report Selector used in Planner or nor." %>
<%@ attribute name="isBranchMode" required="false" type="java.lang.Boolean" description="Whether the Report Selector is used in branch mode." %>
<%@ attribute name="triggerResultAfterInit" required="false" type="java.lang.Boolean" description="Wheater the result will be displayed immediately after the Report Selector initalized." %>
<%@ attribute name="contextualSearch" required="false" type="java.lang.Boolean" description="Wheater the selector tag should contain contextual search." %>
<%@ attribute name="sticky" required="false" type="java.lang.Boolean" description="If the Report Selector should be stayed on the top of the page if scrolling down." %>
<%@ attribute name="mergeToActionBar" required="false" type="java.lang.Boolean" description="If the Report Selector should be merged to the action bar of the page." %>
<%@ attribute name="queryString" required="false" type="java.lang.String" description="Initial cbQL." %>
<%@ attribute name="trackerItemTableId" required="false" type="java.lang.String" description="The id of the table containing the tracker items." %>
<%@ attribute name="filterProjectIds" required="false" type="java.lang.String" description="Optional list for filtering always by project IDs." %>
<%@ attribute name="filterTrackerIds" required="false" type="java.lang.String" description="Optional list for filtering always by tracker IDs." %>
<%@ attribute name="traceabilityTrackerId" required="false" type="java.lang.Integer" description="Tracker ID for Traceability Browser." %>
<%@ attribute name="onlyBranchableTrackers" required="false" type="java.lang.Boolean" description="If true then only those branches that can be branched" %>
<%@ attribute name="autoHeight" required="false" type="java.lang.Boolean" description="If true then the height of the select lists are computed automatically instead of using the hardcoaded value" %>
<%@ attribute name="useSimpleSelectedText" required="false" type="java.lang.Boolean" description="If true then the tracker selector shows only the number of the selected items instead of hteir names" %>
<%@ attribute name="showResizeableColumns" required="false" type="java.lang.Boolean" description="If resizeable columns option show in Report Picker overlay." %>

<%! static int idgen = 0; %>
<% jspContext.setAttribute("htmlId", "reportSelector" + idgen++); %>

<%! private static final ReportSelectorSupport support = ReportSelectorSupport.getInstance(); %>
<%
	UserDto user = (UserDto) request.getUserPrincipal();
	Boolean resizeableColumns = Boolean.FALSE;
	if (viewId != null) {
		CbQLDto query = support.getCbQLDto(user, viewId, trackerId);
		jspContext.setAttribute("reportId", viewId);
		jspContext.setAttribute("reportQueryString", support.getQueryString(user, viewId, trackerId));
		jspContext.setAttribute("logic", query == null ? "" : (query.getLogic() == null ? "" : query.getLogic()));
		jspContext.setAttribute("logicSlices", query == null ? "{}" : (query.getLogicSlicesJSON() == null ? "{}" : query.getLogicSlicesJSON()));
		jspContext.setAttribute("reportFilterAttributes", support.getFilterAttributes(user, viewId));
		resizeableColumns = query != null ? query.getResizeableColumns() : Boolean.FALSE;
	}
	if (trackerId != null || releaseTrackerId != null || releaseId != null) {
		jspContext.setAttribute("predefinedPublicReports", support.getPredefinedReports(user, releaseTrackerId != null ? releaseTrackerId : trackerId, releaseId));
		jspContext.setAttribute("canUserAdminPublicReport", support.canUserAdminPublicReport(user, releaseTrackerId != null ? releaseTrackerId : trackerId, releaseId));
	}
	jspContext.setAttribute("resizeableColumns", resizeableColumns);
%>

<script src="<ui:urlversioned value="js/codemirror/lib/codemirror.js"/>"></script>
<link rel="stylesheet" href="<ui:urlversioned value="js/codemirror/lib/codemirror.css"/>">
<script src="<ui:urlversioned value="js/codemirror/mode/sql/sql.js"/>"></script>

<link rel="stylesheet" href="<ui:urlversioned value='/stylesheet/selectorUtils.less' />" type="text/css" media="all" />
<link rel="stylesheet" href="<ui:urlversioned value='/stylesheet/reportSelector.less' />" type="text/css" media="all" />
<script type="text/javascript" src="<ui:urlversioned value='/js/selectorUtils.js'/>"></script>
<script type="text/javascript" src="<ui:urlversioned value='/js/reportSupport.js'/>"></script>

<!-- Set defaults -->
<c:if test="${empty resultRenderUrl}">
	<c:set var="resultRenderUrl" value="/proj/queries/runQuery.spr"/>
</c:if>
<c:if test="${empty resultJsCallback}">
	<c:set var="resultJsCallback" value="codebeamer.ReportSupport.defaultReportTagSelectorResultCallback"/>
</c:if>
<c:if test="${empty maxGroupByElements}">
	<c:set var="maxGroupByElements" value="3"/>
</c:if>
<c:if test="${empty maxOrderByElements}">
	<c:set var="maxOrderByElements" value="3"/>
</c:if>
<c:if test="${empty autoHeight}">
	<c:set var="autoHeight" value="false"/>
</c:if>

<%--<c:if test="${not empty releaseId}">--%>
	<%--<c:remove var="projectId"/>--%>
<%--</c:if>--%>

<c:if test="${not empty projectId}">
	<c:set var="queryString" value="project.id IN (${projectId})"/>
</c:if>
<c:if test="${not empty projectId && not empty trackerId}">
	<c:set var="queryString" value="project.id IN (${projectId}) AND tracker.id IN (${trackerId})"/>
</c:if>
<c:if test="${not empty reportQueryString}">
	<c:set var="queryString" value="${reportQueryString}"/>
</c:if>

<div class="reportSelectorTag<c:if test="${mergeToActionBar}"> mergeToActionBar</c:if>" id="${htmlId}">
	<div class="selectorSection">
	<table class="reportSelectorTable selectorSection">
		<tr>
			<td class="filterTd fieldArea" style="width: ${showGroupBy && showOrderBy ? '61%' : (showGroupBy && !showOrderBy ? '76%' : (!showGroupBy && showOrderBy ? '81%' : '96%'))}">
				<div class="filterContainer droppableArea">
					<span class="filterLabel actionBarIcon" title="<spring:message code="query.condition.widget.add.filter"/>"></span>
					<span class="projectSelectorLabel"<c:if test="${not empty projectId}"> style="display: none"</c:if>><b><spring:message code="project.label"/>:</b></span><select data-cbQlAttrName="projectId" class="selector projectSelector" multiple="multiple" style="display: none"></select>
					<span class="trackerSelectorLabel"<c:if test="${not empty trackerId}"> style="display: none"</c:if>><b><spring:message code="tracker.label"/>:</b></span><select data-cbQlAttrName="trackerId" class="selector trackerSelector" multiple="multiple" style="display: none"></select>
					<span class="queryConditionSelectorPlaceHolder"></span>
					<c:if test="${!hideAndOr}">

						<span class="modifiableArea">
							<span class="addButton droppableAreaButton">+ <spring:message code="query.condition.widget.add.filter"/></span>
							<span class="logicButton droppableAreaButton"><spring:message code="query.widget.and.or.label" text="AND/OR"/></span>
							<span class="logicStripe droppableAreaButton">
								<table class="logicStripeTable">
									<tr>
										<td class="logicStripeInput"><input placeholder="<spring:message code="query.widget.and.or.logic.label"/>" type="text" class="logicString"></td>
										<td class="logicStripeRemove"><span class="ui-icon removeIcon removeLogic"></span></td>
									</tr>
								</table>
							</span>
						</span>
					</c:if>
					<div class="reportAjaxLoading"><img src="<c:url value="/images/ajax-loading_16.gif"/>" /></div>
				</div>
			</td>
			<td class="groupByTd groupArea" <c:if test="${!showGroupBy}"> style="display: none"</c:if>>
				<div class="droppableArea">
					<div class="selectorContainer">
						<span class="groupByOrderByLabel groupByLabel actionBarIcon" data-tooltip="<spring:message code="query.widget.add.group.by"/>"></span>
						<span class="queryConditionSelectorPlaceHolder"></span>
						<span class="addDroppableButton addGroupByButton"></span>
					</div>
				</div>
			</td>
			<td class="orderByTd orderByArea" <c:if test="${!showOrderBy}"> style="display: none"</c:if>>
				<div class="droppableArea">
					<div class="selectorContainer">
						<span class="groupByOrderByLabel orderByLabel actionBarIcon" data-tooltip="<spring:message code="query.widget.add.order.by"/>"></span>
						<span class="queryConditionSelectorPlaceHolder"></span>
						<span class="addDroppableButton addOrderByButton"></span>
					</div>
				</div>
			</td>
			<c:if test="${contextualSearch}">
				<td class="contextualSearchTd">
					<spring:message var="trackerFilterTitle" code="tracker.filter.tooltip" text="Filter this tracker for summary, description and comments"/>
					<input type="text" title="${trackerFilterTitle}" class="contextualSearchBox" placeholder="<spring:message code="search.hint"/>">
				</td>
			</c:if>
			<c:if test="${not empty resultContainerId}">
				<td class="controlTd">
					<button class="button searchButton"><spring:message code="search.submit.label" text="GO"/></button>
				</td>
				<td class="controlTd reportSelectorButtonTd">
					<span class="reportSelectorButton"></span>
				</td>
			</c:if>
		</tr>
	</table>
	</div>
	<div class="inputSection" style="display: none">
		<textarea class="queryWidgetAdvanced" rows="1"></textarea>
	</div>
	<div class="reportPickerContainer">
		<div class="reportPickerMenuHeader">
			<span class="reportPickerMenu save"><a href="#"><spring:message code="button.save"/></a></span>
			<span class="reportPickerMenu saveAs"><a href="#"><spring:message code="queries.contextmenu.duplicate"/></a></span>
			<span class="reportPickerMenu properties"><a href="#"><spring:message code="queries.contextmenu.properties"/></a></span>
			<span class="reportPickerMenu delete"><a href="#"><spring:message code="queries.contextmenu.delete"/></a></span>
			<span class="reportPickerMenu revert"><a href="#"><spring:message code="queries.contextmenu.revert"/></a></span>
		</div>
		<div class="reportPickerCurrentHeader">
			<span class="reportNameLabel"><spring:message code="report.selector.current.report.label"/>: </span>
			<span class="reportName"></span>
			<span class="setAsDefault"><a href="#"><spring:message code="tracker.view.setasdefault.label"/></a></span>
			<span class="clearDefault"><a href="#"><spring:message code="tracker.view.unsetasdefault.label"/></a></span>
			<c:if test="${showResizeableColumns}">
				<span class="resizeableColumns">
					<input type="checkbox" id="resizeableColumns"<c:if test="${resizeableColumns}"> checked="checked"</c:if>>
					<label for="resizeableColumns"><spring:message code="report.selector.resizeable.columns"/></label>
				</span>
			</c:if>
		</div>
		<c:if test="${not empty trackerId && !isDocumentView && !isDocumentExtendedView}">
			<div class="reportPickerIntelligentTableView">
				<a href="#"><spring:message code="intelligent.table.view.configuration.label"/></a>
			</div>
		</c:if>
		<table>
			<tr>
				<c:if test="${not empty trackerId || not empty releaseTrackerId || not empty releaseId}">
					<td sytle="width: 50%">
						<div class="reportTypeContainer">
							<div class="reportTypeHeader publicReports" title="<spring:message code="report.selector.public.reports.tooltip"/>"><spring:message code="report.selector.public.reports.label"/></div>
							<div class="reportTypeListContainer">
								<span class="predefinedReports">
									<ui:UserSetting var="expandDefaultViews" setting="EXPAND_DEFAULT_VIEWS_SECTION" defaultValue="false" />
									<fieldset class="collapsingBorder relations-box<c:if test="${!expandDefaultViews}"> collapsingBorder_collapsed</c:if>">
										<legend class="collapsingBorder_legend">
											<a href="#" class="collapseToggle" onclick="CollapsingBorder.toggle(this, null, ''); return false;"><spring:message code="report.selector.default.reports.label"/></a>
										</legend>
										<div class="collapsingBorder_content">
											<ul>
												<c:forEach items="${predefinedPublicReports}" var="predefinedReport">
													<li class="predefined"><input type="radio" value="${predefinedReport.id}"><span class="reportName"><spring:message code="tracker.view.${predefinedReport.name}.label"/></span></li>
												</c:forEach>
											</ul>
										</div>
									</fieldset>
								</span>
								<span class="publicReportPicker"></span>
							</div>
						</div>
					</td>
				</c:if>
				<td style="width: ${not empty trackerId || not empty releaseTrackerId || not empty releaseId ? '50%' : '100%'}">
					<div class="reportTypeContainer">
						<div class="reportTypeHeader privateReports" title="<spring:message code="report.selector.private.reports.tooltip"/>"><spring:message code="report.selector.private.reports.label"/></div>
						<div class="reportTypeListContainer userDefinedReportPicker">
							<img src="${pageContext.request.contextPath}/images/ajax-loading_26.gif">
						</div>
					</div>
				</td>
			</tr>
		</table>
	</div>
	<select class="filterSelector" id="filterSelector_${htmlId}" multiple="multiple"></select>
	<c:if test="${showGroupBy}">
		<select class="filterSelector" id="groupBySelector_${htmlId}" multiple="multiple"></select>
	</c:if>
	<c:if test="${showOrderBy}">
		<select class="filterSelector" id="orderBySelector_${htmlId}" multiple="multiple"></select>
	</c:if>
	<select class="filterSelector" id="addFieldSelector_${htmlId}" multiple="multiple"></select>
</div>

<script type="text/javascript">
	$(function() {
		var logic = "<c:out value="${logic}"/>";
		logic = logic.replaceAll("@", "");
		logic = logic.slice(1, -1); // remove brackets, they will be added back by saving/validating
		var logicSlices = ${empty logicSlices ? 'null' : logicSlices};
		var resultContainerId = "${empty resultContainerId ? 'null' : resultContainerId}";
		var useSimpleSelectedText = ${empty useSimpleSelectedText ? false : true};

		var config = {
			"resultRenderUrl" : "${resultRenderUrl}",
			"resultJsCallback" : "${resultJsCallback}",
			"queryId" : ${empty reportId ? 'null' : reportId},
			"queryString" : "${empty queryString ? '' : ui:escapeJavaScript(queryString)}",
			"logic": logic,
			"logicSlices": logicSlices,
			"filterAttributes" : ${empty reportFilterAttributes ? '{}' : reportFilterAttributes},
			"projectId" : ${empty projectId ? 'null' : projectId},
			"trackerId" : ${empty trackerId ? 'null' : trackerId},
			"releaseId" : ${empty releaseId ? 'null' : releaseId},
			"releaseTrackerId" : ${empty releaseTrackerId ? 'null' : releaseTrackerId},
			"defaultViewId" : ${empty defaultViewId ? 'null' : defaultViewId},
			"showGroupBy" : ${showGroupBy ? 'true' : 'false'},
			"showOrderBy" : ${showOrderBy ? 'true' : 'false'},
			"maxGroupByElements" : ${maxGroupByElements},
			"maxOrderByElements" : ${maxOrderByElements},
			"triggerResultAfterInit" : ${triggerResultAfterInit ? 'true' : 'false'},
			"canUserAdminPublicReport" : ${canUserAdminPublicReport ? 'true' : 'false'},
			"isDocumentView" : ${isDocumentView ? 'true' : 'false'},
			"isDocumentExtendedView" : ${isDocumentExtendedView ? 'true' : false},
			"isPlanner" : ${isPlanner ? 'true' : 'false'},
			"isBranchMode" : ${isBranchMode ? 'true' : 'false'},
			"contextualSearch" : ${contextualSearch ? 'true' : 'false'},
			"sticky" : ${sticky ? 'true' : 'false'},
			"mergeToActionBar" : ${mergeToActionBar ? 'true' : 'false'},
			"trackerItemTableId" : "${empty trackerItemTableId ? 'trackerItems' : trackerItemTableId}",
			"filterProjectIds" : "${empty filterProjectIds ? 'null' : filterProjectIds}",
			"filterTrackerIds" : "${empty filterTrackerIds ? 'null' : filterTrackerIds}",
			"traceabilityTrackerId" : ${empty traceabilityTrackerId ? 'null' : traceabilityTrackerId},
			"onlyBranchableTrackers": ${empty onlyBranchableTrackers ? 'false' : onlyBranchableTrackers},
			'autoHeight': ${autoHeight},
			'useSimpleSelectedText': useSimpleSelectedText,
			'showResizeableColumns' : ${showResizeableColumns ? 'true' : 'false'}
		};
		if (resultContainerId != null) {
			config["resultContainer"] = $("#" + resultContainerId);
		}
		codebeamer.ReportSupport.initReportSelectorTag($("#${htmlId}"), config);
	});
</script>