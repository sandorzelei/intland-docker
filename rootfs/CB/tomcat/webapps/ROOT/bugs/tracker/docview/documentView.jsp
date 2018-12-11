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
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="wysiwyg" prefix="wysiwyg" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<script src="<ui:urlversioned value='/js/inlineIssueRating.js'/>"></script>
<script type="text/javascript" src="<ui:urlversioned value='/js/suspectedLinkBadge.js'/>"></script>
<script type="text/javascript" src="<ui:urlversioned value='/js/extendedDocumentView.js'/>"></script>

<script type="text/javascript" src="<ui:urlversioned value='/bugs/tracker/includes/embeddedTable.js'/>"></script>
<script type="text/javascript" src="<ui:urlversioned value='/bugs/addUpdateTask.js'/>"></script>
<script type="text/javascript" src="<ui:urlversioned value='/js/colorPicker.js'/>"></script>

<link rel="stylesheet" href="<ui:urlversioned value="/bugs/addUpdateTask/addUpdateTask.css" />" type="text/css" media="all" />
<link rel="stylesheet" type="text/css" href="<ui:urlversioned value='/js/jquery/dragtable/dragtable.css' />" />

<wysiwyg:froalaConfig />

<c:if test="${canCreateIssue && param.mode == 'create'}">
	<%-- opening the document view in 'create' mode --%>
	<script type="text/javascript">
		$(function(){
			$("#treePane").bind("loaded.jstree", function() {
				$("#panes").layout().open("west");
				var $root = $("#treePane li[type=tracker]");
				$.jstree.reference("#treePane").open_node($root);
				// wait until the tree coloring is finished
				setTimeout(function(){trackerObject.addRequirement($root, "last", false)}, "100");
			});
		});
	</script>
</c:if>

<script type="text/javascript">
	$(function(){
		var panes = $("#panes");
		panes.on("codebeamer.resizeEnd", function () {
			var $panes = $("#panes");
			$panes.height($panes.height() + 10);
		});

		$("#treePane").bind("loaded.jstree", function() {
			var state = panes.layout().state;

			var $middleHeader = $("#middleHeaderDiv");
			if (state && state.west.isClosed) {
				$middleHeader.addClass('westClosed');
			}

			if (state && state.east.isClosed) {
				$middleHeader.addClass('eastClosed');
			}
		});
	});
</script>

<%--
	putting css here (and not in documentView.jsp), because IE ignores if it is loaded via ajax
	wrapping this to the <head> tag move that piece to the html head by the sitemesh decorator
--%>

<c:if test="${empty extended}">
	<c:set var="extended" value="${empty param.extended  ? 'false' : param.extended == 'true' }"></c:set>
</c:if>

<head>
	<link rel="stylesheet" href="<ui:urlversioned value='/stylesheet/documentView.less' />" type="text/css" media="all" />

	<c:if test="${'true' == extended }">
		<link rel="stylesheet" href="<ui:urlversioned value='/stylesheet/extendedDocumentView.less' />" type="text/css" media="all" />
	</c:if>
	<link rel="stylesheet" href="<ui:urlversioned value='/stylesheet/rating.less' />" type="text/css" media="all" />
</head>

<c:set var="subtreeRoot" ><c:out value='${subtreeRootId}'/></c:set>

<spring:message code="tracker.type.${tracker.type.name}.create.label" var="newRequirementName" text="New requirement"/>
<c:set var="baselineId">${param.revision}</c:set>
<c:set var="baselineParameter">&baseline_id=${baselineId}</c:set>
<c:set var="branchParameter">&branchId=${branch.id}</c:set>

<c:set var="branchOrTrackerId" value="${empty branch ? tracker.id : branch.id }"/>

<script type="text/javascript">

	function showBaselines() {
		var dialog =
			inlinePopup.show("${pageContext.request.contextPath}/branching/trackerBaselinesAndBranches.spr" +
					"?mode=documentView&openEditableView=${extended}&trackerId=${tracker.id}${empty branch ? '' : branchParameter}${empty baselineId ? '' : baselineParameter}", {geometry: 'large'});
	}

	var editable = ${empty baseline && (empty canEdit || canEdit)};
	var populateTree = function (n) {
		var parameters = {"project_id": "${tracker.project.id}",
			"nodeId": n.attr ? n.attr("id") : "",
			"type": n.attr ? n.attr("type") : "",
			"tracker_id": "${branchOrTrackerId}",
			"revision": "${baseline.id}",
			"view_id": "${selectedView}"
		};

		// for showing a subtree only we need to set the type to tracker_item and the nodeId
		if("${subtreeRoot}") {
			parameters["type"] = "tracker_item";
			parameters["buildSubtree"] = true;

			if ("${subtreeRoot}" == "-1") {
				parameters["showRoot"] = true;
				parameters["buildSubtree"] = false;
			} else {
				parameters["nodeId"] = "${subtreeRoot}";
				parameters["subtreeRoot"] = "${subtreeRoot}";
			}
		}

		var filterParams = getFilterParameters();
		if (filterParams) {
			$.extend(parameters, filterParams);
		}

		var cbQL = null;
		if (codebeamer.ReportSupport) {
			var containerId = $(".reportSelectorTag").attr("id");
			var initialCbQL = codebeamer.ReportSupport.getInitialCbQLForTree(containerId);
			cbQL = initialCbQL != null ? initialCbQL : codebeamer.ReportSupport.getCbQl(containerId);
			parameters["cbQL"] = cbQL;
			codebeamer.ReportSupport.clearInitialCbQLForTree(containerId);
			var specialFilterValues = codebeamer.ReportSupport.getSpecialFilterValues(containerId);
			parameters = $.extend(parameters, specialFilterValues);
		}

		return parameters;
	};

	var trackerObject = new codebeamer.trackers.Tracker({
		"id": "${branchOrTrackerId}",
		"originalTrackerId": "${tracker.id}",
		"projectId": "${tracker.project.id}",
		"revision": "${baseline.id}",
		"docViewAjaxUrl": "/trackers/ajax/getDocumentView.spr?mode=${param.mode}&subtreeRoot=${subtreeRoot == null ? param.subtreeRoot : subtreeRoot}" +
			"&pageSize=${param.pageSize}&comparedBaselineId=${param.comparedBaselineId}&buildSubtree=${empty subtreeRoot or subtreeRoot == -1 ? false : true}",
		"contextPath": "${pageContext.request.contextPath}",
		"selectedView": "${not empty selectedView ? selectedView : -11}",
		"treePaneId": "treePane",
		"editable": editable,
		"clipboardEmpty": ${clipboardEmpty},
		"canCreateIssue": ${canCreateIssue},
		"canDeleteIssue": ${canDeleteIssue},
		"canCreateFolder": ${canCreateFolder},
		"canMassEdit": ${canMassEdit},
		"newRequirementName": "${newRequirementName}",
		"isRequirementTracker": ${tracker.requirement},
		"exportToWordUrl": "${exportToWordUrl}",
		"requiredFieldWithoutDefault": ${requiredFieldWithoutDefault},
		"canViewAssociations": ${canViewAssociations},
		"canCreateAssociations": ${canCreateAssociations},
		"showSubitemCounts": ${showSubitemCounts},
		"synchronizeTree": ${synchronizeTree}
		<c:if test="${not empty pageSize}">
		, "pageSize": ${pageSize}
		</c:if>
		<c:if test="${not empty branch}">
		, "branchId": ${branch.id}
		, "originalTrackerId": ${originalTrackerId}
		</c:if>
		<c:if test="${not empty subtreeRoot}">
		, "subtreeRoot": ${subtreeRoot}
		</c:if>
		<c:if test="${not empty extended}">
		, "extended": ${extended}
		</c:if>
		<c:if test="${not empty riskTrackerId}">
		, "riskTrackerId": ${riskTrackerId}
		</c:if>
		<c:if test="${not empty defaultDescription}">
		, "defaultDescription": "${defaultDescription}"
		</c:if>
		<c:if test="${not empty defaultName}">
		, "defaultName": "${defaultName}"
		</c:if>
		<c:if test="${not empty availableTestRunTrackersJSON}">
		, "availableTestRunTrackers": <c:out value="${availableTestRunTrackersJSON}" escapeXml="false"/>
		</c:if>
		<c:if test="${!empty defaultTestPlanTracker }">
		,
		"canEditTestcases": ${canCreateTestCase && canEditSubject},
		"canCreateTestCase": ${canCreateTestCase},
		"testPlanHasRequiredField": ${testPlanHasRequiredField}
		</c:if>
		<c:if test="${!empty rpeDisabled }">
		,
		"rpeDisabled": "${rpeDisabled}"
		</c:if>
	});
	trackerObject.init();

	$(document).ready(function () {
		trackerObject.bindEventHandlers();
		var panes = $("#panes");

		initInlineRating(panes);
		panes.on("afterRatingSubmitted", ".rating-container", function (event, stats, rating) {
			var $rating = $(this);
			var issueId = $rating.data('issueid');
			trackerObject.reloadIssue(issueId);

			trackerObject.showIssueProperties(issueId, trackerObject.config.id, $('#issuePropertiesPane'), trackerObject.config.editable, true);
		});

		// clears the middle panel filter when the user filters in the tree
		$("#go_treePane").click(function() {
			var text = $("#searchBox_treePane").val();

			var $widget = $("#intervalSelector");

			var $checked = $(".ui-multiselect-menu").find(".checked").siblings("[type=checkbox]");
			var checkedValues = $checked.val();
			if (checkedValues) {
				// if there are checked values in the center panel filter clear them
				// clear the filter selector and disable/enable it
				$(".checker.checked").removeClass("checked");

				$widget.multiselect("uncheckAll");

				//clearFilters();
			}

			if (text.length <= 2 || text == i18n.message("association.search.as.you.type.label")) {
				$widget.multiselect("enable");
			} else {
				$widget.multiselect("disable");
			}
		});

		// prevent the mouseout event from propagating to the layout because it causes some js errors
		$("select#selectedView").on("mouseout mouseover", null, function(event){event.stopPropagation();})

		codebeamer.NavigationAwayProtection.init(false, $('#issuePropertiesPane'));
	});

	var canCreateIssue = ${canCreateIssue && (empty baseline)};
	// initialize the hotkeys
	var disabledModules = [];
	if (!canCreateIssue) {
		disabledModules.push("create");
	}
	var hotkeys = new codebeamer.DocumentViewHotkeys({disabledModules: disabledModules});

	var treeConfig = {
			updateDropIcon: true
	};
</script>

<c:if test="${not empty baseline}">
	<c:set var="rev" value="${baseline.id}"/>
</c:if>

<script type="text/javascript" src="<ui:urlversioned value='/js/treeViewFullTextSearch.js'/>"></script>

<c:url var="treeSettingsUrl" value="/trackers/viewTreeConfig.spr?trackerId=${branchOrTrackerId}&revision=${rev}&view_id=${param.view_id}&branchId=${branch == null ? '' : branch.id }&openEditableView=${extended }"/>
<ui:treeControl containerId="treePane" url="${pageContext.request.contextPath}/trackers/ajax/tree.spr"
	layoutContainerId="panes" rightPaneId="rightPane" editable="${revision == null && baseline == null}" headerDivId="headerDiv" populateFnName="populateTree"
	nodeClickedHandler="trackerObject.nodeClicked" initTreeOnPageLoad="${not empty baseline}"
	nodeMovedHandler="trackerObject.nodeMoved" checkMoveFnName="trackerObject.checkMove" externalDropHandler="trackerObject.externalDrop"
	checkExternalDrop="trackerObject.checkExternalDrop" populateContextMenuFnName="trackerObject.populateContextMenu"
	settingsUrl="${treeSettingsUrl }"
	revision="${rev}" eventHandlerScope="trackerObject" searchConfig="${baseline == null ? 'codebeamer.fullTextSearch.searchConfig' : ''}" config="treeConfig"
	/>

<script type="text/javascript">

	jQuery(function($) {

		codebeamer.documentViewTrackerId = ${branchOrTrackerId};

		function initTree(t) {
			if (!t.jstree) {
				t.init(); // initialize the tree if it is not initialized yet
			}
		}

		var treePane = $("#treePane");
		treePane.bind("loaded.jstree after_open.jstree refresh.jstree", function (event, data) {
			setTimeout(function () {
				//codebeamer.trackers.markSuspectedNodes(data.node);
				//codebeamer.trackers.markCopyNodes("treePane", data.node);
				codebeamer.trackers.markSubtreeRoot();
			}, 1000);
		});

		treePane.bind("search.jstree clear_search.jstree", function (event, data) {
			setTimeout(function () {
				codebeamer.trackers.markSubtreeRoot();
			}, 500);

		});

		treePane.bind("rename_node.jstree", trackerObject.onNodeRenamed);
		$("#releaseTreePane").bind("rename_node.jstree", trackerObject.onNodeRenamed);
		codebeamer.defaultReleaseTrackerId = "${defaultReleaseTracker.id}";

		treePane.bind("state_ready.jstree", function() {
			var t = $.jstree.reference("#treePane");
			var selected = t.get_selected();
			// when no node is selected in the tree then select the root node
			if (!selected || selected.length == 0) {
				t.select_node($("#treePane li").first());
			}
		});

		treePane.bind("loaded.codebeamer.jstree", function() {
			var tree = $.jstree.reference("#treePane");
			var selectedItemId = UrlUtils.getParameter("selectedItemId");
			if (selectedItemId) {
				var node = tree.get_node(selectedItemId);
				if (node) {
					tree.deselect_all();
					tree.select_node(node);
				}
			}
		});
		initFilter();

		// set the "hijacking" of issue interwiki links
		setIssueClickSelectNodeInTree("#centerDiv", "treePane");
	});
</script>

<c:if test="${baseline == null }">
	<script type="text/javascript">
		jQuery(function($) {
			var treePane = $("#treePane");

			initTreeViewSearch(treePane, "documentView", "${tracker.id}");
		});
	</script>
</c:if>

<meta name="showGlobalMessages" content="false"/>
<ui:splitTwoColumnLayoutJQuery cssClass="layoutfullPage autoAdjustPanesHeight" rightMinWidth="380" leftMinWidth="280" config="${extended ? '{east: {initClosed: true}, stateManagement: {autoSave: false, autoLoad: false}}' : ''}">
	<jsp:attribute name="leftPaneActionBar">
		<ui:treeFilterBox treeId="treePane" disableNativeFiltering="${baseline == null }" triggerWithButton="true"/>
		<div style="float:right;margin-right:13px;margin-left:2px;margin-top:4px;">
			<c:if test="${canCreateIssue && (empty baseline)}">
				<spring:message code="tracker.type.${tracker.type.name}.create.label" text="New requirement" var="newReqTitle"/>
				<img class="action" onclick="trackerObject.addTopLevelRequirement(); return false;" title="${newReqTitle}" src="<ui:urlversioned value="/images/newskin/actionIcons/icon_add_blue_14.png"/>">
			</c:if>
			<spring:message code="baselines.and.branches.title" text="Baselines and Branches" var="baselinesTitle"/>
			<spring:message code="tracker.tree.settings.title" text="Settings" var="settingsTitle"/>
			<img class="action" onclick="showBaselines(); return false;" title="${baselinesTitle}" src="<ui:urlversioned value="/images/newskin/actionIcons/icon-branch-bl_14.png"/>">
			<c:if test="${!anonymous}"><img class="action" src="<ui:urlversioned value='/images/newskin/actionIcons/settings-s_14.png'/>" title="${settingsTitle}" onclick="showPopupInline('${treeSettingsUrl}', {'width': 600}); return false;"></c:if>
		</div>
		<a class="scalerButton"></a>
	</jsp:attribute>
	<jsp:attribute name="leftContent">
		<div id="treePane" style="height: calc(100% - 32px);overflow:auto;"></div>
	</jsp:attribute>
	<jsp:attribute name="rightPaneActionBar">
		<a class="scalerButton" style="left: -8px;"></a>
	</jsp:attribute>
	<jsp:attribute name="middlePaneActionBar">
		<c:if test="${empty baseline}">
			<table class="reportSelectorActionBarTable">
				<tr>
					<td class="actionBarColumn">
						<jsp:include page="centerActionBar.jsp"/>
						<c:choose>
							<c:when test="${extended }">
								<spring:message code="button.save" text="Save" var="saveLabel"></spring:message>
								<spring:message code="button.cancel" text="Cancel" var="cancelLabel"></spring:message>
								<input type="button" class="button" onclick="codebeamer.trackers.extended.save();" value="${saveLabel }" data-role="save"/>
								<a class="button cancel cancelButton" href="#" onclick="codebeamer.trackers.extended.showNormalView('${tracker.urlLink}');">${cancelLabel }</a>
							</c:when>
						</c:choose>

						<a class="scalerButton"></a>
					</td>
					<td class="reportSelectorColumn">
						<ui:reportSelector resultContainerId="reportSelectorResult" projectId="${tracker.project.id}" trackerId="${branchOrTrackerId}"
										   resultRenderUrl="/proj/tracker/showDocumentView.spr?comparedBaselineId=${param.comparedBaselineId }&view_id=${not empty selectedView ? selectedView : -11}&extended=${extended }${isIe11 ? '&pageSize=25' : ''}" sticky="false" resultJsCallback="codebeamer.trackers.documentViewReportSelectorTagCallback"
										   showGroupBy="false" showOrderBy="false" triggerResultAfterInit="true" viewId="${selectedViewDto.id}" defaultViewId="${defaultViewId}"
										   isDocumentView="true" isDocumentExtendedView="${'true' == extended }" isBranchMode="${not empty branch }" mergeToActionBar="true" trackerItemTableId="requirements" showResizeableColumns="${'true' == extended}"/>
					</td>
				</tr>
			</table>

		</c:if>
		<c:if test="${not empty baseline}">
			<jsp:include page="centerActionBar.jsp"/>
			<a class="scalerButton"></a>
			<%--<ui:actionMenu title="more" builder="${actionBuilder}" subject="${trackerMenuData}" keys="${actionKeys}" inline="true"/>--%>
		</c:if>
	</jsp:attribute>
	<jsp:attribute name="rightContent">
		<jsp:include page="documentViewRightPanel.jsp"/>
	</jsp:attribute>
	<jsp:body>
		<c:choose>
			<c:when test="${empty baseline}">
				<div class="document-view-container" id="reportSelectorResult"></div>
			</c:when>
			<c:otherwise>--</c:otherwise>
		</c:choose>
	</jsp:body>
</ui:splitTwoColumnLayoutJQuery>

<%-- <ui:inProgressDialog imageUrl="${pageContext.request.contextPath}/images/newskin/branch_create_in_progress.gif" height="235"
	attachTo="body" triggerOnClick="false" />--%>

	<c:url var="createBranchUrl" value="/branching/createBranch.spr">
		<c:param name="trackerId" value="${branch != null ? branch.id : tracker.id }"></c:param>
		<c:param name="baselineId" value="${revision}"></c:param>
		<c:param name="openEditableView" value="${extended}"></c:param>
	</c:url>

<wysiwyg:editorInline />
