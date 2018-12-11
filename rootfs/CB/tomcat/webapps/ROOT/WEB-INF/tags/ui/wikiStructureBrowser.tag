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
<%@ tag language="java" pageEncoding="UTF-8" body-content="scriptless" %>

<%--
	Tag for browsing a wiki-tree structure.
--%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>

<%@ attribute name="topNodeId" type="java.lang.String" %>
<%@ attribute name="topNodeLink" type="java.lang.String" %>
<%@ attribute name="topNodeLabel" type="java.lang.String" %>
<%@ attribute name="projectId" type="java.lang.String" %>
<%@ attribute name="showRoot" type="java.lang.Boolean" description="If the root node is shown" %>

<%@ attribute name="treeType" type="java.lang.String" %>
<%@ attribute name="multiSelection" type="java.lang.Boolean" %>
<%@ attribute name="ajaxRequestParams" type="java.lang.String" description="Optional parameters passed in the ajax request' url." %>

<%@ attribute name="inputName" type="java.lang.String" description="The name of the input field used for selection checkboxes/radio buttons" %>
<%@ attribute name="showSelectors" type="java.lang.Boolean" description="if the tree shows checkboxes/radio buttons" %>

<c:if test="${empty showRoot}">
	<c:set var="showRoot" value="true"/>
</c:if>

<%-- CSS showing the simple tree --%>
<link rel="stylesheet" type="text/css" href="<ui:urlversioned value="/js/yui-extensions/classic-tree-skin/treeview.css"/>" />

<%-- TODO: this layout is only hacked together quickly: fix it! --%>
<style type="text/css">
	#wikiRender {
		margin: 5px;
	}

	.tree-last-clicked-node a {
		font-weight:bold;
	}
</style>

<script type="text/javascript">
	var EntityIdParser = {

		re: new RegExp("(\\d+)\\-(\\d+)(?:/(\\d+))?"),

		/**
		 * Parses the entityId is the form of "<grouptype>-<entityid>".
		 *
		 * @param entityId The entity-id
		 * @return null if can not parse, or an object with two attributes of grouptype" and "id"
		 */
		parse:function(entityId) {
			var m = EntityIdParser.re.exec(entityId);
			if (m != null) {
				return { grouptype: m[1], id: m[2], version: m[3] };
			}
			return null;
		}

	};

	var populateTree = function (node) {
		return {
			"project_id": "${projectId}",
			"nodeId": "${topNodeId}",
			"includeNodeId": "true"
		};
	};

	var nodeClicked = function (node, tree) {
		showNodeContent(node.id);
	};

	var showAjaxResultIn = function (elementId, url) {
		$.getJSON(url, function (data, status) {
			var html = "";
			if (data.hasOwnProperty("isDashboard") && data.isDashboard) {
				html = '<div class="warning">' + i18n.message("dashboard.preview.unavailable") + '</div>';
			} else {
				html = data.hasOwnProperty("content") ? data.content : "";
			}
			$('#' + elementId).html(html);
		});
	};

	var showNodeContent = function(nodeId, treeNode) {
		var entityId = EntityIdParser.parse(nodeId);
		if (entityId != null) {
			var wikiRenderHeader = document.getElementById("wikiRenderHeader");

			if (entityId.grouptype == 5) {
				var url = contextPath + "/ajax/wiki/getWikiContentAsHtml.spr?doc_id=" + entityId.id;
				if (entityId.version != null && entityId.version != "null") {
					url = url + "&revision=" + entityId.version;
				}
				showAjaxResultIn("wikiRender", url);

				// update the the node header
				if (treeNode != null) {
					wikiRenderHeader.innerHTML = i18n.message("ui.wikiStructureBrowser.showing.content.of", "<a href='" + contextPath +"/wiki/" + entityId.id +"'>"+ treeNode.data.label +"</a>");
				}

			} else {
				var wikiRender = document.getElementById("wikiRender");

				if (entityId.grouptype == 8) {
				    var downloadurl = contextPath +"/displayDocument/" + encodeURIComponent(treeNode.data.label) + "?object_comment_id=" + entityId.id;
					wikiRender.innerHTML = i18n.message("ui.wikiStructureBrowser.can.download.content", "<a href='#' onclick=\"launch_url('" + downloadurl +"');\" >" + escape(treeNode.data.label) +"</a>");
				} else {
					wikiRender.innerHTML= i18n.message("ui.wikiStructureBrowser.not.rendered");
				}

				// update the the node header
				if (treeNode != null) {
					wikiRenderHeader.innerHTML = i18n.message("ui.wikiStructureBrowser.selected.page","<strong>" + treeNode.data.label +"</strong>");
				}
			}
		}
	};
</script>

<div id="wikiStructureBrowserTree">
	<ui:splitTwoColumnLayoutJQuery>
	<jsp:attribute name="leftContent">
		<ui:treeControl containerId="treeDiv1" url="${pageContext.request.contextPath}/ajax/wikis/tree.spr" editable="false"
						populateFnName="populateTree" dndDisabled="true" nodeClickedHandler="nodeClicked" disableTreeCookies="true"/>
		<div id="treeDiv1" >
		</div>
	</jsp:attribute>
		<jsp:body>
			<div id="wikiRenderHeader" class="actionBar">
			</div>
			<div id="wikiRender">
				<div class="information"><spring:message code="wiki.tree.browser.hint" /></div>
			</div>
		</jsp:body>
	</ui:splitTwoColumnLayoutJQuery>
</div>

<c:choose>
	<c:when test="${empty inputName}"><c:set var="jsInputNameParam" value="null"/></c:when>
	<c:otherwise><c:set var="jsInputNameParam" value="'${inputName}'"/></c:otherwise>
</c:choose>

