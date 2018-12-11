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
<%@ page import="com.intland.codebeamer.manager.testmanagement.TestRun.TestRunResult"%>
<%@ page import="com.intland.codebeamer.manager.testmanagement.TestRun"%>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<%@ taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@ taglib uri="taglib" prefix="tag" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="bugstaglib" prefix="bugs" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>

<meta name="decorator" content="popup" />
<meta name="module" content="tracker" />
<ui:actionMenuBar>
	<jsp:body>
		<spring:message code="testrun.editor.restart.option.redo.select.page.title" text="Select which Test Runs will be re-run" />
    </jsp:body>
</ui:actionMenuBar>

<style type="text/css">
	.menuTrigger * {
		display: none !important; /* hide all menu, must not be used here */
	}
	.indenter a {
		display: none !important; /* must not expan to the children, those are not selectable !*/
	}

</style>

<script type="text/javascript">
function saveSelection() {
	var $selected = $("[name=selectedSubtaskIds]:checked");

	var $field =getHiddenField();
	var value = [];
	$selected.each(function() {
		var val = $(this).val();
		value.push(val);
	});
	$field.val(value.join(","));

	// $container.closest("li").find("a").first().text(i18n.message("testrun.editor.restart.option.redo.selected.n.items", $selected.length));

	inlinePopup.close();
}

function getHiddenField() {
	var field = window.parent.$("input[name='removeSelectedChildRuns']");
	return field;
}

$(function() {
	// initialize selection on load
	var $field = getHiddenField();
	var selectedValues = {}
	$($field.val().split(",")).map(function(idx,val) {
		selectedValues[val] = true;
	});

	//var value = [];
	$("[name=selectedSubtaskIds]").each(function() {
		var val = $(this).val();
		var checked = selectedValues[val];
		$(this).prop("checked", checked);
	});
});
</script>

<c:set var="testRunSelector">
	<jsp:include page="./testRunsByResultFilter.jsp"/>
	<script type="text/javascript">
		initTestRunResultFilter("#subtasks", "[name='selectedSubtaskIds']");
	</script>
</c:set>

<spring:message var="selectLabel" code="button.select" text="Select" />
<spring:message var="cancelLabel" code="button.cancel" text="Cancel" />
<ui:actionBar>
	<input type="submit" class="button" name="submit" value="${selectLabel}" onclick="saveSelection();">
	<input type="submit" class="cancelButton" name="cancel" value="${cancelLabel}" onclick="inlinePopup.close();" />

	<span style="margin-left: 30px;">${testRunSelector}</span>
</ui:actionBar>

<%--
 JSP used when selecting which TestRuns will be re-run. See addUpdateTestRun.jsp
--%>
<form>
<bugs:displaytagTrackerItems htmlId="subtasks" layoutList="${subTaskColumns}" items="${subTasks}"
	browseTrackerMode="true" export="false"	selection="true" multiSelect="true" selectionFieldName="selectedSubtaskIds"
	paginationParamPrefix="subtasks-" pagesize="99999" />
</form>
