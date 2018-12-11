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

<spring:message code="post.installer.navigation.next.label" text="Next" var="nextLabel"/>
<spring:message code="post.installer.navigation.previous.label" text="Previous" var="prevLabel"/>
<spring:message code="post.installer.navigation.skip.label" text="Skip" var="skipLabel"/>

<spring:message code="review.flow.step.${param.nextStep }.title" var="nextStepLabel"/>
<c:if test="${createReviewForm.mergeRequest and param.nextStep == 'addReviewers'}">
	<spring:message code="review.flow.step.merge.${param.nextStep }.title" var="nextStepLabel"/>
</c:if>

<c:set var="step" value="${param.step}"/>

<div class="footer">

	<c:if test="${!param.noPrevious and step != 'select' and (createReviewForm.mergeRequest or step != 'previewSelection'  or createReviewForm.reviewType != 'trackerItemReview')}">
		<input type="submit" name="_eventId_previous" value="${prevLabel }" class="prev-button link-button"/>
	</c:if>

	<c:if test="${step != 'done' and param.noNext != 'true'}">
		<c:if test="${param.hideNext }">
			<c:set var="disabled" value="disabled='disabled'"/>
		</c:if>
		<input type="submit" id="nextButton" name="_eventId_next" value="${nextLabel} (${nextStepLabel})" class="next-button link-button" ${disabled }/>
	</c:if>

</div>