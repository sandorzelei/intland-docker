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
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<script type="text/javascript" src="<ui:urlversioned value='/js/itemHistory.js'/>"></script>

<style type="text/css">
.show-all-link {
	font-size: 14px;
	color: #0093b8;
	margin-top: 25px;
	padding-top: 10px;
	width: 100%;
}
</style>

<script type="text/javascript">
	$(document).ready(function() {
		codebeamer.item.history.init();
	});
</script>

<c:if test="${!empty trackerItemStateHistoryPlugin}">
	<div style="margin:10px 0 10px 0;">
		${trackerItemStateHistoryPlugin}
	</div>
</c:if>

<c:if test="${!empty param.historyTitle}">
	<ui:title style="headline.grayed" topMargin="10" >
		<c:out value="${param.historyTitle}" />
	</ui:title>
</c:if>

<c:if test="${showCompareVersionsButton and fn:length(itemHistory) > 1}">
	<a href="#" class="compare-versions-link" data-item-id="${itemHistory[0].id}" data-head-version="${fn:length(itemHistory) > 0 ? itemHistory[0].version : 1}">
		<strong><spring:message code="baseline.diff.versions.label"/></strong>
	</a>
</c:if>

<jsp:include page="./itemHistoryTable.jsp" />

<c:if test="${showAllHistoryButton eq true}">
	<c:set var="historyCount" value="${fn:length(itemHistory)}" />
	<c:if test="${not empty historyFullCount}">
		<c:set var="historyCount" value="${historyFullCount}" />
	</c:if>
	<div class="information">
		<spring:message code="issue.history.paging" text="Only the last {0} history item loaded." arguments="${fn:length(itemHistory)}"/>
		<a href="#" class="show-all-history-link" data-item-id="${itemHistory[0].id}">
			<spring:message code="comments.attachments.showAll" text="Show All ({0})" arguments="${historyCount}"/>
		</a>
	</div>
</c:if>
