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
<%@page import="com.intland.codebeamer.remoting.GroupTypeClassUtils"%>
<meta name="decorator" content="main"/>
<meta name="module" content="start"/>
<meta name="moduleCSSClass" content="newskin workspaceModule"/>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>

<link rel="stylesheet" href="<ui:urlversioned value='/stylesheet/historyList.css' />" type="text/css"/>

<ui:actionMenuBar>
			<spring:message code="user.subscriptions.type.${command.type}" var="typeText" />
			<c:set var="subscriberName"><c:out value='${subscriber.name}'/></c:set>
			<ui:pageTitle><spring:message code="user.subscribed.by.title" text="{0} followed by {1}" arguments="${typeText},${subscriberName}" htmlEscape="true"/></ui:pageTitle>
</ui:actionMenuBar>

<c:url var="action" value="/listSubscribes.spr" />
<form:form action="${action}" method="GET">
<ui:actionBar>
	Show:
	<form:select path="type" onchange="$(this).closest('form').submit();">
		<form:option value="1"><spring:message code="Trackers"/></form:option>
		<form:option value="2"><spring:message code="Wikis"/></form:option>
		<form:option value="3"><spring:message code="Documents"/></form:option>
		<form:option value="4"><spring:message code="Issues"/></form:option>
	</form:select>
</ui:actionBar>
</form:form>

<style type="text/css">
	.menuColumn {
		text-align: left;
		width: 100%;
	}
	.entityCell {
		white-space: nowrap;
	}
</style>

<c:set var="requestURI" value="/listSubscribes.spr" />

<c:choose>
<c:when test="${command.type == 1}">
	<jsp:include page="tracker/trackersSummary.jsp" flush="true">
		<jsp:param name="showNotificationBox" value="false" />
	</jsp:include>
</c:when>
<c:otherwise>
	<spring:message code="subscription.unsubscribe.label" var="unfollow" />

	<%-- showing generic list of entities, similar to history.jsp --%>
	<ui:displaytagPaging defaultPageSize="${pageSize}" items="${entities}" excludedParams="page"/>

	<display:table class="followed-items" cellpadding="0" requestURI="${requestURI}" name="${entities}" id="entity" defaultorder="descending" decorator="com.intland.codebeamer.ui.view.table.HistoryDecorator">
		<%
			Integer entityTypeId = GroupTypeClassUtils.objectToGroupType(entity);
			pageContext.setAttribute("entityTypeId", entityTypeId);
		%>
        <display:setProperty name="paging.banner.placement" value="bottom" />
		<display:setProperty name="paging.banner.some_items_found" value="${allItems}" />

		<c:set var="styleClass" value="" />
		<c:catch>
			<c:if test="${entity.closed}">
				<c:set var="styleClass" value="closedItem" />
			</c:if>
		</c:catch>

		<spring:message var="objectShortDescription" code="user.history.shortDescription.label" text="Artifact"/>
		<display:column>
			<span class="entityMenuTrigger" entityId="${entity.id}" entityTypeId="${entityTypeId}"><img class="menuArrowDown" src="<c:url value='/images/space.gif'/>"/></span>
		</display:column>
		<display:column title="${objectShortDescription}" sortProperty="sortReferableDtoDtoAsWikiOrTrackerLink"  property="referableDtoDtoAsWikiLinkWithShortDescription" sortable="true" headerClass="textData" class="expand textDataWrap columnSeparator">
		</display:column>

	</display:table>
    <div style="clear:both;"></div>
</c:otherwise>
</c:choose>

<script type="text/javascript">
function removeNotification(link, entityTypeId, entityId) {
	setNotifications(contextPath + "/ajax/setNotification.spr", function() {
		// removing the unsubscribed item's row
		$(link).closest("tr").remove();
	}, entityTypeId, entityId, false);
}

$(function() {
	var contextMenu = new ContextMenuManager({
		selector: ".entityMenuTrigger",
		build: function($trigger, event) {
			var entityTypeId = $trigger.attr("entityTypeId");
			var entityId = $trigger.attr("entityId");
			return {
				items: {
					"unfollow" : {
						name: "${unfollow}",
						callback: function() {
							removeNotification($trigger, entityTypeId, entityId);
						}
					}
				}
			}
		},
		trigger: "left"
	});
	contextMenu.render();
	if (codebeamer.userPreferences.alwaysDisplayContextMenuIcons) {
		$('#entity .menuArrowDown').addClass('always-display-context-menu');
	}
});
</script>
