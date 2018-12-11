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
<meta name="decorator" content="popup"/>
<meta name="module" content="wikispace"/>
<meta name="moduleCSSClass" content="wikiModule newskin"/>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>

<%@ taglib uri="uitaglib" prefix="ui" %>

<SCRIPT LANGUAGE="JavaScript" type="text/javascript">

var populateTree = function (node) {
	return {
		"project_id": "${wikiPage.project.id}",
		"nodeId": "${wikiPage.id}",
		"includeNodeId": "true"
	};
};

function showBusy() {
	ajaxBusyIndicator.showBusyPage("tracker.issues.exportToWord.wait", false, { width: "32em"});
}
</SCRIPT>

<style type="text/css">
	#formatBox {
		float:right;
		width: auto;
		border: solid 1px #ABABAB;
		border-top: 0;
		border-right: 0;
		padding: 10px;
		display: none;	/* hidden !*/
	}

	#wikiTreePane {
		height: 375px;
		overflow: auto;
		border-bottom: solid 1px #ABABAB;
	}
</style>

<spring:message var="exportButton" code="wiki.export.to.word.label" text="Export"/>

<ui:actionMenuBar>
		<ui:pageTitle prefixWithIdentifiableName="false" >${exportButton}</ui:pageTitle>
</ui:actionMenuBar>

<form:form action="${pageContext.request.contextPath}/proj/wiki/exportWikiPage.spr" id="exportForm">
	<form:hidden path="wikiPageId" />
	<form:hidden path="revision" />
	<form:hidden path="selectedWikiPageId" />

	<spring:message var="cancelButton" code="button.cancel" text="Cancel"/>

	<div class="actionBar">
		&nbsp;&nbsp;<input type="submit" id="exportButton" class="button" value="${exportButton}" onclick="getSelectedItemsForSubmit(); showBusy(); return true;" />
		&nbsp;&nbsp;<input type="submit" class="cancelButton" name="_cancel" value="${cancelButton}" onclick="inlinePopup.close(); return false;" />
	</div>

	<div id="formatBox">
		Export format:
		<label for="format_docx"><form:radiobutton id="format_docx" path="format" value="docx" />Word</label>
		<label for="format_pdf"><form:radiobutton id="format_pdf" path="format" value="pdf" />PDF</label>
	</div>

	<div id="wikiTreePane"></div>
	<ui:treeControl containerId="wikiTreePane" url="${pageContext.request.contextPath}/ajax/wikis/tree.spr" editable="false" useCheckboxPlugin="true" restrictCheckboxCascade="true" checkboxName="selectedWikiPageId" populateFnName="populateTree" dndDisabled="true" />

	<div class="contentWithMargins">
		<jsp:include page="/bugs/importing/includes/selectExportTemplateFragment.jsp" />
	</div>
</form:form>

<script type="text/javascript">
function getSelectedItemsForSubmit() {
	var checked_ids = $(".jstree-clicked").map(function () { return $(this).parent().attr("id");}).toArray();
	document.getElementById("selectedWikiPageId").value = checked_ids.join(",");
}

function onNodeCheckChange(event, jstree) {
	// using throttle because this event is fired quickly many times for each checkbox being unchecked/checked,
	// and we just need to update the submit button when all are done (would be very slow...)
	throttle(function() {
		// find all checked nodes
		var $selectedNodes = $(".jstree-clicked");
		var hasSelected = $selectedNodes.size() > 0;
		$("#exportButton").attr("disabled", ! hasSelected);
	});
}

$("#wikiTreePane")
		.bind("select_node.jstree", onNodeCheckChange)
		.bind("deselect_node.jstree", onNodeCheckChange);

function markNodeAsDashboard($domNode) {
	$domNode.addClass("dashboard-node");
}
</script>
