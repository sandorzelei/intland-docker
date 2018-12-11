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
<%@ taglib uri="bugstaglib" prefix="bugs" %>
<%@ taglib uri="uitaglib" prefix="ui" %>

<jsp:include page="includes/head.jsp"></jsp:include>

<style type="text/css">
 table.chooseReferences.fullExpandTable   {
 	border-color: #f5f5f5;
 }
</style>

<%-- this is only relevant for merge requests between general trackers (not branches) --%>
<c:set var="hasPotentialItemMappings" value="${createReviewForm.mergeRequest and not isBranchMergeRequest}"/>

<div class="form-container">
	<jsp:include page="includes/header.jsp?step=previewSelection&stepIndex=${createReviewForm.mergeRequest ? '3' :'2'}"/>

	<c:if test="${reviewStats > maximumReviewSize }">
		<div class="warning">
			<spring:message code="review.flow.to.many.items.message" arguments="${maximumReviewSize },${maximumReviewSize }"></spring:message>
		</div>
	</c:if>

	<div class="info">
		<form:form method="POST" modelAttribute="createReviewForm">
			<form:errors cssClass="error"></form:errors>
			<table class="propertyTable">
				<c:if test="${!createReviewForm.mergeRequest or isSelection }">
					<tr>
						<td class="mandatory">
							<label for="reviewName"><spring:message code="review.flow.step1.reviewName.label" text="Name"/>:</label>
						</td>
						<td>
							<form:input path="reviewName" id="reviewName" autofocus="autofocus"/>
							<form:errors path="reviewName" cssClass="invalidfield" />
						</td>
					</tr>
				</c:if>
				<c:if test="${ not createReviewForm.branchMergeRequest}">
					<tr class="projectField">
						<td class="optional">
							<label for="baselineId"><spring:message code="review.flow.step1.baseline.label" text="Select a Baseline"/>:</label>
						</td>
						<td>
							<form:select path="baselineId" >
								<c:set var="checked" value="${0 ==  createReviewForm.baselineId ? 'selected=selected' : ''}"></c:set>
								<spring:message code="None" var="noneLabel"/>
								<option value="0" ${checked }>${noneLabel }</option>
								<c:forEach items="${baselines }" var="group">
									<optgroup label="${group.key }">
										<c:forEach items="${group.value }" var="baseline">
											<c:set var="checked" value="${baseline.id ==  createReviewForm.baselineId ? 'selected=selected' : ''}"></c:set>
											<option value="${baseline.id }" ${checked }><c:out value="${baseline.name }" /></option>
										</c:forEach>

									</optgroup>
								</c:forEach>
							</form:select>
							<form:errors path="baselineId" cssClass="invalidfield" />
						</td>
					</tr>
				</c:if>

				<c:if test="${createReviewForm.reviewType == 'trackerReview' and not createReviewForm.branchMergeRequest}">
					<tr class="field form-field">
						<td class="optional"></td>
						<td>
							<c:if test="${createReviewForm.mergeRequest or createReviewForm.baselineId == null or createReviewForm.baselineId == 0 }">
								<c:set var="disabled" value="true"></c:set>
							</c:if>
							<form:checkbox path="fromBaselineDifference" id="fromBaselineDifference" disabled="${disabled }"/>
							<label for="fromBaselineDifference" class="checkboxLabel"><spring:message code="review.flow.step1.fromBaselineDifference.label"/></label>
						</td>
					</tr>
				</c:if>
			</table>

			<p>
				<c:set var="itemsAdded" value="${reviewStats > maximumReviewSize ? maximumReviewSize : reviewStats }"></c:set>
				<spring:message code="review.flow.step2${createReviewForm.mergeRequest ? '.merge' : ''}.${createReviewForm.reviewType }.info" arguments="${itemsAdded}"/>
			</p>

			<p style="margin-left: 10px;">
				<c:if test="${hasPotentialItemMappings }">
					<span class="hint">
						<spring:message code="review.flow.step2.potential.mappings.hint"/>
					</span>
				</c:if>

				<c:set var="hasitemThatNeedsMapping" value="false"/>
				<c:set var="subjectsTable">
					<table class="propertyTable" style="width: 100%;">
						<tr>
							<th class="textData"><spring:message code="project.label" text="Project"/></th>
							<th class="textData"><spring:message code="review.create.summary.${createReviewForm.mergeRequest ? 'mergeRequest' : createReviewForm.reviewType }.table.head" text="Tracker"/></th>

							<c:if test="${hasPotentialItemMappings }">
								<th class="textData"><spring:message code="review.flow.step1.mergeTarget.label" text="Merge Target"/></th>
							</c:if>
						</tr>
						<c:forEach items="${reviewSubjects }" var="subject" varStatus="loop">
							<tr>
								<td class="textData">
									<c:out value="${subject.project.name }"/>
								</td>
								<td class="textData">
									<ui:wikiLink item="${subject}"/>
								</td>

								<c:if test="${hasPotentialItemMappings }">
									<td class="textData">
										<c:choose>
											<c:when test="${not empty createReviewForm.mergeItemPairs && not empty createReviewForm.mergeItemPairs[subject.id] }">
												<c:set var="mergeTarget" value="${ createReviewForm.mergeItemPairs[subject.id]}"/>
												<c:url var="mergeTargetUrl" value="${mergeTarget.urlLink }"></c:url>
												<a href="${mergeTargetUrl }" target="_blank"><c:out value="${mergeTarget.name }"></c:out></a>
												<input type="hidden" name="targetItemMapping[${subject.id}]" value="9-${ mergeTarget.id}"/>
											</c:when>

											<c:otherwise>
												<%-- show a reference field with the possible pair item selected --%>

												<c:set var="targetTrackerId" value="${createReviewForm.targetTrackerId }"/>
												<c:set var="selectedIds" value=""/>
												<c:if test="${not empty createReviewForm.potentialPairs and not empty createReviewForm.potentialPairs[subject.id]}">
													<c:set var="selectedIds" value="9-${createReviewForm.potentialPairs[subject.id].id }"/>
												</c:if>

												<c:set var="htmlId" value="${subject.id}mergeItemSelector"/>
												<c:set var="urlParams" value="htmlId=${htmlId}&workItemMode=true&fieldName=targetItemMapping&workItemTrackerIds=${targetTrackerId}"/>
												<c:set var="onclick">chooseReferences.selectReferences('${htmlId}', '${urlParams}', 'null'); return false;</c:set>

												<bugs:chooseReferencesUI ids="${selectedIds }" showPopupButton="true"
													htmlId="${htmlId }" title="Select the target item for this item"  multiSelect="false"
													workItemMode="true" workItemTrackerIds="${targetTrackerId}" fieldName="targetItemMapping[${subject.id}]"
													ajaxURLParameters="${urlParams }" onclick="${onclick }"/>

												<c:set var="hasitemThatNeedsMapping" value="true"/>
											</c:otherwise>
										</c:choose>
									</td>
								</c:if>
							</tr>
						</c:forEach>
					</table>
				</c:set>

				<c:choose>
					<c:when test="${hasitemThatNeedsMapping }">
						<script type="text/javascript">
							(function ($) {
								var busyPage = ajaxBusyIndicator.showBusyPage();
								$('body').on('codebeamer:referenceFieldInitialized', throttleWrapper(function () {
									if (busyPage) {
										busyPage.remove();
									}
								}, 100));
							})(jQuery);
						</script>

						<spring:message code="review.flow.step1.itemMappings.label" text="Item Mappings" var="itemMappingsLabel"/>
						<ui:collapsingBorder label="${itemMappingsLabel }"
									hideIfEmpty="false" open="${showDescription}" toggle="#descriptionField"
									cssClass="separatorLikeCollapsingBorder" cssStyle="margin-bottom: 0;">
							${subjectsTable }
						</ui:collapsingBorder>
					</c:when>
					<c:otherwise>
						${subjectsTable }
					</c:otherwise>
				</c:choose>
			</p>

			<c:if test="${not empty baseline }">
				<spring:message code="review.flow.step2.baseline.info" text="The review will be created from this Baseline"/>:
				<c:set value="${baseline['name'] }" var="baselineName"></c:set>
				<c:url value="${baseline['url'] }" var="baselineUrl"/>
				<a href="${baselineUrl }" target="_blank" title="${baselineName }">${baselineName }</a>

			</c:if>

			<jsp:include page="includes/footer.jsp?step=previewSelection&nextStep=addReviewers"/>
		</form:form>
	</div>

</div>

<script type="text/javascript">
	$(document).ready(function () {
		codebeamer.dashboard.multiSelect.initSingleSelect("baselineId");
		<c:if test="${empty createReviewForm.baselineId or createReviewForm.baselineId == 0}">
			$("#baselineId").multiselect("uncheckAll");
		</c:if>

		<c:if test="${!createReviewForm.mergeRequest}">
			$("#baselineId").change(function () {
				var value = $(this).val();

				if (value == 0) {
					$("#fromBaselineDifference").prop("disabled", true);
				} else {
					$("#fromBaselineDifference").prop("disabled", false);
				}
			});
		</c:if>
	});
</script>

<jsp:include page="includes/common.jsp"></jsp:include>