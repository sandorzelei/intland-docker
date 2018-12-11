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
<%@page import="com.intland.codebeamer.controller.testmanagement.TestCaseController"%>
<%@ page import="com.intland.codebeamer.persistence.dto.TrackerTypeDto"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<%@ taglib uri="http://struts.apache.org/tags-logic" prefix="logic" %>

<%@ taglib uri="http://ditchnet.org/jsp-tabs-taglib" prefix="tab" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="http://displaytag.sf.net" prefix="display" %>

<%@ taglib uri="log" prefix="log" %>
<%@ taglib uri="taglib" prefix="tag" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="acltaglib" prefix="acl" %>
<%@ taglib uri="bugstaglib" prefix="bugs" %>

<%@ page import="com.intland.codebeamer.persistence.dto.TrackerLayoutLabelDto" %>
<%@ page import="com.intland.codebeamer.remoting.GroupType"%>
<%@ page import="com.intland.codebeamer.taglib.TableCellCounter"%>
<%@ page import="com.intland.codebeamer.persistence.util.Directory"%>
<%@ page import="com.ecyrd.jspwiki.providers.ProviderUtils"%>

<meta name="decorator" content="${param.isPopup ? 'popup' : 'main'}"/>
<c:set var="module" value="${empty tracker.parent.id ? (tracker.category ? 'cmdb' : 'tracker') : 'docs'}"/>
<c:if test="${branch != null}">
	<c:set var="module" value="branch"/>
</c:if>
<c:if test="${not empty taskRevision.baseline}">
	<c:set var="module" value="baselines"/>
</c:if>
<meta name="module" content="${module}"/>
<meta name="moduleCSSClass" content="newskin ${tracker.category ? 'CMDBModule' : 'trackersModule'} ${not empty taskRevision.baseline ? 'tracker-baseline' : ''} ${empty taskRevision.baseline && branch != null ? 'tracker-branch' : ''}"/>

<c:if test="${param.isPopup}">
	<style type="text/css">
		body {
			overflow-x: hidden !important;
		}
	</style>
</c:if>

<c:set var="task_id" value="${task.id}" scope="request" />

<spring:message var="officeEditTooltip" code="document.officeEdit.tooltip"/>
<spring:message var="officeEditHelp" code="document.officeEdit.help"/>

<spring:message var="officeEditLabel" code="button.edit"/>

<script type="text/javascript" src="<ui:urlversioned value='/js/IssueDescriptionPoller.js'/>"></script>

<link rel="stylesheet" href="<ui:urlversioned value='/stylesheet/inlineComment.less' />" type="text/css" media="all" />
<script type="text/javascript" src="<ui:urlversioned value='/js/inlineComment.js'/>"></script>

<script type="text/javascript" src="<ui:urlversioned value='/bugs/includes/commentVisibility.js'/>"></script>

<link rel="stylesheet" href="<ui:urlversioned value="/bugs/tracker/traceabilityBrowser/traceabilityBrowser.less" />" type="text/css" media="all" />
<script type="text/javascript" src="<ui:urlversioned value='/bugs/tracker/traceabilityBrowser/traceability.js'/>"></script>

<link rel="stylesheet" href="<ui:urlversioned value="/stylesheet/multiselect.less" />" type="text/css" media="all" />
<link rel="stylesheet" href="<ui:urlversioned value="/bugs/itemDetails.less" />" type="text/css" media="all" />

<script type="text/javascript" src="<ui:urlversioned value='/js/suspectedLinkBadge.js'/>"></script>
<script type="text/javascript" src="<ui:urlversioned value='/js/trackerItemDetailsTabSupport.js'/>"></script>

<script type="text/javascript" src="<ui:urlversioned value='/js/displaytagTrackerItemsInlineEdit.js'/>"></script>
<script type="text/javascript" src="<ui:urlversioned value='/bugs/itemDetails.js'/>"></script>

<link rel="stylesheet" href="<ui:urlversioned value="/stylesheet/multiselect-filter.less" />" type="text/css" media="all" />
<link rel="stylesheet" href="<ui:urlversioned value="/stylesheet/selectorUtils.less" />" type="text/css" media="all" />

<c:set var="TESTRUN_TRACKER_TYPE" value="<%=TrackerTypeDto.TESTRUN%>" />
<c:set var="isTestRun" value="${task.tracker.type.id == TESTRUN_TRACKER_TYPE.id}" />

<c:set var="branchOrTracker" value="${branch != null ? branch : tracker }"/>
<bugs:branchStyle branch="${branchOrTracker}"/>

<script type="text/javascript">

	var pollUri = "${pollUri}";
	var issueId = "${task.id}";
	var time = "${task.modifiedAt.time}";
	var baselineId = ${empty taskRevision.baseline ? 'null' : taskRevision.baseline.id};

	IssueDescriptionPoller.addIssue(issueId, time, "fieldset.officeEdit > div.collapsingBorder_content");

    itemHistoryAlignTable.init();

    $(function() {
		codebeamer.TrackerItemDetailsTabSupport.initOnPageLoad($("#task-details"), issueId, baselineId);
	});

	function onTabChange(evt) {
		var baseurl = '<c:url value="${repository.urlLink}"/>';
		var selectedTabPane = evt.getTabPane(); // reloads the page only
		if (selectedTabPane.id == "changesets") {
			var newurl = baseurl +"/" + selectedTabPane.id;
				window.location = newurl;
		}

		codebeamer.TrackerItemDetailsTabSupport.loadProperTab(selectedTabPane.id + "-tab", issueId, baselineId);

		itemHistoryAlignTable.setWidths();

		if (selectedTabPane.id == 'task-details-attachments') {
			codebeamer.InlineComment.fixWidths($(selectedTabPane).find('.editCommentSection'));
		}
	}

	function onRelationsToggle(relations) {
		var isTestRun = ${isTestRun ? 'true' : 'false'};
        var relationsOpen = !$(this).hasClass("collapsingBorder_collapsed"),
            revisionParameter = !baselineId ? '' : '&revision=' + baselineId;

		var $legend = $("#relations-box").find(".collapsingBorder_legend");
		var $traceabilitySettingCont = $legend.find(".traceabilitySettingCont");
		relationsOpen ? $traceabilitySettingCont.show() : $traceabilitySettingCont.hide();
		if (relationsOpen) {
			codebeamer.Traceability.setTabArrowHeight();
		}
		var $relationBox = $("#relations-box > div.collapsingBorder_content");
		if ($relationBox.children("div").length == 0) {
			if ($traceabilitySettingCont.length == 0) {
				var $settingCont = $("<div>", { "class" : "traceabilitySettingCont"});
				var $showAssociationsInput = $("<input>", { id: "itemTraceabilityShowAssociations", type: "checkbox", checked : "checked"});
				var $showAssociationLabel = $("<label>", { "for": "itemTraceabilityShowAssociations"}).text(i18n.message("tracker.item.traceability.show.associations"));
				$settingCont.append($showAssociationsInput);
				$settingCont.append($showAssociationLabel);
				var $depthLabel = $("<span>").text(i18n.message("tracker.item.traceability.number.of.levels") + ":");
				var $depthSelector = $("<select>", { id: "itemTraceabilityDepthSelector"});
				var maxLevel = isTestRun ? 5 : 10;
				for (var i = 1; i <= maxLevel; i++) {
					$depthSelector.append($("<option>", { value: i}).text(i));
				}
				$depthSelector.val(${defaultTraceabilityDepth});
				$settingCont.append($depthLabel);
				$settingCont.append($depthSelector);

				if (!isTestRun) {
					var $showDescriptionInput = $("<input>", { id: "itemTraceabilityShowDescription", type: "checkbox"});
					var $showDescriptionLabel = $("<label>", { "for": "itemTraceabilityShowDescription"}).text(i18n.message("tracker.traceability.browser.show.description"));
					$settingCont.append($showDescriptionInput);
					$settingCont.append($showDescriptionLabel);

					var $showSCMInput = $("<input>", { id: "itemTraceabilityShowSCM", type: "checkbox"});
					var $showSCMLabel = $("<label>", { "for": "itemTraceabilityShowSCM"}).text(i18n.message("tracker.traceability.browser.show.scm"));
					$settingCont.append($showSCMInput);
					$settingCont.append($showSCMLabel);
				}

				var $ignoreRedundantsInput = $("<input>", { id: "itemTraceabilityIgnoreRedundants", type: "checkbox"});
				<c:if test="${defaultTraceabilityIgnoreRedundants}">
					$ignoreRedundantsInput.prop("checked", true);
				</c:if>
				var $ignoreRedundantsLabel = $("<label>", { "for": "itemTraceabilityIgnoreRedundants"}).text(i18n.message("tracker.traceability.browser.dont.show.redundant"));
				$settingCont.append($ignoreRedundantsInput);
				$settingCont.append($ignoreRedundantsLabel);

				$settingCont.hide();
				$legend.append($settingCont);
			}
			codebeamer.Traceability.loadTrackerItemTraceability($relationBox, issueId, baselineId, function() {
				if ($("#relations-box").hasClass("collapsingBorder_expanded")) {
					$legend.find(".traceabilitySettingCont").show();
				}
			}, isTestRun);
		}

	}

	function onDetailsToggle(isOpen){
		$.post(contextPath + "/userSetting.spr?name=ISSUE_DETAILS_CLOSED&value=" + (isOpen ? 1 : 0));
	}

	function reloadEditedIssue() {
		location.reload();
	}

	function executeTransitionCallback() {
		reloadEditedIssue();
	}

	function updateContextMenuIconPositions() {
		/**
		* Comment context menu intelligent positioning.
		*/
	    var constraintElem = $("#attachment"),
	    	container = constraintElem.closest(".ditch-tab-pane-wrap"),
	    	isIE = $('body').hasClass('IE'),
	    	margin = 30,
	    	$window = $(window);
	    
		var repositionContextMenuIcons = function($items, alwaysDisplayContextMenuIcons) {
	    	$items.each(function() {
		        var row = $(this).closest('tr'),
		        	$menu = row.find('.action-column-minwidth .yuimenubar');
	
		        if (!alwaysDisplayContextMenuIcons) {
			        container.find('.menu-position-changed')
			        	.removeClass('menu-position-changed')
			        	.css('position', 'static');
		        }
		        
		        $menu.addClass('menu-position-changed').css({
		            position: 'relative',
		            left: $window.outerWidth() - constraintElem.outerWidth() - (isIE ? 80 : 40),
		            'background-color': 'white'
		        });
	    	});
		};
		
		// comments could be too wide, so align their context menu to the right
	    if (constraintElem.outerWidth() > $window.outerWidth() - margin - (isIE ? 50 : 0)) {
		    if (codebeamer.userPreferences && codebeamer.userPreferences.alwaysDisplayContextMenuIcons) {
		    	repositionContextMenuIcons(container.find('.classComment,.classAttachment'), true);
		    } else {
		    	if (!container.data('handlingMouseEnterForContextMenu')) {
			    	container.on('mouseenter', '.classComment,.classAttachment', function() {
			    		repositionContextMenuIcons($(this));
			    	});
			    	container.data('handlingMouseEnterForContextMenu', true);
		    	}
		    }
	    } else {
	    	container.find('.menu-position-changed')
	        	.removeClass('menu-position-changed')
	        	.css('position', 'static');
	    }		
	}
	
	function refreshAfterComment() {
		updateContextMenuIconPositions();
	}
	
	$(function() {
		// Scroll to Traceability (Relations) box if this is set in the URL
		var openTraceability = window.location.hash && window.location.hash == "#task-traceability-tab";
		var $relationsBox = $("#relations-box");
		if (openTraceability) {
			if ($relationsBox.hasClass("collapsingBorder_collapsed")) {
				$relationsBox.find(".collapseToggle").click();
			}
			$('html, body').animate({
				scrollTop: $relationsBox.offset().top
			}, 500);
		}

		updateContextMenuIconPositions();
		$(window).on('resize', throttleWrapper(function() {
			setTimeout(updateContextMenuIconPositions, 100);
		}));
	});

	// initialize the hotkeys
	var disabledModules = [];
	if (!${editable && empty taskRevision.baseline}) {
		disabledModules.push("edit");
	}
	if (!${canAddComment && empty taskRevision.baseline}) {
		disabledModules.push("comment");
	}
	if (!${canCreateSibling && empty taskRevision.baseline}) {
		disabledModules.push("create");
	}
	var itemHotkeys = new codebeamer.TrackerItemHotkeys({subjectId: ${task.id},  trackerId: ${task.tracker.id}, disabledModules: disabledModules, canCreateAssociation: ${canCreateAssociation} });

</script>


<jsp:useBean id="taskRevision" beanName="taskRevision" scope="request" type="com.intland.codebeamer.persistence.dto.TrackerItemRevisionDto" />
<jsp:useBean id="decorated" beanName="decorated" scope="request" type="com.intland.codebeamer.ui.view.table.TrackerSimpleLayoutDecorator" />

<%
try {
	if (taskRevision.getBaseline() != null) {
		ProviderUtils.pushPageContext(taskRevision.getBaseline());
	}
%>

<jsp:include page="/bugs/includes/issueCopyMove.jsp" />
<jsp:include page="/bugs/includes/issueReminder.jsp" />

<ui:pageTitle printBody="false">
	<c:out value="${task.keyAndId}" default="--"/>
</ui:pageTitle>

<ui:actionGenerator builder="${actionBuilder}" subject="${task}" actionListName="actions" >
	<c:set var="taskActions" scope="request" value="${actions}" />
</ui:actionGenerator>

<ui:actionGenerator builder="trackerItemReferringItemActionsMenuBuilder" subject="${task}" actionListName="actions">
	<c:set var="newReferringItemActions" scope="request" value="${actions}" />
</ui:actionGenerator>

<c:if test="${canGenerateRisk and task.tracker.requirement and !task.groupingItem}">
	<ui:actionGenerator builder="generateRiskActionMenuBuilder" subject="${task}" actionListName="actions">
		<c:set var="generateRiskActions" scope="request" value="${actions}" />
	</ui:actionGenerator>
</c:if>

<c:if test="${canGenerateMitigationRequirement and task.tracker.risk and !task.groupingItem}">
	<ui:actionGenerator builder="generateMitigationRequirementActionMenuBuilder" subject="${task}" actionListName="actions">
		<c:set var="generateMitigationReqActions" scope="request" value="${actions}" />
	</ui:actionGenerator>
</c:if>

<ui:actionMenuBar cssClass="large" showRating="false">
	<jsp:attribute name="rightAligned">
		<c:if test="${!param.isPopup}">
			<c:set var="rightFragment">
				<c:choose>
					<c:when test="${isRelease}">
						<ui:actionGenerator builder="agileVersionScopeActionMenuBuilder" actionListName="actions" subject="${task}">
							<c:if test="${not empty actions}">
								<div class="release-train-icon"></div>
								<div class="release-train">
										<ui:combinedActionMenu actions="${actions}" subject="${task}"
															   buttonKeys="planner,cardboard,versionStats" cssClass="large" hideMoreArrow="true" />
								</div>
							</c:if>
						</ui:actionGenerator>
						<div class="release-train-extra-icons">
							<ui:combinedActionMenu builder="agileVersionScopeActionMenuBuilder" subject="${task}" buttonKeys="coverageBrowser"
												   keys="coverageBrowser" cssClass="large" hideMoreArrow="true"/>
						</div>
					</c:when>
					<c:otherwise>
						<ui:combinedActionMenu builder="trackerItemDetailsActionMenuBuilder" keys="showCardboardView,showDocumentView,viewTraceabilityBrowser"
											   buttonKeys="showTableView,showDocumentView,showDocumentViewExtended,showCardboardView,viewTraceabilityBrowser"
											   subject="${taskRevision}" cssClass="large" hideMoreArrow="true" />
					</c:otherwise>
				</c:choose>
			</c:set>
			<ui:branchBaselineBadge branch="${branch}" baseline="${taskRevision.baseline}" originalItemId="${originalItemId}" masterItemId="${masterItemId}" rightFragment="${rightFragment}"/>
		</c:if>
	</jsp:attribute>
	<jsp:body>
		<c:url value="${historyUrl}" var="historyUrlLink" context="/"/>
		<ui:breadcrumbs projectAware="${taskRevision}" historyUrl="${historyUrlLink}" showProjects="false"/>
		<c:if test="${!empty taskRevision.baseline}">
				<c:url var="baselineUrl" value="${taskRevision.baseline.urlLink}" />
				<c:set var="baselineInfo">
					<spring:message code="baseline.createdBy.label" text="Created by"/>: <c:out value="${taskRevision.baseline.createdBy}"/>,
					<tag:formatDate value="${taskRevision.baseline.createdAt}" />

				</c:set>
		</c:if>
		<c:if test="${empty taskRevision.baseline}">
			<c:choose>
				<%-- hard lock info --%>
				<c:when test="${!empty tracker.additionalInfo.lockedBy}">
					<div>
						<spring:message var="lockInfo" code="document.lockedBy.tooltip" text="Locking information"/>
						<span class="main high" title="${lockInfo}">
							<spring:message code="tracker.${tracker.name}.label" text="${tracker.name}" htmlEscape="true"/>:
							<spring:message code="document.lockedBy.label" text="Currently locked by"/>
							<tag:userLink user_id="${tracker.additionalInfo.lockedBy.id}" />.
						</span>
					</div>
				</c:when>

				<%-- soft lock info --%>
				<c:when test="${PAGE_LOCKER.id gt 0}">
					<div>
						<spring:message var="editInfo" code="document.editedBy.tooltip" text="Editing information"/>
						<span class="main high" title="${editInfo}">
							<spring:message code="tracker.${tracker.name}.label" text="${tracker.name}" htmlEscape="true"/>:
							<spring:message code="document.editedBy.label" text="Currently edited by"/>
							<tag:userLink user_id="${PAGE_LOCKER.id}" />.
						</span>
					</div>
				</c:when>
				<c:when test="${not empty itemLocker }">
					<div>
						<spring:message var="lockInfo" code="document.lockedBy.tooltip" text="Locking information"/>
						<span class="main high" title="${lockInfo}">
							<spring:message code="document.lockedBy.label" text="Currently locked by"/>
							<tag:userLink user_id="${itemLocker.id}" />.
						</span>
					</div>
				</c:when>
			</c:choose>
		</c:if>
		<ui:itemDependenciesBadge item="${task}" />
	</jsp:body>
</ui:actionMenuBar>

<ui:breadCrumbNavigation id="upstream" itemId="${task.id}" baseline="${taskRevision.baseline}" showRating="true"/>

<c:if test="${!param.isPopup}">

<c:choose>
	<c:when test="${headRevision}">
	  <spring:message var="backTitle" code="issue.details.back.tooltip" text="Go back..."/>

	  <ui:actionBar>
		<ui:rightAlign>
			<jsp:attribute name="rightAligned">
				<acl:isAnonymousUser var="isAnonym" />
				<%--
				<c:if test="${!isAnonym}">
					<ui:ajaxTagging entity="${task}" favourite="true" />
				</c:if>
				--%>
			</jsp:attribute>
			<jsp:body>
				<%--
				<c:if test="${!empty previousIssue}">
					<a class="actionLink" href="<c:url value="${previousIssue.urlLink}" />" title="<c:out value="${previousIssue.shortDescription}" />"><spring:message code="issue.details.prev.label" text="Previous"/></a>
				</c:if>

				<c:if test="${!empty nextIssue}">
					<a class="actionLink" href="<c:url value="${nextIssue.urlLink}" />" title="<c:out value="${nextIssue.shortDescription}" />"><spring:message code="issue.details.next.label" text="Next"/></a>
				</c:if>
				--%>

				<ui:actionLink keys="${(!isTestRun or empty missingEssentialFields) ? 'runTestRun, runInExcel, edit' :'' }" actions="${taskActions}" />
				<c:if test="${!isTestRun and actionsRendered}">
					<span class="menu-separator" style="position: relative; left: -7px;"></span>
				</c:if>
				<ui:actionLink keys="${isTestRun ? '' : 'newTrackerItem, '} newTestRun, createSprintSchedule" actions="${taskActions}" />

				<c:if test="${(task.tracker.testCase || task.tracker.testSet) && not empty availableTestRunTrackers && availableTestRunTrackers.size() > 1}">
					<spring:message var="newTestRunLabel" code="tracker.type.Testrun.create.label"/>
					<ui:actionMenu keys="newTestRun*" title="${newTestRunLabel}" actionIconMode="true" iconUrl="/images/newskin/actionIcons/icon-new-test-run.png" actions="${taskActions}" inline="true"/>
				</c:if>

				<ui:actionGenerator builder="trackerItemTransitionsActionsMenuBuilder" subject="${task}" actionListName="transitionActions">

					<c:if test="${!empty newReferringItemActions}">
						<spring:message var="newReferringItemTitle" code="menu.newReferringIssue.title"/>
						<ui:actionMenu keys="newReferringTrackerItem*" title="${newReferringItemTitle}" actionIconMode="true" iconUrl="/images/newskin/actionIcons/icon_new_referring_item_plus_blue.png" actions="${newReferringItemActions}" inline="true" />
					</c:if>

					<c:if test="${!empty generateRiskActions}">
						<ui:actionMenu keys="generateRisk*" actions="${generateRiskActions}" inline="true" cssClass="actionLink" >
							<a href="#"><spring:message code="tracker.view.layout.document.generate.risk"/></a>
						</ui:actionMenu>
					</c:if>

					<c:if test="${!empty generateMitigationReqActions}">
						<ui:actionMenu keys="generateMitigationRequirement*" actions="${generateMitigationReqActions}" inline="true" cssClass="actionLink" >
							<a href="#"><spring:message code="tracker.view.layout.document.generate.mitigation.req"/></a>
						</ui:actionMenu>
					</c:if>

					<ui:actionLink keys="goToTestSetRun, showParent, newTestRuns, versionStats" actions="${taskActions}" />

					<c:set var="transitionCount" value="${fn:length(transitionActions)}"/>

					<c:set var="showTransitions" value="true" />
					<c:if test="${isTestRun}">
						<c:set var="showTransitions" value="${(empty missingEssentialFields) && !testSetOrTestCaseMissing}" />
					</c:if>

					<c:if test="${showTransitions && transitionCount > 0}" >
						<div class="item-transitions" id="item-transitions">
							<c:choose>
								<c:when test="${transitionCount <= 3}">
									<c:forEach items="${transitionActions}" var="action" varStatus="loopStatus">
										<c:if test="${loopStatus.index < transitionCount }">
											<ui:actionLink keys="${action.key }" actions="${transitionActions}" withIcon="true"/>
										</c:if>
									</c:forEach>
								</c:when>
								<c:otherwise>
									<c:set var="keysInDropdown" value=" "/>
									<c:forEach items="${transitionActions}" var="action" varStatus="loopStatus">
										<c:choose>
											<c:when test="${loopStatus.index < 2 }">
												<ui:actionLink keys="${action.key }" actions="${transitionActions}" withIcon="true"/>
											</c:when>
											<c:otherwise>
												<c:set var="keysInDropdown" value="${keysInDropdown}${action.key}${loopStatus.last ? '' : ','}"/>
											</c:otherwise>
										</c:choose>
									</c:forEach>
									<spring:message var="transitionMenuTitle" code="issue.transitions.title" text="Transitions"/>
									<%-- for normal (non TestRun) trackers show the transitions menu --%>
									<ui:actionMenu title="${transitionMenuTitle}" actions="${transitionActions}" inline="true" cssClass="actionLink" keys="${keysInDropdown}"/>
								</c:otherwise>
							</c:choose>
						</div>
					</c:if>
				</ui:actionGenerator>

				<ui:actionMenu actions="${taskActions}" keys="import, exportToWord,----,planner, cardboard, versionStats, bubbleChart,---,${isTestRun ? '' : 'addSubTask,'},editViaOffice,addAttachment,addCommentViaOffice,addAssociation,addReminder,viewTraceabilityBrowser,[---],cut,copy,copyTo,moveTo,delete,[---],referenceSettings,Follow,subscribeOthers,Favourite,addLabel,[---],useAsTemplate, ---, setAsRoot, ---, showCoverage,[---],slackChannel" inline="true" cssClass="actionLink" />
			</jsp:body>
		</ui:rightAlign>
	  </ui:actionBar>

	</c:when>
	<c:otherwise><%-- viewing historical version --%>
	  <%-- show the new-test-run for historical TestCases or TestSets --%>
	  <c:set var="links"><ui:actionLink keys="newTestRun*" actions="${taskActions}" /></c:set>

	  <c:if test="${! empty links}">
	  	<ui:actionBar>
			<c:choose>
			  	<c:when test="${(task.tracker.testCase || task.tracker.testSet) && not empty availableTestRunTrackers && availableTestRunTrackers.size() > 1}">
					<ui:actionMenu keys="newTestRun*" actions="${taskActions}" inline="true" cssClass="actionLink">
						<a href="#"><spring:message code="tracker.type.Testrun.create.label"/></a>
					</ui:actionMenu>
				</c:when>
				<c:otherwise>
					${links}
				</c:otherwise>
			</c:choose>
	  	</ui:actionBar>
	  </c:if>

	</c:otherwise>
</c:choose>
</c:if>

<%-- missingEssentialFieldscontains all the field names that are necessary on each test run tracker and are missing from the current tracker. --%>
<c:if test="${not empty missingEssentialFields }">
	<div class="error">
		<spring:message code="tracker.testRun.some.ssential.fields.missing.error"/>
	</div>
</c:if>

<c:if test="${testSetOrTestCaseMissing }">
	<div class="warning">
		<spring:message code="tracker.testRun.has.no.test.cases.error" text="You cannot run this test run because it has no Test Sets or Test Cases."/>
	</div>
</c:if>

<div class="contentWithMargins">

<jsp:include page="/testmanagement/showSequentialTestSetLockedException.jsp" />

<jsp:include page="../label/entityLabelList.jsp">
    <jsp:param name="entityTypeId" value="${GROUP_TRACKER_ITEM}" />
    <jsp:param name="entityId" value="${task.id}" />
    <jsp:param name="forwardUrl" value="${task.urlLink}" />
    <jsp:param name="editable" value="${!param.isPopup}"/>
</jsp:include>

<h3 class="onlyInPrint"><c:out value="${task.name}" /><span style='margin-left:15px'>[<c:out value="${task.keyAndId}"/>]</span></h3>

<c:if test="${!empty layout.fields}">
<%
	final int MAXCOLUMNS = 3;
	TableCellCounter tableCellCounter = new TableCellCounter(out, pageContext, MAXCOLUMNS, 2);
%>


<style type="text/css">
	.padding-left-none {
		padding: 5px 15px 5px 0px !important;
	}

	.issueStatus {
		height: 13px !important;
		line-height: 14px;
	}

/* 	.embeddedFieldTable { */
/* 		border-style: Solid !important; */
/* 		border-color: silver !important; */
/* 		border-width: 1px !important; */
/* 	} */

	.embeddedFieldTable tr.head {
		border-style: None !important;
	}

	.embeddedFieldTable th.embeddedTableHeader {
		padding-top: 0 !important;
		padding-bottom: 0 !important;
		padding-right: 0 !important;
	}

	.embeddedFieldTable td.embeddedTableCell {
		padding-top:    2px !important;
		padding-bottom: 2px !important;
	}

	.embeddedFieldTable th.date, .embeddedFieldTable td.date  {
		white-space: nowrap;
		text-align: right;
		padding: 0 4px 0 4px;
	}

	.embeddedFieldTable th.number, .embeddedFieldTable td.number  {
		white-space: nowrap;
		text-align: right;
		padding: 0 4px 0 4px;
	}

	.embeddedFieldTable th.text, .embeddedFieldTable td.text  {
		white-space: nowrap;
		text-align: left;
		padding: 0 4px 0 4px;
	}

	.positionWrapper .yuimenubar {
		background-color: white;
		padding: 0;
	}

	#item-transitions {
		display: inline-block;
  		border-left: 1px solid #d1d1d1;
  		border-right: 1px solid #d1d1d1;
		padding-left: 10px;
		padding-right: 2px;
		margin-top: -3px;
		position: relative;
		top: -5px;
		margin-bottom: -16px;
		bottom: 0px;
		height: 30px;
		margin-right: 5px;
	}

	#item-transitions > a, #item-transitions > .actionLink {
		position: relative;
		top: 4px;
	}

	#item-transitions span.actionLink {
		margin-right: 5px;
	}

	.tableItem .menu-container {
		height: 5px;
		display: block;
	}

	.tableItem .menuArrowDown {
		margin-top: 0px;
	}

	.tableItem .yuimenubaritem.first-of-type .menuArrowDown {
		position: absolute;
	}

	.newskin .ui-multiselect-menu {
		display: none;
	}

</style>

<c:set var="itemName"><c:out escapeXml="true" value="${task.name}" /></c:set>
<table border="0" class="propertyTable${isItemEditable ? ' inlineEditEnabled' : ''}" cellpadding="2" class="fieldLayoutTable" data-item-id="${task.id}" data-item-name="${itemName}">

	<c:if test="${(! empty testRun) && testRun.testCaseRun && not empty testRun.delegate.parent}">
		<tr class="tableCellCounter_firstRow">
			<td class="optional"><spring:message code="testrun.details.run.results" />:</td>
			<td class="tableItem"><a href="${pageContext.request.contextPath}${testRun.delegate.parent.urlLink}">${testRun.delegate.parent.name}</a></td>
		</tr>
	</c:if>

	<%-- tracker always show to get consistent layout for fields --%>
	<%	tableCellCounter.insertNewRow(); %>
	<td class="optional">
		<spring:message code="tracker.label"/>:
	</td>
	<td class="tableItem">
		<spring:message code="tracker.${task.tracker.name}.label" text="${task.tracker.name}"/>
	</td>

	<c:forEach items="${layout.fields}" var="fieldLayout">
		<c:if test="${!fieldLayout.hidden}">

			<c:set var="label_id" value="${fieldLayout.id}" />
			<spring:message var="label" code="tracker.field.${fieldLayout.labelWithoutBR}.label" text="${fieldLayout.labelWithoutBR}"/>

			<c:set var="hideLabel" value="${false}"/>

			<c:set var="showBorder" value="${true}"/>

			<c:set var="tooltip" value=""/>
			<c:set var="breakRow" value="${fieldLayout.breakRow}" />
			<c:set var="colspan" value="${fieldLayout.colspan}" />
			<c:set var="xcolspan" value="${empty colspan or colspan < 1 ? 1 : colspan}" />

			<log:trace value="label_id: ${label_id} label: ${label}" />

			<c:if test="${!empty fieldLayout.description}">
				<c:set var="tooltip">
					<c:out value="${fieldLayout.description}"/>
				</c:set>
			</c:if>

			<c:if test="${colspan gt 1}">
				<c:set var="xcolspan" value="${colspan * 2 - 1}" />
			</c:if>

			<jsp:useBean id="fieldLayout" beanName="fieldLayout" type="com.intland.codebeamer.persistence.dto.TrackerLayoutLabelDto" />

			<c:choose>
				<%-- item status --%>
				<c:when test="${label_id == STATUS_ID}">
					<%	tableCellCounter.insertNewRow(); %>
					<spring:message var="statusTooltip" code="${task.groupingItem ? 'issue.status.na.tooltip' : 'issue.quicktransition.tooltip'}" text="Quick workflow transition, if no required field is missing" htmlEscape="true"/>
					<TD CLASS="optional" <c:if test="${hideLabel}">style="display:none;"</c:if> valign="top" title="${statusTooltip}"><c:out escapeXml="false" value="${label}" /><c:if test="${not empty label}">:</c:if></TD>
					<TD CLASS="tableItem" valign="top" title="${statusTooltip}">
						<c:choose>
							<c:when test="${task.groupingItem}">
								<spring:message code="issue.status.na.label" text="n/a"/>
							</c:when>
							<c:otherwise>
								<c:out escapeXml="false" value="${decorated.status}" default="--" />

								<c:if test="${empty taskRevision.baseline && empty taskRevision.version}">	<%-- don't show transition for baselines and versions --%>
									<img class="menuArrowDown menu-trigger" src="<c:url value='/images/space.gif'/>"/>
									<span class="menu-container"></span>
								</c:if>
							</c:otherwise>
						</c:choose>
					</TD>
				</c:when>

				<%-- item priority --%>
				<c:when test="${label_id == PRIORITY_ID}">
					<%	tableCellCounter.insertNewRow(); %>

					<TD CLASS="optional" <c:if test="${hideLabel}">style="display:none;"</c:if> valign="top" title="${tooltip}"><c:out escapeXml="false" value="${label}" /><c:if test="${not empty label}">:</c:if></TD>
					<TD CLASS="tableItem fieldColumn fieldId_${label_id}" valign="top"><c:out escapeXml="false" value="${decorated.priorityWithIcon}" default="--" /></TD>
				</c:when>

				<%-- resolution in the test run trackers --%>
				<c:when test="${label_id == 15 && task.tracker.testRun}">
					<%	tableCellCounter.insertNewRow(); %>

					<TD CLASS="optional" <c:if test="${hideLabel}">style="display:none;"</c:if> valign="top" title="${tooltip}"><c:out escapeXml="false" value="${label}" /><c:if test="${not empty label}">:</c:if></TD>
					<TD CLASS="tableItem fieldColumn fieldId_${label_id}" valign="top"><c:out escapeXml="false" value="${decorated.resolutions}" default="--" /></TD>
				</c:when>

				<%-- choice fields --%>
				<c:when test="${fieldLayout.choiceField}">
					<%	tableCellCounter.insertNewRow(); %>

					<td class="optional" <c:if test="${hideLabel}">style="display:none;"</c:if> valign="top" title="${tooltip}"><c:out escapeXml="false" value="${label}" /><c:if test="${not empty label}">:</c:if></td>

					<td class="tableItem hideLongListOfElements fieldColumn fieldId_${label_id}" valign="top" colspan="${xcolspan}" style="white-space: normal;">
						<div class="choice-field-wrapper">
							<c:out escapeXml="false" value="<%= decorated.getReferences(fieldLayout) %>" default="--"/>
							<c:if test="${label_id == ASSIGNED_TO_ID and !empty task.assignedAt}">
								<tag:formatDate value="${task.assignedAt}" />
							</c:if>
						</div>
					</td>
				</c:when>

				<%-- color fields --%>
				<c:when test="${fieldLayout.colorField}">
					<%	tableCellCounter.insertNewRow(); %>

					<td class="optional" <c:if test="${hideLabel}">style="display:none;"</c:if> valign="top" title="${tooltip}"><c:out escapeXml="false" value="${label}" /><c:if test="${not empty label}">:</c:if></td>

					<td class="tableItem fieldColumn fieldId_${label_id}" valign="top" COLSPAN="${xcolspan}" style="white-space: normal;">
						<c:set var="colorValue" value="<%= decorated.getRenderValue(fieldLayout) %>" />
						<c:if test="${empty colorValue}">
							<c:set var="colorValue" value="--" />
						</c:if>
						${colorValue}
					</td>
				</c:when>

				<%-- url fields --%>
				<c:when test="${fieldLayout.urlField}">
					<%	tableCellCounter.insertNewRow(); %>

					<td class="optional" <c:if test="${hideLabel}">style="display:none;"</c:if> valign="top" title="${tooltip}"><c:out escapeXml="false" value="${label}" /><c:if test="${not empty label}">:</c:if></td>

					<td class="tableItem fieldColumn fieldId_${label_id}" valign="top" COLSPAN="${xcolspan}" style="white-space: normal;">
						<c:set var="urlValue" value="<%= decorated.getRenderValue(fieldLayout) %>" />
						<c:if test="${empty urlValue}">
							<c:set var="urlValue" value="--" />
						</c:if>
						${urlValue}
					</td>
				</c:when>

				<%-- user defined fields --%>
				<c:when test="${fieldLayout.userDefined}">
					<%	tableCellCounter.insertNewRow(); %>

					<TD CLASS="optional" <c:if test="${hideLabel}">style="display:none;"</c:if> valign="top" title="${tooltip}"><c:out escapeXml="false" value="${label}" /><c:if test="${not empty label}">:</c:if></TD>

					<TD CLASS="tableItem fieldColumn fieldId_${label_id}<c:if test="${fieldLayout.isWikiTextField()}"> thumbnailImages thumbnailImages300px</c:if>" valign="top" COLSPAN="${xcolspan}" style="white-space: normal;">
						<c:out escapeXml="false" value="<%= decorated.getRenderValue(fieldLayout) %>" default="--" />
					</TD>
				</c:when>

				<c:when test="${fieldLayout.label == TEST_CASES_FIELD_NAME}">
					<%-- hiding Test Cases table, will show test cases as it looks on editor... --%>
				</c:when>

				<c:when test="${fieldLayout.label == TEST_STEPS_FIELD_NAME}">
					<%-- hiding Test Steps table and moving it to a separate tab --%>
				</c:when>

				<c:when test="${fieldLayout.labelWithoutBR == 'Test Step Results'}">
					<c:set var="testStepResultsTable" value="<%= decorated.getRenderValue(fieldLayout, true) %>"></c:set>
				</c:when>

				<c:when test="${fieldLayout.labelWithoutBR == 'Test Cases'}">
					<c:set var="testCasesTable" value="<%= decorated.getRenderValue(fieldLayout, true) %>"></c:set>
				</c:when>

				<%-- embedded tables --%>
				<c:when test="${fieldLayout.table}">
					<%	tableCellCounter.insertNewRow(); %>

					<TD CLASS="optional" <c:if test="${hideLabel}">style="display:none;"</c:if> valign="top" title="${tooltip}"><c:out escapeXml="false" value="${label}" /><c:if test="${not empty label}">:</c:if></TD>

					<TD CLASS="tableItem thumbnailImages" COLSPAN="${xcolspan}" style="white-space: normal;">
						<%= decorated.getRenderValue(fieldLayout, true) %>
					</TD>
				</c:when>

				<c:otherwise>

				<%-- Submitted by --%>
				<logic:equal name="label_id" value="<%=Integer.toString(TrackerLayoutLabelDto.SUBMITTED_BY_LABEL_ID)%>">
					<% tableCellCounter.insertNewRow(); %>
					<TD CLASS="optional" <c:if test="${hideLabel}">style="display:none;"</c:if> valign="top" title="${tooltip}"><c:out value="${label}" escapeXml="false" /><c:if test="${not empty label}">:</c:if></TD>

					<TD CLASS="tableItem" valign="top">
						<tag:userLink user_id="${task.submitter.id}" />
						<tag:formatDate value="${task.submittedAt}" />
					</TD>
				</logic:equal>

				<%-- Modified by --%>
				<logic:equal name="label_id" value="<%=Integer.toString(TrackerLayoutLabelDto.MODIFIED_BY_LABEL_ID)%>">
					<% tableCellCounter.insertNewRow();	%>
					<TD CLASS="optional" <c:if test="${hideLabel}">style="display:none;"</c:if> valign="top" title="${tooltip}"><c:out value="${label}" escapeXml="false" /><c:if test="${not empty label}">:</c:if></TD>

					<TD CLASS="tableItem" valign="top">
						<tag:userLink user_id="${task.modifier.id}" />
						<tag:formatDate value="${task.modifiedAt}" />
					</TD>
				</logic:equal>

				<%-- Start date --%>
				<logic:equal name="label_id" value="<%=Integer.toString(TrackerLayoutLabelDto.START_DATE_LABEL_ID)%>">
					<% tableCellCounter.insertNewRow();	%>
					<TD CLASS="optional" <c:if test="${hideLabel}">style="display:none;"</c:if> valign="top" title="${tooltip}"><c:out value="${label}" escapeXml="false" /><c:if test="${not empty label}">:</c:if></TD>

					<TD CLASS="tableItem fieldColumn fieldId_${label_id}" valign="top">
						<c:out escapeXml="false" value="${decorated.startDate}" default="--" />
					</TD>
				</logic:equal>

				<%-- End date --%>
				<logic:equal name="label_id" value="<%=Integer.toString(TrackerLayoutLabelDto.END_DATE_LABEL_ID)%>">
					<% tableCellCounter.insertNewRow();	%>
					<TD CLASS="optional" <c:if test="${hideLabel}">style="display:none;"</c:if> valign="top" title="${tooltip}"><c:out value="${label}" escapeXml="false" /><c:if test="${not empty label}">:</c:if></TD>

					<TD CLASS="tableItem fieldColumn fieldId_${label_id}" valign="top">
						<c:out escapeXml="false" value="${decorated.endDate}" default="--" />
					</TD>
				</logic:equal>

				<%-- Closed at --%>
				<logic:equal name="label_id" value="<%=Integer.toString(TrackerLayoutLabelDto.CLOSED_AT_LABEL_ID)%>">
					<% tableCellCounter.insertNewRow();	%>
					<TD CLASS="optional" <c:if test="${hideLabel}">style="display:none;"</c:if> valign="top"  title="${tooltip}"><c:out value="${label}" escapeXml="false" /><c:if test="${not empty label}">:</c:if></TD>

					<TD CLASS="tableItem" valign="top">
						<c:out escapeXml="false" value="${decorated.closedAt}" default="--" />
					</TD>
				</logic:equal>

				<%-- Story points --%>
				<logic:equal name="label_id" value="<%=Integer.toString(TrackerLayoutLabelDto.STORY_POINTS_LABEL_ID)%>">
					<% tableCellCounter.insertNewRow();	%>
					<TD CLASS="optional" <c:if test="${hideLabel}">style="display:none;"</c:if> valign="top" title="${tooltip}"><c:out value="${label}" escapeXml="false" /><c:if test="${not empty label}">:</c:if></TD>

					<TD CLASS="tableItem fieldColumn fieldId_${label_id}" valign="top">
						<c:out escapeXml="false" value="${decorated.storyPoints}" default="--" />
					</TD>
				</logic:equal>

				<%-- Spent effort --%>
				<logic:equal name="label_id" value="<%=Integer.toString(TrackerLayoutLabelDto.SPENT_H_LABEL_ID)%>">
					<% tableCellCounter.insertNewRow();	%>
					<TD CLASS="optional" <c:if test="${hideLabel}">style="display:none;"</c:if> valign="top" title="${tooltip}"><c:out value="${label}" escapeXml="false" /><c:if test="${not empty label}">:</c:if></TD>

					<TD CLASS="tableItem" valign="top">
						<c:out escapeXml="false" value="${decorated.spentMillis}" default="--" />
					</TD>
				</logic:equal>

				<%-- Estimated effort --%>
				<logic:equal name="label_id" value="<%=Integer.toString(TrackerLayoutLabelDto.ESTIMATED_H_LABEL_ID)%>">
					<% tableCellCounter.insertNewRow();	%>
					<TD CLASS="optional" <c:if test="${hideLabel}">style="display:none;"</c:if> valign="top" title="${tooltip}"><c:out value="${label}" escapeXml="false" /><c:if test="${not empty label}">:</c:if></TD>
					<TD CLASS="tableItem fieldColumn fieldId_${label_id}" valign="top">
						<c:out escapeXml="false" value="${decorated.estimatedMillis}" default="--" />
					</TD>
				</logic:equal>

				<%-- Spent/Estimated ratio --%>
				<logic:equal name="label_id" value="<%=Integer.toString(TrackerLayoutLabelDto.SPENT_ESTIMATED_H_LABEL_ID)%>">
					<% tableCellCounter.insertNewRow();	%>
					<TD CLASS="optional" <c:if test="${hideLabel}">style="display:none;"</c:if> valign="top" title="${tooltip}"><c:out value="${label}" escapeXml="false" /><c:if test="${not empty label}">:</c:if></TD>
					<TD CLASS="tableItem" valign="top">
						<c:out escapeXml="false" value="${decorated.spentEstimatedHours}" default="--" />
					</TD>
				</logic:equal>
				</c:otherwise>
			</c:choose> <%-- choose for reference fields --%>
		</c:if>
	</c:forEach>

</tr>

</table>

<c:if test="${not empty testStepResultsTable}">
	<div class="testStepResultsContainer thumbnailImages480px">
		<div class="testCase">
			${testCasesTable}
		</div>
		${testStepResultsTable}
	</div>
</c:if>

<spring:message var="label" code="issue.relationsBox.label" text="Traceability"/>
<ui:collapsingBorder id="relations-box" label="${label}" hideIfEmpty="false" open="false" cssClass="relations-box separatorLikeCollapsingBorder" onChange="onRelationsToggle">
	<spring:message code="ajax.loading" text="Loading..."/>
</ui:collapsingBorder>

<%-- removed last-10-runs tab
<c:if test="${fn:length(last10Runs) > 0}">
	<spring:message var="resultsLabel" code="issue.last10RunsBox.label" text="Results"/>
	<ui:collapsingBorder id="last10Runs-box" label="${resultsLabel}" hideIfEmpty="false" open="false" cssClass="relations-box separatorLikeCollapsingBorder">
		<c:forEach items="${last10Runs }" var="run">
			<c:url var="url" value="${run.delegate.urlLink }"/>
			<spring:message code="${run.testRunResult.labelCode }" var="resultLabel"/>

			<tag:formatDate value="${run.delegate.closedAt}" var="closedAtFormatted"/>
			<c:set var="userNames" value=""/>
			<c:forEach items="${run.delegate.assignedTo }" var="assignee" varStatus="status">
				<c:if test="${!status.first }">
					<c:set var="userNames" value="${userLinks },"/>
				</c:if>
				<c:set var="userNames" value="${userLinks }${assignee.name }"/>
			</c:forEach>

			<a class="resultBox ${run.testRunResult.CSSClass }" href="${url }" target="_blank"></a>
			<div class="testRunInfo" style="display:none">
				<c:url var="testRunUrl" value="${run.delegate.urlLink}"/>
				<a href="${testRunUrl}" target="_blank"><c:out escapeXml="true" value="${run.delegate.name }"/></a>
				<p>
					<spring:message code="tracker.coverage.browser.last10Runs.run.tooltip" arguments="${resultLabel},${userNames},${closedAtFormatted},${run.runtimeFormatted}"/>
				</p>
			</div>
		</c:forEach>
	</ui:collapsingBorder>
</c:if>
--%>

<c:if test="${testParametersOverviewModel != null || testParametersOverviewModelLazyLoading}">
	<tag:catch>
		<c:choose>
			<c:when test="${testParametersOverviewModel != null}">
				<c:set var="numParams" value="${fn:length(testParametersOverviewModel.usedParameters)}" />
				<spring:message var="label" code="testing.parameters.label" arguments="(${numParams})" />
				<c:set var="showParamBlock" value="${numParams > 0}"/>
				<c:set var="testParametersOverview">
					<jsp:include page="/testmanagement/parameters/testParametersOverview.jsp" flush="true"/>
				</c:set>
			</c:when>
			<c:otherwise>
				<spring:message var="label" code="testing.parameters.label" arguments=" " />
				<c:set var="showParamBlock" value="${false}"/>
				<c:set var="testParametersOverview">
					<img title="<spring:message code='ajax.loading' />" src="<ui:urlversioned value='/images/ajax_loading_horizontal_bar.gif'/>" />
					<script type="text/javascript">
						function loadTestParametersOverviewWithAjax() {
							var $paramsOverviewPart = $("#paramsOverviewPart");
							if ($paramsOverviewPart.hasClass("alreadyLoaded")) {
								console.log("Test Parameters are already loaded!");
								return;
							}
							$paramsOverviewPart
								.addClass("alreadyLoaded")
								.load(contextPath + "/testmanagement/showTestParametersOverview.spr?testSetId=${task.id}");
						}
					</script>
				</c:set>
			</c:otherwise>
		</c:choose>

		<ui:collapsingBorder id="parametersPart" label="${label}" hideIfEmpty="false" open="${showParamBlock}" cssClass="scrollable separatorLikeCollapsingBorder thumbnailImages thumbnailImages800px" toggle="#paramsOverviewPart"
			onChange="${testParametersOverviewModelLazyLoading ? 'loadTestParametersOverviewWithAjax' :'' }">
		</ui:collapsingBorder>
		<div id="paramsOverviewPart" style="${showParamBlock ? '' : 'display:none;'}">
			${testParametersOverview}
		</div>
	</tag:catch>
</c:if>

<c:set var="fieldLayout" value="${layout.mapTable[DESCRIPTION_LABEL_ID]}" />
<c:if test="${!(empty fieldLayout.label or fieldLayout.hidden)}">
	<spring:message var="label" code="tracker.field.${fieldLayout.labelWithoutBR}.label" text="${fieldLayout.labelWithoutBR}"/>
	<c:set var="tooltip" value="${label}" />
	<c:if test="${empty missingEssentialFields && (! empty testRun) && testRun.testCaseRun}">
		<%-- for TestCaseRuns the description is called "Conclusion" --%>
		<spring:message var="label" code="testrun.field.conclusion" />
		<spring:message var="tooltip" code="testrun.field.conclusion.hint" />
	</c:if>

	<c:set var="itemDescription"><%=decorated.getDescription() %></c:set>
	<c:set var="emptyDescription" value="${itemDescription == '' || itemDescription == '--'}" />
	<ui:collapsingBorder id="descriptionPart" label="${label}" title="${tooltip}" hideIfEmpty="false" open="${!emptyDescription}" cssClass="descriptionBox scrollable separatorLikeCollapsingBorder officeEdit thumbnailImages thumbnailImages800px">
		<div class="fieldColumn fieldId_${DESCRIPTION_LABEL_ID}${isItemEditable ? ' inlineEditEnabled' : ''}" data-item-id="${task.id}" data-item-name="${itemName}">
			<c:out value="${itemDescription}" escapeXml="false"/>
		</div>
	</ui:collapsingBorder>
</c:if>
</c:if>

<c:if test="${!param.isPopup && (canViewStaff || canViewComment || canViewAttachment || canViewAssociation || canViewEscalation || canViewScmHistory || canViewHistory)}">
	<spring:message var="label" code="issue.details.label" text="Details"/>
	<ui:collapsingBorder label="${label}" cssClass="descriptionBox scrollable separatorLikeCollapsingBorder"
		open="${(! detailsClosed && (!isTestRun))}" onChange="${isTestRun ? '' : 'onDetailsToggle'}"
	>
		<div class="collapsingBorder_content padding-left-none">
			<c:if test="${canViewAssociation}">
				<%-- Get the data here, because "<tab:tabContainer" would execute it twice. --%>
				<tag:itemDependecy var="itemDependency" item_id="${taskRevision.id}" item_type_id="${taskRevision.typeId}" item_rev="${taskRevision.baseline.id}" limit="${limit}" scope="request" />
			</c:if>

			<c:if test="${not empty highlightComment}">
   				<c:set var="commentUrl" value="task-details-attachments" />
			</c:if>

			<c:if test="${not empty param.childrenTab}">
				<c:set var="commentUrl" value="task-details-subtasks" />
			</c:if>

			<tab:tabContainer id="task-details" skin="cb-box" jsTabListener="onTabChange" selectedTabPaneId="${commentUrl}">
				<c:if test="${testSetTestCases != null}">
					<spring:message var="label" code="testset.editor.testcases.or.testsets.label" />
					<c:set var="labelWithCount" value="${ui:getTabLabelWithCount(label, fn:length(testSetTestCases))}" />
					<tab:tabPane id="testSetTestCases" tabTitle="${labelWithCount}">
					  <tag:catch>
						<c:set var="testCases" value="${testSetTestCases}" scope="request" />
						<div class="actionBar" style="margin-bottom: 5px;"></div>
						<jsp:include page="/testmanagement/testSetsTestCases.jsp?editable=false&openInSameWindow=true" flush="true"/>
					  </tag:catch>
					</tab:tabPane>
				</c:if>

				<c:if test="${testRunTestCases != null}">
					<spring:message var="label" code="testset.editor.testcases.or.testsets.label" />
					<c:set var="labelWithCount" value="${ui:getTabLabelWithCount(label, fn:length(testRunTestCases))}" />
					<tab:tabPane id="testRunTestCases" tabTitle="${labelWithCount}">
					   <tag:catch>
						<c:set var="testCases" value="${testRunTestCases}" scope="request" />
						<jsp:include page="/testmanagement/testRunTestCases.jsp" flush="true"/>
					   </tag:catch>
					</tab:tabPane>
				</c:if>

				<%-- shows the test steps table (if available) --%>
				<c:if test="${testSteps != null}">
					<spring:message var="label" code="tracker.field.Test Steps.label" />
					<c:set var="labelWithCount" value="${ui:getTabLabelWithCount(label, fn:length(testSteps))}" />
					<tab:tabPane id="testStepsTab" tabTitle="${labelWithCount}">
					   <tag:catch>
						<div class="actionBar" style="margin-bottom: 5px;"></div>
						<ui:testSteps owner="${task}" tableId="testSteps" testSteps="${testSteps}" readOnly="true"/>
					   </tag:catch>
					</tab:tabPane>
				</c:if>

				<%-- test case runs --%>
				<c:if test="${hasTestRuns && !task.groupingItem}">
					<spring:message var="testRunsLabel" code="tracker.Test Runs.label" text="Test Runs"/>
					<tab:tabPane id="testRuns" tabTitle="${testRunsLabel}">
					   <tag:catch>
						<jsp:include page="/testmanagement/testRunHistoryLazyLoad.jsp" flush="true"/>
					   </tag:catch>
					</tab:tabPane>

					<!-- showing TestCase's reported bugs -->
					<spring:message var="reportedBugsLabel" code="tracker.field.Reported as.label" text="Reported bug(s)"/>
					<tab:tabPane id="reportedBugs" tabTitle="${reportedBugsLabel}">
					   <tag:catch>
						<div id="loadTestCaseBugs" >
							<script type="text/javascript">
								$(function(){reportedBugsLazyLoad("#loadTestCaseBugs", '${task.id}')});
							</script>
						</div>
					   </tag:catch>
					</tab:tabPane>
				</c:if>

<%--
				<c:if test="${testParametersOverviewModel != null}">
					<spring:message var="label" code="testing.parameters.label" arguments="(${fn:length(testParametersOverviewModel.usedParameters)})" />
					<tab:tabPane id="testParametersTab" tabTitle="${label}">
					   <tag:catch>
						<jsp:include page="/testmanagement/parameters/testParametersOverview.jsp" flush="true"/>
					   </tag:catch>
					</tab:tabPane>
				</c:if>
--%>

				<c:if test="${canViewStaff}">
					<spring:message var="label" code="tracker.field.Staff.label" text="Staff"/>
					<c:set var="labelWithCount" value="${ui:getTabLabelWithCount(label, itemStaffCount)}" />
					<tab:tabPane id="task-details-staff" tabTitle="${labelWithCount}">
					   <tag:catch>
						<jsp:include page="itemStaff.jsp" flush="true" />
					   </tag:catch>
					</tab:tabPane>
				</c:if>

				<c:if test="${canViewAttachment}">
					<c:set var="attachmentCount" value="${fn:length(itemAttachments)}" />
					<c:if test="${not empty attachmentFullCount}">
						<c:set var="attachmentCount" value="${attachmentFullCount}" />
					</c:if>
					<spring:message var="commentsAttachmentsTitle" code="document.commentsAndAttachments.tab.title" text="Comments &amp; Attachments" />

                    <c:set var="commentCountContainer" value='<span id="commentCountContainer"></span>' />
                    <c:if test="${attachmentCount gt 0}">
                        <c:set var="commentCountContainer"><span id="commentCountContainer">(${attachmentCount})</span></c:set>
                    </c:if>

					<tab:tabPane id="task-details-attachments" tabTitle="${commentsAttachmentsTitle} ${commentCountContainer}">
					   <tag:catch>
						<jsp:include page="itemAttachments.jsp" flush="true" >
							<jsp:param name="showActionBar" value="${headRevision}" />
						</jsp:include>
					   </tag:catch>
					</tab:tabPane>
				</c:if>

				<c:if test="${canViewAssociation}">
					<spring:message var="label" code="associations.title" text="Associations"/>
                    <c:set var="labelWithCount" value="${ui:getTabLabelWithCount(label, itemDependency.numberOfDependencies)}" />
					<tab:tabPane id="task-details-associations" tabTitle="${labelWithCount}">
					   <tag:catch>
						<jsp:include page="itemAssociations.jsp" flush="true" />
					   </tag:catch>
					</tab:tabPane>
				</c:if>

				<c:if test="${canViewReviews || not empty itemReviewStats}">
					<spring:message var="label" code="issue.reviews.label" text="Reviews"/>
                    <c:set var="labelWithCount" value="${ui:getTabLabelWithCount(label, fn:length(itemReviews) + (not empty itemReviewStats ? fn:length(itemReviewStats) : 0))}" />
					<tab:tabPane id="task-details-reviews" tabTitle="${labelWithCount}">
					   <tag:catch>
						<jsp:include page="itemReviews.jsp" flush="true" />
					   </tag:catch>
					</tab:tabPane>
				</c:if>

				<c:if test="${canViewChildren && (!isTestRun)}">
					<spring:message var="label" code="${isRelease ? 'tracker.field.Sprints.label' : 'tracker.field.Children.label'}"/>
                    <c:set var="labelWithCount" value="${ui:getTabLabelWithCount(label, subTasks.fullListSize)}" />
					<tab:tabPane id="task-details-subtasks" tabTitle="${labelWithCount}">
					   <tag:catch>
						<jsp:include page="itemSubTasks.jsp" flush="true" />
					   </tag:catch>
					</tab:tabPane>
				</c:if>

				<c:if test="${canViewReferringIssues}">
					<tab:tabPane id="task-referring-issues" tabTitle="${referringIssuesTitle}">
					  <tag:catch>
						<jsp:include page="itemReferringIssues.jsp" flush="true" />
					  </tag:catch>
					</tab:tabPane>
				</c:if>

				<%-- SCM History --%>
				<c:if test="${canViewScmHistory}">
					<spring:message var="label" code="SCM commits" text="SCM Commits"/>
					<c:if test="${not empty scmHistorySize && scmHistorySize > 0}">
						<c:set var="label" value="${label} (${scmHistorySize})"></c:set>
					</c:if>
					<tab:tabPane id="task-details-commits" tabTitle="${label}">
					   <tag:catch>
							<div class="actionBar" style="margin-bottom: 5px;"></div>
							<div id="scmHistory" class="trackerItemDetailsTabContainer"></div>
					   </tag:catch>
					</tab:tabPane>
				</c:if>

				<c:if test="${canViewHistory}">
					<c:set var="historyCount" value="${fn:length(itemHistory)}" />
					<c:if test="${not empty historyFullCount && historyFullCount > 0}">
						<c:set var="historyCount" value="${historyFullCount}" />
					</c:if>
					<spring:message var="label" code="issue.history.title" text="History"/>
					<c:set var="labelWithCount" value="${ui:getTabLabelWithCount(label, historyCount)}" />
					<tab:tabPane id="task-details-history" tabTitle="${labelWithCount}">
						<tag:catch>
							<div class="actionBar" style="margin-bottom: 15px;"></div>
							<div id="itemHistory">
								<jsp:include page="itemHistory.jsp" flush="true" />
							</div>
						</tag:catch>
					</tab:tabPane>
				</c:if>

				<c:if test="${canViewBaselines}">
					<spring:message var="label" code="document.baselines.tab.title" text="Baselines" />
					<c:set var="labelWithCount" value="${ui:getTabLabelWithCount(label, fn:length(itemBaselines))}" />
					<tab:tabPane id="task-details-baselines" tabTitle="${labelWithCount}">
						<tag:catch>
							<div class="actionBar" style="margin-bottom: 5px;"></div>
							<jsp:include page="itemBaselines.jsp" flush="true" />
						</tag:catch>
					</tab:tabPane>
				</c:if>

				<c:set var="branchCount" value="${fn:length(itemVariants) }"></c:set>
				<c:if test="${canViewBranches and branchCount > 1}">
					<spring:message var="label" code="issue.branches.title" text="Branches" />
					<c:set var="labelWithCount" value="${ui:getTabLabelWithCount(label, branchCount)}" />
					<tab:tabPane id="task-details-branches" tabTitle="${labelWithCount}">
						<tag:catch>
							<div class="actionBar" style="margin-bottom: 5px;"></div>
							<jsp:include page="itemBranches.jsp" flush="true" />
						</tag:catch>
					</tab:tabPane>
				</c:if>

                <%-- Escalation schedule --%>
                <c:if test="${canViewEscalation and fn:length(itemEscalations) gt 0}">
                    <spring:message var="label" code="issue.escalations.title" text="Escalations"/>
                    <tab:tabPane id="task-escalation-schedule" tabTitle="${label} (${fn:length(itemEscalations)})">
                       <tag:catch>
                        <div class="actionBar" style="margin-bottom: 10px;"></div>
                        <jsp:include page="itemEscalationSchedule.jsp" flush="true" />
                       </tag:catch>
                    </tab:tabPane>
                </c:if>

				<spring:message var="label" code="search.results.all" text="All"/>
				<c:if test="${not empty allSize && allSize > 0}">
					<c:set var="label" value="${label} (${allSize})"></c:set>
				</c:if>
				<tab:tabPane id="task-details-all" tabTitle="${label}">
				   <tag:catch>
						<div class="actionBar" style="margin-bottom: 5px;"></div>
						<div id="allHistory" class="trackerItemDetailsTabContainer"></div>
				   </tag:catch>
				</tab:tabPane>
			</tab:tabContainer>
		</div>
	</ui:collapsingBorder>

	<c:if test="${isTestRun}">
		<c:set var="testRunItem" value="${task}" scope="request" />
		<jsp:include page="/testmanagement/testRunResults.jsp" flush="true"/>
	</c:if>

</c:if>

</div>

<%
} finally {
	if (taskRevision.getBaseline() != null) {
		ProviderUtils.popPageContext(taskRevision.getBaseline());
	}
}
%>

<script type="text/javascript">
$(function(){
	var initCodeReview = function () {
		codeReview.reset();
		codeReview.init({
			"entityTypeId": <%=GroupType.TRACKER_ITEM%>,
			"entityId": ${task.id}
		});
	};

	initCodeReview();

	$(document).on("diffsRendered", null, function () {
		initCodeReview();
	});

	$(".propertyTable").on("click", ".menuArrowDown", function (event) {
		var $trigger = $(event.target).next(".menu-container");
		$(".tableItem .menu-downloaded .yuimenu").hide();
		setTimeout(function() {
			$trigger.trigger("codebeamer.menuloaded");
		}, 1);

		buildAjaxTransitionMenu($trigger, {
			'task_id': "${task.id}",
			'cssClass': 'inlineActionMenu transition-action-menu',
			'builder': 'trackerItemTransitionsOverlayActionsMenuBuilder'
		});

		$trigger.on("codebeamer.menuloaded", function () {
			var left = $(".tableItem > .menuArrowDown").offset().left;
			$(".tableItem .yuimenubaritem.first-of-type .menuArrowDown").css({"left": left});
			$(".tableItem .menu-downloaded .yuimenu").css({"left": left + 3, "top": ""}).show();
		});
	});

	// initialize the tooltips for the test run result boxes
	$("#last10Runs-box").tooltip({
		items: ".resultBox",
		tooltipClass : "tooltip contextHelpTooltip",
		position: {my: "left top+5" , collision: "flipfit"},
		content: function() {
			var $box = $(this);
			var tooltip = $box.next();

		 	var result = $("<div>").html(tooltip.html());

		 	return result;
		},
		close: function(event, ui) {
			jquery_ui_keepTooltipOpen(ui);
		}
	});

	codebeamer.ReferenceSettingBadges.init($(".propertyTable"));
	codebeamer.ReferenceSettingBadges.init($("#referringIssues"));

    <c:if test="${not empty branchSwitchWarningTargetName}">
    	showBranchSwitchWarning("${ui:escapeJavaScript(branchSwitchWarningTargetName)}", ${branchSwitchWarningTargetId}, ${branchSwitchWarningBranchesJSON});
    </c:if>


    // reload the page after the suspected badge was cleared
    $("body").on("codebeamer.clearSuspect", function (event, taskId) {
	  location.reload();
	});
});

$(hideLongListOfElements)
</script>

