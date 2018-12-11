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
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>

<meta name="decorator" content="popup"/>

<c:choose>
	<c:when test="${empty relationsHierarchyTo && empty relationsHierarchyFrom}">
		<c:set var="relationItem" value="${relationsHierarchyOrigin[0]}" scope="request" />
		<jsp:include page="noRelatedItems.jsp" />
	</c:when>
	<c:otherwise>
		<%-- items referenced by current issue --%>
		<c:set var="relationItems" value="${relationsHierarchyTo}" scope="request" />
		<c:set var="cssClass" value="outgoing-relations" scope="request" />
		<c:set var="showDescription" value="true" scope="request" />
		<jsp:include page="relationItems.jsp" />

		<%-- current issue --%>
		<c:set var="relationItems" value="${relationsHierarchyOrigin}" scope="request" />
		<c:set var="cssClass" value="relation-origin" scope="request" />
		<c:set var="showDescription" value="false" scope="request" />
		<jsp:include page="relationItems.jsp" />

		<%-- items referencing current issue --%>
		<c:set var="relationItems" value="${relationsHierarchyFrom}" scope="request" />
		<c:set var="cssClass" value="incoming-relations" scope="request" />
		<c:set var="showDescription" value="true" scope="request" />
		<jsp:include page="relationItems.jsp" />
	</c:otherwise>
</c:choose>
