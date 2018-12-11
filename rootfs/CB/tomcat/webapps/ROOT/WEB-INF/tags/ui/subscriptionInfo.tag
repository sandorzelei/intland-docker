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
 * $Id$
--%>
<%@ tag language="java" pageEncoding="ISO-8859-1"%>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>

<%@ attribute name="entitySubscription" required="true" rtexprvalue="true" type="com.intland.codebeamer.persistence.dto.SubscriptionDto" %>
<%@ attribute name="hideUnsubscribed" required="false" rtexprvalue="true" type="java.lang.String" %>

<c:set var="writeSettings" value="${entitySubscription.writeEventSetting}"/>

<span class="subscriptionInfo">
	<c:choose>
		<c:when test="${writeSettings.subscribed}">
			<c:choose>
				<c:when test="${writeSettings.editable}">
					<spring:message code="repository.subscribed.label" text="Subscribed"/>
				</c:when>
				<c:otherwise>
					<spring:message code="repository.subscribed.permanently.label" text="Subscribed by role"/>
				</c:otherwise>
			</c:choose>
		</c:when>
		<c:otherwise>
			<c:if test="${empty hideUnsubscribed}">
				<spring:message code="repository.unsubscribed.label" text="Unsubscribed"/>
			</c:if>
		</c:otherwise>
	</c:choose>
</span>

