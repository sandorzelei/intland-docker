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
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="taglib" prefix="tag" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>

<%@page import="com.intland.codebeamer.search.Indexer"%>

<SCRIPT LANGUAGE="JavaScript" type="text/javascript">
<!-- Hide script from old browsers
function confirmReindexing() {
	return confirm('<spring:message code="indexing.reindex.confirm" />');
}
// -->
</SCRIPT>

<ui:actionMenuBar>
	<ui:pageTitle><spring:message code="indexing.title" text="Indexing"/></ui:pageTitle>
</ui:actionMenuBar>

<%
	pageContext.setAttribute("info", Indexer.getInstance().getInfo());
%>

<c:url var="url" value="/sysadmin/reindex.spr" />
<c:set var="warning" value="" />
<form:form action="${url}">
	<c:if test="${!info.running}">
	<ui:actionBar>
		<input type="submit" class="button" onclick="return confirmReindexing();" value='<spring:message code="indexing.reindex.yes"/>' />
		<spring:message code="button.cancel" text="Cancel" var="cancelLabel"/>
		<input type="submit" class="cancelButton button" name="_cancel" value="${cancelLabel}" />
	</ui:actionBar>

	<c:set var="warning">
	<div class="warning">
		<spring:message code="indexing.reindex.hint" text="Re-indexing can take several minutes depending on the number of entities and on the hardware configuration."/><br>
		<spring:message code="indexing.reindex.question" text="Do you want to re-index search database?"/>
	</div>
	</c:set>

	</c:if>
</form:form>

<div class="contentWithMargins">
${warning}

<TABLE BORDER="0" CELLPADDING="2" class="formTableWithSpacing">
	<TR>
		<TH colspan="2"><spring:message code="indexing.reindex.status.label" text="Indexer Status"/></TH>
	</TR>

	<TR>
		<TD class="optional"><spring:message code="indexing.reindex.running.label" text="Running"/>:</TD>
		<TD>
			<c:choose>
				<c:when test="${info.running}"><spring:message code="button.yes" text="Yes"/></c:when>
				<c:otherwise><spring:message code="button.no" text="No"/></c:otherwise>
			</c:choose>
		</TD>
	</TR>

<c:if test="${info.running}">
	<TR>
		<TD class="optional"><spring:message code="indexing.reindex.since.label" text="Since"/>:</TD>
		<TD><tag:formatDate value="${info.lastExecution}" /></TD>
	</TR>
</c:if>

<c:if test="${!info.running}">
	<TR>
		<TD class="optional"><spring:message code="indexing.reindex.lastExecution.label" text="Last execution"/>:</TD>
		<TD><tag:formatDate value="${info.lastExecution}" /></TD>
	</TR>

	<TR>
		<TD class="optional"><spring:message code="indexing.reindex.nextExecution.label" text="Next full indexing after"/>:</TD>
		<TD><tag:formatDate value="${info.nextFullIndexingAfter}" /></TD>
	</TR>
</c:if>

	<TR>
		<TD class="optional"><spring:message code="indexing.reindex.artifacts.label" text="Artifacts"/>:</TD>
		<TD><fmt:formatNumber value="${info.documents}" /></TD>
	</TR>
</TABLE>
</div>
