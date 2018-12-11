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

<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>


<c:set var="user" value="${pageContext.request.userPrincipal}" />

<TABLE WIDTH="160" BORDER="0" CELLSPACING="0" CELLPADDING="0">
<TR>
	<TD TITLE="<c:out value="${user.lastName},${user.firstName}" />">
		<STRONG>Logged in: <c:out value="${user.name}" /></STRONG>
	</TD>
</TR>
<TR>
	<%-- Just a gap --%>
	<TD>&nbsp;</TD>
</TR>
</TABLE>
