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
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>

<ui:pageTitle prefixWithIdentifiableName="false" printBody="false" >
	<spring:message code="review.flow.step.${step}.title" text=""/>
</ui:pageTitle>

<c:set var="step" value="${param.step}"/>
<c:set var="stepIndex" value="${param.stepIndex}"/>
<c:set var="currentStep" value="1"></c:set>

<div class="actionMenuBar"><div class="header-icon"></div><span><spring:message code="${createReviewForm.mergeRequest ? 'merge.request' : 'review'}.flow.header" text="Select items to review"/></span></div>
<div class="step-list">
	<span class="${step == 'select' ? 'current' : '' }">${currentStep }. <spring:message code="review.flow.step.select.title" text="Select"/>
		<c:set var="currentStep" value="${currentStep + 1 }"></c:set>
	</span>
	<c:choose>
		<c:when test="${createReviewForm.branchMergeRequest}">
			<span class="${step == 'showBranchDiff' ? 'current' : '' }">${currentStep }. <spring:message code="review.flow.step.merge.showBranchDiff.title" text="Preview Branch Diff"/>
				<c:set var="currentStep" value="${currentStep + 1 }"></c:set>
			</span>
		</c:when>
		<c:when test="${createReviewForm.mergeRequest}">
			<span class="${step == 'selectTargetTracker' ? 'current' : '' }">${currentStep }. <spring:message code="review.flow.step.selectTargetTracker.title" text="Select Target Tracker"/>
				<c:set var="currentStep" value="${currentStep + 1 }"></c:set>
			</span>
		</c:when>
	</c:choose>

	<span class="${step == 'previewSelection' ? 'current' : '' }">${currentStep}. <spring:message code="review.flow.step.previewSelection.title" text="Preview Selection"/>
		<c:set var="currentStep" value="${currentStep + 1 }"></c:set>
	</span>
	<span class="${step == 'addReviewers' ? 'current' : '' }">${currentStep}. <spring:message code="review.flow.step.${createReviewForm.mergeRequest ? 'merge.' : '' }addReviewers.title" text="Set Up Review"/>
		<c:set var="currentStep" value="${currentStep + 1 }"></c:set>
	</span>
	<span class="${step == 'done' ? 'current' : '' }"><spring:message code="review.flow.step.done.title" text="Done"/></span>
</div>

<div class="step-info">
	<div class="step-title">
		${stepIndex}.
		<spring:message code="review.flow.step${createReviewForm.mergeRequest ? '.merge' : '' }.${step}.title" text=""/>
	</div>

	<div class="step-icon ${step}"></div>
</div>


<c:if test="${not empty sourceTracker or not empty targetTracker}">
	<div class="contentWithMargins">
		<span class="hint">
			<c:if test="${not empty sourceTracker}">
				<label class="optional"><spring:message code="review.statistics.source.${createReviewForm.branchMergeRequest or sourceTracker.branch ? 'branch' : 'tracker'}.label" text="Source Branch"/>:</label>
				<ui:wikiLink item="${sourceTracker}" useKeyInLabel="true"/>
			</c:if>
			<c:if test="${not empty targetTracker}">
				, <label class="optional"><spring:message code="review.statistics.target.${createReviewForm.branchMergeRequest or targetTracker.branch ? 'branch' : 'tracker'}.label" text="Target Branch"/>:</label>
				<ui:wikiLink item="${targetTracker}" useKeyInLabel="true"/>
			</c:if>
		</span>
	</div>
</c:if>