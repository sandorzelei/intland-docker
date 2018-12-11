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

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="taglib" prefix="tag" %>
<%@ taglib uri="uitaglib" prefix="ui" %>

<c:url var="actionUrl" value="/proj/doc/history.do"/>

<div class="actionBar" style="padding-top: 9px; padding-bottom: 9px;">
<form action="${actionUrl}" method="GET">
	<input type="hidden" name="doc_id" value="${document.id}" />

	<table CELLPADDING="0" width="100%">
		<tr>
			<td width="80%" align="right" nowrap>
				<spring:message code="project.newMember.filter.label" text="Filter"/>:&nbsp;
				<spring:message var="filterTitle" code="project.newMember.filter.tooltip" text="Filter for Users"/>
				<input type="text" name="accessLogFilter" value="<c:out value='${accessLogFilter}'/>" title="${filterTitle}" size="25" class="searchFilterBox"/>
				&nbsp;
				<spring:message var="searchButton" code="search.submit.label" text="GO"/>
				<input type="submit" class="button" name="GO" value="${searchButton}" />
			</td>
		</tr>
	</table>
</form>
</div>

<table class="displaytag" CELLPADDING="0">
	<tr>
		<th class="textData"><spring:message code="document.accessLog.summary.label" text="Access Summary" />:</th>
		<th class="dateData columnSeparator"><spring:message code="document.accessLog.last2Days" text="Yesterday &amp; Today" /></th>
		<th class="dateData columnSeparator"><spring:message code="document.accessLog.thisWeek" text="This Week" /></th>
		<th class="dateData columnSeparator"><spring:message code="document.accessLog.last30Days" text="Last 30 Days" /></th>
		<th class="dateData"><spring:message code="document.accessLog.total" text="All" /></th>
	</tr>
	<tr class="odd">
		<td class="textData">&nbsp;</td>
		<td class="dateData columnSeparator" width="10%"><fmt:formatNumber value="${historyStatsVar.todayAccesses}" /></td>
		<td class="dateData columnSeparator" width="10%"><fmt:formatNumber value="${historyStatsVar.weekAccesses}" /></td>
		<td class="dateData columnSeparator" width="10%"><fmt:formatNumber value="${historyStatsVar.monthAccesses}" /></td>
		<td class="dateData" width="10%"><fmt:formatNumber value="${historyStatsVar.totalAccesses}" /></td>
	</tr>
</table>

<h3><spring:message code="document.accessLog.history.label" text="Access History" /></h3>

<display:table name="${accessLog}" id="accessLogEntry" requestURI="/proj/doc/details.do" excludedParams="orgDitchnetTabPaneId"
			sort="external" cellpadding="0" export="false" decorator="com.intland.codebeamer.ui.view.table.ArtifactAccessLogDecorator">
	<display:setProperty name="paging.banner.placement" value="none"/>

	<spring:message var="accessDate" code="document.accessLog.date.label" text="Date"/>
	<display:column title="${accessDate}" property="date" headerClass="dateData" class="dateData columnSeparator" style="width:10%" />

	<spring:message var="accessUser" code="document.accessLog.user.label" text="User"/>
	<display:column title="${accessUser}" property="name" headerClass="textData" class="textData columnSeparator" style="width:10%" />

	<spring:message var="accessVersion" code="document.accessLog.version.label" text="Version"/>
	<display:column title="${accessVersion}" property="version" headerClass="numberData" class="numberData" />

</display:table>

