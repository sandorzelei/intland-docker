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
<%@ taglib uri="taglib" prefix="tag" %>
<%@ taglib uri="bugstaglib" prefix="bugs" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>

<script src="<ui:urlversioned value="/wro/codemirror.js"/>"></script>
<link rel="stylesheet" href="<ui:urlversioned value="/wro/codemirror.css"/>">

<link rel="stylesheet" href="<ui:urlversioned value='/stylesheet/selectorUtils.less' />" type="text/css" media="all" />
<link rel="stylesheet" href="<ui:urlversioned value='/queries/queryWidget.less' />" type="text/css" media="all" />

<script type="text/javascript" src="<ui:urlversioned value='/js/selectorUtils.js'/>"></script>
<script type="text/javascript" src="<ui:urlversioned value='/js/reportSupport.js'/>"></script>
<script type="text/javascript" src="<ui:urlversioned value='/bugs/tracker/includes/referenceField.js'/>"></script>

<div id="reportPageWidget" class="queryWidget">

	<div class="selectorSection">

	<div class="queryWidgetHeader">
		<div class="headerLabel"><spring:message code="project.label"/>:</div>
		<div class="headerSelector project" id="queryWidgetProjectSelectorDiv">
			<select id="queryWidgetProjectSelector" data-cbQlAttrName="projectId" class="selector projectSelector" multiple="multiple"></select>
		</div>
		<span class="currentProjectPlaceholder" data-id="0">
			<span class="label"><spring:message code="query.condition.widget.current.project"/>:</span>
			<span class="projectName"></span>
			<span class="controls"><a href="#" class="setCurrentProjectButton"><spring:message code="button.set"/></a> <a href="#" class="clearCurrentProjectButton"><spring:message code="button.clear"/></a></span>
		</span>
		<div class="headerLabel"><spring:message code="tracker.label"/>:</div>
		<div class="headerSelector tracker" id="queryWidgetTrackerSelectorDiv">
			<select id="queryWidgetTrackerSelector" data-cbQlAttrName="trackerId" class="selector trackerSelector" multiple="multiple"></select>
		</div>
		<div class="reportAjaxLoading"><img src="<c:url value="/images/ajax-loading_16.gif"/>" /></div>
	</div>

	<table class="queryWidgetTable">
		<tr>
			<td class="fieldArea" rowspan="2" id="queryWidgetFieldArea">
				<div class="droppableArea">
					<span class="modifiableArea">
						<span class="logicStripe droppableAreaButton">
							<table class="logicStripeTable">
								<tr>
									<td class="logicStripeText"><spring:message code="query.widget.and.or.logic.label" text="AND/OR Logic"/>:</td>
									<td class="logicStripeInput"><input placeholder="<spring:message code="query.widget.logic.valid.phrases.tooltip"/>" type="text" class="logicString"></td>
									<td class="logicStripeRemove"><span class="ui-icon removeIcon removeLogic"></span></td>
								</tr>
							</table>
						</span>
						<span class="addButton droppableAreaButton">+ <spring:message code="query.condition.widget.add.filter" text="Add filter"/></span>
						<span class="clearButton droppableAreaButton" title="<spring:message code="report.selector.clear.filters.tooltip"/>"><spring:message code="report.selector.clear.filters.label" text="Remove all"/></span>
						<span class="logicButton droppableAreaButton">+ <spring:message code="query.widget.add.and.or.label" text="Add AND/OR"/></span>
					</span>
				</div>
			</td>
			<td class="groupArea" id="queryWidgetGroupByArea">
				<div class="droppableArea">
					<div class="selectorContainer">
						<spring:message code="query.widget.group.by"/>:
						<span class="addDroppableButton addGroupByButton">+ <spring:message code="button.add"/></span>
					</div>
				</div>
			</td>
		</tr>
		<tr>
			<td class="orderByArea" id="queryWidgetOrderByArea">
				<div class="droppableArea">
					<div class="selectorContainer">
						<spring:message code="query.widget.order.by"/>:
						<span class="addDroppableButton addOrderByButton">+ <spring:message code="button.add"/></span>
					</div>
				</div>
			</td>
		</tr>
	</table>

	</div>

	<div class="inputSection">
		<textarea class="queryWidgetAdvanced" rows="6"></textarea>
	</div>

	<div class="buttonContainer">
		<button id="queryWidgetGoButton" class="button searchButton"><spring:message code="search.submit.label" text="GO" /></button>
		<button id="queryWidgetAdvancedButton" class="advancedLink"><spring:message code="queries.advanced.label"/></button>
		<span class="resizeableColumns">
			<input type="checkbox" id="resizeableColumns" <c:if test="${resizeableColumns}"> checked="checked"</c:if>>
			<label for="resizeableColumns"><spring:message code="report.selector.resizeable.columns"/></label>
		</span>
	</div>

	<select class="filterSelector" id="filterSelector_reportPageWidget" multiple="multiple"></select>
	<select class="filterSelector" id="groupBySelector_reportPageWidget" multiple="multiple"></select>
	<select class="filterSelector" id="orderBySelector_reportPageWidget" multiple="multiple"></select>
	<select class="filterSelector" id="addFieldSelector_reportPageWidget" multiple="multiple"></select>

</div>

<script type="text/javascript">

	(function($) {
		$(function() {

			var widgetContainer = $("#reportPageWidget");
			var resultContainer = $("#queryResultTable");
			var queryId = ${not empty queryId ? queryId : 'null'};
			var queryString = null;
			<c:if test="${not empty queryString}">
				queryString = "${ui:escapeJavaScript(queryString)}";
			</c:if>
			var advanced = ${advancedMode ? 'true' : 'false'};
			var viewMode = ${editMode ? 'false' : 'true'};
			var logic = "<c:out value="${logic}"/>";
			logic = logic.replaceAll("@", "");
			logic = logic.slice(1, -1); // remove brackets, they will be added back by saving/validating
			var logicSlices = ${empty logicSlices ? 'null' : logicSlices};

			widgetContainer.data("format", '${format}');
			widgetContainer.data("aggregatefunctions", '${aggregatefunctions}');

			codebeamer.ReportSupport.initReportWidget($("#reportPageWidget"), {
				"reportPage" : true,
				"queryId" : queryId,
				"queryString" : queryString,
				"advanced" : advanced,
				"resultContainer" : resultContainer,
				"viewMode": viewMode,
				"logic": logic,
				"logicSlices": logicSlices
			});

		});
	})(jQuery);

</script>