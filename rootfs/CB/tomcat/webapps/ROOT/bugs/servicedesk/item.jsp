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
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://ditchnet.org/jsp-tabs-taglib" prefix="tab" %>

<meta name="decorator" content="main"/>
<meta name="module" content="tracker"/>
<meta name="moduleCSSClass" content="newskin trackersModule"/>

<link rel="stylesheet" href="<ui:urlversioned value="/bugs/servicedesk/serviceDesk.less" />" type="text/css" media="all" />
<link rel="stylesheet" href="<ui:urlversioned value='/stylesheet/inlineComment.less' />" type="text/css" media="all" />
<link rel="stylesheet" href="<ui:urlversioned value="/stylesheet/multiselect.less" />" type="text/css" media="all" />
<script type="text/javascript" src="<ui:urlversioned value='/bugs/includes/commentVisibility.js'/>"></script>
<script type="text/javascript" src="<ui:urlversioned value='/js/inlineComment.js'/>"></script>

<ui:pageTitle printBody="false">
	<c:out value="${task.keyAndId}" default="--"/>
</ui:pageTitle>

<ui:actionMenuBar>
	<jsp:body>
		<c:url var="serviceDeskUrl" value="/servicedesk/serviceDesk.spr"/>
		<spring:message code="${serviceDeskTitle}" var="title"/>
		<a href="${serviceDeskUrl}" title="${title }">${title}</a><span class='breadcrumbs-separator'>&raquo;</span>
		<c:url var="trackerUrl" value="${task.tracker.urlLink }"/>
		<span><a href="${trackerUrl}">${trackerTitle}</a></span><span class='breadcrumbs-separator'>&raquo;</span>
		<c:url var="itemUrl" value="${task.urlLink }"/>
		<a href="${itemUrl}"><c:out value="${task.keyAndId}" default="--"/></a>
	</jsp:body>
</ui:actionMenuBar>

	<div class="actionBar">
		<c:if test="${canEdit }">
			<c:url var="editUrl" value="/servicedesk/addItem.spr">
				<c:param name="task_id" value="${task.id}"/>
			</c:url>
			<spring:message code="button.edit" text="Edit" var="editTitle"/>
			<a href="${editUrl}" title="${editTitle}">${editTitle}</a>
		</c:if>

		<c:url value="/servicedesk/serviceDesk.spr" var="backUrl"/>
		<spring:message code="button.back" text="Back" var="backLabel"/>
		<a href="${backUrl}" title="${backLabel }" style="margin-left: 10px;">${backLabel }</a>
	</div>
<div class="contentWithMargins">
	<ui:globalMessages/>

	<c:choose>
		<c:when test="${imageId != null}">
			<div class="left-aligned tracker-icon-edit" style="margin-top: 6px;">
				<c:url var="iconUrl" value="/displayDocument">
					<c:param name="doc_id" value="${imageId}"></c:param>
				</c:url>
				<img src="${iconUrl}" class="icon-img" style="background-color: ${colorCode};"/>
			</div>
		</c:when>
		<c:otherwise>
			<div class="tracker-icon-edit" style="margin-top: 6px;">
				<ui:letterIcon elementId="${trackerId}"
					elementName="${trackerTitle}" color="${colorCode}" />
			</div>
		</c:otherwise>
	</c:choose>
	<div>${trackerTitle}</div>

	<div>
		<div class="item-name">
			<c:set var="summary">
				<c:out value="${task.name}"/>
			</c:set>
			<h2><a href="${itemUrl}" title="${sumary}">${summary}</a></h2>${decorated.status }
			<div class="details">
				<span class=""><c:out value="${decorated.modifiedAt }"/></span>
			</div>
			<c:if test="${canClose}">
				<c:url var="actionUrl" value="/servicedesk/closeItem.spr"></c:url>
				<form action="${actionUrl}" method="POST" id="closeForm">
					<spring:message code="button.close" text="Close" var="closeLabel"/>
					<input type="hidden" value="${task.id }" name="issue_id"/>

					<spring:message code="tracker.serviceDesk.close.tooltip" text="Do you want to close this item?" var="closeTitle"/>
					<label for="closeButton" style="margin-right: 5px;"><spring:message code="tracker.serviceDesk.close.label" text="Is your problem already solved?"/></label>
					<input id="closeButton" type="button" class="button" value="${closeLabel}" onclick="closeItem();" title="${closeTitle}"></input>
				</form>
			</c:if>
		</div>
	</div>
	<div class="description section">
		<label><spring:message code="${descriptionLabel }" text="${descriptionLabel }" htmlEscape="true"/></label>
		<div class="descriptionBox"><c:out value="${decorated.description }"  escapeXml="false"/></div>
	</div>

	<c:if test="${canViewAttachment}">
		<tab:tabContainer id="task-details" skin="cb-box">
			<spring:message var="commentsAttachmentsTitle" code="document.commentsAndAttachments.tab.title" text="Comments &amp; Attachments" />

			<c:set var="commentCountContainer" value='<span id="commentCountContainer"></span>' />
			<c:if test="${commentCount gt 0}">
			    <c:set var="commentCountContainer"><span id="commentCountContainer">(${commentCount})</span></c:set>
			</c:if>

			<tab:tabPane id="task-details-attachments" tabTitle="${commentsAttachmentsTitle} ${commentCountContainer}">
				<div class="addCommentBar">
				    <jsp:include page="/bugs/inlineComment.jsp"/>
				</div>

				<jsp:include page="/bugs/itemAttachments.jsp" flush="true" >
					<jsp:param name="showActionBar" value="false" />
				</jsp:include>
				<c:if test="${commentListTruncated }">
					<c:url var="showAllUrl" value="/servicedesk/showItem.spr">
						<c:param name="task_id" value="${task.id }"/>
						<c:param name="showAllComments" value="true"/>
					</c:url>
					<a href="${showAllUrl}" title="Show all comments" class="show-all">Show all</a>
				</c:if>
			</tab:tabPane>
		</tab:tabContainer>
	</c:if>
</div>

<script type="text/javascript">
	function closeItem() {
		var msg = i18n.message("Do you really want to close this item?");
		showFancyConfirmDialogWithCallbacks(msg, function () {
			$("#closeForm").submit();
		});
	}
</script>

