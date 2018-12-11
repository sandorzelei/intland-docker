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

<%@ taglib uri="uitaglib" prefix="ui" %>

<meta name="decorator" content="main"/>
<meta name="moduleCSSClass" content="newskin reviewModule ${not empty revision ? 'tracker-baseline' : ''}"/>
<meta name="module" content="review"/>

<head>
	<link rel="stylesheet" href="<ui:urlversioned value='/stylesheet/review/review.less' />" type="text/css" media="all" />
	<script type="text/javascript" src="<ui:urlversioned value='/bugs/includes/commentVisibility.js'/>"></script>

    <link rel="stylesheet" href="<ui:urlversioned value="/stylesheet/multiselect.less" />" type="text/css" media="all" />
	<link rel="stylesheet" href="<ui:urlversioned value='/stylesheet/inlineComment.less' />" type="text/css" media="all" />
	<script type="text/javascript" src="<ui:urlversioned value='/js/inlineComment.js'/>"></script>
</head>

<ui:actionMenuBar cssClass="large">
	<jsp:attribute name="rightAligned">

		<c:set scope="request" value="/feedback" var="subPage"/>
		<jsp:include page="includes/switchToHead.jsp"/>

		<ui:combinedActionMenu builder="reviewActionMenuBuilder" keys="review,feedback,statistics"
			buttonKeys="review,feedback,statistics,history" subject="${review}" activeButtonKey="feedback"
			cssClass="large" hideMoreArrow="true" />
	</jsp:attribute>
	<jsp:body>
		<ui:breadcrumbs showProjects="false" showLast="false" showTrailingId="false" strongBody="false">
			<ui:pageTitle printBody="true">
				<spring:message code="review.feedback.title" arguments="${review.name}" text="Feedback for ${review.name }" htmlEscape="true"/>
			</ui:pageTitle>
		</ui:breadcrumbs>
	</jsp:body>
</ui:actionMenuBar>

<ui:actionBar>
	<label for="commentFilter"><spring:message code="Filter" text="Filter"></spring:message>:</label>
	<select id="commentFilter" style="margin-right: 10px;">
		<c:forEach items="${counts }" var="entry">
			<c:set var="selected" value="${filter.name == entry.key.name ? 'selected=selected' : '' }"></c:set>
			<option value="${entry.key.name }" ${selected }><spring:message code="review.comment.type.${entry.key.name }.label"/> (${ entry.value})</option>
		</c:forEach>
	</select>

	<c:if test="${canAddComment}">
		<ui:actionLink builder="reviewFeedbackActionMenuBuilder" keys="addComment,addQuestion,addProblem,addFeatureRequest" subject="${review }"></ui:actionLink>
	</c:if>
</ui:actionBar>

<c:if test="${canAddComment}">
    <div class="inline-comment-wrapper">
        <jsp:include page="/bugs/inlineComment.jsp"/>
    </div>
</c:if>

<jsp:include page="includes/comments.jsp"></jsp:include>

<script type="text/javascript">
	$(function () {
		$("#commentFilter").change(function () {
			var $filter = $(this);
			var value = $filter.val();

			var url = contextPath + "/proj/review/feedback.spr?reviewId=${review.id}&filter=" + value;

			location.href = url
		});

		// expandTable displaytag
		var $table = $(".expandTable.displaytag");
		$table.after($(".pagelinks"));
		$table.after($(".pagebanner"));
	});

	$(document).on("codebeamer:inilineCommentInitialized", function () {
		// when the inline commenting was initialized move the other comment links beside the first link
		var $addCommentLink = $(".addCommentLink");
		var $commentTypeLinks = $(".actionLink.commentTypeLink");

		$commentTypeLinks.on('click', function () {
			var $link = $(this);
			var type = $link.data("type");

			$("input[name=commentType]").val(type);

			$addCommentLink.find("a").click();

			$(".editCommentSection").removeClass("Question Problem Comment FeatureRequest").addClass(type);
		});
	});
</script>
