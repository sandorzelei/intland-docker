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
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>

<c:set var="windowsPlatform" value="${databaseConnectionForm.windowsPlatform}"/>

<spring:message var="databaseSchema" code="post.installer.database.schema.label" text="Database schema"/>
<spring:message var="databaseSid" code="post.installer.database.sid.label" text="Service Name/SID"/>

<div class="form-container">
	<jsp:include page="includes/header.jsp?step=databaseError"/>

	<div class="info">
		<spring:message code="post.installer.database.error" text="Please set up your database connection in general.xml file."/>
	</div>

	
</div>


