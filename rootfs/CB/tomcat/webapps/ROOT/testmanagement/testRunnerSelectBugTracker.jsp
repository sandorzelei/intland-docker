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
<%@page import="com.intland.codebeamer.controller.testmanagement.TestCaseController"%>
<meta name="decorator" content="popup"/>
<meta name="module" content="cmdb"/>
<meta name="moduleCSSClass" content="newskin CMDBModule"/>

<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>

<script type="text/javascript" src="<ui:urlversioned value='/testmanagement/testRunnerAddBug.js'/>"></script>

<style type="text/css">
	#alreadyReportedBugs {
		min-height: 400px;
	}
	.reportThis {
		float: left;
		margin-right: 10px;
		margin-top: -2px;
	}
	#alreadyReportedBugs .actionBar, #explanation {
		margin-top: 10px;
		border-top: solid 1px #ababab;
	}

	#alreadyReportedBugs .actionBar > h4, #explanation > h4 {
		font-size: 14px;
		float:left;
		margin: 4px;
	}

	.wikiLinkContainer {
		max-width: 500px !important;
		float:left;
	}

	table.submitterTable >tbody >tr >td {
		padding: 0 !important;
	}
</style>

<%-- Select the bug tracker where the bug will be added to during test run --%>
<ui:actionMenuBar>
	<spring:message code="testrunner.bug.report.select.tracker.title" />
</ui:actionMenuBar>

<c:set var="noTrackers" value="${empty projects or empty trackersByProject}" />
<form:form method="POST" action="${submitUrl}" >
	<div class="actionBar">
		<c:if test="${! noTrackers}">
			<spring:message var="buttonTitle" code="button.next" text="Next"/>
			<input type="submit" value="${buttonTitle}" class="button" onclick="ajaxBusyIndicator.showBusyPage();return true;">
		</c:if>

		<spring:message var="cancelTitle" code="button.cancel" text="Cancel"/>
		<input type="button" class="cancelButton" onclick="closePopupInline(); return false;" value="${cancelTitle}"/>
	</div>
	<div class="contentWithMargins">
		<c:choose>
			<c:when test="${noTrackers}">
				<div class="warning"><spring:message code="testrunner.bug.report.no.tracker.available" text="No tracker is available for reporting bugs"/></div>
			</c:when>
			<c:otherwise>
				<jsp:include page="/agile/selectTrackerWidget.jsp"></jsp:include>
			</c:otherwise>
		</c:choose>

		<div id="explanation" class="actionBar">
			<spring:message var="existingBugExplanation" code="testrunner.bug.report.select.existing.bug"/>
			<h4>${existingBugExplanation}</h4>
			<div style="clear:both;"></div>
		</div>

		<div id="alreadyReportedBugs">
		</div>
	</div>
</form:form>

<script type="text/javascript">
	$(function(){
		function initReportedBugs() {
			// all links should open to a new window so the test runner remains open
			var $a = $("#alreadyReportedBugs a");
			$("#alreadyReportedBugs a").attr("target", "_blank");

			// add the buttons to report previously reported bugs
			var $r = $(".reportedBug");
			var msg = i18n.message("testrunner.bug.report.select.existing.bug.button");
			var title= i18n.message("testrunner.bug.report.select.existing.bug.button.tooltip");
			$(".reportedBug").prepend("<button class='reportThis' title='" + title +"'>" + msg +"</button>");

			// move the explanation to the actionbar
			$("#explanation").remove();
			var $actionBar = $("#alreadyReportedBugs .actionBar");
			$actionBar.children().wrapAll("<div style='float:right;'></div>");
			$actionBar.prepend("<h4>${existingBugExplanation}</h4>")
					  .append("<div style='clear:both;'></div>");
		}

		reportedBugsLazyLoad("#alreadyReportedBugs", '${command.testCaseId}', "allRelatedBugs=true", true).always(function(data) {
			initReportedBugs();
		});

		// init the gui when reported-bugs is reloaded
		$(document).on("loaded", ".reportedBugs", function(event) {
			initReportedBugs();
		});
	});

	// event handler to the report-this button
	$(document).on("click", ".reportThis", function(event) {
		// don't follow the link!
		event.preventDefault();
		var $a = $(this).closest("td").find("a").first();
		var url = $a.attr("href");
		var name = $a.text();
		var extractIdRegexp = /issue\/(\d*)/g;
		var match = extractIdRegexp.exec(url);
		console.log("extracting id:" + match);
		var id = match[1];
		if (id != null) {
			closeWithBugAdded(id, name, url);
		}
		return false;

	});

	$(function() {
		selectTracker.init(${selectedProjectId}, ${selectedTrackerId});
	});

</script>
