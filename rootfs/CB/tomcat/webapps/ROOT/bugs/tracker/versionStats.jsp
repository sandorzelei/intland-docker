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
<meta name="module" content="cmdb"/>
<meta name="bodyCSSClass" content="newskin releaseModule" />

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>

<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="taglib" prefix="tag" %>
<%@ taglib prefix="bugs" uri="bugstaglib" %>

<link rel="stylesheet" href="<ui:urlversioned value='/agile/release.less' />" type="text/css" media="all" />

<c:if test="${not empty version}">
	<bugs:branchStyle branch="${version.tracker}"/>
</c:if>


<%-- page title will contain the version-name too --%>
<ui:pageTitle prefixWithIdentifiableName="false" printBody="false">
	<c:choose>
		<c:when test="${not empty version.reqIfSummary}">
			<spring:message code="${isChild ? 'cmdb.sprint.stats.page.title' : 'cmdb.version.stats.page.title'}" arguments="${version.reqIfSummary}" />
		</c:when>
		<c:otherwise>
			<spring:message code="${isChild ? 'cmdb.sprint.stats.page.no.summary.title' : 'cmdb.version.stats.page.no.summary.title'}" />
		</c:otherwise>
	</c:choose>
</ui:pageTitle>

<ui:actionMenuBar>
	<jsp:attribute name="rightAligned">
		<c:if test="${version != null }">
			<ui:actionGenerator builder="versionsViewActionMenuBuilder" actionListName="actions" subject="${version}">
				<c:if test="${not empty actions}">
					<div class="release-train-icon"></div>
					<div class="release-train">
						<ui:combinedActionMenu subject="${version}"
							buttonKeys="planner,cardboard,versionStats" activeButtonKey="versionStats" cssClass="large" hideMoreArrow="true" actions="${actions }"/>
					</div>
				</c:if>
			</ui:actionGenerator>
			<div class="release-train-extra-icons">
				<ui:combinedActionMenu builder="versionsViewActionMenuBuilder" subject="${version}" keys="coverageBrowser"
								   buttonKeys="coverageBrowser" cssClass="large" hideMoreArrow="true" />
			</div>
		</c:if>
	</jsp:attribute>
	<jsp:body>
		<ui:breadcrumbs showProjects="false"><span class="breadcrumbs-separator">&raquo;</span><span><spring:message code="${isChild ? 'cmdb.sprint.stats.breadcrumb.label' :'cmdb.version.stats.breadcrumb.label' }" /></span>
		</ui:breadcrumbs>
	</jsp:body>
</ui:actionMenuBar>

<ui:actionBar cssClass="version-stats-actions">
	<jsp:body>
		<ui:actionGenerator builder="versionsViewActionMenuBuilder" actionListName="actions" subject="${version}">
			<ui:rightAlign>
				<jsp:attribute name="filler">
					<ui:actionMenu title="more" actions="${actions}" keys=",details,releaseNotes,sendToReview,sendMergeRequest,[---],createSprintSchedule,generateNextSprint,[---],coverageBrowser,planner,cardboard,bubbleChart,[---],referenceSettings" />
				</jsp:attribute>
				<jsp:attribute name="rightAligned">
					<c:if test="${(version != null) and (versionsViewModel != null)}">
						<c:if test="${showActionBarControls}">
							<jsp:include page="includes/versionViewControls.jsp">
								<jsp:param name="autoSaveReleaseTreeState" value="${autoSaveReleaseTreeState}" />
							</jsp:include>
						</c:if>
						<c:set var="idPrefix" value="action-bar-" scope="request" />
						<div class="versionFilterContainer">
							<jsp:include page="includes/generateVersionFilterMenu.jsp" />
							${filterMenu}
						</div>
					</c:if>
				</jsp:attribute>
				<jsp:body>
					<ui:actionLink actions="${actions}" keys="newSprint"/>
					<a class="actionLink" href="${permanentLink}" id="permalink"><spring:message code="tracker.coverage.browser.perma.link.label" text="Permanent Link"/></a>
				</jsp:body>
			</ui:rightAlign>
		</ui:actionGenerator>
	</jsp:body>
</ui:actionBar>

<c:if test="${!empty baseline}">
	<ui:baselineInfoBar projectId="${version.tracker.project.id}" baselineName="${baseline.name}" baselineParamName="revision" cssStyle="margin-bottom: 10px;" notSupported="true"/>
</c:if>

<ui:delayedScript avoidDuplicatesOnly="true" trim="true">
	<link rel="stylesheet" href="<ui:urlversioned value='/bugs/tracker/versionsview/versionStats.css'/>" type="text/css" media="all" />
</ui:delayedScript>

<c:set var="releaseId" value="${version.id}"/>
<div class="accordion ganttAccordion">
	<h4 class="accordion-header"><spring:message code="release.gantt.chart.label" text="Release Gantt Chart"/><img class="ganttChartInlineLoadingIndicator" style="display: none;" src="<c:url value="/images/ajax-loading_16.gif"/>"</img></h4>
</div>

<div class="container releaseDashboard" style="visibility: hidden;">
	<div class="pane ui-layout-north" id="releaseGanttChart" style="display: none"></div>

	<div class="pane ui-layout-center">
		<table class="versions" id="versionsTable" data-version-level-view="true" data-filter-category="${activeFilters.selectedFilterCategory}"
			data-filter-value="${activeFilters.selectedFilterValue}" data-status-open="${activeFilters.openOrClosedFilter}"
			data-status-main="${activeFilters.mainStatusFilter}" data-type-main="${activeFilters.mainTypeFilter}">
			<tr>
				<%-- This is where the version lists will be loaded using AJAX --%>
				<td style="position:relative;">
					<div class="statsLoading" style="display:none;"><img src='<ui:urlversioned value='/js/yui/assets/skins/sam/ajax-loader.gif'/>' /><spring:message code="ajax.loading"/></div>

					<c:set var="isInvidualReleaseDashboard" value="${false}" scope="request"/>
					<c:if test="${not empty isChild}">
						<c:set var="isInvidualReleaseDashboard" value="${true}" scope="request"/>
					</c:if>

					<jsp:include page="/bugs/tracker/includes/versionsViewReleasesList.jsp"/>
				</td>

				<%-- This is the right column of the layout where the Burn Down chart and the statistic filters reside --%>
				<td class="rightColumn">
					<c:choose>
						<c:when test="${! empty trackerItems}">
							<div class="versionStatBurnDown">
								<div class="settingsButton">
									<spring:message code="tracker.tree.settings.title" text="Settings" var="settingsTitle"/>
									<img class="action" src="<ui:urlversioned value='/images/newskin/actionIcons/settings-s_14.png'/>" title="${settingsTitle}">
								</div>
								${burnDownChart}
							</div>
							<c:set var="cssClass" scope="request" value=""/>
							<c:set var="versionStatsPageEventHandlers" scope="request" value="true"/>
							<c:set var="showTotals" scope="request" value="true"/>
							<c:set var="showStoryPointsStats" scope="request" value="true"/>
							<c:set var="showOnlineState" scope="request" value="true"/>
							<jsp:include page="/bugs/tracker/includes/versionStatsBox.jsp"/>
						</c:when>
						<c:otherwise>
							<c:choose>
								<c:when test="${activeFilters.filteringActive == true}">
									${burnDownChart}
									<c:set var="cssClass" scope="request" value=""/>
									<c:set var="versionStatsPageEventHandlers" scope="request" value="true"/>
									<c:set var="showTotals" scope="request" value="true"/>
									<c:set var="showStoryPointsStats" scope="request" value="true"/>
									<c:set var="showOnlineState" scope="request" value="true"/>
									<jsp:include page="/bugs/tracker/includes/versionStatsBox.jsp"/>
								</c:when>
								<c:otherwise>
									<div class="noIssuesNotification">
										<spring:message code="cmdb.version.issues.no.issues" text="No issues to display."/>
									</div>
								</c:otherwise>
							</c:choose>
						</c:otherwise>
					</c:choose>
				</td>
			</tr>
		</table>

		<script type="text/javascript" src="<ui:urlversioned value='/bugs/tracker/versionStats.js'/>"></script>
		<script type="text/javascript" src="<ui:urlversioned value='/js/release.js'/>"></script>
		<script type="text/javascript">
			// ids of those releases which are editable, so drag-drop reordering of issues is enabled there
			var editableReleasesIds = [
				<c:forEach var="release" items="${editableReleases}" varStatus="status">${release.id}${status.last ? '' : ', '}</c:forEach>
			];

			jQuery(function($) {

				var mode = "${mode}";
				var releaseId = "${releaseId}";
				var ganttChartAllowed = ${ganttChartAllowed};
				VersionStats.init(mode, releaseId, ganttChartAllowed);

				$(".settingsButton .action").click(function(event) {
					event.stopPropagation();
					event.preventDefault();
					showPopupInline(contextPath + '/bugs/tracker/versionStats/burndown/configuration.spr');
				});

				if ($(".version[data-version-id]").length === 1 && $(".versionWithoutChildren").length === 1 &&  $(".versionWithoutChildren .versionIssues").children().length === 0) {
					$(".releaseDashboard .ui-layout-center").addClass("noScroll");
				}

			});

			$(window).load(function () {
				var footerHeight = $("#footer").outerHeight();

				$(".releaseDashboard").height($(window).innerHeight() - $(".releaseDashboard").offset().top - footerHeight);
				$(".releaseDashboard").css("visibility", "visible");
			});

			VersionStats.installExecuteTransitionCallback();

			var reload = function () {
				location.reload();
			};

			new codebeamer.ReleaseHotkeys({subjectId: "${release.id}", isReleaseTracker: false});

		</script>
	</div>
</div>

<c:if test="${issueStatsByAssignee.aggregatedTotals.storyPoints == 0}">
	<%-- when there are no story points values at all then "hide" the column --%>
	<style type="text/css">
		td.storyPoints {
			padding: 0px !important;
		}
	</style>
</c:if>
