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
 * $Revision: 23432:e1ea81dfd394 $ $Date: 2009-10-28 11:27 +0100 $
--%>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="taglib" prefix="tag" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>

<%@ page import="com.intland.codebeamer.taglib.TableCellCounter"%>

<style type="text/css">
	.newskin td.optional {
		padding-left: 0px;
	}

	.ditch-tab-skin-cb-box {
		margin-top: 0px;
	}
</style>

<%
	final int MAXCOLUMNS = 2;
	TableCellCounter tableCellCounter = new TableCellCounter(out, pageContext, MAXCOLUMNS, 2);
%>

<TABLE class="propertyTable" BORDER="0" class="formTableWithSpacing" CELLPADDING="3">

	<%	tableCellCounter.insertNewRow(); %>
	<TD CLASS="optional"><spring:message code="document.name.label" text="Name"/>:</TD>
	<TD CLASS="tableItem"><c:out value="${wikiPage.name}" /></TD>

	<%	tableCellCounter.insertNewRow(); %>
	<TD CLASS="optional"><spring:message code="document.description.label" text="Description"/>:</TD>
	<TD CLASS="tableItem"><tag:transformText value="${wikiPage.description}" format="${wikiPage.descriptionFormat}" default="--" /></TD>

	<%	tableCellCounter.insertNewRow(); %>
	<TD CLASS="optional"><spring:message code="document.lastModifiedAt.label" text="Modified"/>:</TD>
	<TD NOWRAP CLASS="tableItem"><tag:userLink user_id="${wikiPage.lastModifiedBy.id}" />
		<c:if test="${!empty wikiPage.lastModifiedBy.id}">
			<tag:formatDate value="${wikiPage.lastModifiedAt}" />
		</c:if>
	</TD>

	<%	tableCellCounter.insertNewRow(); %>
	<TD CLASS="optional"><spring:message code="wiki.page.id.label" text="Page ID"/>:</TD>
	<TD CLASS="tableItem"><c:out value="${wikiPage.id}" /></TD>

	<%	tableCellCounter.insertNewRow(); %>
	<TD CLASS="optional"><spring:message code="document.owner.label" text="Owner"/>:</TD>
	<TD CLASS="tableItem"><tag:userLink user_id="${wikiPage.owner.id}" /></TD>

	<%	tableCellCounter.insertNewRow(); %>
	<TD CLASS="optional"><spring:message code="document.status.label" text="Status"/>:</TD>
	<TD CLASS="tableItem">
		<c:choose>
			<c:when test="${empty wikiPage.status}">
				--
			</c:when>
			<c:otherwise>
				<spring:message code="document.status.${wikiPage.status.name}" text="${wikiPage.status.name}"/>
			</c:otherwise>
		</c:choose>
	</TD>

	<%	tableCellCounter.insertNewRow(); %>
	<TD CLASS="optional"><spring:message code="document.createdAt.label" text="Created"/>:</TD>
	<TD CLASS="tableItem"><tag:formatDate value="${wikiPage.createdAt}" /></TD>

	<%	tableCellCounter.insertNewRow(); %>
	<TD CLASS="optional"><spring:message code="document.version.label" text="Version"/>:</TD>
	<TD CLASS="tableItem"><c:out value="${wikiPage.version}" /></TD>

	<%	tableCellCounter.insertNewRow(); %>
	<c:choose>
		<c:when test="${empty pageLock}">
			<TD CLASS="optional"><spring:message code="document.lock.label" text="Lock"/>:</TD>
			<TD CLASS="tableItem"><spring:message code="document.unlocked.label" text="Unlocked"/></TD>
		</c:when>

		<c:when test="${pageLock.temporary}">
			<TD CLASS="optional"><spring:message code="document.lock.label" text="Lock"/>:</TD>
			<TD CLASS="tableItem">
				<spring:message code="document.editedBy.label" text="Currently edited by"/>
				<tag:userLink user_id="${pageLock.userId}" />
			</TD>
		</c:when>

		<c:otherwise>
			<TD CLASS="optional"><spring:message code="document.lockedBy.label" text="Locked by"/>:</TD>
			<TD NOWRAP CLASS="tableItem"><tag:userLink user_id="${pageLock.userId}" />&nbsp;</TD>
		</c:otherwise>
	</c:choose>

	<%	tableCellCounter.insertNewRow(); %>
	<TD CLASS="optional"><spring:message code="document.fileSize.label" text="Size"/>:</TD>

	<c:choose>
		<c:when test="${wikiPage.fileSize lt 1024}">
			<fmt:formatNumber var="humanSize" maxFractionDigits="0"	value="${wikiPage.fileSize}" />
			<c:set var="humanSize" value="${humanSize} Byte" />
		</c:when>

		<c:when test="${wikiPage.fileSize gt 1024*1014}">
			<fmt:formatNumber var="humanSize" maxFractionDigits="2"	value="${(wikiPage.fileSize)/1024.0/1024.0}" />
			<c:set var="humanSize" value="${humanSize} MB" />
		</c:when>

		<c:otherwise>
			<fmt:formatNumber var="humanSize" maxFractionDigits="1"	value="${wikiPage.fileSize/1024.0}" />
			<c:set var="humanSize" value="${humanSize} KB" />
		</c:otherwise>
	</c:choose>

	<TD CLASS="tableItem"><c:out value="${humanSize}" />&nbsp;(<fmt:formatNumber value="${wikiPage.fileSize}" /> Bytes)</TD>

	<%	tableCellCounter.insertNewRow(); %>
	<TD CLASS="optional"><spring:message code="document.keptHistoryEntries.label" text="Max. Versions"/>:</TD>

	<c:set var="versions" value="${wikiPage.additionalInfo.keptHistoryEntries}" />
	<c:choose>
		<c:when test="${empty versions or versions == -1}">
			<spring:message var="versionsString" code="document.keptHistoryEntries.all" text="All"/>
		</c:when>

		<c:when test="${versions == 0}">
			<spring:message var="versionsString" code="document.keptHistoryEntries.none" text="None"/>
		</c:when>

		<c:when test="${versions == 1}">
			<spring:message var="versionsTxt" code="document.keptHistoryEntries.prev" text="Previous"/>
		</c:when>

		<c:otherwise>
			<spring:message var="versionsString" code="document.keptHistoryEntries.lastX" text="Last {0}" arguments="${versions}"/>
		</c:otherwise>
	</c:choose>
	<TD CLASS="tableItem"><c:out value="${versionsString}" /></TD>

<c:forEach items="${attributes}" var="attribute">
	<%	tableCellCounter.insertNewRow(); %>
	<TD CLASS="optional" title="<c:out value="${attribute.key.title}" />">&nbsp;<c:out value="${attribute.key.label}"/>:</TD>
	<TD CLASS="tableItem"><c:out value="${attribute.value}" default="--"/></TD>
</c:forEach>

</TABLE>
