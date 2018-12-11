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
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="taglib" prefix="tag" %>

<%@page import="com.intland.codebeamer.persistence.dto.ArtifactDto"%>
<%@page import="com.intland.codebeamer.persistence.dto.TrackerItemEscalationScheduleDto"%>

<%--
Small scriptlet to render user photo for tracker item histories. This is used to render
the <ui:userPhoto> from the tracker item history displaytag decorator code.

Parameters:
	request.item	The history entry
--%>

<%
	Object item = request.getAttribute("item");
	if (item instanceof ArtifactDto) { %>

		<ui:submission userId="${requestScope.item.owner.id}" userName="${requestScope.item.owner.name}" date="${requestScope.item.createdAt}"/>

<%	} else if (item instanceof TrackerItemEscalationScheduleDto) { %>

		<span class="subtext"><tag:formatDate value="${requestScope.item.dueAt}"/></span>

<%  } else { %>
	<c:choose>
		<c:when test="${! empty requestScope.item.submitter}" >
			<ui:submission userId="${requestScope.item.submitter.id}" userName="${requestScope.item.submitter.name}" date="${requestScope.item.submittedAt}"/>
		</c:when>
		<c:otherwise>
			<c:out value='${requestScope.item.submitterName}'/>
		</c:otherwise>
	</c:choose>
<% } %>
