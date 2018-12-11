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
<%@ tag import="com.intland.codebeamer.controller.support.BreadCrumbNavigationSupport" %>
<%@ tag import="com.intland.codebeamer.controller.ControllerUtils" %>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="ui" uri="uitaglib" %>

<%@ attribute name="itemId" type="java.lang.Integer" required="true" description="The ID of the Tracker Item." %>
<%@ attribute name="id" type="java.lang.String" required="false" description="Unique ID of the BreadCrumb Navigation, mandatory if more are used in one page." %>
<%@ attribute name="isIncoming" type="java.lang.Boolean" required="false" description="False if outgoing (upstream) references will display, true if incoming references." %>
<%@ attribute name="numberOfLevels" type="java.lang.Integer"  required="false" description="Number of levels (depth)." %>
<%@ attribute name="numberOfItemsPerLevel" type="java.lang.Integer" required="false" description="Number of referencing Tracker Items per Level." %>
<%@ attribute name="baseline" type="com.intland.codebeamer.persistence.util.Baseline" required="false" description="Optional Baseline of the Tracker Item." %>
<%@ attribute name="showRating" type="java.lang.Boolean" required="false" description="If rating should show or not." %>

<link rel="stylesheet" href="<ui:urlversioned value='/stylesheet/breadCrumbNavigation.less' />" type="text/css"/>

<%
	if (id == null) {
		id = "breadCrumbNavigation";
	}
	jspContext.setAttribute("id", id);
	if (isIncoming == null) {
		isIncoming = Boolean.FALSE;
	}
	if (numberOfLevels == null) {
		numberOfLevels = BreadCrumbNavigationSupport.DEFAULT_NUMBER_OF_LEVELS;
	}
	if (numberOfItemsPerLevel == null) {
		numberOfItemsPerLevel = BreadCrumbNavigationSupport.DEFAULT_NUMBER_OF_ITEMS_PER_LEVEL;
		jspContext.setAttribute("numberOfItemsPerLevelVar", numberOfItemsPerLevel);
	}
	BreadCrumbNavigationSupport support = ControllerUtils.getSpringBean(request, null, BreadCrumbNavigationSupport.class);
	jspContext.setAttribute("references", support.getReferences(request, itemId, numberOfLevels, numberOfItemsPerLevel, baseline, isIncoming.booleanValue()));
%>

<div id="breadCrumbNavigation_${id}" class="breadCrumbNavigation">

	<c:forEach items="${references}" var="level" varStatus="loop">
		<c:choose>
			<c:when test="${loop.index == 0}">
				<div class="levelPlaceholder levelContainer">
					<c:if test="${fn:length(level) > 0}">
						<div class="labelText"><spring:message code="breadcrumb.navigation.first.level.${isIncoming ? 'incoming.' : ''}label"/></div>
					</c:if>
			</c:when>
			<c:otherwise>
				<c:if test="${fn:length(level) > 0}">
					<div class="level levelContainer">
						<div class="labelText"><spring:message code="breadcrumb.navigation.level.label" text="Level"/> <c:out value="${loop.index}"/></div>
				</c:if>
			</c:otherwise>
		</c:choose>
		<c:forEach items="${level}" var="item" varStatus="referenceLoop">
			<c:if test="${referenceLoop.index < numberOfItemsPerLevelVar}">
				<div class="item" data-item-id="${item.id}">
					<ui:coloredEntityIcon iconUrlVar="iconUrl" iconBgColorVar="iconBgColor" subject="${item}"/>
					<span class="statusIcon" style="background-color: ${iconBgColor}"></span>
					<span class="itemKeyAndId"><a title="<ui:breadcrumbTitle item="${item}"></ui:breadcrumbTitle>" href="${pageContext.servletContext.contextPath}${item.getUrlLinkBaselined(empty baseline ? null : baseline.id)}"><c:out value="${item.keyAndId}"/></a></span>
				</div>
			</c:if>
		</c:forEach>
		<c:if test="${fn:length(level) >= numberOfItemsPerLevelVar}">
			<div class="contextMenu" title="<spring:message code="breadcrumb.navigation.show.all"/>" id="breadCrumbContextMenu_${loop.index}"
				 data-level="${loop.index}" data-item-id="${itemId}" data-baseline-id="${empty baseline ? 0 : baseline.id}" data-is-incoming="${isIncoming}"></div>
		</c:if>
		<c:if test="${loop.index == 0 && fn:length(level) == 0}">
			<div class="item"><spring:message code="breadcrumb.navigation.no.item"></spring:message></div>
		</c:if>
		<c:if test="${loop.index == 0 || fn:length(level) > 0}">
			</div>
		</c:if>
	</c:forEach>

	<c:if test="${showRating}">
		<ui:rating voting="false" onlyForWikiOrIssue="true" disabled="true" />
	</c:if>

</div>

<script type="text/javascript">
	(function($) {

		var getIncludedItemIds = function($menuArrow) {
			var itemIds = [];
			$menuArrow.closest(".levelContainer").find(".item").each(function() {
				itemIds.push($(this).attr("data-item-id"))
			});
			return itemIds.join(",");
		};

		var initializeContextMenus = function () {
			$("#breadCrumbNavigation_${id}").on('click', '.contextMenu', function () {
				var $menuArrow = $(this);
				buildInlineMenuFromJson($menuArrow, "#" + $menuArrow.attr("id"), {
					'task_id': $menuArrow.attr("data-item-id"),
					'cssClass': 'inlineActionMenu',
					'builder': 'breadCrumbNavigationActionMenuBuilder',
					'breadCrumbLevel': $menuArrow.attr("data-level"),
					'breadCrumbBaselineId': $menuArrow.attr("data-baseline-id"),
					'breadCrumbIsIncoming': $menuArrow.attr("data-is-incoming"),
					'breadCrumbIncludedItemIds' : getIncludedItemIds($menuArrow)
				});
			})
		};

		$(function() {
			initializeContextMenus();
		});

	})(jQuery);
</script>