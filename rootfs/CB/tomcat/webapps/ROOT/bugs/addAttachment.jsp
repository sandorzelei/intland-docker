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
<meta name="decorator" content="popup"/>
<meta name="module" content="tracker"/>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<%@ taglib uri="taglib" prefix="tag" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="bugstaglib" prefix="bugs" %>
<%@ taglib uri="wysiwyg" prefix="wysiwyg" %>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>

<%@ page import="com.intland.codebeamer.Config"%>

<wysiwyg:froalaConfig />

<c:set var="wysiwyg" value="${param.wysiwyg}" />

<head>
<style type="text/css">
	.expandWikiTextArea {
		margin-bottom: 0px;
		width: 100%;
		height: 80%;
		border: solid 1px #d1d1d1;

		/* using css3 so this does not go out on the right */
		box-sizing: border-box;
    	-moz-box-sizing: border-box;
    	-webkit-box-sizing: border-box;
	}
	.ditch-tab-pane-wrap {
		padding-bottom: 5px;
	}
	.ditch-tab-pane-wrap .actionBar {
		margin: 0px !important;
	}
	.formTableWithSpacing {
		padding: 0px !important;
	}
	.ditch-tab-skin-cb-box {
		padding-top: 0px !important;
		padding-bottom: 0px !important;
		padding-left: 0px !important;
		padding-right: 20px !important;
	}

	.commentVisibilityControl li .ui-state-hover {
		font-weight: normal !important;
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

	label.visible-for-label {
	    color: #666 !important;
	    margin-right: .5em;
	}

	.comment-subscription-wrapper {
	    margin: 15px 15px -10px 15px;
	}
</style>
</head>

<SCRIPT LANGUAGE="JavaScript" type="text/javascript">
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

	$('form#popupLayoutContentArea').submit();

	return true;
}

function cancelForm() {
	window.close();
	// If page is overlay, close this.
	try {
		closePopupInline();
	} catch(e) {
		//
	}
	return false;
}

$(function() {
	$.FroalaEditor.COMMANDS.cbSave.callback = submitForm;
	$.FroalaEditor.COMMANDS.cbCancel.callback = cancelForm;
});

</SCRIPT>

<style type="text/css">
<%-- TODO: the css selectors are pretty crappy for popups, but can not fix just before 7.0 release... --%>
.ditch-tab-skin-cb-box {
	padding: 0 !important;
}
</style>

<form:form enctype="multipart/form-data" id="popupLayoutContentArea" cssClass="ratingOnInlinedPopup">

<c:if test="${param.closeAfterSubmit != null }">
	<input type="hidden" name="viewName" value="<c:out value='${param.closeAfterSubmit}'/>"/>
</c:if>

<c:if test="${param.targetURL != null }">
	<input type="hidden" name="targetURL" value="<c:out value='${param.targetURL}'/>"/>
</c:if>

<c:if test="${param.overlay != null }">
	<input type="hidden" name="overlay" value="<c:out value='${param.overlay}'/>"/>
</c:if>

<div class="ui-layout-north" >

<ui:actionMenuBar>
	<ui:pageTitle prefixWithIdentifiableName="false"><spring:message code="attachment.add.page.title" arguments="${task.name}" htmlEscape="true" /></ui:pageTitle>
</ui:actionMenuBar>

<c:set var="visibilityControl">
	<div class="issueCommentVisibilityControl">
	    <table border="0" cellspacing="0" cellpadding="0">
	        <tr valign="middle">
	            <td style="color: white; font-weight: bold;" nowrap>
	                <label for="visibility" class="visible-for-label">
	                    <img src='<ui:urlversioned value="/images/shield.png"/>'/>
	                    <spring:message code="attachment.visibility.label" text="Visible for"/>:&nbsp;
	                </label>
	            </td>
	            <td id="visibilityContainer">
	                <input id="visibility" type="hidden" name="visibility" value="<c:out value='${command.visibility}'/>"/>
	            </td>
	        </tr>
	    </table>
	</div>
</c:set>

<div class="comment-subscription-wrapper">
    <jsp:include page="commentSubscription.jsp"/>
</div>
</div>

<div class="ui-layout-center contentWithMargins edit-comment-section">
	<spring:hasBindErrors name="command">
		<ui:showSpringErrors errors="${errors}" />
	</spring:hasBindErrors>

	<wysiwyg:editor editorId="editor" entity="${task}" uploadConversationId="${command.uploadConversationId}" resizeEditorToFillParent="true"
		insertNonImageAttachments="false" useAutoResize="false" showSaveCancel="true" hideQuickInsert="true" focus="true">

		<form:textarea path="description" id="editor" rows="15" cols="80" autocomplete="off" />
	</wysiwyg:editor>

    ${visibilityControl}

</div>

</form:form>

<script type="text/javascript" src="<ui:urlversioned value='/bugs/includes/commentVisibility.js'/>"></script>

<link rel="stylesheet" href="<ui:urlversioned value="/stylesheet/multiselect.less" />" type="text/css" media="all" />

<script type="text/javascript">
	jQuery(function($) {
		setupKeyboardShortcuts("popupLayoutContentArea");

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
			defaultVisibility   : '${ui:removeXSSCodeAndJavascriptEncode(defaultVisibility)}'
		});

		(function rePositionRoleSelectorOnWindowResize() {
			$(window).resize(function() {
				$(".ui-widget.ui-multiselect-menu").position({
					of: $("#visibilityContainer"),
					my: "left top",
					at: "left bottom"
				});
			});
		})();
	});
</script>
