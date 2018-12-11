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
<meta name="module" content="tracker"/>
<meta name="bodyCSSClass" content="newskin riskMatrix ${not empty branch ? 'tracker-branch' : '' }"/>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="taglib" prefix="tag" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="http://ditchnet.org/jsp-tabs-taglib" prefix="tab" %>

<%@ taglib uri="bugstaglib" prefix="bugs" %>

<style type="text/css">

	.riskMatrixSettings table {
		margin-top: 0.5em;
		width: 100%;
	}

	.riskMatrixSettings table td {
		padding: 0.3em;
		border: none;
	}

	.riskMatrixSettings table td.icon {
		text-align: right;
		width: 20px;
	}

	#riskTrackerSelector {
		padding: 4px;
		width: 95%;
		border: 1px solid #ddd;
		margin: 0.2em;
	}

	.riskMatrixSettings .relatedTrackers {
		padding-top: 2em;
		font-weight: bold;
	}

	a.exportToWord {
		background: url("${exportWordImgUrl}") no-repeat 0 -2px;
		padding-left: 18px;
		margin: 1em 1em 0 1em;
		display: inline-block;
		cursor: pointer;
		font-weight: bold;
	}

	a.exportToExcel {
		background: url("${exportExcelImgUrl}") no-repeat 0 -2px;
		padding-left: 18px;
		margin: 1em 1em 0 1em;
		display: inline-block;
		cursor: pointer;
		font-weight: bold;
	}

	a.bottom {
		margin-bottom: 1em;
	}

	.riskMatrixTabContainer {
		padding: 0.5em;
	}

	#risk-matrix-diagram-req, #risk-matrix-diagram-risk {
		margin-left: 0 !important;
		margin-right: 0 !important;
	}

	.ui-multiselect-menu.trackerSelectorTag .ui-multiselect-close {
		display: none !important;
	}

	.ui-multiselect-menu.trackerSelectorTag li {
		padding-top: 3px !important;
		padding-bottom: 3px !important;
	}

	button.trackerSelectorTag {
		width: 100%;
		min-width: auto !important;
	}

</style>

<bugs:branchStyle branch="${currentTracker }"/>

<ui:actionMenuBar showGlobalMessages="true">
	<jsp:attribute name="rightAligned">
		<ui:branchBaselineBadge branch="${importForm.branch}"/>
	</jsp:attribute>
	<jsp:body>
		<ui:breadcrumbs showProjects="false"><span class="breadcrumbs-separator">&raquo;</span>
			<ui:pageTitle prefixWithIdentifiableName="false">
				<spring:message code="tracker.riskMatrix.title" text="Risk Matrix Diagram"/>
			</ui:pageTitle>
		</ui:breadcrumbs>
	</jsp:body>
</ui:actionMenuBar>

<ui:splitTwoColumnLayoutJQuery leftMinWidth="220" cssClass="layoutfullPage autoAdjustPanesHeight">
	<jsp:attribute name="leftContent">
		<div class="riskMatrixSettings">
			<table>
				<tr>
					<td class="icon" style="vertical-align: top;">
						<img style="background-color: ${iconProvider.getIconBgColor(currentTrackerType)}" src="${contextPath}${iconProvider.getIconUrl(currentTrackerType)}">
					</td>
					<td>
						<ui:trackerSelector projectId="${currentTracker.project.id}" filterTrackerIds="${currentTracker.id}" selectedValue="${not empty branch ? branch.id : currentTracker.id}"/>
					</td>
				</tr>

				<c:if test="${allowedReqTrackerTypes.contains(currentTrackerType) && fn:length(riskTrackers) > 1}">
					<tr>
						<td colspan="2">
							<div class="information">
								<spring:message code="tracker.riskMatrix.info"/>
							</div>
						</td>
					</tr>
					<tr>
						<td colspan="2">
							<select id="riskTrackerSelector">
								<option value="0"><spring:message code="tracker.riskMatrix.selectRiskTracker" text="Select risk tracker"/></option>
								<optgroup label="----------">
									<option value="all"><spring:message code="tracker.riskMatrix.allRiskTracker" text="All risk trackers"/></option>
								</optgroup>
								<optgroup label="----------">
									<c:forEach var="riskTracker" items="${riskTrackers}">
										<option value="${riskTracker.id}"><c:out value='${riskTracker.name} (${riskTracker.project.name})'/></option>
									</c:forEach>
								</optgroup>
							</select>
						</td>
					</tr>
				</c:if>
				<tr>
					<td class="relatedTrackers" colspan="2"><spring:message code="tracker.riskMatrix.relatedTrackers" text="Related trackers"/></td>
				</tr>
				<c:forEach var="tracker" items="${requirementTrackers}">
					<tr>
						<td class="icon">
							<img style="background-color: ${iconProvider.getIconBgColor(reqTrackerType)}" src="${contextPath}${iconProvider.getIconUrl(reqTrackerType)}">
						</td>
						<td>
							<a href="${contextPath}${tracker.urlLink}" target="_blank"><spring:message code="tracker.${tracker.name}.label" text="${tracker.name}" htmlEscape="true"/></a>
						</td>
					</tr>
				</c:forEach>
				<c:forEach var="tracker" items="${riskTrackers}">
					<tr>
						<td class="icon">
							<img style="background-color: ${iconProvider.getIconBgColor(riskTrackerType)}" src="${contextPath}${iconProvider.getIconUrl(riskTrackerType)}">
						</td>
						<td>
							<a href="${contextPath}${tracker.urlLink}" target="_blank"><spring:message code="tracker.${tracker.name}.label" text="${tracker.name}" htmlEscape="true"/></a>
						</td>
					</tr>
				</c:forEach>
			</table>
		</div>
	</jsp:attribute>
	<jsp:body>

		<div class="accordion">
			<h3 class="accordion-header"><spring:message code="tracker.riskMatrix.title" text="Risk Matrix Diagram"/></h3>
			<div class="accordion-content">
				<div class="information">
					<spring:message code="tracker.riskMatrix.whatIs"/>
				</div>
			</div>
		</div>

		<form id="exportToWord" method="GET" action="${exportWordUrl}">
			<input type="hidden" name="tracker_id" value="${currentTracker.id}">
			<input type="hidden" name="risk_tracker" value="all">
			<input type="hidden" name="based_on" value="risk">
		</form>
		<form id="exportToExcel" method="GET" action="${exportExcelUrl}">
			<input type="hidden" name="tracker_id" value="${currentTracker.id}">
			<input type="hidden" name="risk_tracker" value="all">
		</form>

		<spring:message var="exportToWordLabel" code="tracker.issues.exportToWord.label" text="Export to Word"/>
		<spring:message var="exportToExcelLabel" code="tracker.issues.exportToExcel.label" text="Export to Excel"/>
		<a class="exportToWord" href="#">${exportToWordLabel}</a>
		<a class="exportToExcel" href="#">${exportToExcelLabel}</a>

		<div class="riskMatrixTabContainer">
			<tab:tabContainer id="risk-matrix-diagram" skin="cb-box" jsTabListener="riskMatrixChangeTab" selectedTabPaneId="risk-matrix-diagram-risk">

				<spring:message var="diagramTitleBasedOnRisk" code="tracker.riskMatrix.title.basedOnRisk" text="Risks"/>
				<tab:tabPane id="risk-matrix-diagram-risk" tabTitle="${diagramTitleBasedOnRisk}">
					<div class="information">
						<spring:message code="tracker.riskMatrix.risk.information"/>
					</div>
					<div class="warning">
						<spring:message code="tracker.riskMatrix.mitigation.req.warning"/>
					</div>
					<div id="riskMatrixDiagramRisk">
						<tag:transformText value="${riskMatrixWikiMarkupRisk}" format="W"/>
					</div>
				</tab:tabPane>

				<c:if test="${currentTracker.isRequirement()}">
					<spring:message var="diagramTitleBasedOnReq" code="tracker.riskMatrix.title.basedOnReq" text="Requirements with Risk"/>
				</c:if>
				<c:if test="${currentTracker.isEpic()}">
					<spring:message var="diagramTitleBasedOnReq" code="tracker.riskMatrix.title.basedOnEpic" text="Epics with Risk"/>
				</c:if>
				<c:if test="${currentTracker.isUserStory()}">
					<spring:message var="diagramTitleBasedOnReq" code="tracker.riskMatrix.title.basedOnUserStory" text="User Stories with Risk"/>
				</c:if>
				<c:if test="${currentTracker.isRisk()}">
					<spring:message var="diagramTitleBasedOnReq" code="tracker.riskMatrix.title.basedOnReqOrUserStory" text="Requirements/User Stories with Risk"/>
				</c:if>
				<tab:tabPane id="risk-matrix-diagram-req" tabTitle="${diagramTitleBasedOnReq}">
					<div class="information">
						<spring:message code="tracker.riskMatrix.requirement.information"/>
					</div>
					<div class="warning">
						<spring:message code="tracker.riskMatrix.mitigation.req.warning"/>
					</div>
					<div id="riskMatrixDiagramReq">
						<tag:transformText value="${riskMatrixWikiMarkupReq}" format="W"/>
					</div>
				</tab:tabPane>

			</tab:tabContainer>
		</div>

		<a class="exportToWord bottom" href="#">${exportToWordLabel}</a>
		<a class="exportToExcel bottom" href="#">${exportToExcelLabel}</a>

	</jsp:body>
</ui:splitTwoColumnLayoutJQuery>

<script type="text/javascript">

	function riskMatrixChangeTab(event) {
		var tabId = event.getTabPane().id;
		var exportWordForm = $('form#exportToWord');
		var exportExcelForm = $('form#exportToExcel');
		var basedOn = tabId == 'risk-matrix-diagram-req' ? "requirement" : "risk";
		exportWordForm.find('input[name="based_on"]').val(basedOn);
	}

	$(function() {

		var accordion = $('.accordion');
		accordion.cbMultiAccordion({
			active: 1
		});

		var matrixContReq = $('#riskMatrixDiagramReq');
		var matrixContRisk = $('#riskMatrixDiagramRisk');
		var riskTrackerSelector = $("#riskTrackerSelector");
		var branchSelector = $("#branchSelector");
		var exportWordForm = $('form#exportToWord');
		var exportExcelForm = $('form#exportToExcel');

		var refreshExportUrl = function() {
			var riskTrackerValue = riskTrackerSelector.val();
			riskTrackerValue = riskTrackerValue == 0 ? 'all' : riskTrackerValue;
			exportWordForm.find('input[name="risk_tracker"]').val(riskTrackerValue);
			exportExcelForm.find('input[name="risk_tracker"]').val(riskTrackerValue);
		};

		$('a.exportToWord').click(function() {
			exportWordForm.submit();
			return false;
		});

		$('a.exportToExcel').click(function() {
			exportExcelForm.submit();
			return false;
		});

		var refreshDiagrams = function(value) {
			var trackerId = branchId ? branchId : "${currentTracker.id}";
			$.ajax('${refreshUrl}' + '?tracker_id=' + trackerId +  (value ? '&risk_tracker_id=' + value : ''), {
				type: 'GET'
			}).success(function (data) {
				matrixContReq.html(data);
				$.ajax('${refreshUrl}' + '?tracker_id=' + trackerId + '&based_on=risk' +  (value ? '&risk_tracker_id=' + value : ''), {
					type: 'GET'
				}).success(function (data) {
					ajaxBusyIndicator.close(busyDialog);
					refreshExportUrl();
					matrixContRisk.html(data);
					accordion.cbMultiAccordion("close", 0);
				}).fail(function (o) {
					ajaxBusyIndicator.close(busyDialog);
				});
			}).fail(function (o) {
				ajaxBusyIndicator.close(busyDialog);
			});
		};

		var refreshDiagramsWithValue = function () {
			var value = riskTrackerSelector.val();
			if (value != 0) {
				refreshDiagrams(value);
			}
		};

		riskTrackerSelector.change(refreshDiagramsWithValue);

		$('.trackerSelectorTag').on('multiselectclick', function (event, data) {
			if (data.checked) {
				var url = contextPath + '/proj/tracker/riskmatrix.spr?tracker_id=';
				var $option = $(".trackerSelectorTag").find('option[value="' + data.value + '"]');
				if ($option.hasClass("branchTracker")) {
					url += "${trackerId}" + "&branchId=" + data.value;
				} else {
					url += data.value;
				}
				ajaxBusyIndicator.showBusyPage();
				location.href = url;
			}
		});

	});
</script>