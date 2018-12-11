<%--
 * Copyright by Intland Sofware
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

<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>

<%@ taglib uri="taglib" prefix="tag" %>
<%@ taglib uri="uitaglib" prefix="ui" %>

<TABLE CLASS="displaytag" BORDER="0" CELLSPACING="0" CELLPADDING="0">
	<TR CLASS="head">
		<TH CLASS="numberData"><spring:message code="document.accessLog.last2Days" text="Yesterday &amp; Today"/></TH>
		<tag:tableColumnSeparator header="true" />

		<TH CLASS="numberData"><spring:message code="document.accessLog.thisWeek" text="This Week"/></TH>
		<tag:tableColumnSeparator header="true" />

		<TH CLASS="numberData"><spring:message code="document.accessLog.last30Days" text="Last 30 Days"/></TH>
		<tag:tableColumnSeparator header="true" />

		<TH CLASS="numberData"><spring:message code="document.accessLog.total" text="All"/></TH>
	</TR>

	<TR>
		<TD CLASS="numberData">
			<c:url var="link" value="/repository/${repository.id}/changesets">
				<c:param name="range" value="day" />
			</c:url>
			<html:link href="${link}"><fmt:formatNumber value="${commitsStat.yesterday}" /></html:link>
		</TD>

		<tag:tableColumnSeparator />

		<TD CLASS="numberData">
			<c:url var="link" value="/repository/${repository.id}/changesets">
				<c:param name="range" value="week" />
			</c:url>
			<html:link href="${link}"><fmt:formatNumber value="${commitsStat.thisWeek}" /></html:link>
		</TD>

		<tag:tableColumnSeparator />

		<TD CLASS="numberData">
			<c:url var="link" value="/repository/${repository.id}/changesets">
				<c:param name="range" value="month" />
			</c:url>
			<html:link href="${link}"><fmt:formatNumber value="${commitsStat.last30Days}" /></html:link>
		</TD>

		<tag:tableColumnSeparator />

		<TD CLASS="numberData">
			<c:url var="link" value="/repository/${repository.id}/changesets"/>
			<html:link href="${link}"><fmt:formatNumber value="${commitsStat.all}" /></html:link>
		</TD>
	</TR>
</TABLE>
