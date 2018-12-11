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
<%@ taglib uri="taglib" prefix="tag" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="uitaglib" prefix="ui" %>

<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>

<jsp:include page="/bugs/includes/issueReview.jsp" />

<c:if test="${not empty itemReviewStats }">
	<spring:message code="review.details.statistics.label" var="reviewStatisticsLabel"/>
	<ui:collapsingBorder label="${reviewStatisticsLabel }" cssClass="separatorLikeCollapsingBorder" open="true">

		<select name="reviewStatsSelector" style="margin-bottom: 15px;">
			<option value="all"><spring:message code="issue.review.filter.all" text="All Reviews"/></option>
			<option value="open" selected="selected"><spring:message code="issue.review.filter.open" text="Open Reviews"/></option>
		</select>

		<label for="showMergeRequests">
			<input type="checkbox" name="showMergeRequests" id="showMergeRequests" checked="checked"/>
			<spring:message code="issue.review.filter.merge.requests" text="Show Merge Requests"/>
		</label>

		<jsp:include page="/bugs/tracker/includes/itemReviewStats.jsp"></jsp:include>
	</ui:collapsingBorder>
</c:if>

<c:if test="${not empty itemReviews }">
	<spring:message code="review.details.item.statistics.label" text="Tracker Item Reviews" var="reviewsLabel"/>
	<ui:collapsingBorder label="${reviewsLabel }" cssClass="separatorLikeCollapsingBorder">
		<div id="itemReviews"></div>
	</ui:collapsingBorder>
</c:if>

<script type="text/javascript">

	$("[name=reviewStatsSelector],[name=showMergeRequests]").change(function () {
		var reviewSelector = $("[name=reviewStatsSelector]").val();
		var showMergeRequests = $("[name=showMergeRequests]").is(':checked');
		// all + show: $(".reviewStatsBox").show()
		// all + notshow: $(".reviewStatsBox:not(.merge-request)").show()
		// open + show $(".reviewStatsBox:not(.closed)").show()
		// open + notshow $(".reviewStatsBox:not(.closed):not(.merge-request)").show()

		// hide all boxes
		$('.reviewStatsBox').hide();

		// show only the matching ones
		// build the selector
		var selector = '.reviewStatsBox';
		if (reviewSelector != 'all') {
			selector += ':not(.closed)';
		}

		if (!showMergeRequests) {
			selector += ':not(.merge-request)';
		}

		$(selector).show();
	});


	$('#itemReviews').trackerItemReviews(issueCopyMoveContext, ${itemReviewsJSON}, $.extend({}, trackerItemReviews, {
		editable : ${canEditReviews}
	}));

</script>
