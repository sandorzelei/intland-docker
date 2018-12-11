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
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>

<%@ taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>

<%@ taglib uri="taglib" prefix="tag" %>
<%@ taglib uri="report" prefix="report" %>

<%@ taglib uri="log" prefix="log" %>
<%@ taglib uri="uitaglib" prefix="ui" %>

<%@page import="com.intland.codebeamer.ui.view.table.TrackerReportDecorator"%>
<%@page import="com.intland.codebeamer.servlet.report.MergedTrackerReportQuery"%>

<meta name="decorator" content="main"/>
<meta name="module" content="${module}"/>
<meta name="moduleCSSClass" content="newskin ${moduleCSSClass}"/>

<ui:actionMenuBar>
		<ui:breadcrumbs showProjects="false">
			<span class="breadcrumbs-separator">&raquo;</span><ui:pageTitle prefixWithIdentifiableName="false"><spring:message code="report.result.title" text="Report Results"/></ui:pageTitle>
		</ui:breadcrumbs>
</ui:actionMenuBar>

<ui:actionBar>
	<ui:actionGenerator builder="reportsListContextActionMenuBuilder" subject="${documentRevision}" actionListName="actions" >
		<ui:actionLink keys="customize, export, run" actions="${actions}" />
	</ui:actionGenerator>
</ui:actionBar>

<div class="descriptionBox">
	<tag:transformText value="${document.description}" format="${document.descriptionFormat}" />
</div>

<%--
		<c:url var="csvURL" value="/exportTrackerReportResults/${document.name}.xls">
			<c:param name="doc_id" value="${document.id}" />
		</c:url>
		&nbsp;&nbsp;<html:link href="${csvURL}${pars}">Export to Excel</html:link>
--%>
<%--
		<c:url var="mmURL" value="/exportTrackerReportResults/${document.name}.mm">
			<c:param name="doc_id" value="${document.id}" />
			<c:param name="type" value="mm" />
		</c:url>
		&nbsp;&nbsp;<html:link href="${mmURL}${pars}">Export to Mindmap</html:link>
--%>
<%--
	&nbsp;&nbsp;<html:button styleClass="button" property="EXPORT"
		onclick="document.location.href='${csvURL}'; return false" value="Export" />
--%>

<report:execute doc_id="${document.id}" revision="${param.revision}"/>

<c:set var="CMDB" value="${report.CMDB}" />
<c:set var="merged" value="${report.merged}" />

<c:if test="${!merged && fn:length(reportQueries) > 1}">
	<c:set var="totalFetched" value="0" />
	<c:forEach items="${reportQueries}" var="query">
		<c:set var="totalFetched" value="${totalFetched + query.page.fullListSize}" />
	</c:forEach>

	<ui:title style="top-sub-headline" >
		<spring:message code="report.result.total" text="Totally found {0} records." arguments="${totalFetched}"/>
	</ui:title>
</c:if>

<c:set var="cnt" value="0" />
<c:forEach var="query" items="${reportQueries}">
	<log:debug value="Fields: ${query.fields}"/>
	<c:set var="cnt" value="${cnt + 1}" />

	<c:set var="summary" value="${query.summaryFieldCharts}" />
	<c:set var="page"    value="${query.page}" />
	<c:set var="fetched" value="${page.fullListSize}" />

	<c:choose>
		<c:when test="${merged}">
			<ui:title style="top-sub-headline" >
				<spring:message code="report.merged.label" text="Merged Report"/>
				<spring:message code="report.query.total" text="found {0} records." arguments="${fetched}"/>
			</ui:title>
		</c:when>

		<c:otherwise>
			<c:url var="projectLink" value="${query.tracker.project.urlLink}"/>
			<c:url var="trackerLink" value="${query.tracker.urlLink}"/>
			<ui:title style="top-sub-headline-decoration" >
				<spring:message code="${CMDB ? 'cmdb.category' : 'tracker'}.label"/>:&nbsp;
				<html:link href="${projectLink}"><c:out value='${query.tracker.project.name}'/></html:link>
				&nbsp;-&nbsp;
				<html:link href="${trackerLink}"><spring:message code="tracker.${query.tracker.name}.label" text="${query.tracker.name}" htmlEscape="true"/></html:link>
				<spring:message code="report.query.total" text="found {0} records." arguments="${fetched}"/>
			</ui:title>
		</c:otherwise>
	</c:choose>

	<c:if test="${!empty summary}">
		<table cellpadding="0" cellspacing="0">
	  		<tr>
	  			<c:forEach items="${summary}" var="summaryField">
					<td valign="top">
						<table class="displaytag" style="margin-right: 4px;">
							<tr>
								<th align="left" colspan="2">
									<spring:message code="tracker.field.${summaryField.key.label}.label" text="${summaryField.key.labelWithoutBR}"/>
								</th>
							</tr>
	  						<c:forEach items="${summaryField.value}" var="valueChart">
								<tr>
									<td align="left" style="padding: 1px;">
										<spring:message code="tracker.choice.${valueChart.labelName}.label" text="${valueChart.labelName}"/>
									</td>
									<td align="right" style="padding: 1px;">
										<c:out value="${valueChart.totalCount}" />
									</td>
								</tr>
							</c:forEach>
						</table>
					</td>
					<td valign="top" style="width: 10px;">
					</td>
	  			</c:forEach>
			</tr>
		</table>
		<br/>
	</c:if>

	<%
		// create the decorator instance for the report
		MergedTrackerReportQuery query = (MergedTrackerReportQuery) pageContext.findAttribute("query");

		TrackerReportDecorator trackerReportDecorator = new TrackerReportDecorator(request);
		trackerReportDecorator.setClearNavigationList(Boolean.TRUE);
		request.setAttribute("trackerReportDecorator", trackerReportDecorator);
	%>

<%--
The default sort order of displaytag table is the same as the first column
of ORDER BY statement of the source SQL, when it's calculationg first time.
This is kind of trick. The list of data come from SQL query already sorter
at least by the first column in statement. Thus, when the displaytag
tries to resort the list it will not change the order of records
becase the data already sorted at least by the first column in ORDER BY statement.
It seems the solution is correct.
--%>
	<display:table requestURI="/proj/report/execute.do" sort="external" defaultsort="${query.defaultSort}" defaultorder="${query.defaultOrder}"
		name="${page}" id="item-${cnt}" cellpadding="0" class="relationsExpander"
		decorator="trackerReportDecorator">

		<display:setProperty name="pagination.pagenumber.param"    value="page-${cnt}" />
		<display:setProperty name="pagination.sort.param"          value="sort-${cnt}" />
		<display:setProperty name="pagination.sortdirection.param" value="dir-${cnt}" />
		<display:setProperty name="paging.banner.all_items_found"><spring:message code="paging.all.banner"/></display:setProperty>
		<display:setProperty name="paging.banner.onepage" value="" />
		<display:setProperty name="paging.banner.placement" value="${empty page.list ? 'none' : (fn:length(page.list) > 15 ? 'both' : 'bottom')}"/>

		<c:forEach items="${query.fields}" var="fieldLayout" varStatus="loopStatus">
			<spring:message var="label" code="tracker.field.${fieldLayout.label}.label" text="${fieldLayout.label}"/>
			<spring:message var="title" code="tracker.field.${fieldLayout.title}.label" text="${fieldLayout.title}"/>
			<spring:message var="labelWithoutBR" code="tracker.field.${fieldLayout.labelWithoutBR}.label" text="${fieldLayout.labelWithoutBR}"/>
			<c:set var="property" value="${fieldLayout.property}" />
			<c:set var="sortProperty" value="${fieldLayout.sortProperty}" />
			<c:set var="headerStyleClass" value="${fieldLayout.headerStyleClass}" />
			<c:set var="styleClass" value="${fieldLayout.styleClass}" />

			<%-- Html view --%>
			<display:column title="${empty title ? label : title}" property="${property}"
				headerClass="${headerStyleClass}" class="${styleClass} columnSeparator"
				sortable="true" sortProperty="${sortProperty}"
				media="html" />

			<%-- Export view --%>
			<display:column title="${labelWithoutBR}" property="${property}"
				headerClass="${headerStyleClass}" class="${styleClass}"
				media="excel xml csv pdf" />
		</c:forEach>
	</display:table>

</c:forEach>
