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
<%@ taglib uri="wysiwyg" prefix="wysiwyg" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="bugstaglib" prefix="bugs" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>

<wysiwyg:froalaConfig />

<c:if test="${canAddComment}">
	<ui:osSpecificHotkeyTooltip code="attachment.add.tooltip.label" var="addCommentTooltip" modifierKey="ALT" />
	<div class="addCommentLink"><a href="#" title="${addCommentTooltip}"><spring:message code="attachment.add.label" text="Add Comment/Attachment"/></a></div>
	<div class="editCommentSection" id="commentSection_${comment.id ? comment.id : 'new'}">
		<jsp:include page="commentSubscription.jsp"/>

		<c:set var="entity" value="${comment}" scope="request" />
		<c:if test="${task != null}">
			<c:set var="entity" value="${task}" scope="request" />
		</c:if>

		<wysiwyg:editor editorId="editor_${comment.id ? comment.id : 'new'}" entity="${entity}" uploadConversationId="${commentCommand.uploadConversationId}"
		    insertNonImageAttachments="false" useAutoResize="true" heightMin="200" showSaveCancel="true" toolbarSticky="true" overlayHeaderKey="wysiwyg.comment.overlay.header">

		    <textarea id="editor_${comment.id ? comment.id : 'new'}" rows="3" cols="80"></textarea>
		</wysiwyg:editor>

		<div class="issueCommentVisibilityControl">
			<table border="0" cellspacing="0" cellpadding="0">
				<tr valign="middle">
					<td style="color: white; font-weight: bold;" nowrap>
						<label for="visibility" class="visible-for-label">
							<img src='<ui:urlversioned value="/images/shield.png"/>'/>
							<spring:message code="attachment.visibility.label" text="Visible for"/>:&nbsp;
						</label>
					</td>
					<td class="visibilityContainer">
						<input id="visibility" type="hidden" name="visibility" value="<c:out value='${commentCommand.visibility}'/>"/>
					</td>
				</tr>
			</table>
		</div>
		<form>
			<input type="hidden" name="tracker_id" value="${commentCommand.tracker_id}">
			<input type="hidden" name="task_id" value="${commentCommand.task_id}">
			<input type="hidden" name="artifact_id" value="${commentCommand.artifact_id}">
			<input type="hidden" name="visibility" value="${commentCommand.visibility}">
			<input type="hidden" name="reply" value="${commentCommand.reply}">
			<input type="hidden" name="description" value="${commentCommand.description}">
			<input type="hidden" name="format" value="${commentCommand.format}">
			<input type="hidden" name="charsetName" value="${commentCommand.charsetName}">
			<input type="hidden" name="uploadConversationId" value="${commentCommand.uploadConversationId}">
			<input type="hidden" name="commentType" value="${commentCommand.commentType}">
		</form>
	</div>
</c:if>

<div class="commentFilterContainer">
	<div style="padding-right: 10px; display: inline;">
		<spring:message code="issue.filter.label" text="Filter"/>
	</div>
	<select onchange="showSelectedCommentTypes(this);">
		<option value="all">
			<spring:message code="search.results.all" text="All"/>
		</option>
		<option value="comments">
			<spring:message code="comments.label" text="Comments"/>
		</option>
		<option value="attachments">
			<spring:message code="attachments.label" text="Attachments"/>
		</option>
	</select>
</div>

<c:if test="${canAddComment}">
	<script type="text/javascript">
		$(function() {

			var $container = $("#commentSection_${comment.id ? comment.id : 'new'}");

			$container.find('.visibilityContainer').commentVisibilityControl(${commentCommand.tracker_id}, "${commentCommand.visibility}", {
				memberFields		: [<c:forEach items="${memberFields}" var="field" varStatus="loop">{ id : ${field.id}, name : "<spring:message code='tracker.field.${field.label}.label' text='${field.label}' javaScriptEscape='true'/>" }<c:if test="${!loop.last}">, </c:if></c:forEach>],
				roles				: [<c:forEach items="${roles}"        var="role"  varStatus="loop">{ id : ${role.id}, name : "${ui:escapeJavaScript(role.name)}" }<c:if test="${!loop.last}">, </c:if></c:forEach>],
				visibilityTitle		: '<spring:message code="comment.visibility.tooltip" text="Limit visibility of this comment" javaScriptEscape="true" />',
				everybodyLabel		: '<spring:message code="comment.visibility.everybody.label" text="Everybody" javaScriptEscape="true" />',
				everybodyTitle		: '<spring:message code="comment.visibility.everybody.tooltip" text="Everybody who normally can see the issue, will see this comment too" javaScriptEscape="true" />',
				memberFieldsLabel	: '<spring:message code="tracker.fieldAccess.memberFields.label" text="Participants" javaScriptEscape="true"/>',
				rolesLabel		 	: '<spring:message code="tracker.fieldAccess.roles.label" text="Roles" javaScriptEscape="true"/>',
				checkAllText		: '<spring:message code="tracker.field.value.choose.all" text="Check all" javaScriptEscape="true"/>',
				uncheckAllText		: '<spring:message code="tracker.field.value.choose.none" text="Uncheck all" javaScriptEscape="true"/>',
				defaultVisibility   : '${defaultVisibility}'
			});

			codebeamer.InlineComment.init($container, 'editor_${comment.id ? comment.id : 'new'}');
		});
	</script>
</c:if>
