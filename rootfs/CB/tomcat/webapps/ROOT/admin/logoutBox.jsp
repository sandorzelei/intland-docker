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
<%@ taglib uri="http://java.sun.com/jsp/jstl/core"   prefix="c" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>

<c:choose>
  <c:when test="${empty loggedOut}">
  	<spring:message var="realUserName" code="user.label" text="User" />
  </c:when>
  <c:otherwise>
  	<c:set var="realUserName" value="${loggedOut.realName}"/>
  </c:otherwise>
</c:choose>

<spring:message code="login.openIDConnect.logout.success" text="{0} was logged out successfully." arguments="${realUserName}" />
