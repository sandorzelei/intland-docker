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
 * $Revision: 23756:e0ca2d8a74b6 $ $Date: 2009-11-18 18:56 +0100 $
--%>
<%@ page import="org.springframework.web.util.UriUtils"%>
<%@ page import="org.apache.commons.lang.StringUtils"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>

<%@ page import="com.intland.codebeamer.servlet.Utils"%>
<%@ page import="com.intland.codebeamer.controller.ControllerUtils"%>

<link rel="stylesheet" type="text/css" href="<ui:urlversioned value="/stylesheet/folders-tree.css"/>" />

<div id="treeDiv1"></div>

<spring:message var="rootNodeLabel" code="scm.repository.node.label"/>

<c:set var="branchOrTag"><spring:escapeBody htmlEscape="false" javaScriptEscape="false">${command.branchOrTag}</spring:escapeBody></c:set>
<%
	// the "path" parameter contains the branch plus the path of the current selected file
	// extracting out the path of the selected file, because this is the node-id of it
	String path = request.getParameter("path");
	if (path != null) {
		String directory = StringUtils.substringAfter(path, "/");
		if (StringUtils.isNotEmpty(directory)) {
			String encoded = UriUtils.encodeQueryParam(directory, "UTF-8");
			pageContext.setAttribute("selectedNodeId", encoded);
		}
	}

	pageContext.setAttribute("project", ControllerUtils.getCurrentProject(request));
%>
<script type="text/javascript">
var populateTree = function (n) {
	var encodedBranch = "${branchOrTagEncoded}";
	var params = {
		"proj_id": "${project.id}",
		"selectedNodeId": "${selectedNodeId}",
		"repositoryId": "${repository.id}",
		"branchOrTag": encodedBranch
	};
	if (n .id !== "#") {
		params["nodeId"] = n.id;
	}

	return params;
};

var openDirectory = function (n) {
	if (n.id !== "#" && n.id !== "-1") {
		location.href = n.li_attr["href"];
	} else {
		location.href = contextPath + encodeURI("/scm/dir/${repository.id}/"+ encodeURIComponent("${branchOrTag}"));
	}
};

$(document).ready(function() {
	$("#treePane").bind("close_node.jstree", function(event, data){
		var node = data.node;
		$.ajax({
			"url": contextPath + "/ajax/closeScmNode.spr",
			"type": "POST",
			"data": {
				"nodeId": node.id,
				"repositoryId": "${repository.id}"
			}
		});
	});

	$("#treePane").bind("open_node.jstree", function(event, data){
		var node = data.node;
		$.ajax({
			"url": contextPath + "/ajax/openScmNode.spr",
			"type": "POST",
			"data": {
				"nodeId": node.id,
				"repositoryId": "${repository.id}"
			},
		});
	});

	$("#treePane").bind("loaded.jstree", function() {
		var selectedNodeId = "${selectedNodeId}";
		if (selectedNodeId){
			$.jstree.reference("#treePane").deselect_all();

			var $selected = $("#" + escapeSelector(selectedNodeId) + " .jstree-anchor");
			$selected.first().addClass("jstree-clicked");
		}
	});

	// triggered after a node is loaded
	$("#treePane").bind("load_node.jstree", function(node, status) {
		// node: the node that was loading, status: was the node loaded successfully
		initializeTreeIconColors($("#treePane"));
	});
});
</script>

<c:url var="scmTreeUrl" value="/ajax/getScmTree.spr"/>

<ui:treeControl url="${scmTreeUrl}" containerId="treePane" populateFnName="populateTree" editable="false"
	dndDisabled="true" disableTreeCookies="true" cookieNameOpenNodes="false" disableContextMenu="true" nodeClickedHandler="openDirectory" layoutCookie="false"/>
<div id="treePane"></div>


