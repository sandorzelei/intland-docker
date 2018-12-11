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
<%@ tag language="java" pageEncoding="UTF-8" %>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="http://ditchnet.org/jsp-tabs-taglib" prefix="tab" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>

<%@ attribute name="id" required="true"
	description="The tab id" %>
<%@ attribute name="tabTitle" required="false"
	description="The tab title" %>
<%@ attribute name="selectedTabId" required="true"
	description="The selected tab's id" %>

<%--
	Same as ditchnet's tag (<tab:tabPane.../>), except that it will only render the body
		if the "${selectedTabId}" parameter matches with the id.
--%>
<tab:tabPane id="${id}" tabTitle="${tabTitle}">
<c:set var="loadingIndicator">
	<img src="<c:url value='/js/yui/assets/skins/sam/ajax-loader.gif'/>" style='margin:10px; vertical-align: middle;' ><spring:message code="ajax.loading"/></img>
</c:set>

<c:choose>
	<c:when test="${id eq selectedTabId}">
		<jsp:doBody></jsp:doBody>
	</c:when>
	<c:otherwise>
		${loadingIndicator}
	</c:otherwise>
</c:choose>
</tab:tabPane>
