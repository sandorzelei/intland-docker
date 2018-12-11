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

<meta name="decorator" content="main"/>
<meta name="module" content="project_browser"/>
<meta name="moduleCSSClass" content="workspaceModule newskin"/>

<jsp:include page="./includes/listProjectsActionBar.jsp" flush="true"></jsp:include>

<c:choose>
	<c:when test="${displayAllProjects}">
		<jsp:include page="includes/sharedProjectsBrowser.jsp" />
	</c:when>

	<c:otherwise>
		<jsp:include page="includes/listMyProjects.jsp" />
	</c:otherwise>
</c:choose>
