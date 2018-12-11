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
--%>
<meta name="decorator" content="main"/>
<meta name="module" content="cmdb"/>
<meta name="moduleCSSClass" content="newskin CMDBModule planner"/>

<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="taglib"   prefix="tag"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="wysiwyg" prefix="wysiwyg" %>
<%@ taglib prefix="bugs" uri="bugstaglib" %>

<link rel="stylesheet" href="<ui:urlversioned value='/agile/planner.less' />" type="text/css" media="all" />
<link rel="stylesheet" href="<ui:urlversioned value='/agile/release.less' />" type="text/css" media="all" />
<link rel="stylesheet" href="<ui:urlversioned value='/stylesheet/accordion-item-controls.less' />" type="text/css" media="all" />
<link rel="stylesheet" href="<ui:urlversioned value='/stylesheet/inlineEdit.css' />" type="text/css" media="all" />
<link rel="stylesheet" href="<ui:urlversioned value='/bugs/tracker/versionsview/versionStats.css'/>" type="text/css" media="all"/>
<link rel="stylesheet" href="<ui:urlversioned value='/stylesheet/rating.less' />" type="text/css" media="all" />
<link rel="stylesheet" href="<ui:urlversioned value="/stylesheet/multiselect-filter.less" />" type="text/css" media="all" />

<script src="<ui:urlversioned value='/js/jquery/jquery-waypoints/waypoints.js'/>"></script>
<script src="<ui:urlversioned value='/bugs/tracker/versionStats.js'/>"></script>
<script src="<ui:urlversioned value='/js/overlayCommentEditor.js'/>"></script>
<script src="<ui:urlversioned value='/js/waypointHelpers.js'/>"></script>
<script src="<ui:urlversioned value='/js/sortableHelpers.js'/>"></script>
<script src="<ui:urlversioned value='/js/planner.js'/>"></script>
<script src="<ui:urlversioned value='/js/release.js'/>"></script>
<script src="<ui:urlversioned value='/js/suspectedLinkBadge.js'/>"></script>
<script src="<ui:urlversioned value='/js/inlineIssueRating.js'/>"></script>
<script src="<ui:urlversioned value='/js/multiselect-filter.js'/>"></script>
<script type="text/javascript" src="<ui:urlversioned value='/js/colorPicker.js'/>"></script>

<wysiwyg:froalaConfig />

<c:choose>
	<c:when test="${isReleaseScope or isSprintScope}">
		<bugs:branchStyle branch="${currentVersion.tracker}"/>
	</c:when>

	<c:otherwise>
		<bugs:branchStyle branch="${currentTracker}"/>
	</c:otherwise>
</c:choose>

<ui:pageTitle prefixWithIdentifiableName="false" printBody="false">
	<c:choose>
		<c:when test="${not empty currentVersion.reqIfSummary}">
			<c:choose>
				<c:when test="${isReleaseScope or isSprintScope}">
					<spring:message code="tracker.view.layout.planner.for.${scopeName}.title" arguments="${currentVersion.reqIfSummary}" />
				</c:when>
				<c:otherwise>
					<spring:message code="tracker.view.layout.planner.for.tracker.title" arguments="${currentTracker.reqIfSummary}" />
				</c:otherwise>
			</c:choose>
		</c:when>
		<c:otherwise>
			<spring:message code="${'tracker.view.layout.planner.for.no.summary.title'}" />
		</c:otherwise>
	</c:choose>
</ui:pageTitle>

<ui:actionMenuBar>
	<jsp:attribute name="rightAligned">
		<c:choose>
			<c:when test="${!empty currentVersion}">
				<ui:actionGenerator builder="agileVersionScopeActionMenuBuilder" actionListName="actions" subject="${currentVersion}">
					<c:if test="${not empty actions}">
						<div class="release-train-icon"></div>
						<div class="release-train">
								<ui:combinedActionMenu actions="${actions}" subject="${currentVersion}"
										   buttonKeys="planner,cardboard,versionStats" activeButtonKey="planner" cssClass="large" hideMoreArrow="true" />
						</div>
					</c:if>
				</ui:actionGenerator>
				<div class="release-train-extra-icons">
					<ui:combinedActionMenu builder="agileVersionScopeActionMenuBuilder" subject="${currentVersion}" buttonKeys="coverageBrowser, details"
						keys="coverageBrowser, details" cssClass="large" hideMoreArrow="true" />
				</div>

			</c:when>
			<c:otherwise>
				<ui:combinedActionMenu builder="plannerTrackerScopeActionMenuBuilder" subject="${currentTracker}" buttonKeys="planner,versionStats" activeButtonKey="planner" cssClass="large" hideMoreArrow="true" />
			</c:otherwise>
		</c:choose>
	</jsp:attribute>
	<jsp:body>
		<ui:breadcrumbs showProjects="false" projectAware="${currentVersion}">
			<span class='breadcrumbs-separator'>&raquo;</span>${currentVersion.name}
			<span><spring:message code="tracker.view.layout.planner.breadcrumbs.for.${scopeName}.label" text="Planner"/></span>
		</ui:breadcrumbs>
	</jsp:body>
</ui:actionMenuBar>

<c:if test="${!hasAgileLicense }">
	<div class="warning">
		<spring:message code="agile.no.agile.license.message" text="To use all features of this page (filtering, adding new item, organizing issues) you need an Agile license."/>
	</div>
</c:if>

<c:if test="${!empty currentVersion}">
	<div id="currentVersion" data-id="${currentVersion.id}"></div>
</c:if>
<div id="currentTracker" data-id="${currentTracker.id}"></div>

<div id="planner">
	<input type="hidden" id="plannerProjectId" value="${plannerProjectId}">
	<ui:splitTwoColumnLayoutJQuery cssClass="layoutfullPage" rightMinWidth="335" rightQuickOpenDisabled="true" leftMinWidth="270">
		<jsp:attribute name="middlePaneActionBar">
			<%--<span style="padding-left:10px;"></span>--%>
			<c:if test="${hasAgileLicense}">
				<span class="reportSelectorContainer">
					<c:choose>
						<c:when test="${isTrackerScope}">
							<ui:reportSelector resultContainerId="plannerCenterPane" resultRenderUrl="/planner/showPlanner.spr" resultJsCallback="codebeamer.planner.reportSelectorTagCallback"
											   releaseTrackerId="${plannerReleaseTrackerId}" showGroupBy="true" showOrderBy="true" triggerResultAfterInit="true" sticky="false"
											   mergeToActionBar="true" viewId="${viewId}" defaultViewId="${defaultViewId}" isPlanner="true" maxGroupByElements="2"/>
						</c:when>
						<c:otherwise>
							<ui:reportSelector resultContainerId="plannerCenterPane" resultRenderUrl="/planner/showPlanner.spr" resultJsCallback="codebeamer.planner.reportSelectorTagCallback"
											   releaseId="${currentVersion.id}" showGroupBy="true" showOrderBy="true" triggerResultAfterInit="true" sticky="false"
											   mergeToActionBar="true" viewId="${viewId}" defaultViewId="${defaultViewId}" isPlanner="true" maxGroupByElements="2"/>
						</c:otherwise>
					</c:choose>
				</span>
			</c:if>
		</jsp:attribute>
		<jsp:attribute name="rightPaneActionBar">
			<span style="padding-left:10px;">
				<span class="expandAll" style="display: none"><a href="#"><spring:message code="tracker.import.history.expandAll"/></a></span>
				<span class="collapseAll" style="display: none"><a href="#"><spring:message code="tracker.import.history.collapseAll"/></a></span>
			</span>
		</jsp:attribute>
		<jsp:attribute name="rightContent">
			<div class="right-pane">
				<jsp:include page="/agile/includes/plannerRightPane.jsp" />
			</div>
		</jsp:attribute>
		<jsp:attribute name="leftPaneActionBar">
			<c:if test="${not isAnonymous and hasAgileLicense}">
				<div class="action-lane left">
					<c:if test="${hasAgileLicense }"><a href="#" class="add-new-item-link actionBarIcon" title="<spring:message code="cardboard.create.new" text="New Item"/>"></a></c:if>
					<a href="#" class="add-new-version-link actionBarIcon" title="New <c:choose><c:when test="${isTrackerScope}">Release</c:when><c:otherwise>Sprint</c:otherwise></c:choose>"></a>
					<a href="#" class="add-team-icon actionBarIcon" title="<spring:message code="tracker.type.Team.create.label" text="New Team"/>"></a>
					<a href="#" class="export-to-excel-icon actionBarIcon" title="<spring:message code="tracker.issues.exportToExcel.label" text="Export to Excel"/>"></a>
				</div>
				<span class="multipleSelectionContainer">
					<input type="checkbox" id="multipleSelection">
					<label for="multipleSelection"><spring:message code="planner.multiple.selection" text="Multiple selection"/></label>
				</span>
			</c:if>
		</jsp:attribute>
		<jsp:attribute name="leftContent">
			<%--<div class="left-pane" style="float: left; width: ${!empty leftPaneInitialWidth ? leftPaneInitialWidth : ''};">--%>
			<div class="left-pane">
				<jsp:include page="/agile/includes/plannerLeftPane.jsp" />
			</div>
		</jsp:attribute>
		<jsp:body>
			<div class="center-pane">
				<div id="plannerAjaxLoading"></div>
				<div id="plannerCenterPane" class="overflow"></div>
				<%--<jsp:include page="/agile/includes/plannerCenterPane.jsp" />--%>
			</div>
		</jsp:body>
	</ui:splitTwoColumnLayoutJQuery>
</div>

<script type="text/javascript">
	codebeamer.plannerConfig = jQuery.extend(codebeamer.plannerConfig || {}, {
		"hasSprints": ${hasSprints ? 'true' : 'false'},
		"releaseTrackerId": ${plannerReleaseTrackerId},
		"canEditRelease": ${canEditRelease ? 'true': 'false'},
		"itemEditable": ${(!empty itemEditable) ? itemEditable : "[]"},
		"targetReleaseEditable": ${(!empty targetReleaseEditable) ? targetReleaseEditable : "[]"},
		"teamFieldEditable": ${(!empty teamFieldEditable) ? teamFieldEditable : "[]"},
		"summaryEditable": ${(!empty summaryEditable) ? summaryEditable : "[]"},
		"assigneeEditable": ${(!empty assigneeEditable) ? assigneeEditable : "[]"},
		"userStoryFieldEditable": ${(!empty userStoryFieldEditable) ? userStoryFieldEditable : "[]"},
		"requirementFieldEditable": ${(!empty requirementFieldEditable) ? requirementFieldEditable : "[]"},
		"isTrackerScope": ${isTrackerScope ? 'true' : 'false'},
		"isReleaseScope": ${isReleaseScope ? 'true' : 'false'},
		"isSprintScope":  ${isSprintScope ? 'true' : 'false'},
		"itemNameMaxLength":  ${itemNameMaxLength},
		"hasAgileLicense": ${hasAgileLicense},
		"versionId": "${versionId}",
        "versionsViewModel": ${versionsViewModelJson},
		"hasReleaseIssueEditPermission" : ${hasReleaseIssueEditPermission},
		"openProductBacklog" : ${openProductBacklog ? 'true' : 'false'}
	});
	$(function () {
		codebeamer.planner.init();
		var planner = $('#planner');
		if ($.cookie("plannerLeftPaneVisible") == "false") {
			setTimeout(function() {
				planner.find(".center-pane .left-pane-toggle").click();
			}, 200);
		}
		initInlineRating(planner);
		planner.on("afterRatingSubmitted", ".rating-container", function (event, stats, rating) {
			codebeamer.planner.reloadSelectedIssue();
		}).on('click', '.item-with-workflow', function (event) {
			var $target = $(event.target);
			buildAjaxTransitionMenu($target.closest("div"), {
				'task_id': $target.parents('tr').data('item-id'),
				'cssClass': 'inlineActionMenu transition-action-menu',
				'builder': 'trackerItemTransitionsOverlayActionsMenuBuilder'
			});
		});
	});

	// initialize the hotkeys
	var plannerHotkeys = new codebeamer.PlannerHotkeys();
</script>
