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
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="callTag" prefix="ct" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="bugstaglib" prefix="bugs" %>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>

<meta name="decorator" content="main"/>
<meta name="module" content="${branch != null ? 'branch' : 'cmdb'}"/>
<meta name="moduleCSSClass" content="newskin CMDBModule ${branch != null ? 'tracker-branch' : ''}"/>

<script type="text/javascript" src="<ui:urlversioned value='/js/jquery/jquery-waypoints/waypoints.js'/>"></script>
<script type="text/javascript" src="<ui:urlversioned value='/js/sticky.js'/>"></script>
<script type="text/javascript" src="<ui:urlversioned value='/js/cardboard.js'/>"></script>
<script type="text/javascript" src="<ui:urlversioned value='/js/release.js'/>"></script>

<c:if test="${tracker != null}">
	<c:set var="branchOrTracker" value="${branch != null ? branch : tracker }"/>
	<bugs:branchStyle branch="${branchOrTracker }"/>
</c:if>

<c:if test="${type == 'release' and not empty subject}">
	<bugs:branchStyle branch="${subject.tracker}"/>
</c:if>

<script type="text/javascript">
	var recursive = false;
	if ("${recursive}" == "true") {
		recursive = true;
	}
	codebeamer.cardboard.setConfig({"originalReleaseId": "${subject.id}"});

	var showCreateBranchDialog = function (url) {
		inlinePopup.close();
		showPopupInline(url);
	}

</script>

<jsp:include page="includes/setCardboardConfig.jsp"/>

<script type="text/javascript" src="<ui:urlversioned value='/js/cardboard_init.js'/>"></script>

<link rel="stylesheet" href="<ui:urlversioned value="/stylesheet/multiselect-filter.less" />" type="text/css" media="all" />
<link rel="stylesheet" href="<ui:urlversioned value="/agile/cardboard.less" />" type="text/css" media="all" />
<link rel="stylesheet" href="<ui:urlversioned value='/agile/release.less' />" type="text/css" media="all" />

<ui:actionMenuBar cssStyle="background-color: ${branch != null ? branch.color : ''}">
	<jsp:attribute name="rightAligned">
		<c:set var="rightFragment">
			<c:choose>
				<c:when test="${type == 'release'}">
					<c:set var="actionBuilder" value="cardboardActionMenuBuilder" scope="request"/>
					<ui:actionGenerator builder="${actionBuilder}" actionListName="actions" subject="${menuSubject}">
						<c:if test="${not empty actions}">
							<div class="release-train-icon"></div>
							<div class="release-train">
									<ui:combinedActionMenu actions="${actions}" subject="${menuSubject}"
														   buttonKeys="planner,cardboard,versionStats" activeButtonKey="cardboard" cssClass="large" hideMoreArrow="true" />
							</div>
						</c:if>
					</ui:actionGenerator>
					<div class="release-train-extra-icons">
						<ui:combinedActionMenu builder="${actionBuilder}" subject="${menuSubject}"
											   buttonKeys="coverageBrowser" activeButtonKey="cardboard"
											   keys="coverageBrowser"
											   inline="false" cssClass="large" hideMoreArrow="true"/>
					</div>
				</c:when>
				<c:otherwise>
					<jsp:include page="/bugs/tracker/includes/initTrackerContextMenu.jsp" flush="true">
						<jsp:param name="isCategoryTracker" value="${tracker.category}" />
						<jsp:param name="isAdvancedView" value="false" />
					</jsp:include>
					<ui:combinedActionMenu title="${viewsMenuLabel}" builder="trackerCardboardViewsActionMenuBuilder" subject="${menuSubject}" keys="${viewsActionKeys}"
										   buttonKeys="showTableView,showDocumentView,showDocumentViewExtended,showCardboardView,coverageBrowser,traceabilityBrowser,showReviewView,testRunBrowser,showDashboardView"
										   activeButtonKey="showCardboardView"
										   cssClass="large" hideMoreArrow="true"
					/>
				</c:otherwise>
			</c:choose>
		</c:set>
		<ui:branchBaselineBadge branch="${branch}" rightFragment="${rightFragment}"/>
	</jsp:attribute>
	<jsp:body>
		<ui:breadcrumbs showTrailingId="false" showProjects="false" projectAware="${subject}"><span class='breadcrumbs-separator'>&raquo;</span><span><spring:message code="tracker.view.layout.cardboard.label" text="Cardboard View"/></span>
			<ui:pageTitle prefixWithIdentifiableName="false" printBody="false" >
				<spring:message code="tracker.view.layout.cardboard.for.release.label" arguments="${subject.name}" htmlEscape="true"/>
			</ui:pageTitle>
		</ui:breadcrumbs>
	</jsp:body>
</ui:actionMenuBar>

<c:if test="${!hasAgileLicense }">
	<div class="warning">
		<spring:message code="agile.no.agile.license.message" text="To use all features of this page (filtering, adding new item, organizing issues) you need an Agile license."/>
	</div>
</c:if>

<ui:actionBar>
	<jsp:body>
		<c:if test="${hasAgileLicense }">
			<c:choose>
				<c:when test="${type == 'tracker' }">
					<table class="reportSelectorActionBarTable">
						<tr>
							<td class="actionBarColumn">
								<ui:rightAlign>
									<jsp:attribute name="filler">
										<ui:actionMenu title="more" keys="configure,[---],createView,editView,[---],traceabilityBrowser,riskMatrixDiagram,transitionsGraph,[---],sendToReview,sendMergeRequest" builder="trackerCardboardContextActionMenuBuilder" subject="${menuSubject}"></ui:actionMenu>
									</jsp:attribute>
									<jsp:body>
										<ui:actionGenerator builder="trackerCardboardViewsActionMenuBuilder" actionListName="actions" subject="${menuSubject}">
											<ui:actionLink keys="fastAddTrackerItem,showBaselinesAndBranches" actions="${actions}" />
										</ui:actionGenerator>
									</jsp:body>
								</ui:rightAlign>
							</td>
							<td class="reportSelectorColumn">
								<ui:reportSelector resultContainerId="cardboard" resultRenderUrl="/proj/tracker/showCardboard.spr" resultJsCallback="codebeamer.cardboard.reportSelectorTagCallback"
												   projectId="${tracker.project.id}" trackerId="${not empty branch ? branch.id : tracker.id}" showGroupBy="true" showOrderBy="true" triggerResultAfterInit="true" sticky="true"
												   mergeToActionBar="true" viewId="${viewId}" defaultViewId="${defaultViewId}"/>
							</td>
						</tr>
					</table>
				</c:when>
				<c:otherwise>
					<table class="reportSelectorActionBarTable">
						<tr>
							<td class="actionBarColumn">
								<a href="#" class="add-new-item-link newCardboardItemLink actionLink actionBarIcon" title="<spring:message code="cardboard.create.new" text="New Item"/>">

								</a>

								<span class="menuArrowDown cardboardMoreMenu extendedCardboardMoreMenu" id="more-menu-${menuSubject.id}" data-id="${menuSubject.id}"></span>

								<!--
								<span class="simpleDropdownMenu cardboardMoreMenu">
									<ui:actionMenu title="more" keys="configure,details,[---],sendToReview,sendMergeRequest,[---],coverageBrowser,planner,versionStats,bubbleChart,[---],permaLink" builder="cardboardActionMenuBuilder" subject="${menuSubject}"></ui:actionMenu>
								</span>
								-->
							</td>
							<td class="reportSelectorColumn">
								<ui:reportSelector resultContainerId="cardboard" resultRenderUrl="/proj/tracker/showCardboard.spr" resultJsCallback="codebeamer.cardboard.reportSelectorTagCallback"
												   releaseId="${subject.id}" showGroupBy="true" showOrderBy="true" triggerResultAfterInit="true" sticky="true"
												   mergeToActionBar="true" viewId="${viewId}" defaultViewId="${defaultViewId}" maxGroupByElements="2"/>
							</td>
						</tr>
					</table>

				</c:otherwise>
			</c:choose>
		</c:if>
	</jsp:body>
</ui:actionBar>

<div id="cardboard" class="contentWithMargins" style="margin-left: 10px;"></div>

