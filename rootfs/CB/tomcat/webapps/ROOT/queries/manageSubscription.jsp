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
<meta name="decorator" content="popup"/>

<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib prefix="tag" uri="http://java.sun.com/jsp/jstl/fmt" %>

<link rel="stylesheet" href="<ui:urlversioned value='/queries/queries.less' />" type="text/css" media="all" />
<script type="text/javascript" src="<ui:urlversioned value='/queries/subscription.js'/>"></script>

<ui:actionMenuBar>
	<spring:message code="queries.manage.subscription.label" text="Manage Query Subscriptions"/>
</ui:actionMenuBar>

<div class="contentWithMargins">
<c:choose>
	<c:when test="${not empty result}">
		<h4><spring:message code="queries.subscription.manage.jobs.info"/></h4>
		<spring:message var="removeTitle" code="queries.subscription.remove.tooltip"/>
		<table class="displaytag manageSubscriptionTable">
			<tr>
				<th><spring:message code="queries.subscription.name.label"/></th>
				<th><spring:message code="queries.report.label"/></th>
				<th><spring:message code="queries.subscription.frequency.label"/></th>
				<th><spring:message code="queries.subscription.last.run.label"/></th>
				<th></th>
				<th></th>
			</tr>
			<c:forEach items="${result}" var="subscription">
				<tr data-query-id="${subscription.dto.objectId}" <c:if test="${subscription.stopped}"> class="disabled"</c:if>>
					<td class="name"><c:if test="${!subscription.stopped}"><a href="<c:url value="/proj/query/editSubscription.spr?queryId=${subscription.dto.objectId}&subscriptionId=${subscription.dto.id}"/>"></c:if>${subscription.dto.name}<c:if test="${!subscription.stopped}"></a></c:if></td>
					<td><c:if test="${!subscription.stopped}"><a href="<c:url value="${subscription.cbQL.urlLink}"/>"></c:if>${subscription.cbQL.name}<c:if test="${!subscription.stopped}"></a></c:if></td>
					<td>${subscription.frequencyText}</td>
					<td class="dateData">
						<c:choose>
							<c:when test="${empty subscription.dto.lastRun}">
								<spring:message code="queries.subscription.not.yet.run"/>
							</c:when>
							<c:otherwise>
								<tag:formatDate value="${subscription.dto.lastRun}"/>
							</c:otherwise>
						</c:choose>
					</td>
					<td class="controls">
						<c:choose>
							<c:when test="${subscription.stopped}">
								<a href="<c:url value="/proj/query/enableSubscription.spr?&subscriptionId=${subscription.dto.id}"/>" id="enableJob"><spring:message code="queries.subscription.enable.label"/></a>
							</c:when>
							<c:otherwise>
								<a href="<c:url value="/proj/query/stopSubscription.spr?&subscriptionId=${subscription.dto.id}"/>" id="disableJob"><spring:message code="queries.subscription.disable.label"/></a>
							</c:otherwise>
						</c:choose>
					</td>
					<td class="controls">
						<a class="removeButton" title="${removeTitle}" href="<c:url value="/proj/query/deleteSubscription.spr?subscriptionId=${subscription.dto.id}"/>"></a>
					</td>
				</tr>
			</c:forEach>
		</table>
	</c:when>
	<c:otherwise>
		<h4><spring:message code="queries.subscription.no.jobs"/></h4>
	</c:otherwise>
</c:choose>
</div>

<script type="text/javascript">
	$(function() {
		var queryIds = [];
		$(".manageSubscriptionTable tr").each(function() {
			queryIds.push(parseInt($(this).attr("data-query-id"), 10));
		});
		var queryId = parseInt(window.parent.$("#editSubscription").attr("data-query-id"), 10);
		if ($.inArray(queryId, queryIds) === -1) {
			window.parent.$("#editSubscription").hide();
			window.parent.$("#newSubscription").show();
		}
	});
</script>