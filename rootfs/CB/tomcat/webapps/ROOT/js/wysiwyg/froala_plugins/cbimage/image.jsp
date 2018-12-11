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
<%@ taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@ taglib uri="taglib" prefix="tag" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<spring:message var="title" code="wiki.edit.images.title" />
<html>

<head>
	<meta name="decorator" content="popup"/>
	<meta name="moduleCSSClass" content="newskin fr-modal" />

	<script type="text/javascript" src="<ui:urlversioned value='/js/wysiwyg/froala_plugins/cbimage/js/imageAttachmentPopup.js'/>"></script>
	<link rel="stylesheet" type="text/css" href="<ui:urlversioned value='/js/wysiwyg/froala_plugins/froalaModal.less'/>"/>


	<style type="text/css">
		.image-attachment-container {
			margin: 20px;
		}

		.image-attachment-container .summaryMessage {
			margin: 20px 0px 0px 10px;
		}

		.image-attachment-container .summaryMessage span {
			font-weight: bold;
		}

		.image-attachment-container table#images {
			width: 100%;
			margin: 0;
		}

		.image-attachment-container img.preview {
			max-width: 50px;
			max-height: 50px;
			float:right;
			margin-right: 10px;
		}

		.image-attachment-container a {
			cursor: pointer;
		}

	</style>

</head>

<body>
	<c:set var="entityRef" ><c:out value="${param.entityRef}" /></c:set>
	<c:url var="baseUrl" value="/wysiwyg/image.spr">
		<c:param name="entityRef" value="${entityRef}" />
	</c:url>

	<ui:actionMenuBar>
		<span class="menuTitle">${title}</span>
	</ui:actionMenuBar>

	<spring:message var="insertImagesButton" code="wiki.edit.images.insert.selected" />
	<spring:message var="cancelButtonLabel" code="wysiwyg.history.link.plugin.cancel.button.label" />

	<ui:actionBar>
		&nbsp;&nbsp;<input type="button" class="button" name="insertImagesButton" value="${insertImagesButton}" />
		<input type="button" class="button cancelButton" value="${cancelButtonLabel}" />
	</ui:actionBar>

	<div class="image-attachment-container">
		<c:choose>
			<c:when test="${!empty images}">
				<div class="summaryMessage">
					<spring:message var="all" code="wiki.edit.images.summary.all" />
					<spring:message code="wiki.edit.images.summary.message"
						arguments="<span>${fn:length(images)}</span>|<span>${all}</span>" argumentSeparator="|" />
				</div>
			</c:when>
			<c:otherwise>
				<div class="summaryMessage" />
			</c:otherwise>
		</c:choose>

		<display:table export="false" requestURI="/wysiwyg/getImageAttachments.spr" excludedParams="src" defaultsort="2" class="displaytag" cellpadding="0"
			name="${images}" id="comment" htmlId="images">

			<c:set var="filename"><c:out value="${comment.name}" /></c:set>
			<c:set var="title">title="Insert '${filename}'"</c:set>

			<display:column title="" headerClass="textData checkbox-column-minwidth" class="textDataWrap checkbox-column-minwidth columnSeparator selectImage"
				escapeXml="false" sortable="true">
				<input type="checkbox" name="selectedImage" data-base-url="${baseUrl}" value="${filename}" ${title} />
			</display:column>

			<spring:message var="attachmentColumnTitle" code="wiki.edit.images.attachment.column.title" />
			<display:column title="${attachmentColumnTitle}" headerClass="textData" class="textDataWrap columnSeparator" escapeXml="false" sortable="true">
				<tag:shortenString var="shortFileName" value="${comment.name}" targetSize="33"/>
				<a class="attachmentImage" data-base-url="${baseUrl}" data-file-name="${filename}" ${title} >${shortFileName}
					<c:set var="imageUrl" value="${baseUrl}&fileName=${filename}" />
					<img class="preview" src="${imageUrl}" />
				</a>
			</display:column>

			<tag:formatFileSize var="fileSize" value="${comment.fileSize}"/>
			<spring:message var="fileSizeColumnTitle" code="wiki.edit.images.size.column.title" />
			<display:column title="${fileSizeColumnTitle}" headerClass="textData" class="textData columnSeparator">
				${fileSize}
			</display:column>

			<spring:message var="commentColumnTitle" code="wiki.edit.images.comment.column.title" />
			<display:column title="${commentColumnTitle}" headerClass="textData" class="textDataWrap columnSeparator" sortable="true">
				<tag:transformText value="${comment.description}" format="W" />
			</display:column>

			<spring:message var="submittedColumnTitle" code="wiki.edit.images.submitted.column.title" />
			<display:column title="${submittedColumnTitle}" headerClass="textData" class="textData columnSeparator" sortable="true">
				<tag:userLink user_id="${comment.owner.id}" />
				<br />
				<tag:formatDate value="${comment.createdAt}" />
			</display:column>

		</display:table>

	</div>
</body>
</html>