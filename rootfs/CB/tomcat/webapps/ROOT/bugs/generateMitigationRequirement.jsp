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
<meta name="module" content="tracker"/>
<meta name="moduleCSSClass" content="newskin trackersModule"/>

<c:url var="actionUrl" value="/trackers/mitigationRequirement/create.spr" />

<div class="container">
	<form:form action="${actionUrl}" enctype="multipart/form-data" commandName="addUpdateTaskForm" method="POST" cssClass="ratingOnInlinedPopup">
		<form:hidden path="riskId"/>
		<form:hidden path="fieldId"/>
		<jsp:include page="/bugs/addUpdateTask.jsp?layoutMode=mandatory&callback=reloadEditedIssue&noReload=true&noForm=true&nestedPath=null&noAssociation=true&noTrackerField=true&isPopup=${param.isPopup}&minimal=true" />
	</form:form>
</div>