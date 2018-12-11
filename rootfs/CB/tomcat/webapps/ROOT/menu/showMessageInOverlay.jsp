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
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>

<%--
	Show the GlobalMessage in the overlay, but don't close it automatically, but wait for the user clicking on close
	@param message The message code or message text to display in the header. Can be null
--%>
<meta name="decorator" content="popup"/>

<ui:actionMenuBar>
	<c:if test="${! empty message}"><ui:pageTitle prefixWithIdentifiableName="false"><spring:message code="${message}" text="${message}" /></ui:pageTitle></c:if>
</ui:actionMenuBar>
<ui:actionBar>
	<spring:message var="close" code="button.close" />
	<input type="button" class="button" onclick="inlinePopup.close();return false;" value="${close}" />
</ui:actionBar>

