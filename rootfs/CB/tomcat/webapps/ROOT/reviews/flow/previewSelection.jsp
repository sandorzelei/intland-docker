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
<%@ taglib uri="uitaglib" prefix="ui" %>

<jsp:include page="includes/head.jsp"></jsp:include>

<div class="form-container">
	<jsp:include page="includes/header.jsp?step=previewSelection&stepIndex=2"/>

	<c:if test="${reviewStats > maximumReviewSize }">
		<div class="warning">
			<spring:message code="review.flow.to.many.items.message" arguments="${maximumReviewSize },${maximumReviewSize }"></spring:message>
		</div>
	</c:if>

	<div class="info">
		<p>
			<c:set var="itemsAdded" value="${reviewStats > maximumReviewSize ? maximumReviewSize : reviewStats }"></c:set>
			<spring:message code="review.flow.step2${createReviewForm.mergeRequest ? '.merge' : ''}.${createReviewForm.reviewType }.info" arguments="${itemsAdded}"/>
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

		<c:if test="${not empty baseline }">
			<spring:message code="review.flow.step2.baseline.info" text="The review will be created from this Baseline"/>:
			<c:set value="${baseline['name'] }" var="baselineName"></c:set>
			<c:url value="${baseline['url'] }" var="baselineUrl"/>
			<a href="${baselineUrl }" target="_blank" title="${baselineName }">${baselineName }</a>

		</c:if>
	</div>
	<form:form method="POST" modelAttribute="createReviewForm">
			<jsp:include page="includes/footer.jsp?step=previewSelection&nextStep=addReviewers"/>
	</form:form>

</div>