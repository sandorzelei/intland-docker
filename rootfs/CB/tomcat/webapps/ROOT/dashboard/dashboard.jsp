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
--%>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="taglib" prefix="tag" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>

<meta name="decorator" content="main"/>
<meta name="moduleCSSClass" content="newskin"/>

<jsp:include page="../wikispace/includes/displayPageActionBar.jsp" >
	<jsp:param name="showActionBar" value="false" />
	<jsp:param name="showRating" value="${showRating}" />
</jsp:include>

<div class="actionBar">
	<jsp:include page="/dashboard/dashboardActionBar.jsp"/>
</div>

<jsp:include page="/dashboard/dashboardContent.jsp"/>

