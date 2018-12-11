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
<meta name="decorator" content="popup"/>
<meta name="moduleCSSClass" content="newskin"/>

<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://ditchnet.org/jsp-tabs-taglib" prefix="tab" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<link rel="stylesheet" href="<ui:urlversioned value='/dashboard/widgetPicker.less' />" type="text/css" media="all" />

<ui:actionMenuBar>
	<jsp:attribute name="rightAligned">
		<a id="codebeamerWidgetDeveloperManualLink" href="https://codebeamer.com/cb/wiki/1469179" target="_blank" title="<spring:message code="dashboard.create.your.own.widget.title" text="How to create custom Widgets in Codebeamer?"/>">
			<spring:message code="dashboard.create.your.own.widget.label" text="Create your own Widget"/>
		</a>
	</jsp:attribute>
	<jsp:body>
		<spring:message code="dashboard.add.widget.action.label" text="Add Widget"/>
	</jsp:body>
</ui:actionMenuBar>

	<input type="text" id="nameFilter" class="inputboxWithHint"/>

<tab:tabContainer id="widget-picker-tabs" skin="cb-box" jsTabListener="onTabChange">
<c:forEach items="${widgetsByCategory}" var="category">

	<%-- for each widget category create a new tab --%>
	<spring:message code="dashboard.widget.category.${category.key}.label" text="${category.key}" var="tabTitle"/>
	<tab:tabPane id="category-${category.key}" tabTitle="${tabTitle} (${fn:length(category.value) })">

		<%-- list the widgets in the category --%>
		<c:forEach items="${category.value }" var="widget">
			<div class="widget-info" data-widget-type="${widget.type }">
				<div class="widget-image" data-role="add-widget">
					<c:choose>
						<c:when test="${not empty widget.imagePreviewUrl }">
							<c:url value="${widget.imagePreviewUrl }" var="imagePreviewUrl"></c:url>
						</c:when>
						<c:otherwise>
							<c:url value="/images/newskin/dashboard/thumbnails/default.png" var="imagePreviewUrl"></c:url>
						</c:otherwise>
					</c:choose>
					<img class="widget-preview" src="${imagePreviewUrl }"></img>
					<spring:message code="button.add" text="Add" var="addLabel"/>
					<input type="button" class="button" value="${addLabel }" data-role="add-widget"/>
				</div>
				<div class="widget-details">
					<div class="widget-name"><spring:message code="${widget.name }" text="${widget.name }"/></div>
					<div class="widget-description">
						<spring:message code="${widget.shortDescription }" text="${widget.shortDescription }"/>
					</div>
					<br/>
					<c:if test="${not empty widget.knowledgeBaseUrl }">
						<c:url value="${widget.knowledgeBaseUrl }" var="knowledgeBaseUrl"></c:url>
						<a href="${knowledgeBaseUrl}" target="_blank">
							<spring:message code="dashboard.widget.knowledge.base.link.title" text="More in Knowledge Base"/></a>
					</c:if>
				</div>
			</div>
		</c:forEach>

		<div class="empty-tab-message" style="display: none;">
			<div class="information">
				<spring:message code="table.nothing.found" text="Nothing found to display"/>
			</div>
		</div>
	</tab:tabPane>
</c:forEach>

</tab:tabContainer>

<script type="text/javascript">
	$("#nameFilter").keyup(function() {
		filterByName(this.value);
	}).Watermark("Filter widgets", "#d1d1d1");

	function filterByName(pattern) {
		var filter = pattern.toLowerCase();
		if (filter.length < 3) {
			$(".widget-info").show();
			$(".empty-tab-message").hide();
		} else {
			$(".widget-info").each(function () {
				var $widget = $(this);
				var name = $widget.find(".widget-name").html();

				var match = name.toLowerCase().indexOf(filter) >= 0;
				$widget.toggle(match);
			});

			// go through all tabs and if there are no visible widgets after filtering show a message
			$("#widget-picker-tabs .ditch-tab-pane").each(function () {
				var $pane = $(this);
				var searchResults = $pane.find(".widget-info").filter(function() {
					var displayStyle = $(this).css("display");
					return !displayStyle || displayStyle != "none";
				});
				var hasMatchingWidgets = searchResults.size() > 0;
				if (!hasMatchingWidgets) {
					$pane.find(".empty-tab-message").show();
				} else {
					$pane.find(".empty-tab-message").hide();
				}
			});
		}

		setPaneWrapHeight();
	}

	function addWidget(event) {
		event.preventDefault();
		event.stopPropagation();

		setTimeout(function() {
			ajaxBusyIndicator.showBusyPage();
		}, 300);

		if (event.currentTarget.tagName === "INPUT") {
			$(event.currentTarget).attr("disabled", "disabled");
		}

		var columnNumber = ${columnNumber};
		var rowNumber = ${rowNumber};

		var $selectedWidget = $(event.currentTarget).closest(".widget-info");
		var widgetType = $selectedWidget.data("widgetType");

		// redirect to the add widget form
		location.href = contextPath + "/dashboard/widgetEditor.spr?dashboardId=${dashboardId}&widgetType=" + widgetType + "&columnNumber=" + columnNumber + "&rowNumber=" + rowNumber;
	}

	function setPaneWrapHeight() {
		var visibleTabHeight = $(".ditch-tab-pane:visible").height();
		var windowHeight = $(parent.window).height() * 0.8 - 80;
		$(".ditch-tab-pane-wrap").height(windowHeight < visibleTabHeight ? "auto" : windowHeight);
	}

	function onTabChange(evt) {
		setPaneWrapHeight();
	}

	$(document).ready(function () {
		setTimeout(function() {
			setPaneWrapHeight();
		}, 10);

		if(self==top) {
			$(location).attr('href', '${dashboardUrl}');
		}

		$("[data-role=add-widget]").on("click", addWidget);
	});
</script>