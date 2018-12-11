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
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="bugstaglib" prefix="bugs" %>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<meta name="decorator" content="popup"/>
<meta name="moduleCSSClass" content="newskin reviewModule"/>
<meta name="module" content="review"/>

<head>
	<link rel="stylesheet" href="<ui:urlversioned value='/stylesheet/review/review.less' />" type="text/css" media="all" />
</head>

<ui:actionMenuBar>
	<spring:message code="review.complete.${review.mergeRequest ? 'merge.' : '' }request.new.version.label" text="Request New Version"/>
</ui:actionMenuBar>

<div class="contentWithMargins">
	<c:url var="actionUrl" value="/proj/review/requestNewVersion.spr"></c:url>
		<form:form id="form" action="${actionUrl }" method="POST" modelAttribute="command" >
			<form:errors path="newVersionType" cssClass="invalidfield"/>
			<table border="0" class="propertyTable" cellpadding="2">
				<tr>
					<td class="optional"><spring:message code="review.request.new.review.items.label" text="Review Items"/>:</td>
					<td><form:checkbox path="newVersionType" value="onlyNotReviewed" id="onlyNotReviewed"/><label class="checkboxLabel" for="onlyNotReviewed">
						<spring:message code="review.request.new.review.items.onlyNotReviewed.label" text="Only not reviewed"/>
					</label></td>
				</tr>
				<tr>
					<td></td>
					<td>

						<form:checkbox path="newVersionType" value="onlySuspected" id="onlySuspected"/>
						<label class="checkboxLabel" for="onlySuspected">
						<spring:message code="review.request.new.review.items.onlySuspected.label" text="Only items that became suspected after starting the last review"/>
						</label>

						<p>
							<form:checkbox path="computeUpdatedIncoming" id="computeUpdatedIncoming" cssStyle="margin-left: 20px;"/>
							<label for="computeUpdatedIncoming"><spring:message code="review.request.new.review.items.computeUpdatedIncoming.label"/></label>
						</p>

						<p>
							<form:checkbox path="computeUpdatedOutgoing" id="computeUpdatedOutgoing" cssStyle="margin-left: 20px;"/>
							<label for="computeUpdatedOutgoing"><spring:message code="review.request.new.review.items.computeUpdatedOutgoing.label"/></label>
						</p>
					</td>
				</tr>
				<tr>
					<td></td>
					<td><form:checkbox path="newVersionType" value="onlyRejected" id="onlyRejected"/><label class="checkboxLabel" for="onlyRejected">
						<spring:message code="review.request.new.review.items.onlyRejected.label" text="All items that need more work"/>
					</label></td>
				</tr>
				<tr>
					<td></td>
					<td><form:checkbox path="newVersionType" value="complete" id="complete"/><label class="checkboxLabel" for="complete">
						<spring:message code="review.request.new.review.items.complete.label" text="All items in the current review"/>
					</label>

					<p style="margin-left: 20px;">
						<form:checkbox path="clearVotes" id="clearVotes"/><label class="checkboxLabel" for="clearVotes">
						<spring:message code="review.request.new.review.clearVotes.label" text="Set all items as 'Not Reviewed'"/>
						</label>
					</p>

					<form:hidden path="reviewId"/>

					</td>
				</tr>
				<tr>
					<td></td>
					<td><form:checkbox path="rejectNotReviewed" id="rejectNotReviewed"/><label class="checkboxLabel" for="rejectNotReviewed">
						<spring:message code="review.request.new.review.set.rejected.label" text="Set as 'Needs More Work' all items not reviewed in the current review"/>
					</label></td>
				</tr>
				<tr>
					<td><label for="reviewers" class="mandatory"><spring:message code="review.flow.step3.reviewers.label" text="Reviewers"/>:</label></td>
					<td>
						<bugs:userSelector htmlId="reviewers"  fieldName="reviewers" ids="${command.reviewers }" allowRoleSelection="true"
									   singleSelect="false"
									   onlyUsersAndRolesWithPermissionsOnTracker="true" tracker_id="${reviewTracker.id}"
							/>
						<form:errors path="reviewers" cssClass="invalidfield"/>
					</td>
				</tr>
				<tr>
				<td><label for="moderators" class="mandatory"><spring:message code="review.flow.step3.moderators.label" text="Moderators"/>:</label></td>
					<td>
						<bugs:userSelector htmlId="moderators"  fieldName="moderators" ids="${command.moderators }" allowRoleSelection="true"
									   singleSelect="false"
									   onlyUsersAndRolesWithPermissionsOnTracker="true" tracker_id="${reviewTracker.id}"
							/>
						<form:errors path="moderators" cssClass="invalidfield"/>
					</td>
				</tr>
				<tr style="border-top: 0px solid;">
					<td class="optional"></td>
					<td>
						<form:checkbox path="notifyReviewers" id="notifyReviewers"/>
						<label for="notifyReviewers" class="checkboxLabel"><spring:message code="review.flow.step3.notifyReviewers.label" text="Notify Reviewers"/></label>
					</td>
				</tr>
				<tr style="border-top: 0px solid;">
					<td class="optional"></td>
					<td>
						<form:checkbox path="notifyModerators" id="notifyModerators"/>
						<label for="notifyModerators" class="checkboxLabel"><spring:message code="review.flow.step3.notifyModerators.label" text="Notify Moderators"/></label>
					</td>
				</tr>
				<tr style="border-top: 0px solid;">
					<td class="optional"></td>
					<td>
						<form:checkbox path="notifyOnItemUpdate" id="notifyOnItemUpdate"/>
						<label for="notifyOnItemUpdate" class="checkboxLabel"><spring:message code="review.flow.step1.notifyOnItemUpdate.label" text="Send notification about Review events (vote, comment)"/></label>
					</td>
				</tr>
				<c:if test="${requiresSignature }">
					<form:hidden path="baselineSignature" size="30" maxlength="30" autocomplete="new-password"/>
				</c:if>
			</table>

<br/>

			<form:button class="button"><spring:message code="${review.mergeRequest ? 'review.complete.merge.request.new.version.label' : 'review.create.summary.button.title' }" text="Create Review"/></form:button>
		</form:form>
</div>


<script type="text/javascript">
	$("#form").submit(function () {
		$("body").trigger("inProgressDialog");
	});

	var choiceGroupOne = $("[name=newVersionType]:not(#complete),#computeUpdatedIncoming,#computeUpdatedOutgoing");
	var choiceGroupTwo = $("[name=newVersionType]#complete,#clearVotes")

	// when the user click these radiobuttons autmatically check their "parent" checkbox
	$("#computeUpdatedIncoming,#computeUpdatedOutgoing").on("click", function () {
		var $box = $(this);

		if ($box.prop("checked")) {
			$("#onlySuspected").prop("checked", true);
		}
	});

	// when the user click these radiobuttons under complete autmatically check their "parent" checkbox
	$("#clearVotes").on("click", function () {
		$("#complete").prop("checked", true);
	})

	// when uncheck the parent checkbox, uncheck the child checkbox too
	$("#onlySuspected").on("click", function() {
		var $box = $(this);

		if (!$box.prop("checked")) {
			$("#computeUpdatedIncoming,#computeUpdatedOutgoing").prop("checked", false);
		}
	});

	// when uncheck the parent checkbox, uncheck the child checkbox too
	$("[name=newVersionType]#complete").on("change", function () {
		var $box = $(this);

		if (!$box.prop("checked")) {
			$("#clearVotes").prop("checked", false);
		}
	});


	// any checkbox from exclusionary groups uncheck all of the other group checkboxes
	choiceGroupOne.on("click", function() {
		choiceGroupTwo.prop("checked", false);
	});

	choiceGroupTwo.on("click", function() {
		choiceGroupOne.prop("checked", false);
	});

	var notificationFunction = function () {
		var enabledOnUpdate = $("#notifyReviewers").prop("checked") || $("#notifyModerators").prop("checked");
		$("#notifyOnItemUpdate").prop("disabled", !enabledOnUpdate);

		if(!enabledOnUpdate){
			$("#notifyOnItemUpdate").prop("checked", false);
		}
	};
	$("#notifyReviewers").on("click", notificationFunction);
	$("#notifyModerators").on("click", notificationFunction);
	notificationFunction();

</script>

<ui:inProgressDialog imageUrl="${pageContext.request.contextPath}/images/newskin/review_create_in_progress.gif" height="235" attachTo="body" triggerOnClick="false" />

