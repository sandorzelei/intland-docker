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
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>

<%@ taglib uri="http://ditchnet.org/jsp-tabs-taglib" prefix="tab" %>
<%@ taglib prefix="tag" uri="taglib" %>

<meta name="decorator" content="main"/>
<meta name="moduleCSSClass" content="newskin reviewModule  ${not empty revision ? 'tracker-baseline' : ''}"/>
<meta name="module" content="review"/>

<head>
	<link rel="stylesheet" href="<ui:urlversioned value='/stylesheet/documentView.less' />" type="text/css" media="all" />
	<link rel="stylesheet" href="<ui:urlversioned value='/stylesheet/review/review.less' />" type="text/css" media="all" />

	<script src="<ui:urlversioned value='/js/jquery/jquery-waypoints/waypoints.js'/>"></script>
	<script src="<ui:urlversioned value='/js/waypointHelpers.js'/>"></script>
	<script src="<ui:urlversioned value='/js/infiniteScroller.js'/>"></script>
	<script src="<ui:urlversioned value='/reviews/review.js'/>"></script>
</head>


<%-- whether this review is signed or closed --%>
<c:set var="isClosed" value="${review.isClosed(user)}"/>
<c:set var="isFinished" value="${review.resolvedOrClosed}"/>

<script type="text/javascript">
	var reviewConfig = {
		reviewId: ${review.id},
		done: ${isClosed},
		hasEditLicense: ${hasEditLicense},
        canEdit: ${canEdit}
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
		<jsp:include page="includes/switchToHead.jsp"/>

		<ui:combinedActionMenu builder="reviewActionMenuBuilder" keys="review,feedback,statistics"
			buttonKeys="review,feedback,statistics,history" subject="${review}" activeButtonKey="review"
			cssClass="large" hideMoreArrow="true" />
	</jsp:attribute>
	<jsp:body>
		<ui:pageTitle printBody="true">
			<c:out value="${review.name}"/>
		</ui:pageTitle>
		<c:if test="${review.mergeRequest and not empty targetTracker}">
			<c:url value="${targetTracker.urlLink }" var="targetTrackerUrl"></c:url>
			<spring:message code="review.statistics.target.${branchMergeRequest or targetTracker.branch ? 'branch' : 'tracker'}.label" var="targetTrackerLabel" text="Target Branch"/>
				<div>
					${targetTrackerLabel }:
					<tag:branchName var="trackerName" trackerId="${targetTracker.id }" prependProjectName="true"></tag:branchName>
					<span class="generalBadge clickable reviewMergedBadge">
						<a href="${ targetTrackerUrl}" title='${targetTrackerLabel }'>${trackerName}</a>
					</span>
				</div>
		</c:if>
	</jsp:body>
</ui:actionMenuBar>

<ui:treeControl containerId="reviewTree" url="${pageContext.request.contextPath}/ajax/review/tree.spr"
	layoutContainerId="panes" rightPaneId="reviewContent" editable="false" headerDivId="headerDiv"
	populateFnName="codebeamer.review.populateTree" nodeClickedHandler="codebeamer.review.nodeClickHandler"/>


<ui:splitTwoColumnLayoutJQuery cssClass="layoutfullPage autoAdjustPanesHeight" hideRightPane="${reviewMode}" rightMinWidth="380" leftMinWidth="280" config="{east: {initClosed: true}, stateManagement: {autoSave: false, autoLoad: false}}">
	<jsp:attribute name="leftPaneActionBar">
		<ui:treeFilterBox treeId="reviewTree" cssStyle="margin-left:15px;width:38%;"/>
		<a class="scalerButton"></a>
	</jsp:attribute>
	<jsp:attribute name="leftContent">
		<spring:message code="review.filters.label" text="Filters" var="filtersLabel"/>
		<spring:message code="review.items.label" text="Items" var="itemsLabel"/>
		<tab:tabContainer id="left-tabs" skin="cb-box" selectedTabPaneId="tree">
			<tab:tabPane id="tree" tabTitle="${itemsLabel}">
				<div id="reviewTree" style="height:100%;overflow:auto;margin-top:10px;"></div>
			</tab:tabPane>
			<tab:tabPane id="filters" tabTitle="${filtersLabel}">
				<div class="actionBar" style="padding: 5px 10px 5px 10px; margin-bottom: 10px;">
					${filtersLabel}
				</div>
				<div style="height:94%;overflow:auto;">
					<c:forEach items="${filters }" var="filter">
						<spring:message code="review.filter.${filter.key }.label" arguments="${filter.value }" var="filterLabel"/>
						<c:set var="checked" value="${filter.key == command.filter ? 'checked=checked' : '' }"/>
						<input type="radio" name="review-filter" value="${filter.key }" id="${filter.key }" ${checked }/>
						<label for="${filter.key }">${filterLabel}</label><br/>
					</c:forEach>
				</div>
			</tab:tabPane>
		</tab:tabContainer>
	</jsp:attribute>
	<jsp:attribute name="rightPaneActionBar">
		<a class="scalerButton" style="left: -8px;"></a>
	</jsp:attribute>
	<jsp:attribute name="middlePaneActionBar">
		<div class="actionBar" style="padding-left:35px;">
			<ui:actionLink builder="reviewActionMenuBuilder" keys="edit,acceptAll,rejectAll,done,requestNewVersion,exportToWord" subject="${review }"></ui:actionLink>
		</div>
		<a class="scalerButton"></a>
	</jsp:attribute>
	<jsp:attribute name="rightContent">
		<div id="accordion" data-item-inner-accordion-state="<c:out value="${itemAccordionStateJson}" />">
			<div id="issuePropertiesPane"  style="height: 100%; overflow: auto;"></div>
		</div>
	</jsp:attribute>
	<jsp:body>
		<div class="information ${isClosed ? 'closed' : '' }" id="review-ended">
			<c:choose>
				<c:when test="${isFinished}">
					<spring:message code="review.${review.mergeRequest ? 'merge.' : '' }done.hint" text="This review has ended. You can view the results but cannot change them."/>
				</c:when>
				<c:otherwise>
					<spring:message code="review.${review.mergeRequest ? 'merge.' : '' }signed.hint" text="You have already signed this Merge Request. You can view the results but cannot change them."/>
				</c:otherwise>
			</c:choose>
		</div>
		<ui:globalMessages></ui:globalMessages>
		<div class="review-container ${isClosed ? 'closed' : '' } ${review.publicReview ? 'public-review' : ''}">

		</div>
	</jsp:body>
</ui:splitTwoColumnLayoutJQuery>

<script type="text/javascript">
	jQuery(function($) {
		var resizeAccordion = throttleWrapper(function() {
			var eastHeight = $(".ui-layout-east").height();
			var targetHeight = eastHeight - $("#rightHeaderDiv").outerHeight();
			$("#issuePropertiesPane").height(targetHeight);
		});
		$(window).resize(function () {
			setTimeout(resizeAccordion, 800);
		});

		// set the accordion size after an item was loaded
		$(document).on("codebeamer:issueLoaded", resizeAccordion);
		setTimeout(resizeAccordion, 250);
	});

	function refreshAfterComment() {
		var $element = $('.adding-comment');
		var id = $element.closest(".requirementTr").attr('id');

		var node = $("#reviewTree").jstree("get_node", id);

		var $propertiesPane = $('#issuePropertiesPane');
		var propertiesUrl = "/reviews/ajax/getIssueProperties.spr";
		codebeamer.common.loadProperties(node.li_attr["reviewItemId"], $propertiesPane, node.li_attr["revision"], false, null, contextPath + propertiesUrl, false);

		codebeamer.review.updateCommentCounts([node.li_attr["reviewItemId"]]);

		// always remove this css class becasue adding the comment ended at this point
		$element.removeClass('adding-comment');

		$(document).trigger("codebeamer:reviewItemUpdated", [id]);
	}

	/**
	 * refreshes the review button states after reject all was executed
	 **/
	function refreshAfterRejectAll() {
		codebeamer.review.resetAllReviewButtons('rejected');

		// update the comment count for all the visible items
		var taskIds = $('.comment-bubble').map(function () { return $(this).data('reviewItemId');}).toArray();
        codebeamer.review.updateCommentCounts(taskIds);
    }

	/**
	* sets the review item to REJECTED and reloads the comment count.
	*/
	function rejectItemWithComment() {
		var $element = $('.adding-comment');
		var $row = $element.closest(".requirementTr");

		codebeamer.review.toggleRejected($row);

		// refresh the comment bubble
		refreshAfterComment();
	}

	/**
	* refreshes the properties of the selected issue after a commment was updated.
	*/
	function refreshSelectedIssueProperties(skipReloadIssue) {
		var $propertiesPane = $('#issuePropertiesPane');
		var selectedId = $propertiesPane.data('showingIssue'); // this is the review item id

		// get the id of the original item
		var id = $(".requirementTr[data-review-id=" + selectedId + "]").attr('id');
		var node = $("#reviewTree").jstree("get_node", id);

		var propertiesUrl = "/reviews/ajax/getIssueProperties.spr";
		codebeamer.common.loadProperties(node.li_attr["reviewItemId"], $propertiesPane, node.li_attr["revision"], false, null, contextPath + propertiesUrl, false);
	}

	if (!$.vakata.storage.get($.jstree.defaults.state.key)) {
		// if there is no tree state stored then don't wait for the set_state event to be triggered
		codebeamer.review.loadFirstPage();
	} else {
		$("#reviewTree").one("set_state.jstree", function() {
			codebeamer.review.loadFirstPage();
		});
	}

</script>