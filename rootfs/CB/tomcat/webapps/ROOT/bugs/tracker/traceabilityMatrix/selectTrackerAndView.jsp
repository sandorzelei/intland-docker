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
<%@page import="com.intland.codebeamer.remoting.ArtifactType"%>
<%@page import="com.intland.codebeamer.persistence.dto.TrackerTypeDto"%>
<meta name="decorator" content="${param.mode == 'popup' ? 'popup' : 'main'}"/>
<meta name="module" content="tracker"/>
<meta name="bodyCSSClass" content="newskin" />

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>

<style type="text/css">
	.treeFilterBox {
		margin: 5px;
		padding: 5px;
	}

	.newskin .ditch-focused {
		background: white;
	}

	.ditch-tab-pane-wrap {
		height: 300px;
	}

	#selectButton {
		min-height: 20px;
		padding: 2px 20px;
	}
</style>

<ui:actionMenuBar showGlobalMessages="true" >
	<ui:breadcrumbs showProjects="false"><span class="breadcrumbs-separator">&raquo;</span>
	<ui:pageTitle prefixWithIdentifiableName="false">
		Traceability matrix: Select trackers and views for the matrix
	</ui:pageTitle>
	</ui:breadcrumbs>
</ui:actionMenuBar>

<ui:actionBar>
	<spring:message var="showDeps" code="tracker.traceability.show.dependencies" text="Show dependencies"/>
	<input id="selectButton" type="button" class="disabledButton" value="${showDeps}" onclick="loadSelectedMatrix(artifactSelectorLeft, artifactSelectorRight);" disabled="disabled" />
</ui:actionBar>

<div class="contentWithMargins">
<ui:globalMessages/>

<script type="text/javascript">
	var populateTree = codebeamer.trackers.generateTreePopulator("${projectId}", "", "", true, true);

	var artifactSelectorLeft;
	var artifactSelectorRight;

	// TODO: move this to the artifactSelector tag
	var disableSelections = function (e, d) {
		if (d.rslt.obj.attr("type") === "tracker" || d.rslt.obj.attr("type") === "group") {
			d.inst.deselect_node(d.rslt.obj);
		}
	};

	// TODO: listen on deselect_node.jstree

	// get the selected views, or null if the selection is missing
	function getSelected(node) {
		var leftSelected = artifactSelectorLeft.getSelectedIds()[0];
		var rigthSelected = artifactSelectorRight.getSelectedIds()[0];

		if ((typeof leftSelected === "undefined") || (typeof rigthSelected === "undefined")) {
			return null;
		}
		return { horizontal: leftSelected, vertical: rigthSelected };
	}

	function handleSelect(node, data) {
		var $b = $("#selectButton");

		if (node.attr("type") === "tracker" || node.attr("type") === "group") {
			data.deselect_node(node);
		}

		var selected = getSelected();
		if (selected) {
			$b.removeAttr("disabled");
			$b.attr("class", "button");
		} else {
			$b.attr("disabled", true);
			$b.attr("class", "disabledButton");
		}
	}

	var loadSelectedMatrix = function (l, r) {
		var selection = getSelected();
		if (selection) {
			var horizontal = selection.horizontal.split("-");
			var vertical = selection.vertical.split("-");

			var url = "${pageContext.request.contextPath}/proj/tracker/traceabilitymatrix2.spr?tracker_id=" + horizontal[1] + "&v_tracker_id=" + vertical[1] +
					"&h_view_id=" + (horizontal.length == 3 ? horizontal[2] : "-" + horizontal[3]) + "&v_view_id=" + (vertical.length == 3 ? vertical[2] : "-" + vertical[3]);
			// "window.top" does the trick: if inside the overlay's iframe open the url in the top window
			window.top.location.href = url;
		}
	};
</script>

<div id="trackerFilter">
	<div class="information">
		Select two tracker views for the top row and for the left column  of the traceability matrix.<br>
		The dependencies between the issues matching those views will be shown.
	</div>

	<c:set var="height" value="260px" />
	<table style="width: 100%;">
		<tr>
			<td style="width: 50%;">
				<%
					String trackerTypesExcluded = TrackerTypeDto.CHANGESET.getId() + ","
							+ TrackerTypeDto.CVS.getId() + "," + TrackerTypeDto.SUBVERSION.getId() + ","
							+ TrackerTypeDto.MERCURIAL.getId() + "," + TrackerTypeDto.GIT.getId() + ","
							+ TrackerTypeDto.PULL.getId();
					pageContext.setAttribute("trackerTypesExcluded", trackerTypesExcluded);
					pageContext.setAttribute("artifactTypesExcluded", ArtifactType.SCM_REPOSITORY);
				%>
				<c:set var="treeUrl" value="${pageContext.request.contextPath}/trackers/ajax/tree.spr?trackerTypesExcluded=${trackerTypesExcluded}&artifactTypesExcluded=${artifactTypesExcluded}" />
				<ui:artifactSelector jsVariable="artifactSelectorRight" treeUrl="${treeUrl}"
					treePopulatorFn="populateTree" disableSearch="true" disableHistory="true" disableTreeMultipleSelection="true"
					onlyTopLevel="true" treeVariableName="rightTree" treePaneTitle="Vertical/Left column" hideHeader="true" treeHeight="${height}"
					showTreeSearchBox="true" initTreeOnPageLoad="true" selectorClickHandler="handleSelect"/>
			</td>
			<td>
				<ui:artifactSelector jsVariable="artifactSelectorLeft" treeUrl="${treeUrl}"
					treePopulatorFn="populateTree" disableSearch="true" disableHistory="true" disableTreeMultipleSelection="true"
					onlyTopLevel="true" treeVariableName="leftTree" treePaneTitle="Horizontal/Top row" hideHeader="true" treeHeight="${height}"
					showTreeSearchBox="true" initTreeOnPageLoad="true" selectorClickHandler="handleSelect"/>
			</td>
		</tr>
	</table>
</div>
</div>

<script type="text/javascript">
function initTree(treeName, trackerId, viewId) {
	// select tracker and view in the tree
	if (trackerId != "" && viewId != "") {
		$("#" + treeName).on("treeInitialized", function (event, data) {
			var tree = $.jstree.reference("#" + treeName);
			tree.deselect_all();
			tree.select_node("#" + trackerId + "-" + viewId);
		});
	}

/* TODO: deselect does not work!
	$("#" + treeName).on("deselect_node.jstree", function(event, data, node) {
		debugger;
	});
*/
}

$(function() {
	initTree("artifactSelectorTreePane_leftTree", "${param.tracker_id}", "${param.h_view_id}");
	initTree("artifactSelectorTreePane_rightTree", "${param.v_tracker_id}", "${param.v_view_id}");
});
</script>

