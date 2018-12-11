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
<%@ tag language="java" pageEncoding="UTF-8" %>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<%-- required attributes --%>
<%@ attribute name="containerId" required="true" description="The id of the div that will contain the tree" %>
<%@ attribute rtexprvalue="true" name="url" required="true" description="The url used for populating the tree" %>
<%-- TODO: the name "populateFnName" is misleading, should be "buildDataFnName" or similar --%>
<%@ attribute name="populateFnName" required="false" description="The name of the js function used for building the request parameters/query data for fetching child nodes" %>

<%@ attribute name="layoutContainerId" required="false" description="The id of the div that will contain the tree and the reight pane" %>
<%@ attribute name="rightPaneId" required="false" description="The id of the div that will the right side" %>
<%@ attribute name="headerDivId" required="false" description="The id of the div that will contain the tree header" %>
<%@ attribute name="settingsUrl" required="false" description="The url used for retrieving/updating the tree settings" %>
<%@ attribute rtexprvalue="true" name="editable" required="false" description="If true, then the tree will be editable (dnd enabled etc.)" %>
<%@ attribute rtexprvalue="true" name="dndDisabled" required="false" description="DND disabled?" %>
<%@ attribute name="populateContextMenuFnName" required="false" description="The name of the js function used for populating the context menu" %>
<%@ attribute name="ajaxContextMenuUrl" required="false" description="The URL of the ajax context menu." %>
<%@ attribute name="ajaxContextMenuLiAttr" required="false" description="The name of the li_attr data attribute which will be used as parameter for the ajax context menu url." %>
<%@ attribute name="nodeCreatedHandler" required="false" description="The name of the js function that must be inkoved when the user creates a new node" %>
<%@ attribute name="nodeMovedHandler" required="false" description="The name of the js function that must be inkoved when the user moves a node" %>
<%@ attribute name="externalDropHandler" required="false" description="The name of the js function that must be inkoved when the user drops a node outside of the tree" %>
<%@ attribute name="checkMoveFnName" required="false" description="The name of the js function that will be used to check if a move is valid (dnd related)" %>
<%@ attribute name="checkExternalDrop" required="false" description="The name of the js function that will be used to check if a move outside the tree is valid (dnd related)" %>
<%@ attribute name="nodeClickedHandler" required="false" description="The name of the js function that must be inkoved when the user clicks a node" %>
<%@ attribute rtexprvalue="true" name="disableMultipleSelection" required="false" description="If true, then multiple selection will be disabled in the tree" %>
<%@ attribute name="onlyTopLevel" required="false" %>
<%@ attribute name="skipExpandCollapseInContextMenu" required="false" description="If set to true, Expand and Collapse options will not appear in the context menu." %>
<%@ attribute name="treeVariableName" required="false" rtexprvalue="true" description="The nem of the js variable of the tree. If you have multiple trees on the same page you must specify this parameter" %>
<%@ attribute name="disableTreeCookies" required="false" description="If true, the tree won't remember its state" %>
<%@ attribute name="initTreeOnPageLoad" required="false" %>
<%@ attribute name="cookieNameOpenNodes" required="false" description="The name of the cookie where the tree structure (which nodes are open and closed) will be stored" %>
<%@ attribute name="layoutCookie" required="false" %>
<%@ attribute name="useCheckboxPlugin" required="false" description="Wether to use checkboxes in the tree nodes" %>
<%@ attribute name="restrictCheckboxCascade" required="false" description="Sets properties in checkbox plugin, selections only cascade down." %>
<%@ attribute name="checkboxName" required="false" description="The prefix used in naming the checkboxes" %>
<%@ attribute name="revision" required="false" rtexprvalue="true" %>
<%@ attribute name="disableContextMenu" required="false" %>
<%@ attribute name="eventHandlerScope" required="false" description="the object in which the event handlers are defined" %>
<%@ attribute name="searchConfig" required="false" %>
<%@ attribute name="isPopup" required="false" %>

<%-- TODO: there are just too many callback functions/parameters to this tree, drop them and use this config instead --%>
<%@ attribute name="config" required="false"
	description="The optional js object for configuring the tree, can contain any of the callback functions above. Optionally can contain a 'treeConfig' property which may contain low level jstree configuration, which is merged to the final jstree config." %>

<c:if test="${empty initTreeOnPageLoad}">
	<c:set var="initTreeOnPageLoad" value="true"/>
</c:if>
<c:if test="${empty config}">
	<c:set var="config" value="{}"/>
</c:if>

<c:set var="contextPath" value="${pageContext.request.contextPath}"/>
<script type="text/javascript">
	<c:choose>
		<c:when test="${not empty treeVariableName}">
			var ${treeVariableName} =
		</c:when>
		<c:otherwise>
			var tree =
		</c:otherwise>
	</c:choose>
		<%-- see trees.js for the implementation of this --%>
		new codebeamer.trees.Tree($.extend({
		"contextPath": "${contextPath}",
		"treeContainerId": "${containerId}",
		"layoutContainerId": "${layoutContainerId}",
		"rightPaneId": "${rightPaneId}",
		"url": "${url}",
		<c:if test="${not empty settingsUrl}">
			"settingsUrl": "${settingsUrl}",
		</c:if>
		"editable": ${editable},
		"headerDivId": "${headerDivId}",
		<c:if test="${not empty nodeClickedHandler}">
			"clicked": ${nodeClickedHandler},
		</c:if>
		<c:if test="${not empty populateContextMenuFnName}">
			"contextmenu": {
				"items": ${populateContextMenuFnName}
			},
		</c:if>
		<c:if test="${not empty ajaxContextMenuUrl}">
			"ajaxContextMenuUrl" : "${ajaxContextMenuUrl}",
			"ajaxContextMenuLiAttr" : "${not empty ajaxContextMenuLiAttr ? ajaxContextMenuLiAttr : 'null'}",
		</c:if>
		<c:if test="${not empty nodeMovedHandler}">
			"moved": ${nodeMovedHandler},
		</c:if>
		<c:if test="${not empty externalDropHandler}">
			"externalDrop": ${externalDropHandler},
		</c:if>
		<c:if test="${not empty checkMoveFnName}">
			"checkMove": ${checkMoveFnName},
		</c:if>
		<c:if test="${not empty checkExternalDrop}">
			"externalDropCheck": ${checkExternalDrop},
		</c:if>
		<c:if test="${not empty nodeCreatedHandler}">
			"created": ${nodeCreatedHandler},
		</c:if>
		<c:if test="${not empty disableMultipleSelection}">
			"disableMultipleSelection": ${disableMultipleSelection},
		</c:if>
		<c:if test="${not empty onlyTopLevel}">
			"onlyTopLevel": ${onlyTopLevel},
		</c:if>
		<c:if test="${not empty skipExpandCollapseInContextMenu}">
			"skipExpandCollapseInContextMenu" : ${skipExpandCollapseInContextMenu},
		</c:if>
		<c:if test="${not empty disableTreeCookies}">
			"disableCookies": ${disableTreeCookies},
		</c:if>
		<c:if test="${not empty cookieNameOpenNodes}">
			"cookieNameOpenNodes": "${cookieNameOpenNodes}",
		</c:if>
		<c:if test="${not empty layoutCookie}">
			"layoutCookie": "${layoutCookie}",
		</c:if>
		<c:if test="${not empty useCheckboxPlugin}">
			"useCheckboxPlugin": ${useCheckboxPlugin},
		</c:if>
		<c:if test="${not empty useCheckboxPlugin && not empty restrictCheckboxCascade}">
			"restrictCheckboxCascade": ${restrictCheckboxCascade},
		</c:if>
		<c:if test="${not empty checkboxName}">
			"checkboxName": "${checkboxName}",
		</c:if>
		<c:if test="${not empty revision}">
			"revision": "${revision}",
		</c:if>
		<c:if test="${not empty dndDisabled}">
			"dndDisabled": ${dndDisabled},
		</c:if>
		<c:if test="${not empty disableContextMenu}">
			"disableContextMenu": ${disableContextMenu},
		</c:if>
		<c:if test="${not empty eventHandlerScope}">
			"eventHandlerScope": ${eventHandlerScope},
		</c:if>
		<c:if test="${not empty searchConfig}">
			"searchConfig": ${searchConfig},
		</c:if>
		"data": ${empty populateFnName ? "null": populateFnName}
	}, ${config} ));

	<c:if test="${initTreeOnPageLoad}">
		<c:choose>
			<c:when test="${isPopup}">
				window.parent.$("#inlinedPopupIframe").load(function() {
			</c:when>
			<c:otherwise>
				$(document).ready(function() {
			</c:otherwise>
		</c:choose>
			<c:choose>
				<c:when test="${not empty treeVariableName}">
					${treeVariableName}.init();
				</c:when>
				<c:otherwise>
					tree.init();
				</c:otherwise>
			</c:choose>
			//$("#${containerId}").height(h - $("#${headerDivId}").height() - 10);

		});
	</c:if>
</script>