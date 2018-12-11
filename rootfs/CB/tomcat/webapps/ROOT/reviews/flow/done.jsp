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
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="taglib" prefix="tag" %>
<%@ taglib uri="uitaglib" prefix="ui" %>

<jsp:include page="includes/head.jsp"></jsp:include>

<div class="form-container">
	<jsp:include page="includes/header.jsp?step=done&stepIndex=${createReviewForm.mergeRequest ? '5' :'4'}"/>

	<c:if test="${reviewStats > maximumReviewSize }">
		<div class="warning">
			<spring:message code="review.flow.to.many.items.message" arguments="${maximumReviewSize },${maximumReviewSize }"></spring:message>
		</div>
	</c:if>

	<form:form method="POST" modelAttribute="createReviewForm" id="createReviewFrom">
		<div class="info">
			<p>
				<spring:message code="review.create${createReviewForm.mergeRequest ? '.merge' : ''}.summary.${createReviewForm.reviewType }"></spring:message>:
			</p>
			<p style="margin-left: 10px;">
				<c:choose>
					<c:when test="${createReviewForm.reviewType == 'reportReview' }">
						<c:forEach items="${reviewSubjects }" var="subject" varStatus="loop">
							<ui:wikiLink item="${subject}"/>

							<c:if test="${not loop.last }">, </c:if>
						</c:forEach>
					</c:when>
					<c:otherwise>
						<table class="propertyTable" style="width: 100%;">
							<tr>
								<th class="textData"><spring:message code="project.label" text="Project"/></th>
								<th class="textData"><spring:message code="review.create.summary.${createReviewForm.branchMergeRequest ? 'mergeRequest' : createReviewForm.reviewType }.table.head" text="Tracker"/></th>
							</tr>
							<c:forEach items="${reviewSubjects }" var="subject" varStatus="loop">
								<tr>
									<td class="textData">
										<c:out value="${subject.project.name }"/>
									</td>
									<td class="textData">
										<ui:wikiLink item="${subject}"/>
									</td>
								</tr>
							</c:forEach>
						</table>
					</c:otherwise>
				</c:choose>
			</p>

			<b>
				<spring:message code="review.create.summary.reviewers"/>:
			</b>
			<p style="margin-left: 10px;">
				<c:forEach items="${reviewers }" var="reviewer" varStatus="loop">
					<ui:userPhoto userId="${reviewer.id }"></ui:userPhoto>
					<tag:userLink user_id="${reviewer.id }"></tag:userLink>
					<c:if test="${not loop.last }">, </c:if>
				</c:forEach>
			</p>

			<b>
				<spring:message code="review.flow.step3.moderators.label"/>:
			</b>
			<p style="margin-left: 10px;">
				<c:forEach items="${moderators }" var="moderator" varStatus="loop">
					<ui:userPhoto userId="${moderator.id }"></ui:userPhoto>
					<tag:userLink user_id="${moderator.id }"></tag:userLink>
					<c:if test="${not loop.last }">, </c:if>
				</c:forEach>
			</p>
		</div>
		<div class="footer" style="width: 30%; z-index:2;">
			<spring:message code="review.create.${createReviewForm.mergeRequest ? 'merge.' : '' }summary.button.title" text="Create Review" var="buttonLabel"></spring:message>
			<input type="submit" id="nextButton" name="_eventId_next" value="${buttonLabel }" class="link-button next-button"/>
		</div>
		<jsp:include page="includes/footer.jsp?step=done"/>
	</form:form>
</div>

<script type="text/javascript">
	$("#nextButton").click(function () {
		$("body").trigger("inProgressDialog");
	});
</script>

<ui:inProgressDialog imageUrl="${pageContext.request.contextPath}/images/newskin/review_create_in_progress.gif" height="235" attachTo="body" triggerOnClick="false" />


