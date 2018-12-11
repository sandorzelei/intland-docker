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
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%@ taglib uri="bugstaglib" prefix="bugs" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<meta name="decorator" content="popup"/>
<meta name="moduleCSSClass" content="newskin reviewModule"/>
<meta name="module" content="review"/>

<link rel="stylesheet" href="<ui:urlversioned value="/stylesheet/review/review-flow.less" />" type="text/css" media="all" />

<script src="<ui:urlversioned value='/reviews/review.js'/>"></script>

<ui:actionMenuBar>
	<c:set var="reviewNameEscaped"><c:out value="${review.name }"/></c:set>
	<spring:message code="${review.mergeRequest ? 'merge' : 'review' }.edit.title" arguments="${reviewNameEscaped}" text="Editing Review ${reviewNameEscaped }"></spring:message>

</ui:actionMenuBar>

<style type="text/css">
	.propertyTable {
		width: 100%;
	}

	.invalidfield {
		display: inline-block;
	}

	.userSelector {
		display: inline-block;
		width: 40%;
	}

	.hint {
		vertical-align: top;
		display: inline-block;
		position: relative;
		margin-left: 10px;
	}
</style>

<form:form method="POST" modelAttribute="command">
	<ui:actionBar>
		<spring:message code="button.save" text="Save" var="saveLabel"/>
		<form:button class="button">${saveLabel }</form:button>

		<button class="cancelButton" onclick="inlinePopup.close();"><spring:message code="button.cancel" text="Cancel"/></button>
	</ui:actionBar>
	<div class="contentWithMargins">
		<div class="form-container">
			<table class="propertyTable">
				<tr>
					<td class="mandatory">
						<label for="reviewName"><spring:message code="review.flow.step1.reviewName.label" text="Name"/>:</label>
					</td>
					<td>
						<form:input path="reviewName" id="reviewName"/>
						<form:errors path="reviewName" cssClass="invalidfield" />
					</td>
				</tr>

				<tr>
					<td class="mandatory">
						<label for="reviewers"><spring:message code="review.flow.step3.reviewers.label" text="Reviewers"/>:</label>
					</td>
					<td>
						<bugs:userSelector htmlId="reviewers"  fieldName="reviewers" ids="${command.reviewers }" allowRoleSelection="false"
											   singleSelect="false"
											   onlyMembers="false"
											   disableRoleFiltering="true"
											   onlyUsersAndRolesWithPermissionsOnTracker="true" tracker_id="${reviewTracker.id}"
									/>
						<span class="hint" style="top: 8px;"><spring:message code="review.flow.step3.reviewers.hint" text="Reviewers can review the items but cannot update the review"/></span>
						<label></label><form:errors path="reviewers" cssClass="invalidfield" cssStyle="top: 0px; margin-left: 12px;"/>
					</td>
				</tr>

				<tr>
					<td class="mandatory">
						<label for="moderators"><spring:message code="review.flow.step3.moderators.label" text="Moderators"/>:</label>

					</td>

					<td>
						<bugs:userSelector htmlId="moderators"  fieldName="moderators" ids="${command.moderators }" allowRoleSelection="false"
											   singleSelect="false"
											   onlyMembers="false"
											   disableRoleFiltering="true"
											   onlyUsersAndRolesWithPermissionsOnTracker="true" tracker_id="${reviewTracker.id}"
									/>

						<span class="hint" style="top: 8px;"><spring:message code="review.flow.step3.moderators.hint" text="Moderators can review the items and can also update the review"/></span>
						<label></label><form:errors path="moderators" cssClass="invalidfield" cssStyle="top: 0px; margin-left: 12px;"/>
					</td>
				</tr>


				<tr class="field form-field">
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

				<tr  style="border-top: 0px solid;">
					<td>
					</td>
					<td>
						<form:checkbox path="requiresSignature" id="requiresSignature"/>
						<label for="requiresSignature" class="checkboxLabel"><spring:message code="review.flow.step1.${review.mergeRequest ? 'merge.':''}requiresSignature.label" text="Requires Signature to Complete the Review"/></label>
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
						<form:errors path="minimumSignaturesRequired" cssClass="invalidfield" cssStyle="margin-top:10px;"/>
					</td>
				</tr>
			</table>
			<script>
				codebeamer.review.initializeCreateFormFieldDependencies();
			</script>
				<div class="form-fields">






				</div>
		</div>

	</div>
</form:form>


