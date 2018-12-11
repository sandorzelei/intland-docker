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
<meta name="decorator" content="main"/>
<meta name="module" content="sysadmin"/>
<meta name="moduleCSSClass" content="newskin sysadminModule"/>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="uitaglib" prefix="ui" %>

<style type="text/css">
    table.displaytag {
        width: calc(100% - 30px) !important;
    }
</style>
<ui:actionMenuBar>
	<ui:pageTitle><spring:message code="isql.title" text="Interactive SQL"/></ui:pageTitle>
</ui:actionMenuBar>

<form:form commandName="iSqlForm">

<ui:actionBar>
	<spring:message code="isql.submit.title" text="Enter a SQL query or statement and"/>&nbsp;
	<spring:message var="goButton" code="isql.submit.button" text="GO"/>
	<spring:message var="performanceButton" code="isql.performance.button" text="Test Performance"/>

	<input type="submit" class="button" value="GO" value="${goButton}" />

	<input type="submit" class="button" name="performanceTest" value="${performanceButton}" />
	<c:url var="cancelUrl" value="/sysadmin.do"/>
	<spring:message code="button.cancel" text="Cancel" var="cancelLabel"/>
	<input type="button" class="button cancelButton" value="${cancelLabel}" onclick="location.href = '${cancelUrl}';"/>
</ui:actionBar>

<div class="contentWithMargins">
<label>Number of runs (only for performance test): </label>
<form:input type="number" path="numberOfRuns" min="1" max="1000"/>
<br />
<table border="0" width="100%" class="displaytag">

<tr>
	<td class="expandTextArea"><form:textarea path="command" rows="10" cols="120" /><br/><form:errors path="command" cssClass="invalidfield"/></td>
</tr>

</table>
</div>

</form:form>

<c:choose>
	<c:when test="${!empty resultSet}">
	<%--Can not get number of all records (because resultSet is not a collection, but an iterator),
		so just setting a very high number for "all" records --%>
		<ui:displaytagPaging defaultPageSize="100" itemNumber="10000" />

		<display:table excludedParams="command" requestURI="/sysadmin/isql.spr" name="resultSet" id="row" cellpadding="0" pagesize="${pagesize}" export="true" >
			<display:setProperty name="paging.banner.some_items_found" value="${allItems}" />
			<display:setProperty name="basic.empty.showtable" value="false" />

			<c:forEach items="${row.columnName}" var="column" varStatus="status">
				<c:set var="columnOffset" value="${status.count - 1}" />
				<c:set var="columnClass" value="${row.columnCss[columnOffset]}" />
				<c:set var="columnValue" value="${row.value[columnOffset]}" />

				<display:column title="${column}" class="${columnClass}" headerClass="${columnClass} columnSeparator" sortable="false">
					<c:out value="${columnValue}" />
				</display:column>
			</c:forEach>
		</display:table>
	</c:when>

	<c:when test="${!empty performanceResults}">
		<display:table name="performanceResults" id="msg" cellpadding="0" export="false" >
			<display:column title="Query" style="font-family: monospace;white-space: nowrap;" sortable="false">
				<c:out value="${msg.query}" />
			</display:column>
			<display:column title="Min" style="font-family: monospace;white-space: nowrap;" sortable="false">
				<b><c:out value="${msg.min}" /></b>
			</display:column>
			<display:column title="Max" style="font-family: monospace;white-space: nowrap;" sortable="false">
				<b><c:out value="${msg.max}" /></b>
			</display:column>
			<display:column title="Avg" style="font-family: monospace;white-space: nowrap;" sortable="false">
				<b><c:out value="${msg.avg}" /></b>
			</display:column>
			<c:forEach items="${msg.runs}" var="run" varStatus="loop">
				<display:column title="${loop.index + 1}" style="font-family: monospace;white-space: nowrap;" sortable="false">
					<c:choose>
						<c:when test="${msg_rowNum eq fn:length(performanceResults)}">
							<b><c:out value="${run}" /></b>
						</c:when>
						<c:otherwise>
							<span><c:out value="${run}" /></span>
					    </c:otherwise>
					</c:choose>
				</display:column>
			</c:forEach>
		</display:table>
	</c:when>
</c:choose>

