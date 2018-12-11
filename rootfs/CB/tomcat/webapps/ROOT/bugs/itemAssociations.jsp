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
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>

<%@ taglib uri="taglib" prefix="tag" %>
<%@ taglib uri="uitaglib" prefix="ui" %>

<%@page import="com.intland.codebeamer.remoting.GroupType"%>

<%
request.setAttribute("TRACKER_ITEM", new Integer(GroupType.TRACKER_ITEM));
%>

<spring:message var="nothingFound" code="table.nothing.found" />

<c:if test="${empty taskRevision.baseline}">
	<div class="actionBar">
		<c:out value="${param.associationsTitle}" />
		<ui:actionLink keys="addAssociation" actions="${taskActions}" />
	</div>
</c:if>

<jsp:include page="/association/associationList.jsp" flush="true" />

