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

<%@ taglib uri="http://displaytag.sf.net" prefix="display" %>

<meta name="decorator" content="main"/>
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

<link rel="stylesheet" href="<ui:urlversioned value="/js/jquery/jquery-selectboxit/jquery.selectBoxIt.css" />" type="text/css" media="all" />
<link rel="stylesheet" href="<ui:urlversioned value="/js/jquery/jquery-selectboxit/jquery.selectBoxIt.custom.less" />" type="text/css" media="all" />
<link rel="stylesheet" href="<ui:urlversioned value='/stylesheet/review/review.less' />" type="text/css" media="all" />


<script src="<ui:urlversioned value='/js/jquery/jquery-selectboxit/jquery.selectBoxIt.min.js'/>"></script>

<ui:actionMenuBar cssClass="large">
	<ui:pageTitle printBody="true">
		<spring:message code="review.list" text="Reviews"/>
	</ui:pageTitle>
	<c:if test="${hasLicense }">
		<span class="breadcrumbs-separator">&raquo;</span>
		<select name="reviewFilter">
			<option value="all" ${!command.onlyOpen ? 'selected=selected' : '' }><spring:message code="issue.review.filter.all" text="All Reviews"/></option>
			<option value="open"  ${command.onlyOpen ? 'selected=selected' : '' }><spring:message code="issue.review.filter.open" text="Open Reviews"/></option>
		</select>
	</c:if>
</ui:actionMenuBar>

<c:if test="${hasLicense }">
	<ui:actionBar>

		<c:url value="/review/create/createReview.spr" var="createReviewUrl"></c:url>
		<spring:message code="review.create.title" text="Create Review" var="createReviewTitle"></spring:message>

		<a href="javascript:showCreateDialog(${hasEditLicense });" class="actionLink actionBarIcon" title="${createReviewTitle }">
			<img class="tableIcon" src="<ui:urlversioned value="/images/newskin/actionIcons/icon-add-blue.png"/>" style="">
		</a>

		<select id="grouping" name="grouping">
			<c:forEach items="${groupingOptions}" var="option">
				<c:set var="selected" value=""/>
				<c:if test="${option == command.grouping}">
					<c:set var="selected" value="selected='selected'"/>
				</c:if>
				<option value="${option}" ${selected}><spring:message code="review.grouping.${option}.label"/></option>
			</c:forEach>
		</select>
	</ui:actionBar>

</c:if>


<div class="contentWithMargins">

	<c:choose>
		<c:when test="${!hasLicense }">
			<div class="warning">
				<spring:message code="license.reviews.nolicense.message"/>
			</div>
		</c:when>
		<c:otherwise>
			<c:forEach items="${grouped}" var="entry">
				<c:if test="${entry.key.id != 0}"> <%-- do not show the header for the default group --%>
					<h3 class="accordion-header">
						<c:choose>
							<c:when test="${entry.key.id == 1}">
								<spring:message code="review.grouping.multi.label" text="Reviews belonging to multiple groups"/>
							</c:when>
							<c:otherwise>
								<c:out value="${grouping.getGroupName(entry.key)}"/>
							</c:otherwise>
						</c:choose>
					</h3>
				</c:if>
				<div clas="accordion-content">
					<bugs:displaytagTrackerItems htmlId="trackerItems" items="${entry.value}" hideIconColumn="true" export="false"
												 pagesize="${pageSize}" decorator="${decorator}"
												 browseTrackerMode="false" selection="false" selectionFieldName="clipboard_task_id" layoutList="${layoutList }"
												 extraColumn="${progressColumn }" extraColumnLabel="review.statistics.overall.stats.label" isReview="true" />
				</div>
			</c:forEach>


			<script type="text/javascript">
				function getUrlParameters () {
                    var reviewFilter = $('[name=reviewFilter]').val();
					var grouping = $('[name=grouping]').val();

					return '?onlyOpen=' + (reviewFilter != 'all')
						+ (grouping != 'None' ? '&grouping=' + grouping : '')
						+ '&showMergeRequests=false'
                }

				$("[name=reviewFilter],[name=grouping]").change(function () {

					var url = contextPath + '/review' + getUrlParameters();
					location.href = url;
				});
				$('[name=reviewFilter]').selectBoxIt();

			</script>
		</c:otherwise>
	</c:choose>
</div>

<script type="text/javascript">
	var showCreateDialog = function (hasEditLicense) {
		if (hasEditLicense) {
			showPopupInline('${createReviewUrl }', {geometry: 'large'});
		} else {
			showFancyAlertDialog(i18n.message("license.reviews.nolicense.message"));
		}
	};
</script>