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
 * $Revision$ $Date$
--%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="uitaglib" prefix="ui" %>

<%--
	This JSP fragement renders the tree on the left side and some other content on the right
	The right content is specified by the "middlePanel" parameter
--%>
<%@page import="com.intland.codebeamer.controller.ControllerUtils"%>

<style>
	.newskin.IE .actionBar {
		padding-top: 5px;
		padding-bottom: 4px;
	}
	.actionBar,
	.newskin.IE8 .actionBar {
		padding-top: 4px;
		padding-bottom: 3px;
	}

	.fileUpload_dropZone {
		padding: 0 15px;
	}
</style>

<c:set var="project" value="<%=ControllerUtils.getCurrentProject(request)%>"/>
<c:if test="${!empty project.id}">
	<c:set var="projectId" value="${project.id }"/>
</c:if>

<c:set var="selectedNode" value="-1"/>
<c:choose>
	<c:when test="${!empty param.doc_id}">
		<c:choose>
			<c:when test="${!empty param.revision}">
					<c:set var="selectedNode" value="${param.revision}-${param.doc_id}"/>
			</c:when>
			<c:otherwise>
				<c:set var="selectedNode" value="${param.doc_id}"/>
			</c:otherwise>
		</c:choose>
	</c:when>
	<c:when test="${!empty param.revision}">
		<c:set var="selectedNode" value="${param.revision}-"/>
	</c:when>
</c:choose>

<c:set var="nodeId" value="" />
<c:if test="${param.isBaselined}">
	<c:set var="nodeId" value="${param.revision}-" />
</c:if>

<script type="text/javascript">

var populateTree = function (n) {
	var params = {
		"proj_id": "${projectId}",
		"selectedNodeId": "${selectedNode}",
		"nodeId": "${nodeId}"
	};
	if (n.id != "#") {
		params["nodeId"] = n.id;
	}

	return params;
};

function populateContextMenu(node) {
	var isBaselined = ${param.isBaselined != null ? param.isBaselined : "null"};
	if (isBaselined || node.li_attr["baseline"] == "true" || node.li_attr["canAdd"] == "false") {
		return {};
	} else {
		return {
			"newDirectory": {
				"label": i18n.message("document.type.directory.create.label"),
				"action": function () {
					var $domNode = $("li#" + node.id);
					var isRoot = $domNode.is(".documentRootNode");
					createNewDirectory(this, ${projectId}, isRoot ? null : parseInt(node.id));
				}
			},
			"newFile": {
				"label": i18n.message("document.type.file.create.label"),
				"action": function () {
					var $domNode = $("li#" + node.id);
					var isRoot = $domNode.is(".documentRootNode");
					location.href = contextPath + "/proj/doc/upload.do" + (isRoot ? "" : "?dir_id=" + node.id);
				}
			},
			"newNote": {
				"label": i18n.message("document.type.wikiNote.create.label"),
				"action": function () {
					var $domNode = $("li#" + node.id);
					var isRoot = $domNode.is(".documentRootNode");
					launch_url(contextPath + "/proj/doc/addWikiPage.do" + (isRoot ? "" : "?dir_id=" + node.id), null);
				}
			}
		}
	}
}

var openDirectory = function (n) {
	if (n.id != "${selectedNode}") {
		var isBaselined = ${param.isBaselined != null ? param.isBaselined : "null"};
		if (n.id !== "-1") {
			location.href = contextPath + n.li_attr["href"];
		} else if (isBaselined) {
			location.href = contextPath + "/proj/doc.do?proj_id=${projectId}&doc_id=${param.revision}&revision=${param.revision}";
		} else {
			location.href = contextPath + "/proj/doc.do?proj_id=${projectId}";
		}
	}
};

$(function() {
	$("#documentTree").bind("close_node.jstree", function(event, data){
		var node = data.node;
		$.ajax({
			"url": contextPath + "/ajax/closeDocumentNode.spr",
			"type": "POST",
			"data": {
				"nodeId": node.id
			}
		});
	});

	$("#documentTree").bind("open_node.jstree", function(event, data){
		var node = data.node;
		$.ajax({
			"url": contextPath + "/ajax/openDocumentNode.spr",
			"type": "POST",
			"data": {
				"nodeId": node.id
			},
			"success": function() {
				initializeTreeIconColors($("#documentTree"));
			}
		});
	});

	$("#documentTree").bind("loaded.jstree", function() {
		$("#documentTree").jstree("select_node", "#${selectedNode}");
	});
});
</script>

<c:url var="treeUrl" value="/ajax/getDocumentTree.spr" />

<ui:treeControl url="${treeUrl}" containerId="documentTree" populateFnName="populateTree" editable="false"
	dndDisabled="true" layoutContainerId="panes" disableTreeCookies="true" cookieNameOpenNodes="false" nodeClickedHandler="openDirectory"
	populateContextMenuFnName="populateContextMenu"/>
<ui:splitTwoColumnLayoutJQuery cssClass="layoutFullPage autoAdjustPanesHeight ${param.panesExtraClasses}">
	<jsp:attribute name="leftPaneActionBar">
		<a class="scalerButton"></a>
	</jsp:attribute>
	<jsp:attribute name="leftContent">
		<div id="documentTree" style="height: calc(100% - 30px);overflow:auto;"></div>
	</jsp:attribute>
	<jsp:attribute name="middlePaneActionBar"><c:if test="${!empty param.middlePaneActionBar}">${param.middlePaneActionBar}</c:if></jsp:attribute>
	<jsp:body>
		${param.middlePanel}

		<c:if test="${param.showFileUploadWidget}">
			<c:url var="uploadFormAction" value="/dndupload/saveasdocument.spr">
				<c:param name="proj_id" value="${listDocumentForm.proj_id}"/>
				<c:param name="doc_id" value="${listDocumentForm.currentDirectory.id}"/>
			</c:url>
			<ui:fileUpload cssStyle="margin-left: 15px;" cssClass="fileUploadLink" submitUrlOnComplete="${uploadFormAction}"
						   elastic="true" dndDropHereMessageCode="dndupload.dropFilesHereOrBrowse" />
		</c:if>

	</jsp:body>
</ui:splitTwoColumnLayoutJQuery>
