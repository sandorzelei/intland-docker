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

<div class="actionBar" style="margin-bottom: 15px;"></div>
<c:set var="artifactToApprove" value="${document}" scope="request" />
<jsp:include page="artifactApprovals.jsp">
	<jsp:param name="forwardUrl" value="${document.urlLink}"/>
</jsp:include>
