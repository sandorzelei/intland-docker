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

<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="bugstaglib" prefix="bugs" %>

<meta name="decorator" content="${param.isPopup == 'true' ? 'popup' : 'main'}"/>
<meta name="moduleCSSClass" content="newskin reviewModule"/>
<meta name="module" content="review"/>

<style type="text/css">

	td.textSummaryData .miniprogressbar {
		width: 90%;
	}

	td.textSummaryData .miniprogressbar div {
		box-sizing: border-box;
	}

	.textSummaryData .tableIcon {
		display: none;
	}
</style>

<ui:actionMenuBar cssClass="large">
	<ui:pageTitle printBody="true">
		<spring:message code="${param.isPopup == 'true' ? 'pending.merge.request.list' : 'review.merge.requests.label'}" text="Pending Merge Requests"/>
	</ui:pageTitle>
	<c:if test="${hasLicense }">
		<span class="breadcrumbs-separator">&raquo;</span>
		<select name="reviewFilter">
			<spring:message code="issue.review.merge.filter.all" text="All Merge Requests" var="allMergeRequestsTitle"/>
			<spring:message code="issue.review.merge.filter.open" text="Open Merge Requests" var="openMergeRequestsTitle"/>

			<option value="all" ${!onlyOpen ? 'selected=selected' : '' } title="${allMergeRequestsTitle }">${allMergeRequestsTitle }</option>
			<option value="open"  ${onlyOpen ? 'selected=selected' : '' } title="${openMergeRequestsTitle }">${openMergeRequestsTitle }</option>
		</select>
	</c:if>
</ui:actionMenuBar>

<c:if test="${param.isPopup != 'true' and hasLicense }">
	<ui:actionBar>

		<c:url value="/review/create/createMergeRequest.spr" var="createMergeRequestUrl"></c:url>
		<spring:message code="review.merge.create.title" text="Create Merge Request" var="createMergeRequestTitle"></spring:message>

		<a href="javascript:showCreateDialog(${hasEditLicense });" class="actionLink actionBarIcon" title="${createMergeRequestTitle }">
			<img class="tableIcon" src="<ui:urlversioned value="/images/newskin/actionIcons/icon-add-blue.png"/>" style="">
		</a>
	</ui:actionBar>

</c:if>

<div class="contentWithMargins">

	<c:choose>
		<c:when test="${!hasLicense }">
			<div class="warning">
				<spring:message code="merge.request.list.no.license"/>
			</div>
		</c:when>
		<c:otherwise>
				<bugs:displaytagTrackerItems htmlId="trackerItems" items="${reviews}" hideIconColumn="true"
					pagesize="${pagesize}" decorator="${decorator}"
					browseTrackerMode="false" selection="false" selectionFieldName="clipboard_task_id" layoutList="${layoutList }"
					extraColumn="${progressColumn }" extraColumnLabel="review.statistics.overall.stats.label" isReview="true" export="false"/>


			<script type="text/javascript">

				(function ($) {
					$("[name=reviewFilter]").change(function () {
						var reviewFilter = $('[name=reviewFilter]').val();

						var url = contextPath + '/proj/review/mergeRequests.spr?isPopup=${param.isPopup == 'true'}&tracker_id=${trackerId}&onlyOpen=' + (reviewFilter != 'all');
						location.href = url;
					});
				})(jQuery);


			</script>
		</c:otherwise>
	</c:choose>
</div>

<script type="text/javascript">
	var showCreateDialog = function (hasEditLicense) {
		if (hasEditLicense) {
			showPopupInline('${createMergeRequestUrl }', {geometry: 'large'});
		} else {
			showFancyAlertDialog(i18n.message("license.reviews.nolicense.message"));
		}
	};
</script>