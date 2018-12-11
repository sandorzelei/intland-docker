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
<meta name="bodyCSSClass" content="newskin" />
<meta name="applyLayout" content="true" />

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="taglib" prefix="tag" %>
<%@ taglib uri="wysiwyg" prefix="wysiwyg" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>

<c:set var="previewMode" value="${editWikiPageForm.map.preview}" />
<c:set var="doc_id" value="${editWikiPageForm.map.doc_id}" />

<wysiwyg:froalaConfig />

<style type="text/css">
	textarea {
		overflow: auto;
		border: 1px solid #D1D1D1;
	}

	.expandWikiTextAreaWH {
		height: 80%;
		width: 100% !important;
	}
	.expandTextArea {
		width: 99.6%;
		padding: 4px;
	}

	.newskin.popupBody .ditch-tab-skin-cb-box {
		padding: 0 !important;
		margin: 15px 0 !important;
	}

	.ditch-tab-pane-wrap .actionBar {
		margin: 0px !important;
	}

	.expandText {
		width: 100% !important;
	}

	.nameDiv {
		margin: 15px 15px 0 15px;
		padding-right: 10px;
	}

	.exandTextAreaContainer {
		padding-right: 4px;
		padding-top: 15px;
	}

	.newskin.popupBody .ditch-tab-skin-cb-box {
		margin-bottom: 0px !important;
	}
</style>


<SCRIPT LANGUAGE="JavaScript" type="text/javascript">
closing = true;

function validate(frm) {
	var name = frm.name.value;
	if ( (trim(name).length == 0) )	{
		alert('"Name" is required!');
		return false;
	}

	var $editor = $('#editor');

    if (codebeamer.WYSIWYG.getEditorMode($editor) == 'wysiwyg') {
        codebeamer.WikiConversion.saveEditor($editor, true);
    }

	return true;
}

function submitAction(frm) {
	if (!validate(frm))	{
		return false;
	}
	var button1 = frm.SAVE1;
	button1.disabled=true;
	closing=false;
	frm.submit();
}

function cancelAction() {
	closing=false;
	inlinePopup.close();
}

window.onbeforeunload = function(event) {
	if (closing) {
		cancelBtn = document.getElementById('cancelBtn');
		cancelBtn.click();
	}
};

document.onkeypress = function(evt) {
	var refreshBtn = unloadBtnPressed(evt);
	if (refreshBtn) {
		closing = false;
	}
};
</SCRIPT>

<html:form action="/proj/doc/editWikiPageDialog" styleId="editWikiPageForm ">

<c:if test="${doc_id gt 0}">
	<html:hidden property="name" />
</c:if>

<html:hidden property="doc_id" />
<html:hidden property="dir_id" />
<html:hidden property="proj_id" />
<html:hidden property="scopeName" />
<html:hidden property="uploadConversationID" />

<div class="ui-layout-north">
	<ui:actionMenuBar>
	    <ui:pageTitle>
	            <ui:breadcrumbs showProjects="false">
	                <span class="breadcrumbs-separator">&raquo;</span><span><spring:message code="document.type.wikiNote.${doc_id gt 0 ? 'edit' : 'create'}.title" /></span>
	            </ui:breadcrumbs>
	    </ui:pageTitle>
	</ui:actionMenuBar>

	<ui:showErrors />

	<ui:actionBar>
		<c:if test="${empty softLock}">
			<html:submit styleClass="button" onclick="submitAction(this.form); return false" property="SAVE1" style="margin-left: 0px;">
				<spring:message code="button.save" text="Save"/>
			</html:submit>
		</c:if>
		<html:cancel styleClass="cancelButton" onclick="cancelAction();" styleId="cancelBtn">
			<spring:message code="button.cancel" text="Cancel"/>
		</html:cancel>

		<c:if test="${!empty softLock and softLock.userId gt 0}">
			&nbsp;&nbsp;
			<html:img border="0" page="/images/locked.gif" height="16" width="16" />
			&nbsp;
			<spring:message code="document.editedBy.label" text="This note is being currently edited by"/>:
			<tag:userLink user_id="${softLock.userId}" />
		</c:if>
	</ui:actionBar>

    <c:if test="${doc_id == -1}">
        <div class="nameDiv">
            <html:text styleClass="expandText" styleId="name_field" size="90" property="name" />
        </div>
        <spring:message var="nameHint" code="wiki.note.name.watermark" text="Name of Wiki Note"/>
        <script type="text/javascript">
            $('#name_field').attr('placeholder', '${nameHint}');
        </script>
    </c:if>
</div>
<div class="contentWithMargins">
	<div class="ui-layout-center">
		<c:remove var="entityRef"/>
		<c:if test="${doc_id > 0}">
			<c:set var="entityRef" value="[DOC:${doc_id}]" />
		</c:if>
		<wysiwyg:editor editorId="editor" entityRef="${entityRef}" uploadConversationId="${editWikiPageForm.map.uploadConversationID}" resizeEditorToFillParent="true"
		    insertNonImageAttachments="true" useAutoResize="false" focus="${doc_id != -1}" hideQuickInsert="true">

			<html:textarea property="text" styleId="editor" rows="22" cols="90" />
		</wysiwyg:editor>
	</div>
	<div class="ui-layout-south">
		<div class="exandTextAreaContainer">
			<html:textarea styleId="commit_text" styleClass="expandTextArea" rows="3" cols="90" property="commit_text" />
			<spring:message var="commentsHint" code="wiki.edit.comments.watermark" text="Comment (optional)"/>
		</div>
		<script type="text/javascript">
		    $('#commit_text').attr('placeholder', '${commentsHint}');
		</script>
	</div>
</div>
</html:form>

<script type="text/javascript" language="JavaScript">
	// focus on editor, or on the name if that is shown
	setTimeout(function() {
	    $("#name_field").focus();
	}, 800);
</script>
