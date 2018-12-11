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
<%@ taglib uri="taglib" prefix="tag" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@ taglib uri="http://ditchnet.org/jsp-tabs-taglib" prefix="tab" %>

<meta name="decorator" content="main"/>
<meta name="moduleCSSClass" content="newskin reviewModule ${not empty revision ? 'tracker-baseline' : ''}"/>
<meta name="module" content="review"/>

<head>
	<link rel="stylesheet" href="<ui:urlversioned value='/stylesheet/review/review.less' />" type="text/css" media="all" />

	<script src="<ui:urlversioned value='/reviews/review.js'/>"></script>

	<style type="text/css">
		.wikiLinkContainer .jumpToDocumentViewBadge a {
			top: 0px;
		}
	</style>
</head>

<c:set var="isClosed" value="${review.isClosed(user)}"/>

<script type="text/javascript">
	var reviewConfig = {
		reviewId: ${review.id},
		done: ${isClosed},
		hasEditLicense: ${hasEditLicense}
	};

	<c:if test="${branchMergeRequest}">
	reviewConfig["branchId"] = ${branchId};
	</c:if>

	<c:if test="${not empty revision}">
	reviewConfig["revision"] = ${revision};
	</c:if>
	codebeamer.review.init(reviewConfig);
</script>

<ui:actionMenuBar cssClass="large">
	<jsp:attribute name="rightAligned">
		<c:set scope="request" value="/statistics" var="subPage"/>
		<jsp:include page="includes/switchToHead.jsp"/>

		<ui:combinedActionMenu builder="reviewActionMenuBuilder" keys="review,feedback,statistics"
			buttonKeys="review,feedback,statistics,history" subject="${review}" activeButtonKey="statistics"
			cssClass="large" hideMoreArrow="true" />
	</jsp:attribute>
	<jsp:body>
		<ui:breadcrumbs showProjects="false" showLast="false" showTrailingId="false" strongBody="false">
			<ui:pageTitle printBody="true">
				<spring:message code="review.statistics.title" arguments="${review.name}" text="Statistics for ${review.name }" htmlEscape="true"/>
			</ui:pageTitle>
		</ui:breadcrumbs>
	</jsp:body>
</ui:actionMenuBar>

<div class="actionBar">
	<ui:actionLink builder="reviewActionMenuBuilder" keys="exportToWord,exportToExcel" subject="${review }"></ui:actionLink>
</div>
<div class="contentWithMargins">

	<c:choose>
		<c:when test="${!hasEditLicense }">
			<div class="warning">
				<spring:message code="license.reviews.nolicense.message"/>
			</div>
		</c:when>
		<c:otherwise>
			<div class="stats-box">
				<table class="propertyTable">
					<tr>
						<td class="optional"><spring:message code="review.statistics.started.by.label" text="Started by"/>:</td>
						<td>
							<ui:userPhoto userId="${review.submitter.id }" ></ui:userPhoto>
							<div class="link-and-date">
								<tag:userLink user_id="${review.submitter }"></tag:userLink>
								<c:choose>
									<c:when test="${not empty review.startDate }">
										<span class="subtext date"><tag:formatDate value="${review.startDate }"></tag:formatDate></span>
									</c:when>
									<c:otherwise>
										<span class="subtext date"><spring:message code="review.statistics.date.not.defined" text="Undefined"/></span>
									</c:otherwise>
								</c:choose>
							</div>
						</td>
					</tr>
					<tr>
						<td class="optional"><spring:message code="review.statistics.completed.at.label" text="Completed at"/>:</td>
						<td>
							<c:choose>
								<c:when test="${review.resolvedOrClosed }">
									<ui:userPhoto userId="${review.closedBy}" ></ui:userPhoto>

									<div class="link-and-date">
										<tag:userLink user_id="${review.closedBy }"></tag:userLink>
										<c:choose>
											<c:when test="${not empty review.closedAt }">
												<span class="subtext date"><tag:formatDate value="${review.closedAt }"></tag:formatDate></span>
											</c:when>
											<c:otherwise>
												<span class="subtext date"><spring:message code="review.statistics.date.not.defined" text="Undefined"/></span>
											</c:otherwise>
										</c:choose>
									</div>
								</c:when>
								<c:otherwise>
									<span class="subtext"><spring:message code="review.statistics.not.finished" text="Not Finished"/></span>
								</c:otherwise>
							</c:choose>
						</td>
					</tr>
					<tr>
						<td class="optional"><spring:message code="review.statistics.signed.by.label" text="Signed by"/>:</td>
						<td>
							<c:choose>
								<c:when test="${review.signedBy != null }">
									<ui:userPhoto userId="${review.signedBy}" ></ui:userPhoto>

									<div class="link-and-date">
										<tag:userLink user_id="${review.signedBy }"></tag:userLink>
										<c:choose>
											<c:when test="${not empty review.signedAt }">
												<span class="subtext date"><tag:formatDate value="${review.signedAt }"></tag:formatDate></span>
											</c:when>
											<c:otherwise>
												<span class="subtext date"><spring:message code="review.statistics.date.not.defined" text="Undefined"/></span>
											</c:otherwise>
										</c:choose>
									</div>
								</c:when>
								<c:otherwise>
									<span class="subtext"><spring:message code="review.statistics.not.signed" text="Not Signed"/></span>
								</c:otherwise>
							</c:choose>
						</td>
					</tr>
					<tr>
						<td class="optional"><spring:message code="review.flow.step1.deadline.label" text="Deadline"/>:</td>
						<td>
							<c:choose>
								<c:when test="${not empty review.endDate }">
									<span class="subtext"><tag:formatDate value="${review.endDate }"></tag:formatDate></span>
								</c:when>
								<c:otherwise>
									<span class="subtext"><spring:message code="review.statistics.date.not.defined" text="Undefined"/></span>
								</c:otherwise>
							</c:choose>
						</td>
					</tr>
					<tr>
						<c:if test="${creationBaseline != null }">
							<td class="optional"><spring:message code="baseline.label" text="Baseline"/>:</td>
							<td>
								<c:url var="baselineUrl" value="${creationBaseline.urlLink }"/>

								<a href="${baselineUrl }"><c:out value="${creationBaseline.name }"/></a>
							</td>
						</c:if>
						<c:if test="${creationBaseline == null }">
							<td class="optional"><spring:message code="baseline.label" text="Baseline"/>:</td>
							<td>
								<span class="subtext">
									<spring:message code="review.baselines.head.label" text="HEAD"></spring:message>
								</span>
							</td>
						</c:if>
					</tr>

					<c:if test="${review.mergeRequest}">
						<tr>
							<td class="optional"><spring:message code="review.statistics.source.${branchMergeRequest or sourceBranch.branch ? 'branch' : 'tracker'}.label" text="Source Branch"/></td>
							<td>
								<ui:wikiLink item="${sourceBranch}" useKeyInLabel="true"/>
							</td>
						</tr>

						<tr>
							<td class="optional"><spring:message code="review.statistics.target.${branchMergeRequest or targetBranch.branch ? 'branch' : 'tracker'}.label" text="Target Branch"/></td>
							<td>
								<ui:wikiLink item="${targetBranch}" useKeyInLabel="true"/>
							</td>
						</tr>
					</c:if>
				</table>
			</div>

			<div>
				<div class="stats-box">${pieChart }</div>
				<c:if test="${not empty  pieChartPrevious}">
					<div class="stats-box">${pieChartPrevious }</div>
				</c:if>
			</div>
			<c:choose>
				<c:when test="${hasPreviousVersion }">
					<spring:message code="review.statistics.tab.stat.title" var="statTabTitle" text="Statistics"/>
					<spring:message code="review.statistics.tab.previous.title" var="previousTabTitle" text="Statistics Before Restart"/>

					<tab:tabContainer id="review-history-stats" skin="cb-box" selectedTabPaneId="current-stats">
						<tab:tabPane id="current-stats" tabTitle="${statTabTitle }">
							<jsp:include page="includes/reviewStatsProgress.jsp"></jsp:include>
						</tab:tabPane>

						<tab:tabPane id="previous-version-stats" tabTitle="${previousTabTitle }">
							<c:set var="statsPerItem" value="${statsPerItemPrevious }" scope="request"/>
							<c:set var="stastPerUser" value="${stastPerUserPrevious }" scope="request"/>
							<jsp:include page="includes/reviewStatsProgress.jsp"/>
						</tab:tabPane>
					</tab:tabContainer>
				</c:when>
				<c:otherwise>
					<jsp:include page="includes/reviewStatsProgress.jsp"></jsp:include>
				</c:otherwise>
			</c:choose>

		</c:otherwise>

	</c:choose>

</div>
