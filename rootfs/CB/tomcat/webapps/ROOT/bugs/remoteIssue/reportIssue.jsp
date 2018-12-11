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
--%>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<jsp:include page="header.jsp?step=submit&stepIndex=2"></jsp:include>

<c:url var="actionUrl" value="/remote/issue/create.spr" />

<div class="container">
	<form:form action="${actionUrl}" enctype="multipart/form-data" commandName="addUpdateTaskForm" method="POST" cssClass="ratingOnInlinedPopup">
		<form:hidden path="operatingSystem"/>
		<form:hidden path="databaseType"/>
		<form:hidden path="memory"/>
		<form:hidden path="diskSpace"/>
		<form:hidden path="releaseId"/>
		<form:hidden path="hostId"/>
		<form:hidden path="mode"/>
		<c:choose>
			<c:when test="${not empty mode}">
				<c:set var="layoutModeParameter" value="${mode}" scope="page" />
			</c:when>
			<c:otherwise>
				<c:set var="layoutModeParameter" value="mandatory" scope="page" />
			</c:otherwise>
		</c:choose>
		<jsp:include page="/bugs/addUpdateTask.jsp?layoutMode=${layoutModeParameter}&noActionMenuBar=true&noForm=true&nestedPath=null&noAssociation=true&noTrackerField=true&isPopup=true&minimal=true" />
	</form:form>
	<br/>

	<jsp:include page="footer.jsp?step=submit"></jsp:include>
</div>

