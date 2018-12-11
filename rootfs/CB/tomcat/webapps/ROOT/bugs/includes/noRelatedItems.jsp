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
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>

<%--
Parameters in scope:
	- relationItem
--%>

<div class="relation-origin-not-related">
	<div class="relation-item">
		<spring:message code="relations.noRelatedItems" arguments="${relationItem.description}" argumentSeparator="|"/>
	</div>
</div>