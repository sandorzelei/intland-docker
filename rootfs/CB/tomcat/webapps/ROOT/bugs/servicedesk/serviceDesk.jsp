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
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="http://ditchnet.org/jsp-tabs-taglib" prefix="tab" %>

<meta name="decorator" content="main"/>
<meta name="moduleCSSClass" content="newskin"/>

<link rel="stylesheet" href="<ui:urlversioned value="/bugs/servicedesk/serviceDesk.less" />" type="text/css" media="all" />

<c:set var="escapedTitle"><c:out value="${config.title}" escapeXml="true" /></c:set>
<ui:actionMenuBar>
	<jsp:body>
		<ui:pageTitle prefixWithIdentifiableName="false" printBody="true" >
		 	<spring:message code="${escapedTitle}"/>
		 </ui:pageTitle>
	</jsp:body>
</ui:actionMenuBar>

<c:choose>
	<c:when test="${licenseDisabled}">
		<div class="warning">
			<spring:message code="sysadmin.serviceDesk.no.license.warning" text="You cannot use this feature because you don't have the necessary license. To read more about this feature visit our <a href='https://codebeamer.com/cb/wiki/635003'>Knowledge base</a>."></spring:message>
		</div>
	</c:when>
	<c:otherwise>
		<tab:tabContainer id="service-desk-tabs" skin="cb-box">
			<spring:message code="tracker.serviceDesk.tabs.submit.label" text="Submit request" var="submitTitle"/>
			<spring:message code="tracker.serviceDesk.tabs.myRequests.label" text="My requests" var="myRequestsTitle"/>
			<tab:tabPane id="submit-item" tabTitle="${submitTitle}">
				<jsp:include page="selectRequestType.jsp"/>
			</tab:tabPane>
			<tab:tabPane id="my-items" tabTitle="${myRequestsTitle}">
				<jsp:include page="myItems.jsp"/>
			</tab:tabPane>
		</tab:tabContainer>
	</c:otherwise>
</c:choose>


