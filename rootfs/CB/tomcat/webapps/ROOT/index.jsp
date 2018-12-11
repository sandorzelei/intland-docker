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
<%@ taglib uri="acltaglib" prefix="acl" %>

<%
	String url = "/user";
%>
<acl:isAnonymousUser var="isAnonym" />
<c:if test="${isAnonym}">
<%
	url = "/login.spr";
%>
</c:if>
<%
	response.sendRedirect(request.getContextPath() + url);
%>
