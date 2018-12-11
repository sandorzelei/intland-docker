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
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="taglib" prefix="tag" %>
<%@ taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>

<%@ page import="com.intland.codebeamer.persistence.util.TrackerItemAttachmentRevision" %>
<%@ page import="com.intland.codebeamer.Config"%>

<meta name="decorator" content="popup"/>
<meta name="module" content="tracker"/>
<meta name="bodyCSSClass" content="newskin" />

<wysiwyg:froalaConfig />

<link rel="stylesheet" href="<ui:urlversioned value="/stylesheet/multiselect.less" />" type="text/css" media="all" />

<ui:coloredEntityIcon subject="${issue}" iconUrlVar="imgUrl" iconBgColorVar="iconBgColor"/>

<style type="text/css">
	.ui-layout-center {
		/*overflow:auto;*/
		height: 25%;
	}

	/* TODO: dirty hacking: these below should be same everywhere together with "contentWithMargins" on the parent ? */
	.newskin.popupBody .ditch-tab-skin-cb-box {
		padding: 0;
	}

	.newskin .contentWithMargins .actionBar {
		margin: 0;
	}

	button.ui-multiselect span {
		color: black !important;
		font-size: 13px;
		font-weight: normal;
		white-space: wrap !important;
	}

	li.ui-multiselect-optgroup {
		text-align: left !important;
	}

	.pagebanner {
		display: none;
	}

	.no-comments {
	    margin-top: 20px;
	}
	.issueCommentVisibilityControl img {
		position: relative;
		top: 2px;
	}
	.issueCommentVisibilityControl label {
		color: #666;
		font-weight: bold;
	}

    .required {
        background-color: #f9e9e9;
    }

    div.required {
        padding: 2px;
    }
</style>

<div id="layoutContainer">

<div style="height:10%;" id="header" class="ui-layout-north">
<ui:actionMenuBar>
	<jsp:attribute name="rightAligned"><ui:rating entity="${issue}" voting="false" cssClass="ratingOnInlinedPopup" /></jsp:attribute>
	<jsp:body>
        <c:set var="defaultTitle">
            <c:if test="${paragraphId != null}"><span class="paragraphId">${paragraphId}</span> </c:if><c:out value="${issue.name}"/>
        </c:set>

        <c:if test="${not empty pageTitle}">
            <spring:message code="${pageTitle}" text="${pageTitle}" var="pageTitle"/>
        </c:if>

		<h2 class="summary">
           ${empty pageTitle ? defaultTitle : pageTitle}
        </h2>
	</jsp:body>
</ui:actionMenuBar>
</div>
    <c:if test="${not empty hideCommentList and hideCommentList}">
        <div class="actionBar">
            <spring:message code="button.cancel" text="Cancel" var="cancelLabel"/>
            <input type="button" class="button cancelButton" value="${cancelLabel}" onclick="inlinePopup.close();"/>
        </div>
    </c:if>
    <c:set var="addCommentForm">
        <div style="${not empty hideCommentList and hideCommentList ? 'height: 100%;' : 'height:60%;'}" id="addComment" class="ui-layout-south contentWithMargins">
            <!-- the comment box (editor) -->
            <ui:globalMessages></ui:globalMessages>
            
            
            <c:url value="${not empty postCommentUrl ? postCommentUrl : '/proj/tracker/docview/addAttachment.spr'}" var="actionUrl"/>
            <form:form enctype="multipart/form-data" action="${actionUrl}" id="mainForm" class="document-view-add-comment">
                <form:hidden path="artifact_id"/>
                <form:hidden path="reply"/>
                <c:if test="${param.commentForReject != null }">
                    <input type="hidden" name="commentForReject" value="<c:out  value='${param.commentForReject}'/>"/>
                </c:if>
                <%-- <form:hidden path="commentType"/>--%>
                <c:if test="${param.viewName != null }">
                    <input type="hidden" name="viewName" value="<c:out value='${param.viewName}'/>"/>
                </c:if>
                <form:errors cssClass="error"/>

                <input type="hidden" name="task_id" value="<c:out value='${command.task_id}'/>"/>

                <div>
                    <jsp:include page="../../commentSubscription.jsp"/>

                    <c:set var="resizeEditorToFillParent" value="${not empty hideCommentList and hideCommentList}"/>
                    <wysiwyg:editor editorId="editor" entity="${issue}" uploadConversationId="${command.uploadConversationId}" height="${resizeEditorToFillParent ? '' : '200'}"
                                    insertNonImageAttachments="false" showSaveCancel="true" hideQuickInsert="true" focus="true" useAutoResize="${not resizeEditorToFillParent}"
                        resizeEditorToFillParent="${resizeEditorToFillParent}">

                        <form:textarea path="description" id="editor" rows="12" cols="80" autocomplete="off" />
                    </wysiwyg:editor>
                    <div class="issueCommentVisibilityControl">
                        <c:if test="${param.showCommentTypes }">
                            <label for="commentType"><spring:message code="review.comment.type.label" text="Comment Type"/>:</label>
                            <form:select path="commentType" id="commentType">
                                <c:forEach items="${commentTypes}" var="type">
                                    <form:option value="${type }"><spring:message code="review.comment.type.${type }.label"/></form:option>
                                </c:forEach>
                            </form:select>
                        </c:if>
                        <label for="visibility">
                            <img src='<ui:urlversioned value="/images/shield.png"/>'/>
                            <spring:message code="attachment.visibility.label" text="Visible for"/>:&nbsp;
                        </label>
                        <span id="visibilityContainer">
					        <input type="hidden" name="visibility" value="<c:out value='${command.visibility}'/>"/>
					    </span>
                    </div>
                </div>
            </form:form>
        </div>
        
    </c:set>
    
<div class="contentWithMargins">
	<c:if test="${revision == null and canAddCommentsAttachments}">
        <c:choose>
            <c:when test="${hideCommentList}">
                <div class="required">
                    ${addCommentForm}
                </div>
            </c:when>
            <c:otherwise>
                <spring:message code="comment.add.label" text="Add comment" var="addCommentLabel"/>
                <ui:collapsingBorder open="true" label="${addCommentLabel }" cssClass="required">
                    ${addCommentForm}
                </ui:collapsingBorder>
            </c:otherwise>
        </c:choose>

		<script type="text/javascript" src="<ui:urlversioned value='/bugs/includes/commentVisibility.js'/>"></script>
		<script type="text/javascript">

		$('#visibilityContainer').commentVisibilityControl(${tracker.id}, "${ui:removeXSSCodeAndJavascriptEncode(command.visibility)}", {
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

		function submitForm(button) {
			var $commentSubscription = $("#commentSubscription");
			if ($commentSubscription.length > 0) {
				var $commentSubscriptionInput = $("#dynamicChoice_references_commentSubscriptionSelector");
				var $emailSubjectInput = $('input[name="emailSubject"]', $commentSubscription);
				var $hiddenCommentSubscriptionInput = $('input[type="hidden"][name="subscription"]', $commentSubscription);
				if (!$commentSubscription.hasClass("collapsingBorder_collapsed")) {
					if ($.trim($commentSubscriptionInput.val()).length == 0 || $.trim($emailSubjectInput.val()).length == 0) {
						showFancyAlertDialog(i18n.message("comment.subscription.mandatory.alert"));
						return false;
					}
					$hiddenCommentSubscriptionInput.val($commentSubscriptionInput.val());
				} else {
					$hiddenCommentSubscriptionInput.val("");
					$emailSubjectInput.val("");
				}
			}

			if (codebeamer.WYSIWYG.isFileUploadInProgress('editor')) {
			    return false;
			}

			var editor = codebeamer.WYSIWYG.getEditorInstance('editor');
			editor.edit.off();

			var container = $('#visibilityContainer');
			$('input[type="hidden"][name="visibility"]', container).val(container.getCommentVisibility());

			setTimeout(function() {
				// a bit later disable the button, because otherwise submit is not reliable
				if (button) {
					button.disabled = true;
				}
			}, 100);

	        $('form#mainForm').submit();

			return true;
		}

		function cancelForm() {
			inlinePopup.close();
		}

		$(function() {
	    	$.FroalaEditor.COMMANDS.cbSave.callback = submitForm;
	        $.FroalaEditor.COMMANDS.cbCancel.callback = cancelForm;
		});

		</script>
	</c:if>

    <c:if test="${not hideCommentList}">
        <c:choose>
            <c:when test="${revision == null && !empty attachments }">
                <div class="contentWithMargins" style="margin-bottom:0;">
                    <h2><spring:message code="comments.label" text="Comments"/></h2>
                    <div style="clear:both;"></div>


                    <display:table excludedParams="orgDitchnetTabPaneId" class="expandTable"
                        name="${attachments}" id="attachment" cellpadding="0"
                        defaultsort="1" defaultorder="descending" export="false" pagesize="200">

                        <spring:message var="submittedTitle" code="comment.submittedAt.label" text="Submitted"/>
                        <display:column title="${submittedTitle}" sortProperty="dto.createdAt" sortable="true" headerClass="textData" class="textData columnSeparator assocSubmitterCol comment-${attachment.dto.id}"
                            style="width:10%; padding-top:2px; padding-bottom:15px;">
                            <ui:submission userId="${attachment.dto.owner.id}" userName="${attachment.dto.owner.name}" date="${attachment.dto.createdAt}"/>
                        </display:column>

                        <spring:message var="commentTitle" code="comment.label" text="Comment"/>
                        <display:column title="${commentTitle}" sortProperty="dto.description" sortable="true" headerClass="textData" class="textDataWrap ${empty attachment.attachments ? 'classComment' : 'classAttachment'}">
                            <tag:transformText owner="${attachment.trackerItem}" value="${attachment.dto.description}" format="${attachment.dto.descriptionFormat}" />

                            <c:if test="${!empty attachment.attachments}">
                                <table cellspacing="0" cellpadding="0">
                                    <c:forEach var="file" items="${attachment.attachments}">
                                        <tr>
                                            <td class="commentListFileItem textData" valign="middle">
                                                <ui:trackerItemAttachmentLink trackerItemAttachment="${file}" revision="${file.baseline.id}" newskin="true"/>
                                            </td>
                                            <td class="commentListFileItem subtext" valign="middle">
                                                <c:set var="attachmentLength" value="${file.dto.fileSize}" />
                                                <span class="subtext" title="${titleLengthValue}"><tag:formatFileSize value="${attachmentLength}" /></span>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </table>
                            </c:if>
                        </display:column>
                    </display:table>

                </div>
            </c:when>
            <c:otherwise>
                <div class="no-comments">
                    <spring:message code="document.commentsAndAttachments.none" text="No comments"/>
                </div>
            </c:otherwise>
            </c:choose>
        </div>
    </c:if>

</div>
