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
<%@ taglib uri="uitaglib" prefix="ui"%>
<%@ taglib uri="http://displaytag.sf.net" prefix="display"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="taglib" prefix="tag"%>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%@ taglib uri="http://ditchnet.org/jsp-tabs-taglib" prefix="tab"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<meta name="decorator" content="popup" />
<meta name="module" content="cmdb"/>
<meta name="moduleCSSClass" content="newskin CMDBModule"/>

<%-- Page to select one of the TestCases by name --%>

<head>
<style type="text/css">
	table td {
		cursor: pointer;
	}
</style>
</head>
<ui:actionMenuBar>
	<spring:message code="testrunner.select.testcaserun.page.title" />
</ui:actionMenuBar>

<spring:message var="buttonSelect" code="button.select" />
<spring:message var="filterTitle" code="testrunner.select.testcaserun.filter.title" />
<ui:actionBar>
	<input id="filterInput" type="text" value="" style='min-width:20em;' title="${filterTitle}" />

	<label for="showParameters"><input type="checkbox" id="showParameters" style="margin-top:2px;"/><spring:message code="testrunner.select.testcaserun.show.parameters"/></label>

	<c:set var="suspendedBadgePrefix"><span class="issueStatus issueStatusResolved" style="background: #ffbc6b; color: black;"></c:set>
	<c:set var="suspendedBadgePostfix"><span></c:set>

	<c:set var="suspendedBadge">${suspendedBadgePrefix}<spring:message code="tracker.choice.Suspended.label"/>${suspendedBadgePostfix}</c:set>

	<label for="showSuspended" title='<spring:message code="testrunner.select.testcaserun.show.suspended.tooltip"/>' >${suspendedBadgePrefix}<input type="checkbox" id="showSuspended"
		checked="checked" /><spring:message code="testrunner.select.testcaserun.show.suspended"/>${suspendedBadgePostfix}</label>

	<spring:message var="cancelTitle" code="button.cancel" text="Cancel" />
	<input type="submit" class="cancelButton" onclick="closePopupInline(); return false;" value="${cancelTitle}" />
</ui:actionBar>

<div class="contentWithMargins" style="margin-top:0;min-height: 400px;">

<style type="text/css">
	.testCaseRunList {
		margin: 10px 0;
	}
	.testCaseRunList input.button {
		margin: 2px 10px 2px 0;
	}
	.TestRunParametersPluginLabel {
		display: none;
	}

	.TestRunParametersPlugin {
		display: none;
	}

	/* marker CSS for suspended TestCaseRuns */
	.suspendedTestRun {
	}

	.actionBar .issueStatus {
		padding-top: 3px;
		padding-bottom: 3px;
		padding-right: 15px;
	}
	.actionBar label {
		margin-left: 10px;
	}
	.actionBar input[type='checkbox'] {
		vertical-align: text-top;
	}

	.wikiLink .itemIcon {
		vertical-align: middle;
	}

</style>

<spring:message var="buttonSelect" code="button.select" />
<spring:message var="closeButton" code="button.close" />
<spring:message var="selectButtonTitle" code="testrunner.select.parameter.button.title" />

<table class="testCaseRunList">
	<c:forEach var="tr" items="${testCaseRunsToRun}">
	<tr class="${tr.suspended ? 'suspendedTestRun' :''}">
		<td>
			<c:set var="id" value="${tr.delegate.id}" />
			<input type="button" class="button" value="${buttonSelect}"
						onclick="return choose(${id});" title="${selectButtonTitle}"/>
		</td>
		<td class="testRunName">

			<ui:wikiLink item="${tr.delegate}" showTooltip="${false}"/>

			<c:if test="${tr.suspended}">${suspendedBadge}</c:if>
		</td>
		<td>
			<%-- show parameters --%>
			<c:if test="${tr.isParameterizedTest()}">
				<tag:transformText value="${tr.parametersAsWiki}" owner="${tr.delegate}" format="W" />
			</c:if>
		</td>
	</tr>
	</c:forEach>
</table>

<script type="text/javascript">
	$(".testCaseRunList a").attr("target", "_blank");

	function doFilter() {
		var table = $("table.testCaseRunList");
		var $filterInput = $("#filterInput");

		var paramsVisible = $("#showParameters").is(":checked");

		var value = $filterInput.val();
		console.log("Filtering <" + value +"> with params-visible:" + paramsVisible);
		// TODO: always filters the parameters even if those are not visible
		$.uiTableFilter(table, value); // , null, null, (paramsVisible ? "td" : "td.testRunName"));
	}

	$(function() {
		$("#filterInput").keyup(function() {
			doFilter();
		}).Watermark(i18n.message("testrunner.select.testcaserun.filter.title"));

		setTimeout(function() {
			$("#filterInput").focus();
		}, 100);

	});

	function choose(testRunId) {
		var parent = window.parent;

		var goToSelected = function() {
			console.log("Choosing TestRun #" + testRunId);
			var href = parent.location.href +"&selectedTestCaseRunId=" + testRunId;
			parent.location.href = href;
		}

		if (parent.navigation.autoSave) {
			// no need to as confirmation because the content is auto-saved when another item is selected
			parent.navigation.saveBeforeNavigatingAway(null, goToSelected);
			// goToSelected();
		} else {
			var msg = i18n.message("testrunner.navigationlinks.confirm.loosing.steps");
			showFancyConfirmDialogWithCallbacks(msg, goToSelected);
		}
		return false;
	}

	$("#showParameters").change(function() {
		var show = $(this).is(":checked");
		$(".TestRunParametersPlugin").toggle(show);

		// doFilter();
	});

	$("#showSuspended").change(function() {
		var show = $(this).is(":checked");
		$(".suspendedTestRun").toggle(show);
	});
</script>


</div>

