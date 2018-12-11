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
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="bugstaglib" prefix="bugs" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<style type="text/css">

	.wikichartbox.myReviewsPlugin .miniprogressbar {
		width: 90%;
	}

	.wikichartbox.myReviewsPlugin .miniprogressbar div {
	    padding: 0;
	}

	.wikichartbox.myReviewsPlugin .miniprogressbar .barLabel {
		display: block;
		text-align: center;
	}

	.wikichartbox.myReviewsPlugin .contentWithMargins {
	    margin: 0;
	}

    .wikichartbox.myReviewsPlugin .trackerImage {
        margin: 0;
    }

    .wikichartbox.myReviewsPlugin .scrollable {
        margin: 0;
    }
</style>
<div class="contentWithMargins">
	<c:choose>
		<c:when test="${!hasLicense}">
			<div class="warning">
				<spring:message code="license.reviews.nolicense.message"/>
			</div>
		</c:when>
		<c:otherwise>
            <c:set var="pluginTableId" value="${not empty pluginTableId ? pluginTableId : 'trackerItems'}"></c:set>
			<bugs:displaytagTrackerItems htmlId="${pluginTableId}" items="${reviews}" hideIconColumn="true"
							requestURI="${action}" pagesize="${pagesize}" decorator="${decorator}" exportMode="${isExportMode}"
							browseTrackerMode="false" selection="false" selectionFieldName="clipboard_task_id" layoutList="${layoutList}"
							extraColumn="${progressColumn}" extraColumnLabel="review.statistics.overall.stats.label" export="false" isReview="true" />

		</c:otherwise>
	</c:choose>
</div>