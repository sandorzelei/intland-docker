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
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>

<c:forEach items="${options}" var="option">
	<c:set var="obsolete" value="${ option == 'Document Approval' or option == 'Document Review'}"/>
	<div>
		<spring:message var="tooltip" code="sysadmin.license.option.${option}.tooltip" text="" htmlEscape="true"/>

		<label title="${tooltip}" style="${obsolete ? 'color: red;': ''}">
			<input type="checkbox" name="options[${part}]" value="${option}" <c:if test="${selectedOptions[option]}">checked="checked"</c:if>>
			<spring:message code="sysadmin.license.option.${option}" text="${option}${obsolete ? ' (deprecated)': ''}"/>
		</label>
	</div>
</c:forEach>

