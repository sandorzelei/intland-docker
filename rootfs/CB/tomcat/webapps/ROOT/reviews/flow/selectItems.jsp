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
<%@ taglib uri='http://java.sun.com/jsp/jstl/core' prefix='c'%>
<%@ taglib uri="uitaglib" prefix="ui" %>

<jsp:include page="includes/head.jsp"></jsp:include>

<link rel="stylesheet" href="<ui:urlversioned value="/stylesheet/selectorUtils.less" />" type="text/css" media="all" />

<script type="text/javascript" src="<ui:urlversioned value="/reviews/review-flow.js" />"></script>

<div class="form-container">
	<jsp:include page="includes/header.jsp?step=select&stepIndex=1"/>


	<form:form method="POST" modelAttribute="createReviewForm" autocomplete="false">
		<form:errors cssClass="error"></form:errors>
		<table class="propertyTable">
			<tr>
				<td class="mandatory">
					<label for="reviewName"><spring:message code="review.flow.step1.reviewName.label" text="Name"/>:</label>
				</td>
				<td>
					<form:input path="reviewName" id="reviewName" autofocus="autofocus"/>
					<form:errors path="reviewName" cssClass="invalidfield" />
				</td>
			</tr>
			<tr>
				<td class="optional"></td>
				<td>
					<c:set var="mergeRequestKey" value="${createReviewForm.mergeRequest ? '.merge' : '' }"/>
					<input type="radio" name="reviewType" value="trackerReview" id="tracker-review" ${createReviewForm.reviewType == 'trackerReview' ? 'checked' : '' }>
					<label for="tracker-review" class="checkboxLabel"><spring:message code="review.flow.step1${mergeRequestKey }.reviewType.tracker.label" text="Tracker Review"/></label>

					<input type="radio" name="reviewType" value="reportReview" id="report-review" ${createReviewForm.reviewType == 'reportReview' ? 'checked' : '' }>
					<label for="report-review" class="checkboxLabel"><spring:message code="review.flow.step1${mergeRequestKey }.reviewType.report.label" text="Report Review"/></label>

					<input type="radio" name="reviewType" value="releaseReview" id="release-review" ${createReviewForm.reviewType == 'releaseReview' ? 'checked' : '' }>
					<label for="release-review" class="checkboxLabel"><spring:message code="review.flow.step1${mergeRequestKey }.reviewType.release.label" text="Release Review"/></label>
				</td>
			</tr>

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
					<label for="trackerIds"><spring:message code="review.flow.step1.trackerReview.label" text="Select trackers to review"/>:</label>

				</td>
				<td>
					<form:select path="trackerIds">
					</form:select>
					<form:errors path="trackerIds"  cssClass="invalidfield"/>
				</td>
			</tr>

			<tr  id="releaseReview-field" style="display:none;">
				<td class="mandatory">
					<label for="releaseIds"><spring:message code="review.flow.step1.${mergeRequestKey }releaseReview.label" text="Select Releases to review"/>:</label>
				</td>
				<td>
					<form:select path="releaseIds">
					</form:select>
					<form:errors path="releaseIds"  cssClass="invalidfield"/>
				</td>
			</tr>

			<c:if test="${not empty queries }">
				<tr style="display: none;" id="reportReview-field">
					<td class="mandatory">
						<label for="cbqlId"><spring:message code="review.flow.step1.${mergeRequestKey }reportReview.label" text="Select a Report to review"/>:</label>
					</td>
					<td>
						<form:select path="cbqlId" id="cbqlId">
							<c:forEach items="${queries }" var="group">
								<c:if test="${not empty group.value }">
									<optgroup label="${group.key }">
										<c:forEach items="${group.value }" var="query">
											<form:option value="${query.id }" label="${query.name }"></form:option>
										</c:forEach>
									</optgroup>
								</c:if>
							</c:forEach>
						</form:select>
						<form:errors path="cbqlId" cssClass="error"/>
					</td>
				</tr>
			</c:if>

			<tr class="projectField">
				<td class="optional">
					<label for="baselineId"><spring:message code="review.flow.step1.baseline.label" text="Select a Baseline"/>:</label>

				</td>

				<td>
					<form:select path="baselineId">
					</form:select>
					<form:errors path="baselineId" cssClass="invalidfield"></form:errors>
				</td>
			</tr>

			<tr class="fromBaselineDiffField">
				<td  class="optional"></td>
				<td>
					<c:if test="${createReviewForm.baselineId == null or createReviewForm.baselineId == 0 }">
						<c:set var="disabled" value="true"></c:set>
					</c:if>
					<label></label>
					<form:checkbox path="fromBaselineDifference" id="fromBaselineDifference" disabled="${disabled }"/>
					<label for="fromBaselineDifference" class="checkboxLabel"><spring:message code="review.flow.step1.fromBaselineDifference.label"/></label>

				</td>
			</tr>
		</table>

		<jsp:include page="includes/footer.jsp?step=select&nextStep=previewSelection"/>
	</form:form>

</div>

<script type="text/javascript">
	var config = {selected: {}};

	<c:if test="${not empty createReviewForm.releaseIds}">
		config.selected["releaseIds"] = ${createReviewForm.releaseIds};
	</c:if>

	<c:if test="${not empty createReviewForm.trackerIds}">
		config.selected["trackerIds"] = ${createReviewForm.trackerIds};
	</c:if>

	<c:if test="${not empty createReviewForm.baselineId}">
		config.selected["baselineId"] = ${createReviewForm.baselineId};
	</c:if>

	codebeamer.review.initFlow(config);

	$("#baselineId").change(function () {
		var value = $(this).val();

		if (value == 0) {
			$("#fromBaselineDifference").prop("disabled", true);
		} else {
			$("#fromBaselineDifference").prop("disabled", false);
		}
	});
</script>

<jsp:include page="includes/common.jsp"></jsp:include>