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
<meta name="module" content="queries"/>
<meta name="moduleCSSClass" content="newskin reportModule"/>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="taglib" prefix="tag" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>

<tag:document var="document" doc_id="${param.doc_id}" scope="request" />

<ui:actionMenuBar>
		<ui:breadcrumbs showProjects="false"> :
			<ui:pageTitle prefixWithIdentifiableName="false"><spring:message code="report.export.wiki.title" text="Wiki Export Report Results"/></ui:pageTitle>
		</ui:breadcrumbs>
</ui:actionMenuBar>

<c:url var="cancelURL" value="/proj/report.do" />

<TABLE>
	<TR>
		<TD CLASS="textData">
			<spring:message code="report.export.wiki.result" text="Wiki export results"/>:
		</TD>
	</TR>

	<TR>
		<TD CLASS="expandTextArea">
			<TEXTAREA COLS="120" ROWS="25"><c:out value="${wikiExport}" /></TEXTAREA>
		</TD>
	</TR>

	<TR>
		<TD>&nbsp;</TD>
	</TR>

	<TR>
		<TD>
			<spring:message var="cancelButton" code="button.cancel" text="Cancel"/>
			<INPUT TYPE="button" VALUE="${cancelButton}" CLASS="button cancelButton" ONCLICK="document.location.href='${cancelURL}'">
		</TD>
	</TR>

</TABLE>
