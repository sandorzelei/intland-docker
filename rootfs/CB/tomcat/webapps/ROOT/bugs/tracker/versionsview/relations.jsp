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
<%@ taglib uri="callTag" prefix="ct" %>
<c:choose>
	<c:when test="${not empty trackerItems}">
		<ct:call object="${versionIssuesRenderer}" method="renderTrackerItemsForVersionsToHtml" print="true"
			param1="${pageContext.request}" param2="${trackerItems}" param3="${issueStatusStyles}" param4="${htmlRenderer}" param5="${rowAttributeProvider}" param6="${trackerItemBranchIndicator}"/>
	</c:when>
	<c:otherwise>
		<table></table>
	</c:otherwise>
</c:choose>