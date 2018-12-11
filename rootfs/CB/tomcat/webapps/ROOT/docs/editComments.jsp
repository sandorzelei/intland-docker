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
<meta name="module" content="docs" />
<meta name="bodyCSSClass" content="newskin"/>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="taglib" prefix="tag" %>
<%@ taglib uri="wysiwyg" prefix="wysiwyg" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>

<%@ page import="com.intland.codebeamer.Config"%>

<wysiwyg:froalaConfig />

<c:choose>
	<c:when test="${empty commentId}">
		<c:set var="setKey" value="button.add" />
	</c:when>

	<c:otherwise>
		<c:set var="setKey" value="button.save" />
	</c:otherwise>
</c:choose>

<SCRIPT LANGUAGE="JavaScript" type="text/javascript">
function cancelAction() {
	closePopupInline();
}

function validate(frm) {
	var $editor = $('#editor');

	if (codebeamer.WYSIWYG.getEditorMode($editor) == 'wysiwyg') {
		codebeamer.WikiConversion.saveEditor($editor, true);
    }

	var text = frm.comment.value;

	if (trim(text).length == 0 && !codebeamer.EditorFileList.hasFiles($editor)) {
		alert('<spring:message code="comment.description.required"/>');
		return false;
	}
	return true;
}

function submitForm() {
	var frm = document.getElementById('documentCommentForm');
	if (!validate(frm)) {
		return false;
	}
	var method = document.getElementById('actionMethod');
	method.value = 'SET';

	frm.submit();
}

$(function() {
    $.FroalaEditor.COMMANDS.cbSave.callback = submitForm;
    $.FroalaEditor.COMMANDS.cbCancel.callback = cancelAction;
});

</SCRIPT>

<div class="ui-layout-north">
	<ui:actionMenuBar>
		<ui:breadcrumbs showProjects="false">
		<span class="breadcrumbs-separator">&raquo;</span>
		<ui:pageTitle>
			<spring:message code="document.editCommentOrAttachment.title" text="Comment/Attachment"/>
		</ui:pageTitle>
		</ui:breadcrumbs>
	</ui:actionMenuBar>

	<ui:showErrors />
</div>

<html:form action="/proj/doc/editComment" enctype="multipart/form-data" styleId="documentCommentForm">

<html:hidden property="doc_id" />
<html:hidden property="commentId" />

<input type="hidden" name="method" id="actionMethod" />
<c:remove var="entityRef"/>
<c:if test="${! empty document}">
	<c:set var="entityRef" value="[DOC:${document.id}]" />
</c:if>
<div class="ui-layout-center contentWithMargins">
	<wysiwyg:editor editorId="editor" entityRef="${entityRef}" resizeEditorToFillParent="true" focus="true" useAutoResize="false" hideQuickInsert="true"
	    insertNonImageAttachments="false" uploadConversationId="${documentCommentForm.uploadConversationId}" showSaveCancel="true">
	    <html:textarea property="comment" styleId="editor" rows="20" cols="85" />
	</wysiwyg:editor>
</div>
</html:form>
