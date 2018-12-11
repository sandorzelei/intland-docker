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
<%@ taglib uri="bugstaglib" prefix="bugs" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="uitaglib" prefix="ui" %>

<c:if test="${tooManyChildren}">
	<ui:message type="warning" isSingleMessage="true">
		<c:url var="clickUrl" value="${itemLink}" />
		<spring:message code="too.many.children.warning" text="Too many children available, please click <a href=\"{0}\">here</a> to display all of the items." arguments="${clickUrl}" />
	</ui:message>
</c:if>

<bugs:displaytagTrackerItems items="${children}" layoutList="${columns}" pagesize="${pagesize}" export="false" browseTrackerMode="${browse}"
							 selection="${selection}" multiSelect="${multiSelect}" selectionFieldName="${selectName}" decorator="${decorator}"/>
