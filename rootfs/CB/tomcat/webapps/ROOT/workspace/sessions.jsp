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
<meta name="decorator" content="main"/>
<meta name="module" content="mystart"/>
<meta name="moduleCSSClass" content="workspaceModule"/>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="taglib" prefix="tag" %>
<%@ taglib uri="log" prefix="log" %>
<%@ taglib uri="uitaglib" prefix="ui" %>

<%@ page import="com.intland.codebeamer.security.acl.Ellenorzo"%>

<%
	pageContext.setAttribute("userSessions", Ellenorzo.getUserSessions(request));

	int counter = 0;
%>

<ui:actionMenuBar>
	<ui:pageTitle>Active Sessions of Account: <c:out value="${userName}" /></ui:pageTitle>
</ui:actionMenuBar>


<html:form action="/invalidateUserSessions">

<html:hidden property="targetURL" value="${param.targetURL}" />

<TABLE BORDER="0" CELLSPACING="0" CELLPADDING="0">

<TR CLASS="head">
	<TH>&nbsp;</TH>

	<TH ALIGN="left" NOWRAP>&nbsp;Last Access Time&nbsp;</TH>

	<tag:tableColumnSeparator header="true" />

	<TH ALIGN="left" NOWRAP>&nbsp;Host&nbsp;</TH>

	<tag:tableColumnSeparator header="true" />

	<TH ALIGN="left" NOWRAP>&nbsp;Session&nbsp;</TH>
</TR>

<c:forEach items="${userSessions}" var="userSession">

	<log:info value="Address: <${pageContext.request.remoteAddr}> <${userSession.remoteAddr}>" />

	<TR CLASS="<%=((counter++ % 2) == 0 ? "even" : "odd")%>">

	<TD>
		<c:if test="${pageContext.request.remoteAddr == userSession.remoteAddr}">
			<INPUT TYPE="CHECKBOX" NAME="sessionId"
				VALUE="<c:out value="${userSession.id}" />" CHECKED />
		</c:if>
	</TD>

	<TD NOWRAP>&nbsp;<tag:formatDate value="${userSession.lastAccessedDate}" />&nbsp;</TD>

	<tag:tableColumnSeparator />

	<TD NOWRAP>&nbsp;<c:out value="${userSession.remoteHost}" />&nbsp;</TD>

	<tag:tableColumnSeparator />

	<TD NOWRAP>&nbsp;<c:out value="${userSession.id}" />&nbsp;</TD>

	</TR>
</c:forEach>


<TR>
	<TD HEIGHT="4"></TD>
</TR>

<TR>
	<TD COLSPAN="6">
		&nbsp;&nbsp;<html:submit styleClass="button"
			property="KILL" value="Kill Selected Sessions" />

		&nbsp;&nbsp;<html:submit styleClass="button"
			property="CONTINUE" value="Keep All Sessions" />
	</TD>
</TR>

</TABLE>

</html:form>
