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
<%@ page import="com.intland.codebeamer.ui.view.table.TrackerSimpleLayoutDecorator"%>
<%@ page import="com.intland.codebeamer.controller.testmanagement.TestRunHistoryController" %>

<%@ taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>

<%
	request.setAttribute("decorator", new TrackerSimpleLayoutDecorator());
%>

<spring:message code="testrunner.release.label" var="releaseLabel" text="Release"/>
<spring:message code="testrunner.configuration.label" var="configurationLabel" text="Configuration"/>
<spring:message code="tracker.field.Running Time.label" var="runningTimeLabel" text="Running Time"/>
<spring:message code="tracker.field.Result.label" var="resultLabel" text="Result"/>
<spring:message code="tracker.type.Testrun" var="testRunLabel"/>
<spring:message code="tracker.field.Assigned to.label" var="runByLabel" text="Assigned to"/>
<spring:message code="tracker.field.Submitted at.label" var="submittedAtLabel"/>
<spring:message code="testrun.results.plugin.completed.at" var="completedAtLabel" />
<spring:message code="tracker.field.Status.label" var="statusLabel" text="Status"/>
<spring:message code="tracker.field.Test Cases.label" var="testCasesLabel" text="Test Cases"/>
<spring:message code="tracker.testRun.statistics.label" var="statisticsLabel" text="Statistics"/>
<spring:message code="tracker.testRun.runnableVsAllTestCases.tooltip" var="runnableVsAllTestCasesTooltip" />

<style type="text/css">
	#filter select, #filter .calendarAnchorLink {
		margin-right: 40px;
	}
</style>
<script type="text/javascript">
    function submitWithFilter(params) {
        var $form = $("#filter");
        var formParams = $form.serialize();

        if (params) {
            formParams += ("&" + params);
        }

        var url = contextPath + "<%= TestRunHistoryController.URL%>?" + formParams;
        console.log("Loading url: " + url);

        var $el = $("#testRunsLazyLoad");
        $.get({
                "url": url,
                "cache": false
            },
            function(data) {
                $el.html(data);
            }).fail(
            function(err) {
                $el.html("<div class='error'>" + escapeHtml(err.responseText) + "</div>");
            }
        );

        return false;
    }

    function initEvents() {
        var $container = $("#testRunsLazyLoad");

        // the paging should do an ajax reload too:
        $container.find(".pagelinks a").click(function(event) {
            var $a = $(this);
            var href = $a.attr("href");
            if (href.startsWith("?")) {
                href = href.substring(1);
            }

            submitWithFilter(href);
            return false;
        });

        // the ajax reload for show-all links
        $container.find(".pagebanner a").click(function(event) {
            submitWithFilter("pagesize=99999");
            return false;
        });
    }

    $(initEvents);
</script>

<form:form cssClass="filterForm actionBar" id="filter" method="GET" onsubmit="return submitWithFilter();" >
	<input type="hidden" name="task_id" value="${command.task_id}" />
    <input type="hidden" name="revision" value="${command.revision}" />

    <c:if test="${not empty releases }">
		<label><spring:message code="testrunner.release.label" text="Release"/>:</label>
		<select name="releaseId">
			<c:forEach items="${releases}" var="release">
				<option value="${release.id}" ${release.id == command.releaseId ? 'selected' : ''}>
					<c:out value='${release.name}'/>
				</option>
			</c:forEach>
		</select>
	</c:if>

	<c:if test="${not empty configurations }">
		<label><spring:message code="testrunner.configuration.label" text="Configuration"/>:</label>
		<select name="configurationId">
			<c:forEach items="${configurations}" var="configuration">
				<option value="${configuration.id}"  ${configuration.id == command.configurationId ? 'selected' : ''}>
					<c:out value='${configuration.name}'/>
				</option>
			</c:forEach>
		</select>
	</c:if>

	<c:if test="${not empty assignees }">
		<label><spring:message code="testcase.run.by" text="Run by"/>:</label>
		<select name="assigneeId">
			<c:forEach items="${assignees}" var="assignee">
				<option value="${assignee.id}"  ${assignee.id == command.assigneeId ? 'selected' : ''}>
					<c:out value='${assignee.name}'/>
				</option>
			</c:forEach>
		</select>
	</c:if>

	<spring:message code="duration.after.label" text="After"/>:
	<input name="lastRunFrom" size="12" maxlength="30" id="lastRunFrom" type="text" value="<c:out value='${command.lastRunFrom}' />"/>
	<ui:calendarPopup textFieldId="lastRunFrom" otherFieldId="lastRunTo" />

	<spring:message code="duration.before.label" text="Before"/>:
	<input name="lastRunTo" size="12" maxlength="30" id="lastRunTo"type="text" value="<c:out value='${command.lastRunTo}' />"/>
	<ui:calendarPopup textFieldId="lastRunTo" otherFieldId="lastRunTo"/>

	<spring:message code="search.submit.label" text="GO" var="submitLabel"/>
	<input type="submit" value="${submitLabel }"/>
</form:form>

<style type="text/css">
	td.wrappable {
		white-space: normal !important;
	}
</style>

<c:set var="requestURI" value=""/> <%-- url is not important: the paging is done via ajax reload!  --%>
<ui:displaytagPaging items="${testRuns}" requestURI="${requestURI}" excludedParams="testrun-page" />

<display:table requestURI="${requestURI}" name="${testRuns}" id="item" decorator="decorator" cellpadding="0" cellspacing="0"
    excludedParams="*"
>
	<c:set var="testRun" value="${testRunMap[item.id]}"/>

	<display:setProperty name="pagination.pagenumber.param"    value="testrun-page" />
	<display:setProperty name="pagination.sort.param"          value="testrun-sort" />
	<display:setProperty name="pagination.sortdirection.param" value="testrun-dir" />

    <display:setProperty name="basic.empty.showtable" value="false" />

	<display:setProperty name="paging.banner.placement" value="bottom"/>
	<display:setProperty name="paging.banner.some_items_found" value="${allItems}" />
	<display:setProperty name="paging.banner.item_name">${testRunLabel}</display:setProperty>
	<display:setProperty name="paging.banner.items_name"><spring:message code="tracker.type.Testrun.plural"/></display:setProperty>

	<display:column title="${testRunLabel}" class="textData columnSeparator expandText" sortable="false" >
		<c:url value='${empty taskRevision.baseline ? item.urlLink : item.getUrlLinkBaselined(taskRevision.baseline.id)}' var="testRunUrl"/>

		<a href="${testRunUrl }">[<c:out value="${item.keyAndId}"/>]&nbsp;<c:out value="${item.name}"/></a>
	</display:column>

	<display:column title="${releaseLabel}" property="versions" class="textData columnSeparator expandText" sortable="false"/>

	<display:column title="${configurationLabel}" property="platforms" class="textData columnSeparator expandText" sortable="false"/>

<%--
	<c:if test="${task.tracker.testSet}">
		<display:column title="${statusLabel}" property="status" class="textData columnSeparator expandText" sortable="false"/>
	</c:if>
--%>

	<display:column title="${resultLabel}" property="testRunResultOrStatus" class="textData columnSeparator expandText" sortable="false"/>

	<display:column title="${runByLabel}" property="assignedTo" class="wrappable textData columnSeparator expandText" sortable="false"/>

	<display:column title="${runningTimeLabel}" class="textData columnSeparator expandText" sortable="false">
		<c:out value="${testRun.runtimeFormatted}"/>
	</display:column>


<%--
	<display:column title="${submittedAtLabel}" property="submittedAt" class="textData columnSeparator expandText" sortable="false"/>
--%>

	<c:if test="${task.tracker.testSet}">
		<display:column title="${testCasesLabel}" class="textData columnSeparator expandText" sortable="false">
			<c:set var="runnableTestCasesCount" value="${testRun.runnableTestCasesCount}" />
			<c:set var="testCaseCount" value="${testRun.testCaseCount}" />
			<c:choose>
				<c:when test="${runnableTestCasesCount == testCaseCount}">
					<c:out value="${testCaseCount}"/>
				</c:when>
				<c:otherwise>
					<span title="${runnableVsAllTestCasesTooltip}" class="wiki-warning" style="padding:0 5px;">
						<c:out value="${runnableTestCasesCount}"/> / <c:out value="${testCaseCount}"/>
					</span>
				</c:otherwise>
			</c:choose>
		</display:column>
	</c:if>

	<c:if test="${task.tracker.testSet}">
		<display:column title="${statisticsLabel}" class="columnSeparator expandText" sortable="false" >
			<ui:testingProgressBar engine="${testRunnerEngines[item]}" showCounts="true" hideTotal="true" />
		</display:column>
	</c:if>

	<display:column title="${completedAtLabel}" property="closedAt" class="textData columnSeparator expandText" sortable="false"/>

</display:table>