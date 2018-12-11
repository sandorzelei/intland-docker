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

<style type="text/css">
	.testRunFilterByResults .testRunResultTablet {
		color: white !important;
		margin-left: 10px;
		cursor: pointer;
	}

	.testRunFilterByResults .testRunResultTablet input {
		vertical-align: text-bottom;
		margin: 0 5px 0 0;
	}
</style>

<script type="text/javascript">
function initTestRunResultFilter(testRunTable, checkboxSelector) {
	$(document).on("click", ".actionBar .testRunResultTablet", function(event) {
		var $clicked = $(this);
		var $checkbox = $clicked.find("input");

		var clickedOnCheckbox = $(event.target).is("input");
		var checked = $checkbox.prop("checked");
		if (!clickedOnCheckbox) {   // toggle status if not clicked on checkbox only!
			var checked = ! checked;
			$checkbox.prop("checked", checked);
		}

		// apply the selected results as filter
		// find out which results are selected ?
		var selectedResults = [];
		$clicked.closest(".testRunFilterByResults").find(".testRunResultTablet").each(function() {
			var selected = $(this).find("input").is(":checked");
			if (selected) {
				var classes = $(this).attr('class').split(' ');
				for (var i=0; i<classes.length; i++) {
					if (classes[i] != "testRunResultTablet") {
						selectedResults.push(classes[i]);
					}
				}
			}
		});

		console.log("Apply filter for TestRun results: " + selectedResults)
		// only select the matching results in teh table
		$(testRunTable).find(checkboxSelector).each(function() {
			var $this = $(this);
			var $resultTablet = $(this).closest("tr").find(".testRunResultTablet").first();
			var select = false;
			for (var i=0; i<selectedResults.length; i++) {
				var r = selectedResults[i];
				if ($resultTablet.hasClass(r)) {
					select = true;
					break;
				}
			}
			$(this).prop("checked", select);
		});
	});
}
</script>

<spring:message var="title" code="testrun.editor.restart.option.redo.select.selectByResult.title" text="Select Test Runs by the result" />
<span class="testRunFilterByResults" title="${title}">
	<c:forEach var="trResult" items="<%=TestRun.TestRunResult.values()%>">
		<%=((TestRunResult) pageContext.getAttribute("trResult")).renderAsHtml(request, "<input type='checkbox'/>")%>
	</c:forEach>
</span>
