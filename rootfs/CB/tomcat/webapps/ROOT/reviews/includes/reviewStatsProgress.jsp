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

<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<spring:message text="Reviewer Progress" code="review.${review.mergeRequest ? 'merge.' : '' }progress.reviewer.progress.label" var="reviewerProgressLabel"></spring:message>
<spring:message text="Item Progress" code="review.progress.item.progress.label" var="itemProgressLabel"></spring:message>

<ui:collapsingBorder label="${reviewerProgressLabel }" open="true" cssClass="separatorLikeCollapsingBorder">
	<jsp:include page="/reviews/includes/reviewProgress.jsp"></jsp:include>
</ui:collapsingBorder>

<ui:collapsingBorder label="${itemProgressLabel }" open="true" cssClass="separatorLikeCollapsingBorder itemProgress">
	<jsp:include page="/reviews/includes/itemProgress.jsp"></jsp:include>
</ui:collapsingBorder>