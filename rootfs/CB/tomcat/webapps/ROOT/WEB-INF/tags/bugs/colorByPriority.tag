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
<%--
	Tag to insert an HTML color value by the passed priority value (typically in the [1 .. 5] range).
	When making modification, also update the #colorByPriority Velocity macro in VM_global_library.vm.
--%>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<%@ attribute name="priority" required="true" type="java.lang.Integer"%>

<c:choose>
	<c:when test="${priority == 1}">#FF0000</c:when>
	<c:when test="${priority == 2}">#FFA500</c:when>
	<c:when test="${priority == 3}">#FFFF00</c:when>
	<c:when test="${priority == 4}">#90EE90</c:when>
	<c:when test="${priority == 5}">#ADD8E6</c:when>
	<c:otherwise>#D3D3D3</c:otherwise>
</c:choose>