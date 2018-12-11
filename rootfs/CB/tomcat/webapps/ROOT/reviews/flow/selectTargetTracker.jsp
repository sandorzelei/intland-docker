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

<script type="text/javascript" src="<ui:urlversioned value="/reviews/review-flow.js" />"></script>

<style type="text/css">
	.propertyTable .hint {
		top: 0px;
	}

	.ui-multiselect-menu li.branchTracker {
		padding-left: 10px !important;
	}
	.ui-multiselect-menu li.branchTracker span {
		color: #187a6d;
	}
</style>

<div class="form-container">

	<form:form method="POST" modelAttribute="createReviewForm" autocomplete="false">

		<%-- for merge requests if a baseline is selected it is used only to send the items that changed since the baseline --%>
		<input type="hidden" name="fromBaselineDifference" value="true"/>

		<jsp:include page="includes/header.jsp?step=selectTargetTracker&stepIndex=2"/>

		<form:errors cssClass="error"></form:errors>
		<table class="propertyTable">
			<tr class="projectField field">
				<td class="mandatory">
					<label><spring:message code="review.flow.step1.project.label" text="Please select a Project"/>:</label>
				</td>
				<td>
					<form:select path="projectIds" id="project" items="${projects }" itemLabel="name" itemValue="id">
					</form:select>
				</td>
			</tr>

			<tr id="trackerReview-field">
				<td class="mandatory">
					<label for="targetTrackerId"><spring:message code="review.flow.step1.targetTracker.label" text="Select the Target Tracker"/>:</label>

				</td>
				<td>
					<form:select path="targetTrackerId" id="targetTrackerId">
					</form:select>
					<span class="hint"><spring:message code="review.flow.step1.targetTracker.hint" text="Target Tracker is the tracker where your selected items will be merged to"/></span>

					<form:errors path="targetTrackerId"  cssClass="invalidfield"/>
				</td>
			</tr>
			<tr class="field form-field">
				<td class="optional"></td>
				<td>
					<form:checkbox path="sendOnlySuspected" id="sendOnlySuspected"/>
					<label for="sendOnlySuspected" class="checkboxLabel"><spring:message code="review.flow.step1.sendOnlySuspected.label"/></label>
				</td>
			</tr>
		</table>

		<jsp:include page="includes/footer.jsp?noPrevious=true&step=selectTargetTracker&nextStep=previewSelectionWithName"/>

	</form:form>
</div>

<jsp:include page="includes/common.jsp"></jsp:include>

<script type="text/javascript">
	var config = {selected: {}}
	<c:if test="${not empty createReviewForm.targetTrackerId}">
		config.selected["targetTrackerId"] = ${createReviewForm.targetTrackerId};
	</c:if>

	<c:if test="${not empty createReviewForm.trackerIds}">
		config.selected["trackerIds"] = ${createReviewForm.trackerIds};
	</c:if>

	codebeamer.review.initMergeRequestFlow(config);
</script>
<!--

//-->
</script>
