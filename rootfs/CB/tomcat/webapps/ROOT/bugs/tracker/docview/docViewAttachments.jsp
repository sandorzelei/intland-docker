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
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="taglib" prefix="tag"%>
<%@ taglib uri="uitaglib" prefix="ui"%>

<%@ taglib uri="http://displaytag.sf.net" prefix="display"%>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>

<%--
 jsp fragment renders document views' attachments

 expects these parameters in the jsp context:
 	"attachments" - the attachments
 	"actions"	  - the actions of trackerItemActionsMenuBuilder built for the current issue/requirement
 	"item"		  - the current issue/requirement
--%>
<span class="reqcommenteditor" id="reqcommenteditor-${item.id}"></span>
<c:if test="${empty canAddCommentsAttachments}">
	<c:set var="canAddCommentsAttachments" value="false" />
</c:if>

<c:if test="${canAddCommentsAttachments == true}">
<div>
	<c:if test="${(empty baseline) && (not empty actions['addAttachment'])}">
		<div class="buttons commentbuttons">
			<a href="#"	onclick="startAddReqComment(this,${item.id}); return false;"><spring:message code="comment.add.label" /></a>
		</div>
	</c:if>
</div>
</c:if>

<c:forEach items="${attachments}" var="attachment">
	<div class="attachment" style="margin-left: ${2 * attachment.depth}em;">
		<c:if test="${empty baseline && canAddCommentsAttachments == true}">
			<ui:actionMenu builder="trackerItemAttachmentListContextActionMenuBuilderInplace"
				subject="${attachment}" cssClass="attachmentMenu" leftAligned="true"/>
		</c:if>
		<span class="subtext">
			<tag:userLink user_id="${attachment.dto.owner.id}" /> - <tag:formatDate	value="${attachment.dto.createdAt}" />
		</span>

		<c:if test="${!empty attachment.attachments}">
			<div class="attachmentFiles">
			<c:forEach items="${attachment.attachments}" var="file">
				<ui:trackerItemAttachmentLink trackerItemAttachment="${file}" revision="${baseline.id}" />
			</c:forEach>
			</div>
		</c:if>

		<c:if test="${!empty attachment.dto.description}">
			<div class="attachmentText">
				<tag:transformText owner="${item}" value="${attachment.dto.description}" format="${attachment.dto.descriptionFormat}" />
			</div>
		</c:if>
	</div>
</c:forEach>

