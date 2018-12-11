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
<%@ taglib uri="http://ditchnet.org/jsp-tabs-taglib" prefix="tab" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%@ taglib uri="taglib" prefix="tag" %>

<meta name="decorator" content="popup"/>
<meta name="module" content="admin"/>
<meta name="moduleCSSClass" content="newskin adminModule"/>

<style type="text/css">
 .newskin .actionBar {
 	border-bottom: none;
 }

 #trackerListPlugin {
 	display: none;
 }

 .trackerListPlugin thead, .trackerListPlugin tfoot{
 	display: none;
 }

 .trackerListPlugin .stats{
 	display: none;
 }

 .actionBar input {
 	margin-left: 10px;
 }
</style>

<c:choose>
	<c:when test="${! empty reload}">
		<%-- because this jsp is inside an iframe after the save it must reload the parent window, which is done from js here --%>
		<script type="text/javascript">
			window.top.location.reload();
		</script>
	</c:when>
<c:otherwise>

<c:url var="url" value="/proj/admin/trackersConfiguration.spr?proj_id=${projectTrackerConfig.proj_id}" />
<form:form modelAttribute="projectTrackerConfig" action="${url}" method="POST" >

<form:hidden id="trackerOrder" path="trackerOrder"/>

<ui:actionBar>
	<c:if test="${canUpdate}">
		<spring:message var="saveButton" code="button.save" text="Save"/>
		<input id="saveButton" type="submit" class="button" name="SAVE" value="${saveButton}" />
	</c:if>

	<spring:message var="cancelButton" code="button.cancel" text="Cancel"/>
	<input type="submit" class="cancelButton" name="_cancel" value="${cancelButton}"/>

	<hr/>
	<p>
		<input type="button" class="button" id="addFolder" value="Add Folder" />
		<input type="button" class="button" id="addTracker" value="Add Tracker" />
		<select id="trackerSelect">
			<option>Task1</option>
		</select>

		<input style="margin-left: 20px;" type="submit" class="button reorderButton" name="groupByTrackerType" value="Regroup by Tracker Type" />
		<input type="submit" class="button reorderButton" name="orderByPriority" value="Reorder by Tracker Type" />
		<input type="submit" class="button reorderButton" name="orderByName" value="Reorder by Tracker Name" />
	</p>

<script type="text/javascript">
	$(".reorderButton").click(function() {
		return confirm("This will change the order of your Trackers, are you sure?");	// TODO: i18n, better message?
	});

	// add a new folder to the tree
	function createTreeFolder(name) {
		var selectedNode = $("#treePane").jstree("get_selected");
/*
		var node = {
			title: name,
			label: name
			// "icon ?"
		}
		$("#treePane").jstree("create_node", selectedNode, node, 'last');
*/
		$("#treePane").jstree("create", selectedNode, "first", {
			attr: {
				"id": "0"
			},
			data: {
				"title" : name
				// "icon" : ...
			}
		});
	}

	$("#addFolder").click(function() {
//		var folder = prompt("Enter new Folder name", "new");
//		if (folder != null) {
			createTreeFolder("new");
//		}
	});
</script>

</ui:actionBar>

<div class="contentWithMargins">

<%-- TODO: i18n --%>
<%--
<table border="0" cellspacing="1" cellpadding="2">
	<tr>
		<td class="optional labelcell" style="vertical-align: middle;">
			<label for="groupByTrackerType"><spring:message code="tracker.configure.project.group.by.tracker.type" text="Group by Tracker type"/>:</label>
		</td>
		<td class="expandText">
			<form:checkbox id="groupByTrackerType" path="groupByTrackerType"/>
		</td>
	</tr>
	<tr>
		<td class="optional labelcell" style="vertical-align: top;"><spring:message code="tracker.configure.project.order.of.trackers" text="Order of Trackers"/>:</td>
		<td class="expandText">
			<form:select id="orderOfTrackers" path="orderOfTrackers">
				<c:forEach var="opt" items="${projectTrackerConfig.orderOptions}">
					<form:option id="order-${opt}" value="${opt}" label="${opt}"/>
				</c:forEach>
			</form:select>
		</td>
	</tr>

	<tr id="trackerListPluginContainer" style="display:none;">
		<td colspan="2">
			<p class="hint">
				<spring:message code="tracker.configure.project.drag.drop.hint" />
			</p>
			<tag:transformText value="[{TrackerList sortable='true' showMenus='false' trackerOrder='${projectTrackerConfig.trackerOrder}'}]" format="W" />
		</td>
	</tr>
</table>
--%>

	<script type="text/javascript">
		function populateTree(n) {
			var parameters = {};
			return parameters;
		}

		function renameFolder (node) {
			$("#treePane").jstree("rename", "#" + node.attr("id"));
		}
		function deleteNode (node) {
			$("#treePane").jstree("remove", "#" + node.attr("id"));
		}

		function populateContextMenu(node) {
			var menu = {};
			$.extend(menu, {
				"rename": { "label": i18n.message("document.rename.label"), "action": renameFolder},
				"delete": { "label": i18n.message("button.delete"), "action": deleteNode}
			});

			return menu;
		}

		function nodeMoved(nodesMoved, newParent, position, targetNode) {
			return true;
		}

		function checkMove (np, o, op) {
			return true;
			/*
			if (np == -1){
				return false;
			}else{
				return true; // allow any moves, including reordering and changing parents
			}
			*/
		}
	</script>

	<%--
			nodeMovedHandler="nodeMoved" checkMoveFnName="checkMove"

	 --%>

	<c:set var="contextPath" value="${pageContext.request.contextPath}" />
	<c:set var="treeURL" value="${contextPath}/proj/admin/trackersConfiguration/tree.spr?proj_id=${projectTrackerConfig.proj_id}&orderOfTrackers=${projectTrackerConfig.orderOfTrackers}" />
	<ui:treeControl containerId="treePane" url="${treeURL}"
		editable="true" populateFnName="populateTree" populateContextMenuFnName="populateContextMenu"
	/>

	<div id="treePane"></div>
</div>

</form:form>


<script type="text/javascript">
<%--
	function updateFormOnChange() {
		var groupByTrackerType = $("#groupByTrackerType").is(":checked");

		var $orderOfTrackers = $("#orderOfTrackers");
		$orderOfTrackers.attr('disabled', groupByTrackerType ? 'disabled' : null);

		var customOrder = false;
		if (! groupByTrackerType) {
			var value = $orderOfTrackers.val();
			console.log("orderOfTrackers selected:<"  + value +">");

			customOrder = (value == 'custom');
		}

		$("#trackerListPluginContainer").toggle(customOrder);
	}

	$("#orderOfTrackers").change(updateFormOnChange);
	$("#groupByTrackerType").change(updateFormOnChange);
	$(updateFormOnChange);

	// init drag-drop sorting
	$(function() {
		$(document).on("orderChanged", function(event, trackerIdsInOrder) {
			var joined = trackerIdsInOrder.join(",");
			console.log("tracker-order has changed to " + joined);
			$("#trackerOrder").val(joined);
		})
	});
--%>
</script>
</c:otherwise>
</c:choose>