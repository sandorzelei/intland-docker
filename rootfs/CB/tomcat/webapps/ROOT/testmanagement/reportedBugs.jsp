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
--%>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="taglib"   prefix="tag"%>

<%-- Render the reported bugs for a TestCase --%>
<div class="reportedBugs">

<style type="text/css">
	.reportedBugs .submitterTable td {
		padding-top:0;
		padding-bottom:0;
	}
</style>

<form:form>
<div class="filterForm actionBar" >
	<label><spring:message code="testrunner.bug.report.select.existing.bug.reported.from" text="From"/>:</label>

	<form:hidden path="allRelatedBugs"/>
	<form:select id="fromMonths" path="fromMonths">
		<form:option value="3"><spring:message code="testrunner.bug.report.select.existing.bug.reported.from.months" arguments="3"/></form:option>
		<form:option value="6" ><spring:message code="testrunner.bug.report.select.existing.bug.reported.from.months" arguments="6"/></form:option>
		<form:option value="12"><spring:message code="testrunner.bug.report.select.existing.bug.reported.from.one.year" /></form:option>
	</form:select>

	<script type="text/javascript">
		function reload(dateFilter) {
			var $el = $(dateFilter);

			var params = $el.closest("form").serialize();
			console.log("Reloading as filter changed:" + params);

			var reload = $el.closest(".reportedBugs").parent();

			reportedBugsLazyLoad(reload, "${command.testCaseId}", params, true).done(function() {
				$(".reportedBugs").trigger("loaded");
			});
		}

		$("#fromMonths").change(function() {
			reload(this);
		});
	</script>
</div>

<c:choose>
	<c:when test="${reportedBugs.isEmpty()}">
		<p>
			<spring:message code="table.nothing.found" />
		</p>
	</c:when>
	<c:otherwise>
		<display:table class="expandText" requestURI="" name="${reportedBugs}" id="bug" cellpadding="0"
			defaultsort="1" defaultorder="descending" export="false" excludedParams="orgDitchnetTabPaneId">

			<spring:message var="submitter" code="tracker.field.Submitter.label" text="Submitter"/>
			<display:column title="${submitter}" sortProperty="submittedAt" sortable="false" headerClass="textData"
			 	class="textData columnSeparator">
				<ui:submission cssClass="submitterTable"
				 userId="${bug.submitter.id}" userName="${bug.submitter.name}" date="${bug.submittedAt}"/>
			</display:column>

			<spring:message var="title" code="tracker.field.Reported as.label" text="Reported Bug(s)"/>
			<c:if test="${command.allRelatedBugs}">
				<spring:message var="title" code="testrunner.bug.report.select.existing.bug.related.bugs" text="Related Bug(s)"/>
			</c:if>
			<display:column title="${title}" headerClass="textData" class="textDataWrap reportedBug" >
				<ui:wikiLink item="${bug}" />
			</display:column>
		</display:table>
	</c:otherwise>
</c:choose>

</div>
</form:form>