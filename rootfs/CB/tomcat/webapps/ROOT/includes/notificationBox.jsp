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
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="acltaglib" prefix="acl" %>

<%--
	param.showNotificationBox If the notification box is shown. Defaults to true
--%>
<acl:isAnonymousUser var="isAnonymousUser" />

<c:if test="${! isAnonymousUser}">
	<c:if test="${empty param.showNotificationBox || param.showNotificationBox}">
		<ui:subscriptionInfo entitySubscription="${entitySubscription}" hideUnsubscribed="true"/>
	</c:if>
	<c:if test="${empty param.starred || param.starred}">
		<c:choose>
			<c:when test="${!empty param.starEntityTypeId and !empty param.starEntityId}">
				<%-- <ui:ajaxTagging entityTypeId="${param.starEntityTypeId}" entityId="${param.starEntityId}" favourite="true" /> --%>
			</c:when>
			<c:when test="${!empty param.entityTypeId and !empty param.entityId}">
				<%--<ui:ajaxTagging entityTypeId="${param.entityTypeId}" entityId="${param.entityId}" favourite="true" />--%>
			</c:when>
		</c:choose>
	</c:if>
</c:if>
