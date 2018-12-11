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
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="taglib" prefix="tag" %>
<%@ taglib uri="bugstaglib" prefix="bugs" %>

<%@ taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<meta name="decorator" content="main"/>
<meta name="module" content="tracker"/>
<meta name="applyLayout" content="true"/>
<meta name="moduleCSSClass" content="trackersModule newskin ${not empty branch ? 'tracker-branch' : '' }"/>

<link rel="stylesheet" href="<ui:urlversioned value='/testmanagement/coverage/coverage.less' />" type="text/css" media="all" />

<script type="text/javascript" src="<ui:urlversioned value='/testmanagement/coverage/coverage.js'/>"></script>

<c:set var="branchOrTracker" value="${branch != null ? branch : tracker }"/>
<c:if test="${branchOrTracker != null}">
	<bugs:branchStyle branch="${branchOrTracker }"/>
</c:if>

<c:if test="${release != null}">
	<bugs:branchStyle branch="${release.tracker }"/>
</c:if>

<c:set var="coverageBrowserTitle">
	<c:choose>
		<c:when test="${not empty release }">
			<spring:message code="tracker.coverage.browser.label" text="Test Coverage"/>
		</c:when>
		<c:otherwise>
			<c:choose>
				<c:when test="${tracker.testSet }">
					<spring:message code="tracker.test.set.browser.label" text="Test Set Result"/>
				</c:when>
				<c:when test="${tracker.testRun }">
					<spring:message code="tracker.test.run.browser.label" text="Test Run Browser"/>
				</c:when>
				<c:otherwise>
					<spring:message code="tracker.coverage.browser.label" text="Test Coverage"/>
				</c:otherwise>
			</c:choose>
		</c:otherwise>
	</c:choose>
</c:set>

<c:choose>
	<c:when test="${not testManagementEnabled}">
		<jsp:include page="coverageMenuBar.jsp"></jsp:include>
		<div class="warning">
			<spring:message code="license.testcov.nolicense.message" text="To use this page you need a Test Management license."/>
		</div>
	</c:when>
	<c:when test="${coverageType != 'requirement' or tracker.requirementLike or tracker.userStory}">

		<c:url value="/trackers/coverage/coverage.spr" var="actionUrl"/>

		<script type="text/javascript">

		function onLoad(event, data) {
			var $tree = $("#coverageTree");
			var $subtreeoot = data.rslt ? $(data.rslt.obj) : $tree;

			codebeamer.trackers.markUncoveredNodes("coverageTree");
		}

		function submitForm(list) {
			loadCoverageBrowser();
		}

		</script>

		<ui:splitTwoColumnLayoutJQuery cssClass="layoutfullPage">
			<jsp:body>
				<%-- breadcrumbs and page title --%>
				<jsp:include page="coverageMenuBar.jsp"></jsp:include>

				<%-- the filter boxes (release, configuration, tracker) --%>
				<form:form id="filterForm" action="${actionUrl}">
					<ui:actionBar id="filters">
						<c:if test="${coverageType != 'release' and coverageType != 'requirement' }">
							<ui:trackerSelector projectId="${tracker.project.id}" filterTrackerIds="${trackerIds}"
								selectedValue="${branch == null ? tracker.id : branch.id }" callbackFunctionName="updatePermanentLink" htmlName="trackerSelector"/>

							<c:if test="${fn:length(views) > 0}">
								<label for="viewSelector" style="padding-left: 10px;"><spring:message code="tracker.view.choose.label" text="View"/>:</label>
								<form:select path="testRunViewId" items="${views }" itemValue="id" itemLabel="name" id="viewSelector" onchange="submitForm(this);"></form:select>
							</c:if>
						</c:if>
						<c:if test="${coverageType == 'release' }">
							<label for="releaseSelector"><spring:message code="tracker.type.Release" text="Release"/>:</label>
							<form:select path="task_id" id="releaseSelector" onchange="submitForm(this);">
								<c:forEach items="${releases}" var="release">
									<form:option value="${release.id}" label="${release.name }" title="${release.name }"/>
								</c:forEach>
							</form:select>
						</c:if>
						<spring:message code="tracker.coverage.browser.perma.link.hint" var="permaLinkHint"/>
						<span style="padding-left:10px"><a title="${permaLinkHint}" href="${actionUrl}?tracker_id=${tracker.id}&configurationIds=${command.configurationIds}&testRunReleases=${command.testRunReleases}" id="permalink">
							<spring:message code="tracker.coverage.browser.perma.link.label" text="Permanent Link"/></a></span>

						<spring:message code="tracker.issues.exportToOffice.tooltip" text="Export items to a Microsoft Word or Microsoft Excel document" var="exportToWordHint"/>
						<span style="padding-left:10px; cursor: pointer;">
							<a class="actionLink editOfficeActionIcon" title="${exportToWordHint }" id="exportToWord"><spring:message code="tracker.issues.exportToOffice.label" text="Export to Office"/></a></span>

						<c:if test="${coverageType == 'testrun' }">
							<%-- the referencing test management tracker menu --%>
							<spring:message code="tracker.test.run.browser.related.menu.label" var="relatedMenuTitle" text="Jump to"/>
							<span style="margin-right: 10px">
								<ui:actionMenu builder="relatedTestManagementTrackersActionMenuBuilder" subject="${tracker}"
									title="${relatedMenuTitle }" keys="testCase*,[---],testSet*,[---],testRun*,[---],configuration*,[---],release*" inline="true"/>
							</span>
						</c:if>

						<c:if test="${coverageType != 'release'}">
							<ui:actionMenu builder="trackerViewsActionMenuBuilder" subject="${trackerMenuData}" keys="transitionsGraph"
								title="more" inline="true"/>
						</c:if>

					</ui:actionBar>
				</form:form>

				<div class="accordion">
					<h3 class="accordion-header"><spring:message code="tracker.coverage.browser.filter.label" text="Filter Coverage Browser" arguments="${coverageBrowserTitle }"/>
						<spring:message code="tracker.coverage.browser.filters.hint" var="helpTitle"></spring:message>
						<c:if test="${filteredView}">
							<span class="filter-warning">
								(<spring:message code="tracker.coverage.browser.filters.show.criteria" text="click to show filtering criteria"/>)
							</span>
						</c:if>
						<spring:message code="tracker.coverage.info" var="coverageInfo"/>
						<span class="helpLinkButton withContextHelp" title="${coverageInfo }" style="float: right; margin-right: 23px; top: 0px;"></span>
					</h3>
					<div class="accordion-content">
						<jsp:include page="coverageFilter.jsp"></jsp:include>
					</div>
				</div>

				<c:if test="${coverageType == 'requirement' }">
					<div class="accordion referring-trackers">
						<h3 class="accordion-header">
							<spring:message code="tracker.coverage.browser.select.trackers.label" text="Select trackers and Branches"/>
						</h3>
						<div class="accordion-content">
							<table border="0" class="propertyTable" cellpadding="2">
								<tr>
									<td class="optional">
										<spring:message code="tracker.coverage.browser.tracker.label" text="Tracker"/>:
									</td>
									<td class="tableItem">
										<ui:trackerSelector projectId="${tracker.project.id}" filterTrackerIds="${trackerIds}"
											selectedValue="${branch == null ? tracker.id : branch.id }" htmlName="trackerSelector"
											callbackFunctionName="updatePermanentLink" showBranches="true"/>
									</td>

								</tr>
								<c:if test="${not empty referringTrackerIds }">
									<tr>
										<td class="optional">
											<spring:message code="tracker.coverage.browser.second.level.tracker.label" text="Second Level Tracker"/>:
										</td>
										<td class="tableItem">
											<ui:trackerSelector projectId="${tracker.project.id}" filterTrackerIds="${referringTrackerIds}"
												htmlName="referringTracker" selectedValue="${param.referringTrackerIds }"
												multiple="true" callbackFunctionName="updatePermanentLink" showBranches="true" listBranchesOnTopLevel="true"/>
										</td>
									</tr>
								</c:if>

									<tr>
										<td class="optional">
											<spring:message code="tracker.coverage.browser.second.test.case.tracker.label" text="Test Case Tracker"/>:
										</td>
										<td class="tableItem">
											<ui:trackerSelector projectId="${tracker.project.id}" filterTrackerIds="${referringTestCaseTrackerIds}"
												htmlName="referringTestCaseTracker" selectedValue="${param.referringTestCaseTrackerId }"
												callbackFunctionName="updatePermanentLink" showBranches="true" listBranchesOnTopLevel="true"/>
										</td>
									</tr>

									<tr>
										<td class="optional">

										</td>
										<td>
											<button class="button" onclick="loadCoverageBrowser();"><spring:message code="search.submit.label" text="GO"/></button>
										</td>
									</tr>

							</table>

						</div>
					</div>
				</c:if>

				<div class="accordion">
					<h3 class="accordion-header">
						<spring:message code="tracker.coverage.browser.statistics.label" text="Coverage Statistics" arguments="${coverageBrowserTitle }"/>
					</h3>
					<div class="accordion-content">
						<c:if test="${fn:length(coverage.trackerOutlines) > 0}">
							<jsp:include page="coverageStats.jsp"></jsp:include>
						</c:if>
					</div>
				</div>
				<%-- TODO TG--%>
				<%--<c:if test="${not empty selectedTestRunRelease }">--%>
					<%--<c:url var="testRunReleaseUrl" value="${ selectedTestRunRelease.urlLink}"/>--%>
					<%--<c:set var="testRunReleaseName"><c:out value="${ selectedTestRunRelease.name}"></c:out></c:set>--%>

					<%--<div class="${noExecutedTestRuns ? 'warning' : 'hint block-hint'}">--%>
						<%--<spring:message code="tracker.coverage.browser.set.testRunRelease.hint" arguments="${testRunReleaseName};${testRunReleaseUrl }" argumentSeparator=";"/>--%>
					<%--</div>--%>
				<%--</c:if>--%>
				<c:if test="${coverage.filteredRequirements != null and fn:length(coverage.filteredRequirements) > issueCountLimit }">
					<div class="warning">
						<spring:message code="tracker.coverage.browser.performance.warning"/>
					</div>
				</c:if>
				<c:if test="${areTestCasesFilteredOut }">
					<div class="information">
						<spring:message code="tracker.coverage.browser.test.cases.not.visible.message"
							text="When filtering by Work Item Release and Status the Test Cases are not visible in the tree"/>
					</div>
				</c:if>

				<%-- the tree --%>
				<div id="filterBox">
					<spring:message code="association.search.as.you.type.label" var="searchPlaceholder"/>
					<input class="treeFilterBox" id="searchBox_coverageTree" placeholder="${searchPlaceholder }"/>
					<spring:message var="requirementsTitle" code="tracker.coverage.search.in.work.items.label" />
					<label for="searchRequirements" title="${requirementsTitle}">
						<input type="checkbox" id="searchRequirements" checked="checked"/>${requirementsTitle }
					</label>

					<spring:message var="testCasesTitle" code="tracker.coverage.search.in.testcases.label" />
					<label for="searchTestCases" title="${testCasesTitle}">
						<input type="checkbox" id="searchTestCases" />${testCasesTitle }
					</label>
				</div>

				<spring:message code="tracker.coverage.browser.show.colors.label" text="Show Colors" var="showColorsLabel"/>
				<label for="showColors" title="${showColorsLabel }">
					<input type="checkbox" id="showColors" ${command.showColors ? "checked='checked'" : "" }/>${showColorsLabel }
				</label>

				<spring:message code="tracker.coverage.browser.combineWithOr.label" text="Combine Results with Or" var="combineWithOrLabel"/>
				<spring:message code="tracker.coverage.browser.combineWithOr.title" var="combineWithOrTitle"/>
				<input type="checkbox" name="combineWithOr" id="combineWithOr" title="${combineWithOrTitle }" ${command.combineWithOr ? "checked='checked'" : "" }/>
				<label for="combineWithOr" title="${combineWithOrTitle}">${combineWithOrLabel }</label>

				<spring:message code="tracker.coverage.browser.hide.incomplete.label" text="Hide Incomplete Items" var="hideIncompleteLabel"/>
				<spring:message code="tracker.coverage.browser.hide.incomplete.title" var="hideIncompleteTitle"/>
				<input type="checkbox" name="hideIncomplete" id="hideIncomplete" title="${hideIncompleteTitle }" ${command.hideIncomplete ? "checked='checked'" : "" }/>
				<label for="hideIncomplete" title="${hideIncompleteTitle}">${hideIncompleteLabel }</label>

				<spring:message code="search.submit.label" text="GO" var="goLabel"/>
				<input type="button" class="button" value="${goLabel}" onclick="loadCoverageBrowser();" style="margin-left: 10px;"/>

				<c:if test="${not empty tree }">
					<jsp:include page="includes/coverageTable.jsp"/>
				</c:if>

				<div id="emptyTreeMessage" style="${empty tree ? 'padding: 10px;' : 'padding: 10px;display:none;'}" class="subtext"><spring:message code="table.nothing.found" text="Nothing found to display"></spring:message></div>
			</jsp:body>
		</ui:splitTwoColumnLayoutJQuery>


		<script type="text/javascript">
			codebeamer.coverage.init({
				"exportUrl": "${exportUrl}",
				"coverageType":"${coverageType}",
				"testRunViewId": "${ui:removeXSSCodeAndJavascriptEncode(param.testRunViewId)}",
				"configurationIds": "${ui:removeXSSCodeAndJavascriptEncode(param.configurationIds)}",
				"testRunReleases": "${ui:removeXSSCodeAndJavascriptEncode(command.testRunReleasesAsString)}",
				"requirementReleases": "${ui:removeXSSCodeAndJavascriptEncode(param.requirementReleases)}",
				"requirementStatuses": "${ui:removeXSSCodeAndJavascriptEncode(param.requirementStatuses)}",
				"filterRequirementsByCoverage": "${ui:removeXSSCodeAndJavascriptEncode(param.filterRequirementsByCoverage)}",
				"recentRuns": "${command.recentRuns}",
				"lastRunTo": "${ui:removeXSSCodeAndJavascriptEncode(param.lastRunTo)}",
				"lastRunFrom": "${ui:removeXSSCodeAndJavascriptEncode(param.lastRunFrom)}",
				"assigneeIds": "${ui:removeXSSCodeAndJavascriptEncode(param.assigneeIds)}",
				"testStability": "${ui:removeXSSCodeAndJavascriptEncode(param.testStability)}",
				"showColors": "${command.showColors}",
				"build": "${ui:removeXSSCodeAndJavascriptEncode(command.build)}",
				"filterTrackerIds": "${ui:removeXSSCodeAndJavascriptEncode(param.filterTrackerIds)}",
				"testCaseTypes": "${ui:removeXSSCodeAndJavascriptEncode(param.testCaseTypes)}",
				"combineWithOr": "${command.combineWithOr}",
				"hideIncomplete": "${command.hideIncomplete}",
				"treeUrl": "${treeUrl}",
				"referringTrackerIds": "${ui:removeXSSCodeAndJavascriptEncode(param.referringTrackerIds)}",
				"referringTestCaseTrackerId": "${ui:removeXSSCodeAndJavascriptEncode(param.referringTestCaseTrackerId)}"
			});

			<c:if test="${coverageType == 'requirement' }">
				function updateReferringList(mainList, selected) {
					if (mainList == 'referringTracker') {

						updateReferringListTypeFiltered(selected, '102', 'referringTestCaseTracker', false);
					} else if (mainList == 'trackerSelector'){
						// update the referring requirement tracker list

						var secondLevelDisabled = $("[name=referringTracker]").is(":disabled")
						if (secondLevelDisabled) {
							updateReferringListTypeFiltered(selected, '102', 'referringTestCaseTracker', false);
						} else {
							updateReferringListTypeFiltered(selected, '5,10', 'referringTracker', true);
						}
					}
				}

				function updateReferringListTypeFiltered(trackerIds, types, dependentListName, multiselect) {
					if (!trackerIds) {
						trackerIds = '-1';
					}
					$.get(contextPath + '/trackers/coverage/ajax/getReferringTrackerIds.spr', {
						'trackerIds': trackerIds,
						'types': types // testcase
					}).done(function(data) {
						// update the referring test case tracker list
						var $list = $("[name=" + dependentListName + "]");
						$list.empty();

						if (data['referringIds'] && data['referringIds'].length) {
							var config = {
								"projectId" : ${tracker.project.id},
								"multiple" : multiselect,
								"showBranches" : true,
								"filterTrackerIds": data['referringIds'].join(','),
								"listBranchesOnTopLevel": true,
								"onlyFilteredTrackers": true
							};

							$list.multiselect("enable");
							codebeamer.SelectorUtils.initTrackerSelector($list, config);
							//$list.trigger('codeBeamer:update');
						} else {
							$list.multiselect("disable");
						}

					});
				}
			</c:if>
		</script>

	</c:when>
	<c:otherwise>
		<ui:actionMenuBar>
			<ui:breadcrumbs showProjects="false"><span class='breadcrumbs-separator'>&raquo;</span><span class="page-title">
				${coverageBrowserTitle }
			</span>
				<ui:pageTitle prefixWithIdentifiableName="false" printBody="false" >

					<spring:message code="tracker.coverage.browser.for.tracker.label" arguments="${tracker.name}" htmlEscape="true"/>
				</ui:pageTitle>
			</ui:breadcrumbs>
			<c:if test="${branch != null }">
				<bugs:trackerBranchBadge branch="${branch }"></bugs:trackerBranchBadge>
			</c:if>
		</ui:actionMenuBar>
		<div class="warning"><spring:message code="tracker.coverage.invalid.tracker.type.warning" text="Coverage browser is available only for Requirement and User Story trackers"></spring:message></div>
	</c:otherwise>
</c:choose>
