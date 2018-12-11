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
<%@ taglib uri="uitaglib" prefix="ui" %>

<style type="text/css">

	tr.itemUserReview {
		border-top: 0px !important;
	}

	tr.itemUserReview td {
		padding-top: 3px !important;
		padding-bottom: 3px !important;
	}

	span.approval {
		vertical-align: middle;
		padding-bottom: 9px;
	}

	span.approval.rejected {
		color: #ab0b0b;
		padding-right: 24px;
		background-image: url("../images/vote_down.png");
		background-position: right top;
		background-repeat: no-repeat;
	}

	span.approval.approved {
		color: rgb(0, 168, 93);
		padding-right: 24px;
		background-image: url("../images/vote_up.png");
		background-position: right top;
		background-repeat: no-repeat;
	}

	input[type="number"]::-webkit-outer-spin-button,
	input[type="number"]::-webkit-inner-spin-button {
	    -webkit-appearance: none;
	    margin: 0;
	}
	input[type="number"] {
	    -moz-appearance: textfield;
	}
</style>

<script type="text/javascript" src="<ui:urlversioned value='/bugs/includes/issueReview.js'/>"></script>
<link rel="stylesheet" href="<ui:urlversioned value='/bugs/includes/itemReviewStats.less' />" type="text/css" media="all" />

<script type="text/javascript">

	var trackerItemReviewConfig = {
		approvedLabel		: '<spring:message code="issue.approved.label" 				text="Approved" javaScriptEscape="true" />',
		approvedTitle		: '<spring:message code="issue.approved.tooltip" 			text="This (work) item was approved/accepted by this user" javaScriptEscape="true" />',
		approvalsLabel		: '<spring:message code="issue.approved.threshold.short" 	text="Required" javaScriptEscape="true" />',
		approvalsTitle		: '<spring:message code="issue.approved.threshold.tooltip" 	text="The minimum number of approvals (positive votes), that are required for the review to be considered approved." javaScriptEscape="true" />',
		approvalsAll		: '<spring:message code="issue.approved.threshold.all.label" text="all" javaScriptEscape="true" />',
		approvalsInvalid	: '<spring:message code="issue.approved.threshold.invalid"  text="The required number of approvals must be either all or an Integer > 0" javaScriptEscape="true" />',
		approvalsVotes		: '<spring:message code="issue.review.votes.label" 			text="Votes" javaScriptEscape="true" />',
		approvedStatusLabel : '<spring:message code="issue.approved.status.label" 		text="Approved Status" javaScriptEscape="true" />',
		approvedStatusTitle : '<spring:message code="issue.approved.status.tooltip" 	text="The subject item should get this status, if the result of the approval is sufficiently decisive and positive" javaScriptEscape="true" />',
		rejectedLabel		: '<spring:message code="issue.rejected.label" 				text="Rejected" javaScriptEscape="true" />',
		rejectedTitle		: '<spring:message code="issue.rejected.tooltip" 			text="This (work) item was rejected by this user" javaScriptEscape="true" />',
		rejectsLabel		: '<spring:message code="issue.rejected.threshold.short" 	text="Allowed" javaScriptEscape="true" />',
		rejectsTitle		: '<spring:message code="issue.rejected.threshold.tooltip"  text="The maximum number of rejects (negative votes), that are allowed, before the review should be considered rejected" javaScriptEscape="true" />',
		rejectsVotes		: '<spring:message code="issue.review.rejects.label" 		text="Rejects" javaScriptEscape="true" />',
		rejectedStatusLabel : '<spring:message code="issue.rejected.status.label" 		text="Rejected Status" javaScriptEscape="true" />',
		rejectedStatusTitle : '<spring:message code="issue.rejected.status.tooltip" 	text="The subject item should get this status, if the result of the approval is sufficiently decisive and negative." javaScriptEscape="true" />',
		statusLabel			: '<spring:message code="issue.status.label=Status" 		text="Status" javaScriptEscape="true" />',
		statusOptionsURL	: '<c:url value="/trackers/ajax/choiceOptions.spr"/>',
		signatureLabel		: '<spring:message code="issue.review.signature.label" 	   text="Signature" javaScriptEscape="true" />',
		signatureTitle		: '<spring:message code="issue.review.signature.tooltip"   text="The type of electronic signature, that is required for this rating/approval" javaScriptEscape="true" />',
		signature			: [{
			label			: '<spring:message code="issue.review.signature.0.label"   text="None" javaScriptEscape="true" />',
			title			: '<spring:message code="issue.review.signature.0.tooltip" text="No electronic signature required" javaScriptEscape="true" />'
		}, {
			label			: '<spring:message code="issue.review.signature.1.label"   text="Password" javaScriptEscape="true" />',
			title			: '<spring:message code="issue.review.signature.2.tooltip" text="The users must enter their password" javaScriptEscape="true" />'
		}, {
			label			: '<spring:message code="issue.review.signature.2.label"   text="Username and Password" javaScriptEscape="true" />',
			title			: '<spring:message code="issue.review.signature.2.tooltip" text="The users must enter must enter their username and password" javaScriptEscape="true" />'
		}]
	};

	var trackerItemReviews = {
		noneLabel		: '<spring:message code="issue.reviews.none" 				text="There are no reviews for this item" javaScriptEscape="true" />',
		subjectLabel 	: '<spring:message code="issue.review.trackerItem.label" 	text="Subject" javaScriptEscape="true" />',
		subjectTooltip	: '<spring:message code="issue.review.trackerItem.tooltip"	text="The specific revision/status of the tracker item to review" javaScriptEscape="true" />',
		resultLabel		: '<spring:message code="issue.review.result.label" 		text="Result" javaScriptEscape="true" />',
		resultTooltip	: '<spring:message code="issue.review.result.tooltip" 		text="The result of the review" javaScriptEscape="true" />',
	    inProgressLabel : '<spring:message code="issue.review.inProgress.label" 	text="In Progress" javaScriptEscape="true" />',
	    inProgressTitle : '<spring:message code="issue.review.inProgress.tooltip" 	text="The review is still in progress" javaScriptEscape="true" />',
	    undecidedLabel 	: '<spring:message code="issue.review.undecided.label" 		text="Undecided" javaScriptEscape="true" />',
	    undecidedTitle	: '<spring:message code="issue.review.undecided.tooltip" 	text="The review was closed without a sufficiently decisive result." javaScriptEscape="true" />',
		votesLabel		: '<spring:message code="issue.review.votes.label" 			text="Votes" javaScriptEscape="true" />',
		votesTooltip	: '<spring:message code="issue.review.votes.tooltip" 		text="Number of submitted votes for this review" javaScriptEscape="true" />',
		votesXofY		: '<spring:message code="issue.reviews.XofY" 				text="after <b>{0}</b> of <b>{1}</b> reviews" arguments="XX,YY" javaScriptEscape="true" />',
		approvedLabel	: '<spring:message code="issue.approved.label" 				text="Approved" javaScriptEscape="true" />',
		approvedTooltip	: '<spring:message code="issue.approved.tooltip" 			text="This (work) item was approved/accepted by this user" javaScriptEscape="true" />',
		approvedXofY	: '<spring:message code="issue.approvals.XofY" 				text="with <b>{0}</b> vs. <b>{1}</b> votes" arguments="XX,YY" javaScriptEscape="true" />',
		rejectedLabel	: '<spring:message code="issue.rejected.label" 				text="Rejected" javaScriptEscape="true" />',
		rejectedTooltip	: '<spring:message code="issue.rejected.tooltip" 			text="This (work) item was rejected by this user" javaScriptEscape="true" />',
		configLabel 	: '<spring:message code="tracker.tree.settings.title" 		text="Settings" javaScriptEscape="true" />',
		configDialog	: {
			title		: '<spring:message code="issue.review.label" 				text="Review"	javaScriptEscape="true" />',
			submitText  : '<spring:message code="button.ok" 					   	text="OK" 		javaScriptEscape="true"/>',
			cancelText  : '<spring:message code="button.cancel" 				   	text="Cancel" 	javaScriptEscape="true"/>'
		},
		configSettings	: trackerItemReviewConfig,
		configURL		: '<c:url value="/trackers/ajax/trackerItemReviewConfig.spr"/>',
		reviewsURL		: '<c:url value="/trackers/ajax/trackerItemReviews.spr"/>',
		reviewerURL		: '<c:url value="/user/"/>',
	};

</script>