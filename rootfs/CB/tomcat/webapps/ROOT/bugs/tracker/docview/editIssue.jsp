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

<meta name="decorator" content="popup"/>

<c:choose>
	<c:when test="${addUpdateTaskForm.trackerItem.id == null}">
		<c:url var="actionUrl" value="/docview/createIssue.spr" />
	</c:when>
	<c:otherwise>
		<c:url var="actionUrl" value="/cardboard/editCard.spr" />
		<input type="hidden" value="${addUpdateTaskForm.trackerItem.id}" id="cardId"/>
	</c:otherwise>
</c:choose>

<form:form action="${actionUrl}" enctype="multipart/form-data" commandName="addUpdateTaskForm" method="POST" cssClass="ratingOnInlinedPopup${param.isOverlayMode ? ' dirty-form-check' : ''}">
	<input type="hidden" name="referenceId" value="${referenceId}"/>
	<jsp:include page="/bugs/addUpdateTask.jsp?noForm=true&layoutMode=mandatory&nestedPath=null&noReload=false&noAssociation=true&noTrackerField=true&isPopup=true&minimal=true&position=${position }" />
</form:form>

<script type="text/javascript">
	$(document).ready(function () {
		activateLayout("mandatory");
	});
</script>

