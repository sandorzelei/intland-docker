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
<%@ taglib uri="bugstaglib" prefix="bugs" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="uitaglib" prefix="ui" %>

<jsp:include page="includes/head.jsp"></jsp:include>

<script src="<ui:urlversioned value='/reviews/review.js'/>"></script>

<div class="form-container">
	<jsp:include page="includes/header.jsp?step=addReviewers&stepIndex=${createReviewForm.mergeRequest ? '4' :'3'}"/>

	<div class="info"><spring:message code="review.flow.step3.info" text="Please add the users that you want to allow to review the selected items"/></div>

	<form:form method="POST" modelAttribute="createReviewForm">
		<table class="propertyTable" style="width: 95%;">
			<tr class="users">
				<td class="mandatory">
					<label for="reviewers"><spring:message code="review.flow.step3.reviewers.label" text="Reviewers"/>:</label>
				</td>
				<td>
					<bugs:userSelector htmlId="reviewers"  fieldName="reviewers" ids="${createReviewForm.reviewers }" allowRoleSelection="false"
										   singleSelect="false"
										   onlyMembers="false"
										   disableRoleFiltering="true"
										   onlyUsersAndRolesWithPermissionsOnTracker="true" tracker_id="${reviewTracker.id}"
								/>
					<form:errors path="reviewers" cssClass="invalidfield" cssStyle="display: inline-block;"/>

					<span class="hint" style="top: 8px;"><spring:message code="review.flow.step3.reviewers.hint" text="Reviewers can review the items but cannot update the review"/></span>
					</td>
			</tr>
			<tr>
				<td class="mandatory">
					<label for="moderators"><spring:message code="review.flow.step3.moderators.label" text="Moderators"/>:</label>
				</td>
				<td>
					<bugs:userSelector htmlId="moderators"  fieldName="moderators" ids="${createReviewForm.moderators }" allowRoleSelection="false"
										   singleSelect="false"
										   onlyMembers="false"
										   disableRoleFiltering="true"
										   onlyUsersAndRolesWithPermissionsOnTracker="true" tracker_id="${reviewTracker.id}"
								/>

					<form:errors path="moderators" cssClass="invalidfield" cssStyle="display: inline-block;"/>

					<span class="hint" style="top: 8px;"><spring:message code="review.flow.step3.moderators.hint" text="Moderators can review the items and can also update the review"/></span>
				</td>
			</tr>
			<tr>
				<td class="optional">
					<label for="deadline"><spring:message code="review.flow.step1.deadline.label" text="Deadline"/>:</label>
				</td>
				<td>
					<ui:calendarPopup textFieldId="deadline" fieldLabel="Deadline" >
						<form:input path="deadline" id="deadline"  size="18" maxlength="30" />
					</ui:calendarPopup>
				</td>
			</tr>

			<tr style="border-top: 0px solid;">
				<td class="optional"></td>
				<td>
					<form:checkbox path="notifyReviewers" id="notifyReviewers"/>
					<label for="notifyReviewers" class="checkboxLabel"><spring:message code="review.flow.step1.notifyReviewers.label" text="Notify Reviewers"/></label>
				</td>
			</tr>
			<tr style="border-top: 0px solid;">
				<td class="optional"></td>
				<td>
					<form:checkbox path="notifyModerators" id="notifyModerators"/>
					<label for="notifyModerators" class="checkboxLabel"><spring:message code="review.flow.step1.notifyModerators.label" text="Notify Moderators"/></label>
				</td>
			</tr>
			<tr style="border-top: 0px solid;">
				<td class="optional"></td>
				<td>
					<form:checkbox path="notifyOnItemUpdate" id="notifyOnItemUpdate"/>
					<label for="notifyOnItemUpdate" class="checkboxLabel"><spring:message code="review.flow.step1.notifyOnItemUpdate.label" text="Send notification about Review events (vote, comment)"/></label>
				</td>
			</tr>

			<tr style="border-top: 0px solid;">
				<td class="optional"></td>
				<td>
					<form:checkbox path="requiresSignature" id="requiresSignature"/>
					<label for="requiresSignature" class="checkboxLabel"><spring:message code="review.flow.step1.${createReviewForm.mergeRequest ? 'merge.':''}requiresSignature.label" text="Requires Signature"/></label>
				</td>
			</tr>

			<tr style="border-top: 0px solid;">
				<td class="optional"></td>
				<td>
					<form:checkbox path="requiresSignatureFromReviewers" id="requiresSignatureFromReviewers"/>
					<label for="requiresSignatureFromReviewers" class="checkboxLabel"><spring:message code="review.flow.step1.requiresSignatureFromReviewers.label" text="Requires Signature from Reviewers"/></label>
				</td>
			</tr>

			<tr style="border-top: 0px solid;">
				<td class="optional">
					<label for="minimumSignaturesRequired"><spring:message code="review.flow.step1.minimumSignaturesRequired.label" text="Minimum Number of Signatures"/></label>
				</td>
				<td>
					<form:input path="minimumSignaturesRequired" id="minimumSignaturesRequired" type="number" min="0"></form:input>
					<span class="hint" style="margin-top: -7px;">
						<spring:message code="review.flow.step1.minimumSignaturesRequired.hint"></spring:message>
					</span>
					<form:errors path="minimumSignaturesRequired" cssClass="invalidfield" cssStyle="margin-top: 10px; display: inline-block;"/>

				</td>
			</tr>
		</table>

		<script>
            codebeamer.review.initializeCreateFormFieldDependencies();
		</script>

		<jsp:include page="includes/footer.jsp?step=addReviewers&nextStep=done"/>
	</form:form>

</div>

<jsp:include page="includes/common.jsp"></jsp:include>
