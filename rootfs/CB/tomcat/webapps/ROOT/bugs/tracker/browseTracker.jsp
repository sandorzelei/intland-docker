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
<meta name="module" content="${empty tracker.parent.id ? (tracker.category ? 'cmdb' : 'tracker') : 'docs'}"/>
<meta name="applyLayout" content="${selectedLayout eq 1 or selectedLayout eq 5}"/>
<meta name="moduleCSSClass" content="newskin noAutoSubmit ${not empty baseline ? 'tracker-baseline' : ''} ${empty baseline && branch != null ? 'tracker-branch' : ''} ${tracker.category ? 'CMDBModule' : 'trackersModule'} ${tracker.versionCategory ? 'releaseModule' : ''}"/>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<%@ taglib uri="http://struts.apache.org/tags-logic" prefix="logic" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>

<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%@ taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>

<%@ taglib uri="acltaglib" prefix="acl" %>
<%@ taglib uri="log" prefix="log" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="bugstaglib" prefix="bugs" %>
<%@ taglib uri="taglib" prefix="tag" %>
<%@ taglib uri="callTag" prefix="ct" %>
<%@ taglib uri="wysiwyg" prefix="wysiwyg" %>

<%@ taglib uri="http://ditchnet.org/jsp-tabs-taglib" prefix="tab" %>

<%@ page import="com.intland.codebeamer.servlet.bugs.BrowseTrackerAction"%>
<%@ page import="com.intland.codebeamer.servlet.bugs.TrackerBrowseForm"%>
<%@ page import="java.util.Map"%>
<%@ page import="java.util.HashMap"%>
<%@ page import="com.intland.codebeamer.taglib.TableCellCounter"%>

<jsp:include page="/bugs/includes/issueCopyMove.jsp" />

<link rel="stylesheet" href="<ui:urlversioned value="/js/jquery/jquery-selectboxit/jquery.selectBoxIt.css" />" type="text/css" media="all" />
<link rel="stylesheet" href="<ui:urlversioned value="/js/jquery/jquery-selectboxit/jquery.selectBoxIt.custom.less" />" type="text/css" media="all" />
<link rel="stylesheet" href="<ui:urlversioned value="/stylesheet/multiselect-filter.less" />" type="text/css" media="all" />
<link rel="stylesheet" href="<ui:urlversioned value='/stylesheet/accordion-item-controls.less' />" type="text/css" media="all" />
<link rel="stylesheet" href="<ui:urlversioned value='/stylesheet/treeViewFullTextSearch.less' />" type="text/css" media="all" />
<link rel="stylesheet" href="<ui:urlversioned value='/agile/release.less' />" type="text/css" media="all" />
<link rel="stylesheet" href="<ui:urlversioned value="/stylesheet/intelligentTableView.less" />" type="text/css" media="all" />

<script src="<ui:urlversioned value='/bugs/tracker/docview/documentView.js'/>"></script>
<script src="<ui:urlversioned value='/js/jquery/jquery-selectboxit/jquery.selectBoxIt.min.js'/>"></script>
<script src="<ui:urlversioned value='/js/issueLibrary.js'/>"></script>
<script src="<ui:urlversioned value='/js/issueDragUtils.js'/>"></script>
<script src="<ui:urlversioned value='/js/testCaseTree.js'/>"></script>
<script src="<ui:urlversioned value='/js/releaseTree.js'/>"></script>
<script src="<ui:urlversioned value='/js/jquery/jquery-waypoints/waypoints.js'/>"></script>
<script src="<ui:urlversioned value='/js/waypointHelpers.js'/>"></script>
<script src="<ui:urlversioned value='/js/infiniteScroller.js'/>"></script>
<script src="<ui:urlversioned value='/bugs/tracker/traceabilityBrowser/traceability.js'/>"></script>

<wysiwyg:froalaConfig />
<c:set var="branchOrTracker" value="${branch != null ? branch : tracker }"/>

<bugs:branchStyle branch="${branchOrTracker }"/>

<style type="text/css">
	#selectedViewSelectBoxItContainer {
		margin-left: -2px;
	}

	#library-tab .treeFilterBox, #test-plan-pane .treeFilterBox {
		width: 46%;
		width: calc(60% - 50px);
	}

	#library-tab #configureLibrary {
		margin-left: 5px;
	}

	#progressBar {
		margin: 0;
		border: none;
	}
	#progressBar span {
		color: black;
	}

	#breadcrumbs {
		margin-top: 1px;
	}

	.searchResetButton {
		margin-left: 1em;
		font-weight: bold;
	}

	.filterAlertSign {
		position: relative;
		top: 4px;
	}

	.switchViewButton {
		margin-left: 2em;
	}
</style>

<c:if test="${tracker.requirement}">
	<style type="text/css">
		#treePane .testcase-node {
			display: none;
		}


		.favouriteWidget {
			margin-left: 13px;
		}

		.actionMenuBar .menuArrowDown {
			top: 3px;
			position: relative
		}

		#release-pane .textHint {
			margin-top: -10px;
			margin-left: -10px;
			margin-right: -10px;
			font-size: 80%;
			padding: 5px;
			padding-left: 25px !important;
		}

		.actionMenuBar * {
			line-height: 14px;
		}
		.lockInfo {
			margin-right: 10px;
		}

		.actionMenuBar .yui-button, .actionMenuBar .simpleDropdownMenu {
			vertical-align: baseline;
		}
		.actionMenuBar .simpleDropdownMenu {
			margin-left: 15px;
		}

		.ditch-tabs-right-aligned td {
   			padding: 0 5px !important;
		}

	</style>
</c:if>

<c:if test="${(selectedLayout ne 1) && (selectedLayout ne 2)}">
	<style type="text/css">
		body {
			overflow-y: scroll;
		}
	</style>
</c:if>

<style type="text/css">
	.ditch-tabs-right-aligned td {
  			padding: 0 5px !important;
	}
</style>

<%-- set different parameter values between Tracker and Category-type trackers --%>
<c:set var="browseTrackerURI" value="/proj/tracker/browseTracker.do" />
<c:set var="currentTrackerId" value="${tracker.id}" />
<c:if test="${empty currentTrackerId}">
	<c:set var="currentTrackerId" value="${trackerBrowseForm.tracker_id}" />
</c:if>

<c:url var="allItemUrl" value="/tracker/${currentTrackerId}?view_id=-2"/>

<jsp:include page="/bugs/includes/remoteImport.jsp" />
<jsp:include page="/bugs/includes/doorsBridge.jsp" />
<jsp:include page="/bugs/includes/jiraImport.jsp" />

<jsp:include page="includes/initTrackerContextMenu.jsp" flush="true">
	<jsp:param name="isCategoryTracker" value="${tracker.category}" />
	<jsp:param name="isAdvancedView" value="${trackerBrowseForm.advancedView}" />
</jsp:include>

<jsp:include page="../../docs/includes/createArtifacts.jsp" />

<c:choose>
	<c:when test="${tracker.category}">
		<spring:message var="trackerLabel" code="cmdb.category.label" text="Configuration tracker" />
		<spring:message var="itemsLabel" code="cmdb.category.items.label" text="Configuration items" />
		<c:set var="resfulURIPrefix" value="/category/" scope="request" />
	</c:when>
	<c:otherwise>
		<spring:message var="trackerLabel" code="tracker.label" text="Work tracker" />
		<spring:message var="itemsLabel" code="tracker.Issues.label" text="Work items" />
		<c:set var="resfulURIPrefix" value="/tracker/" scope="request"/>
	</c:otherwise>
</c:choose>

<c:set var="action" value="${browseTrackerURI}?tracker_id=${currentTrackerId}&pagesize=${pagesize}&view_id=${param.view_id}" />
<c:set var="excludeParams" value="pagesize clipboard_task_id selectedView trackerFilter GO tracker_id view_id" />

<c:if test="${empty trackerName}">
	<c:set var="trackerName"><c:out value="${tracker.name}" /></c:set>
</c:if>


<script type="text/javascript">

	function submitTrackerSelector(selector) {
		if (selector != null) {
			location.href='<c:url value="${resfulURIPrefix}" />' + selector.value;
			return false;
		}
	}

	function submitViewSelector(selector) {
		if (selector != null) {
			var url = $(selector).find(":selected").data("url");
			if (url) {
				location.href = contextPath + url;
			} else {
				location.href = '<c:url value="${tracker.urlLink}"/>${empty baseline ? "?" : "?revision=".concat(baseline.id).concat("&")}view_id=' + selector.value;
			}
			return false;
		}
	}

	function submitBaselineSelector(selector) {
		if (selector != null) {
			var url = '<c:url value="${tracker.urlLink}"/>?view_id=${selectedView}';
			if (selector.value != '') {
				url += "&revision=" + selector.value;
			}
			location.href= url;
			return false;
		}
	}

</script>

<ui:pageTitle prefixWithIdentifiableName="false" printBody="false">${trackerLabel}: <c:out value='${tracker.name}'/></ui:pageTitle>

<html:form action="${action}" styleId="browseTrackerForm">
	<html:hidden property="tracker_id"/>

	<c:set var="trackerBreadcrumbAndFiltersFragment">
		<c:choose>
			<c:when test="${!tracker.versionCategory}">
				<c:choose>
					<c:when test="${empty tracker.parent.id}">
						<ui:breadcrumbs showProjects="false" showLast="false" showTrailingId="false" strongBody="true">
							<c:out value='${tracker.name}'/>
						</ui:breadcrumbs>
					</c:when>
					<c:otherwise>
						<ui:breadcrumbs showProjects="false" showTrailingId="false" />
					</c:otherwise>
				</c:choose>

				<c:if test="${!empty baselines && (selectedLayout eq 1 or selectedLayout eq 5)}">
					<span class="breadcrumbs-separator">&raquo;</span>
					<spring:message var="baselineSelectorTitle" code="document.baselines.selector.title" text="Click here to show/hide available baselines"/>
					<select id="baselineSelector" onchange="submitBaselineSelector(this)" title="${baselineSelectorTitle}" >
						<spring:message var="headRevisionTitle" code="document.baselines.head.tooltip" text="Head"/>
						<option value="" title="${headRevisionTitle}">
							<spring:message code="document.baselines.head.label" text="Head"/>
						</option>

						<c:forEach items="${baselines}" var="option">
							<c:set var="baselineId" value="${empty option.baseline ? option.id : option.baseline.id}"/>
							<option value="${baselineId}"
								<c:if test="${baseline.id eq baselineId}">
									selected="selected"
								</c:if>
							>
								<c:out value="${option.name}"/>
							</option>
						</c:forEach>
					</select>
				</c:if>

				<c:choose>
					<c:when test="${trackerBrowseForm.advancedView}">
						<span class="breadcrumbs-separator"<c:if test="${selectedLayout eq 1}"> style="position: relative; top: -1px;"</c:if>>&raquo;</span>
						<span class="reportSelectorSelectedViewLabel"><spring:message code="tracker.view.All Items.label" text="All Items"/></span>

						<c:if test="${selectedLayout eq 0 or selectedLayout eq 1 or selectedLayout eq 2 or selectedLayout eq 5}">
							<span class="simpleDropdownMenu" style="margin-left: 15px;">
								<ui:actionGenerator builder="${actionBuilder}" actionListName="actions" subject="${trackerMenuData}">
									<ui:actionLink keys="sprintPlanning" actions="${actions}" />
								</ui:actionGenerator>
							</span>
						</c:if>
						<c:if test="${empty baseline and (selectedLayout eq 1 or selectedLayout eq 5)}">
							<span class="simpleDropdownMenu" >
								<ui:actionGenerator builder="${actionBuilder}" actionListName="actions" subject="${trackerMenuData}">
									<ui:actionLink keys="switchToDashboardTrackerView* sprintPlanning" actions="${actions}" />
								</ui:actionGenerator>
							</span>
						</c:if>
					</c:when>
					<c:otherwise>
						<ui:breadcrumbsId />
					</c:otherwise>
				</c:choose>

			</c:when>
			<c:otherwise>
				<ui:breadcrumbs showProjects="false" showLast="true"/>
				<input type="hidden" name="" value="${currentTrackerId}" />
			</c:otherwise>
		</c:choose>
	</c:set>
	<c:set var="emailFragment">
		<c:set var="myEmail" value="${trackerInbox.email}" />
		<c:if test="${!empty myEmail}">
			<span class="low" id="emailFragment">
				<spring:message var="trackerEmailTitle" code="tracker.inbox.email.tooltip"/>
				<span title="${trackerEmailTitle}" style="color: #ababab;" ><spring:message code="inbox.email.label"/>:
					<a style="border-bottom: 1px dotted #888"  href="mailto:<c:out value='${myEmail}' />"><c:out value="${myEmail}" /></a>
				</span>
			</span>
		</c:if>
	</c:set>
	<c:set var="rightActionMenuFragment">
		<c:if test="${!tracker.versionCategory}">

			<span class="simpleDropdownMenu" selectId="editTrackerViewMenu" style="margin-left: 10px;">
				<ui:combinedActionMenu title="${viewsMenuLabel}" builder="trackerViewsActionMenuBuilder" subject="${trackerMenuData}" keys="" hideMoreArrow="true"
										buttonKeys="showTableView,showDocumentView,showDocumentViewExtended${not tracker.rpe ? ',showCardboardView,coverageBrowser,traceabilityBrowser' : ''},${empty branch ? 'testRunBrowser,' : ''}showDashboardView"
										activeButtonKey="${selectedLayout eq 0 ? 'showTableView' :
											(selectedLayout eq 1 or selectedLayout eq 5 ? ((extended or param.extended == 'true') and empty baseline ? 'showDocumentViewExtended' : 'showDocumentView') :
											(selectedLayout eq 2 ? 'showDashboardView' : ''))}"
										cssClass="large"
									/>
			</span>
		</c:if>
		<c:if test="${tracker.versionCategory}">
			<ui:combinedActionMenu builder="plannerTrackerScopeActionMenuBuilder" subject="${tracker}" buttonKeys="traceabilityBrowser,planner,versionStats" activeButtonKey="versionStats" cssClass="large" hideMoreArrow="true"/>
		</c:if>
	</c:set>

	<c:set var="lockInfo">
		<c:if test="${empty baseline}">
			<c:choose>
				<%-- hard lock info --%>
				<c:when test="${!empty branchOrTracker.additionalInfo.lockedBy}">
					<spring:message var="lockInfo" code="document.lockedBy.tooltip" text="Locking information"/>
					<span class="main high lockInfo" title="${lockInfo}">
						<spring:message code="document.lockedBy.label" text="Currently locked by"/>
						<tag:userLink user_id="${branchOrTracker.additionalInfo.lockedBy.id}" />.
						<input type="hidden" id="lockedById" value="${branchOrTracker.additionalInfo.lockedBy.id}" />
					</span>
				</c:when>

				<%-- soft lock info --%>
				<c:when test="${PAGE_LOCKER.id gt 0}">
					<spring:message var="editInfo" code="document.editedBy.tooltip" text="Editing information"/>
					<span class="main high lockInfo" title="${editInfo}">
						<spring:message code="document.editedBy.label" text="Currently edited by"/>
						<tag:userLink user_id="${PAGE_LOCKER.id}" />.
					</span>
				</c:when>
			</c:choose>
		</c:if>
	</c:set>

	<c:set var="actionMenuBodyPart">
		<div style="float:left">
			${trackerBreadcrumbAndFiltersFragment}

			<c:if test="${hasPendingMergeRequests }">
				<spring:message code="review.show.pending.merge.requests.label" text="Pending Merge Requests" var="pendingMergeRequestsLabel"/>
				<c:url value="/proj/review/mergeRequests.spr" var="pendingMergeUrl">
					<c:param name="tracker_id" value="${not empty branch ? branch.id : tracker.id }"></c:param>
					<c:param name="isPopup" value="true"></c:param>
				</c:url>

				<span class="reviewMergedBadge generalBadge clickable" title="${pendingMergeRequestsLabel }" onclick="showPopupInline('${pendingMergeUrl}', {'geometry': 'large'});">
					${pendingMergeRequestsLabel }
				</span>
			</c:if>
		</div>
		<div style="clear:both; display: inline;"></div>
		<c:if test="${!(empty lockInfo && empty emailFragment)}">
			<div style="margin-top: 21px;">
				<span style="margin-left: 20px">${lockInfo} ${emailFragment}</span>
			</div>
		</c:if>
	</c:set>
	<c:set var="actionMenuRightPart">
		<ui:branchBaselineBadge branch="${branch}" baseline="${baseline}" rightFragment="${rightActionMenuFragment}"/>
	</c:set>
	<ui:actionMenuBar>
		<jsp:attribute name="rightAligned">${actionMenuRightPart}</jsp:attribute>
		<jsp:body>${actionMenuBodyPart}</jsp:body>
	</ui:actionMenuBar>

	<c:choose>
		<c:when test="${(selectedLayout ne 1) && (selectedLayout ne 2)}">
			<ui:actionBar excludeGlobalMessages="true">
				<%-- javascript called by actions for combo box --%>
				<script type="text/javascript">
					var trackerActionsHandler = new TrackerActionsHandler('clipboard_task_id', issueCopyMoveConfig, issueCopyMoveContext);
				</script>
				<c:if test="${!tracker.versionCategory && empty baseline}">
				<table class="reportSelectorActionBarTable">
					<tr>
						<td class="actionBarColumn">
				</c:if>
							<ui:rightAlign>
								<jsp:attribute name="filler">
									<ui:actionMenu title="more" cssClass="browseTrackerMoreMenu" builder="${actionBuilder}" subject="${trackerMenuData}" keys="${actionKeys}"/>
								</jsp:attribute>

								<jsp:attribute name="rightAligned">
									<c:choose>
										<c:when test="${!empty baseline}">
										</c:when>

										<c:when test="${selectedLayout eq 2}">
										</c:when>

										<c:otherwise>
											<c:if test="${not empty baseline}">
												<logic:equal property="advancedView" value="true" name="trackerBrowseForm">
													<div id="quickFilters" style="margin-bottom: 15px; display: inline; margin-right: 10px;">

														<c:if test="${tracker.versionCategory && showActionBarControls}">
															<jsp:include page="includes/versionViewControls.jsp">
																<jsp:param name="autoSaveReleaseTreeState" value="${autoSaveReleaseTreeState}" />
															</jsp:include>
														</c:if>

														<spring:message var="trackerFilterTitle" code="tracker.filter.tooltip" text="Filter this tracker for summary, description and comments"/>
														<html:text styleId="trackerFilter" property="trackerFilter" title="${trackerFilterTitle}" styleClass="searchFilterBox" size="15" style="display:inline;"/>
													</div>

													<spring:message var="searchTitle" code="search.submit.tooltip" text="Submit Query"/>
													<html:submit styleClass="button" property="GO" title="${searchTitle}" style="margin-right:0;">
														<spring:message code="search.submit.label" text="GO"/>
													</html:submit>
													<c:if test="${not empty trackerFilterString}">
														<a href="#" class="searchResetButton"><spring:message code="button.reset" text="Reset"/></a>
													</c:if>

													<script type="text/javascript">
														applyHintInputBox("#trackerFilter", "<spring:message code='filter.input.box.hint'/>");
													</script>
												</logic:equal>

												<c:if test="${!tracker.versionCategory}">
													<c:url var="switchViewURL" value="${action}">
														<c:param name="advancedView" value="${!trackerBrowseForm.advancedView}"/>
													</c:url>

													<spring:message var="switchTitle"
																	code="tracker.filter.${trackerBrowseForm.advancedView ? 'advanced' : 'basic'}.tooltip"
																	arguments="${itemsLabel}"/>
													<html:link href="${switchViewURL}" title="${switchTitle}" styleClass="titlenormal smallink switchViewButton">
														<spring:message code="tracker.filter.${trackerBrowseForm.advancedView ? 'advanced' : 'basic'}.label"/>
													</html:link>
												</c:if>
											</c:if>
										</c:otherwise>
									</c:choose>
								</jsp:attribute>

								<jsp:body>
									<ui:actionGenerator builder="${actionBuilder}" actionListName="actions" subject="${trackerMenuData}">
										<ui:actionLink keys="${actionLinkKeys}" actions="${actions}" />
										<c:if test="${tracker.testCase && not empty availableTestRunTrackers && availableTestRunTrackers.size() > 1 && hasTestManagementLicense}">
											<spring:message var="newTestRunLabel" code="tracker.type.Testrun.create.label"/>
											<ui:actionMenu keys="newTestRun*" actions="${actions}" inline="true" actionIconMode="true" cssClass="actionBarIcon newTestRunIcon" iconUrl="/images/newskin/actionIcons/icon-new-test-run.png" title="${newTestRunLabel}"/>
										</c:if>

										<%--
											for "version" trackers and in Document Views, it makes no sense to display cut/copy/paste, because the user can not select the issue with checkboxes,
											because the "versionsView.jsp" does not contain checkboxes at all
										--%>
										<c:if test="${(selectedLayout eq 0) && !tracker.versionCategory}">
											<span class="extraActionsContainer hide">
												<ui:actionComboBox keys="cut, copy, paste, copyTo, moveTo, delete, restore, massEdit" actions="${actions}"
																   onchange="trackerActionsHandler.onSelectionChange(this);" id="actionCombo"
												/>
											</span>
										</c:if>
									</ui:actionGenerator>
								</jsp:body>

							</ui:rightAlign>

				<c:if test="${!tracker.versionCategory && empty baseline}">
						</td>
						<td class="reportSelectorColumn">
								<ui:reportSelector resultContainerId="reportSelectorResult" projectId="${tracker.project.id}" trackerId="${branch == null ? tracker.id : branch.id}"
												   resultRenderUrl="/proj/tracker/showTrackerItems.spr" sticky="true" contextualSearch="true"
												   showGroupBy="true" showOrderBy="true" triggerResultAfterInit="true" viewId="${selectedReportViewId}" defaultViewId="${defaultViewId}"
												   mergeToActionBar="true" showResizeableColumns="true"/>
						</td>
					</tr>
				</table>
				</c:if>
			</ui:actionBar>
		</c:when>
		<c:when test="${selectedLayout eq 2}">
			<ui:actionBar>
				<jsp:attribute name="rightAligned">
					<c:if test="${!empty progressBar}">
						<div class="version" id="progressBar">${progressBar}</div>
					</c:if>
				</jsp:attribute>
				<jsp:body>&nbsp;</jsp:body>
			</ui:actionBar>
		</c:when>
	</c:choose>

	<c:if test="${selectedLayout ne 1 && tracker.isVersionCategory() && !empty baseline}">
		<ui:baselineInfoBar projectId="${tracker.project.id}" baselineName="${baseline.name}" baselineParamName="revision" cssStyle="margin-bottom: 10px;" notSupported="true"/>
	</c:if>

	<%-- the selection of TrackerItem is only allowed if not yet on clipboard or it is copied --%>
	<c:set var="allowSelectionPredicate" value="<%=new BrowseTrackerAction.NotOnClipboardPredicate(request)%>" />

	<input type="hidden" name="tracker_id" value="${currentTrackerId}" id="trackerIdInput"/>
	<input type="hidden" value="${tracker.project.id}" id="projectIdInput"/>

	<c:choose>
		<c:when test="${tracker.versionCategory}">
			<jsp:include page="./includes/versionsView.jsp" />

			<script type="text/javascript">
				VersionStats.initTransitionMenu();
				VersionStats.installExecuteTransitionCallback();
				new codebeamer.ReleaseHotkeys({subjectId: ${currentTrackerId}, isReleaseTracker: true});
			</script>

		</c:when>

		<c:when test="${(selectedLayout eq 1 or selectedLayout eq 5) and hasDocumentViewLicense}">
			<jsp:include page="./docview/documentView.jsp" />
		</c:when>

		<c:when test="${selectedLayout eq 2}">
			<jsp:include page="dashboard.jsp" />
		</c:when>

		<c:otherwise>

			<c:if test="${!tracker.versionCategory}">
				<logic:equal property="advancedView" value="false" name="trackerBrowseForm">
					<jsp:useBean id="trackerBrowseForm" beanName="trackerBrowseForm" scope="session" type="com.intland.codebeamer.servlet.bugs.TrackerBrowseForm" />
					<%
						Map<String,String> labelMap = new HashMap<String,String>(4);
						labelMap.put(TrackerBrowseForm.ANY_VALUE, "tracker.filter.Any.label");
						labelMap.put(TrackerBrowseForm.UNSET_VALUE, TrackerBrowseForm.UNSET_LABEL);

						final int MAXCOLUMNS = 3;
						TableCellCounter tableCellCounter = new TableCellCounter(out, pageContext, MAXCOLUMNS, 2);
					%>

					<style type="text/css">
						<!--
						#advancedFilterTable {
							width: 95%;
						}
						#advancedFilterTable .dataCell {
							width: 23%;
							padding: 0 !important;
						}
						#advancedFilterTable .labelCell {
							padding-left: 0.5em;
							padding-right: 0.5em;
							width: 10%;
						}
						#advancedFilterTable table td {
							padding: 0 !important;
						}
						#advancedFilterTable tr.contextualFilter td {
							padding-top: 2em !important;
						}
						-->
					</style>

					<spring:message var="setAnyButton" code="tracker.filter.any.button" text="Set Any" htmlEscape="true"/>

					<div class="browseTrackerAdvancedSearch accordion">
						<h3 class="accordion-header"><spring:message code="search.advanced.title" text="Advanced Search"/></h3>
						<div class="accordion-content">
							<table border="0" class="formTableWithSpacing" cellpadding="0" class="fieldsTable" id="advancedFilterTable">
								<c:forEach items="${trackerBrowseForm.layoutList}" var="fieldLayout">
									<jsp:useBean id="fieldLayout" beanName="fieldLayout" type="com.intland.codebeamer.persistence.dto.TrackerLayoutLabelDto" />

									<c:choose>
										<c:when test="${fieldLayout.userReferenceField}">
											<% tableCellCounter.insertNewRow(1, false); %>
											<td class="labelCell optional">
												<spring:message code="tracker.field.${fieldLayout.label}.label" text="${fieldLayout.label}"/>
											</td>
											<td class="dataCell">
												<c:set var="ids" value="<%=trackerBrowseForm.getReferenceFieldIds(fieldLayout.getId())%>" />
												<c:set var="propertyName" value="<%=trackerBrowseForm.getReferenceFieldName(fieldLayout)%>" />
												<bugs:userSelector ids="${ids}" field_id="${fieldLayout.id}" fieldName="${propertyName}" showUnset="${! fieldLayout.required}" showCurrentUser="true"
																   onlyUsersAndRolesWithPermissionsOnTracker="true" tracker_id="${currentTrackerId}" allowRoleSelection="true"
																   setToDefaultLabel="${setAnyButton}" defaultValue="<%=TrackerBrowseForm.ANY_VALUE%>"
																   specialValueResolver="com.intland.codebeamer.servlet.report.AddUpdateTrackerReportFormSpecialValues"
														/>
											</td>
											<c:set var="excludeParams" value="${excludeParams} ${propertyName}" />
										</c:when>

										<c:when test="${fieldLayout.choiceField or fieldLayout.languageField or fieldLayout.countryField}">
											<%-- dynamic choice fields does not appear in the filter, because would have too many values...? --%>
											<%	tableCellCounter.insertNewRow(1, false); %>
											<td class="labelCell optional">
												<spring:message code="tracker.field.${fieldLayout.label}.label" text="${fieldLayout.label}"/>
											</td>
											<td class="dataCell">
												<c:set var="ids" value="<%=trackerBrowseForm.getReferenceFieldIds(fieldLayout.getId())%>" />
												<c:set var="defaultValue"><c:out value="${trackerBrowseForm.referenceHandlerSupport.referencesDefaultValue}"/></c:set>
												<bugs:chooseReferences tracker_id="${currentTrackerId}" ids="${ids}" label="${fieldLayout}"
																	   setToDefaultLabel="${setAnyButton}" defaultValue="${defaultValue}" forceMultiSelect="true"
																	   labelMap="<%=labelMap%>" emptyValue="<%=TrackerBrowseForm.ANY_VALUE%>"
																	   showUnset="${! fieldLayout.required}" unsetValue="<%=TrackerBrowseForm.UNSET_VALUE%>"
														/>
											</td>
										</c:when>

										<c:when test="${fieldLayout.booleanField}">
											<% tableCellCounter.insertNewRow(1, false); %>
											<td class="labelCell optional">
												<c:out escapeXml="false" value="${fieldLayout.label}" />:
											</td>
											<td class="dataCell dataCellContainsSelectbox">
												<html:select property="choiceFieldValues(${fieldLayout.id})">
													<html:optionsCollection property="booleanOptions" />
												</html:select>
											</td>
											<c:set var="excludeParams" value="${excludeParams} choiceFieldValues(${fieldLayout.id})" />
										</c:when>
									</c:choose>
								</c:forEach>

								<% tableCellCounter.finishRow(); %>
								<tr class="contextualFilter">
									<td class="labelCell optional"><spring:message code="search.contextual.title" text="Contextual Search"/></td>
									<td class="dataCell" colspan="5">
										<spring:message var="trackerFilterTitle" code="tracker.filter.tooltip"
														text="Filter this tracker for summary, description and comments"/>
										<html:text styleId="trackerFilter" property="trackerFilter" title="${trackerFilterTitle}"
												   style="height: 20px; width: 100%; position: relative; top: -4px; left: 3px;"/>

									</td>
								</tr>
								<tr>
									<td></td>
									<td colspan="5">
										<spring:message var="searchTitle" code="search.submit.tooltip" text="Submit Query"/>
										<html:submit styleClass="button" property="GO" title="${searchTitle}">
											<spring:message code="search.submit.label" text="GO"/>
										</html:submit>
										<a href="#" class="searchResetButton"><spring:message code="button.reset" text="Reset"/></a>
									</td>
								</tr>
							</table>
						</div>
					</div>
					<script type="text/javascript">
						jQuery(function() {
							$(".browseTrackerAdvancedSearch.accordion").cbMultiAccordion({
								active: 0
							}).show();
							applyHintInputBox("#trackerFilter", "<spring:message code='filter.input.box.hint'/>");
						});
					</script>
				</logic:equal>
			</c:if>

			<ui:globalMessages/>

			<c:choose>
				<c:when test="${(selectedLayout eq 1 or selectedLayout eq 5) and not hasDocumentViewLicense}">
					<div class="warning" id="filterNotification">
						<spring:message code="license.docview.nolicense.message" text="To use this page you need a Document View license."/>
					</div>
				</c:when>
				<c:when test="${not empty trackerFilterString}">
					<c:if test="${not empty baseline}">
						<div class="warning" id="filterNotification">
							<c:set var="trackerFilterString"><c:out value='${trackerFilterString}'/></c:set>
							<spring:message code="tracker.browse.tableView.filtered.notification" arguments="${ui:removeXSSCodeAndHtmlEncode(trackerFilterString)}"
											text="This item list is filtered by <b>{0}</b> string. If you would like to see the unfiltered list, clear the Filter input field above or click <a href='#'>here</a>."/>
						</div>
					</c:if>
				</c:when>
				<c:when test="${empty items.getList() && not empty selectedViewDto && selectedViewDto.id != -2}">
					<c:if test="${not empty baseline}">
						<spring:message var="selectedViewName" code="tracker.view.${selectedViewDto.name}.label" text="${ui:removeXSSCodeAndHtmlEncode(selectedViewDto.name)}" htmlEscape="true"/>
						<div class="information">
							<spring:message code="tracker.browse.tableView.filtered.view.notification" arguments="${ui:removeXSSCodeAndHtmlEncode(selectedViewName)},${ui:removeXSSCodeAndHtmlEncode(allItemUrl)}"
											text="This item list is filtered by the tracker''s <b>{0}</b> view. If you would like to see all items, select All items on the view selector above or click <a href=\"{1}\">here</a>."/>
						</div>
					</c:if>
				</c:when>
			</c:choose>

			<!-- Toolbar wrapper for WYSIWYG editor -->
			<div id="toolbarContainer" class="editor-wrapper"></div>

			<div class="contentWithMargins" style="margin-top: 0;">

				<c:url var="entityLabelForwardUrl" value="${tracker.urlLink}" context="/">
					<c:if test="${not empty selectedView}"><c:param name="view_id" value="${selectedView}" /></c:if>
					<c:if test="${not empty param.branchId}"><c:param name="branchId" value="${param.branchId}" /></c:if>
				</c:url>
				<jsp:include page="../../label/entityLabelList.jsp">
				    <jsp:param name="entityTypeId" value="${GROUP_TRACKER}" />
				    <jsp:param name="entityId" value="${tracker.id}" />
				    <jsp:param name="forwardUrl" value="${entityLabelForwardUrl}" />
				    <jsp:param name="editable" value="${!param.isPopup}"/>
				    <jsp:param name="branchId" value="${param.branchId}" />
				</jsp:include>
				<%-- normal tracker item view --%>

				<c:if test="${empty baseline}">
					<div id="reportSelectorResult"></div>
				</c:if>

				<c:if test="${! empty baseline}">
					<bugs:displaytagTrackerItems htmlId="trackerItems" layoutList="${layoutList}" items="${items}"
												 requestURI="${action}" excludedParams="${excludeParams}" pagesize="${pagesize}"
												 browseTrackerMode="true" selection="true" selectionFieldName="clipboard_task_id" selectedItems="${trackerBrowseForm.clipboard_task_id}"
												 allowSelectionPredicate="${allowSelectionPredicate}"
												 clearNavigationList="true" exportTypes="excel csv pdf" includeBaselineInTtId="true"/>
				</c:if>

				<script type="text/javascript">
					var addExportToWordToDisplayTag = function() {
						// create a quick link to "Export To Word" menu in the displaytag's toolbar
						var label = "<spring:message code='tracker.issues.exportToWord.label'/>";
						var $exportToWordLink = $(".yuimenuitem a").filter(function() {
							var txt = $(this).text();
							return txt.indexOf(label) != -1;
						}).first();

						var shortLabel = "<spring:message code='tracker.issues.exportToWord.short.label'/>";
						if ($exportToWordLink.length > 0) {
							var $exportlinks = $(".exportlinks").first().find("a").first().before("<a id='exportToWordInDisplayTag' href='#'><span class='export word'>" + shortLabel +"&nbsp;<span class='separator'></span></span></a><span></span>");
							$("#exportToWordInDisplayTag").click(function() {
								$exportToWordLink.click();	// delegate click to real export-to-word hidden in menu
								return false;
							});
						}
					}
					$(addExportToWordToDisplayTag);

					new codebeamer.TableViewHotkeys({subjectId: ${currentTrackerId}});
				</script>

			</div>
		</c:otherwise>
	</c:choose>

</html:form>

<script type="text/javascript">
	function exportSelectionToWord(trackerId, revision) {
		var Tracker = codebeamer.trackers.Tracker.prototype;

		// get the selected issues from the tree if we're on the document view
		var ids = Tracker.getSelectedIssuesFromTree();

		// when the table view is shown collect the ids of the selected checkboxes
		$("input[name='clipboard_task_id']:checked").each(function() {
			ids.push($(this).val());
		});

		Tracker.exportSelectionToWord(ids, trackerId, revision);
		return false;
	}

	function sendSelectionToReview(projectId, revision, mergeRequest, isBranch) {
		var Tracker = codebeamer.trackers.Tracker.prototype;

		// get the selected issues from the tree if we're on the document view
		var ids = Tracker.getSelectedIssuesFromTree();

		// when the table view is shown collect the ids of the selected checkboxes
		$("input[name='clipboard_task_id']:checked").each(function() {
			ids.push($(this).val());
		});

		Tracker.sendSelectionToReview(ids, projectId, revision, mergeRequest, isBranch);
		return false;
	}

	jQuery(function($) {
		// initialize the custom select list
		$("#selectedView").selectBoxIt();

		// init filter notification hyperlink if present
		var filterNotification = $('#filterNotification');
		if (filterNotification.length > 0) {
			filterNotification.find('a').click(function() {
				$('#trackerFilter').val("");
				$('#browseTrackerForm').submit();
			});
		}

		var resetButtons = $(".searchResetButton");
		resetButtons.click(function() {
			$('#trackerFilter').val("");
			$('.reference-box input[type="hidden"]').val("");
			$('#browseTrackerForm').submit();
		});

		codebeamer.ReferenceSettingBadges.init($("#trackerItems"));

		<c:if test="${not empty branchSwitchWarningTargetName}">
        	showBranchSwitchWarning("${ui:escapeJavaScript(branchSwitchWarningTargetName)}", ${branchSwitchWarningTargetId}, ${branchSwitchWarningBranchesJSON});
		</c:if>

	});

	var showCreateBranchDialog = function (url) {
		inlinePopup.close();
		showPopupInline(url);
	}

</script>
