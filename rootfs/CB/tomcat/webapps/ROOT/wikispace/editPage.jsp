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
<meta name="moduleCSSClass" content="wikiModule"/>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%@ taglib uri="wysiwyg" prefix="wysiwyg" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="taglib" prefix="tag" %>

<c:if var="isNew" test="${wikiPageForm.newPage}" />
<c:choose>
	<c:when test="${isNew}">
		<c:set var="setKey" value="add" />
		<c:set var="methodValue" value="create" />
		<c:set var="submitUrl" value="createWikiPage.spr" />
		<c:set var="parentName"><c:out value='${parentWikiPage.name}'/></c:set>
		<spring:message var="title" code="wiki.child.create.title" text="Adding new child Wiki page to: {0}" arguments="${parentName}"/>
	</c:when>

	<c:otherwise>
		<c:set var="setKey" value="saveandclose" />
		<c:set var="methodValue" value="update" />
		<c:set var="submitUrl" value="editWikiPage.spr" />
		<c:set var="pageName"><c:out value='${wikiPage.name}'/></c:set>
		<spring:message var="title" code="wiki.page.edit.title" text="Updating Wiki page: {0}" arguments="${pageName}"/>
	</c:otherwise>
</c:choose>

<wysiwyg:froalaConfig />

<head>
<style type="text/css">
	body {
		padding: 0 !important;
	}
	.ui-layout-center {
		border: none;
	}
	.ui-layout-south {
		border: none;
		overflow-x: hidden;
		margin-left: 15px !important;
		margin-right: 15px !important;
	}
	.expandTextAreaSpec {
		width: 100%;
		margin-top: 0px;
		margin-bottom: 15px;
		padding: 4px;
		border: solid 1px #d1d1d1;
	}
	.expandWikiTextAreaSpec {
		width: 100%;
		height: 80%;
		font-family: monospace;
		border: solid 1px #d1d1d1;

		-moz-box-sizing: border-box;
		-webkit-box-sizing: border-box;
		box-sizing: border-box;
	}
	.expandText {
		width: 100%;
		margin-bottom: 5px;
		margin-top: 5px;
	}
	.infoMessages {
		margin-left: 15px;
		margin-right: 15px;
	}
	.nameDiv {
		margin-top: 15px;
		margin-left: 15px;
		margin-right: 26px;
	}

	.wiki-form-label {
		text-align: left !important;
		padding-left: 0px;
	}

	.content-form-label {
	}
</style>
</head>

<script type="text/javascript" src="<ui:urlversioned value="/wikispace/includes/wysiwygAutoSave.js"/>"></script>

<script type="text/javascript">

var closing = true;
var deletestore = true;

function validate(frm) {
	var defaultNameContent='<spring:message code="wiki.edit.name.watermark" text="Page name (required)"/>';
	var $name = $(frm).find("[name='name']");
	if ($name.length > 0) {
		var name = $name.val();
		if ( (trim(name).length == 0) || (name == defaultNameContent) )	{
			alert('"Name" is required!');
			return false;
		}
	}

	return true;
}

function setControl(frm) {
	var buttons = document.getElementsByName('actionMethod');
	for (var i=0; i < buttons.length; i++) {
		buttons[i].disabled=true;
	}
}

function removeCommentHint() {
	if (commentContainsHint()) {
		var comment = $('#commitComment');
		comment.val('');
	}
}

function commentContainsHint() {
	var defaultComment = '<spring:message code="wiki.edit.comments.watermark" text="Comment (optional)"/>';
	var comment = $('#commitComment');
	return comment.size() > 0 && comment.val() == defaultComment;
}

function submitAction(frm) {
	if (!validate(frm)) {
		return false;
	}

	codebeamer.NavigationAwayProtection.reset();

	setControl(frm);

	frm.method.value = '<c:out value="${methodValue}" />';

	removeCommentHint();

	closing = false;
	frm.submit();

	return false;
}

function validateAndSetControl(frm) {
	if (!validate(frm)) {
		return false;
	}
	setControl(frm);

	frm.method.value = 'preview';

	removeCommentHint();
	closing = false;
	frm.submit();

	return false;
}

function validateData(tab){
	if(tab.id.indexOf("preview")==-1)
		return true;
	var frm = document.getElementById('wikiPageForm');
	if (!validate(frm)) {
		return false;
	}
	return true;
}

function cancelEditWikiPage() {
	codebeamer.NavigationAwayProtection.reset();
	closing=false;
	<c:if test="${empty canEditPage || canEditPage}">
		if (deletestore) {
			var contentId="WIKIPAGE-${wikiPageForm.doc_id}-${displayedRevision}";
			var displayedRevisionModifiedAt = ${empty displayedRevisionModifiedAt ? "null": displayedRevisionModifiedAt.time};
			new wysiwygAutoSave(contentId, "editor", displayedRevisionModifiedAt);
		}
	</c:if>
	return true;
}

function disableAndProgressifyButtons() {
	$(".weSaveButton").attr('value','<spring:message code="button.saving" text="Saving..."/>');
	$(".weSaveButton").click(function() { return false; });
	$(".weSaveButton").attr("disabled", "disabled");
}

function enableAndDeProgressifyButtons() {
	$(".weSaveButton").attr('value','<spring:message code="button.save" text="Save"/>');
	$(".weSaveButton").removeAttr("disabled");
}

function unlockWikiPage() {
	$.ajax({
		url: contextPath + '/ajax/wiki/releaseLock.spr?wikiId=${wikiPage.id}',
		async: false,
		type: 'GET'
	});
}

$(document).ready(function () {
	function doFocus() {
		$("#${focus}").focus();
	}

	function initPage() {
		setTimeout(function() {
			doFocus();
		}, 800);
	}

	initPage();

	<c:if test="${empty canEditPage || canEditPage}">
    	var contentId="WIKIPAGE-${wikiPageForm.doc_id}-${displayedRevision}";
    	var displayedRevisionModifiedAt = ${empty displayedRevisionModifiedAt ? "null": displayedRevisionModifiedAt.time};

    	// loads the previously saved content, and schedule auto save
    	new wysiwygAutoSave(contentId, "editor", displayedRevisionModifiedAt);
	</c:if>

	codebeamer.NavigationAwayProtection.init(${param.overlay ? 'true': ''});
});

$(window).on("beforeunload", function(e){
	if (closing) {
		unlockWikiPage();
	}
});

$("body").on("beforeInlinePopupDestroy", function(e){
	unlockWikiPage();
});

document.onkeypress = function(evt) {
	var refreshBtn = unloadBtnPressed(evt);
	if (refreshBtn) {
		closing = false;
	}
}

</script>

<c:if test="${! tooManyWikiPages}">

<div class="innerContentArea editWikiPageICA">
	<form:form id="wikiPageForm" commandName="wikiPageForm" action="${submitUrl}" enctype="multipart/form-data" class="dirty-form-check">
	<div class="ui-layout-north" >
		<ui:actionMenuBar>
			<ui:pageTitle><b>${title}</b></ui:pageTitle>
		</ui:actionMenuBar>

		<c:set var="controlButtons">
			<c:if test="${isNew || canEditPage}">
				<spring:message var="saveButton" code="button.save" />
				<input type="submit" class="button weSaveButton" name="actionMethod" value="${saveButton}" onclick="return submitAction(this.form)"  style="margin-left: 0px;"/>
				&nbsp;&nbsp;
			</c:if>

			<spring:message var="cancelButton" code="button.cancel" />
			<input type="submit" class="cancelButton" id="cancelBtn" name="_cancel" value="${cancelButton}" onclick="return cancelEditWikiPage();" />

			<c:if test="${!canEditPage and !empty PAGE_LOCKER}">
				&nbsp;&nbsp;
				<span class="high">
					<spring:message code="document.editedBy.label" text="This note is being currently edited by"/>:
					<tag:userLink user_id="${PAGE_LOCKER.id}" />
				</span>
			</c:if>
		</c:set>

		<c:if test="${wikiPageForm.doc_id != -1}">
			<form:hidden path="doc_id" />
		</c:if>
		<form:hidden path="revision" />
		<form:hidden path="section" />
		<form:hidden path="parent_id" />
		<form:hidden path="navigation_id" />
		<form:hidden path="forward_doc_id" />
		<form:hidden path="method" />
		<form:hidden path="nameEditable" />
		<form:hidden path="overlay" />

		<c:set var="nameEditable" value="${wikiPageForm.nameEditable}" />

		<ui:actionBar>
			<c:out value="${controlButtons}" escapeXml="false" />
		</ui:actionBar>

		<form:errors />

		<c:choose>
			<c:when test="${nameEditable}">
				<div class="nameDiv">
					<div class="mandatory wiki-form-label">
						<spring:message code="wiki.edit.name.label" text="Page name"/>:
					</div>
					<form:input path="name" cssClass="expandText" size="90" maxlength="255" />
				</div>
			</c:when>
			<c:otherwise>
				<%-- when clickin on a wiki link (like [apple]) where page does not exist yet the name for the new wiki-page is passed as parameter, this is bidden here --%>
				<form:hidden path="name" />
			</c:otherwise>
		</c:choose>
	</div>

    <div class="ui-layout-center contentWithMargins">
		<div class="optional wiki-form-label content-form-label">
			<spring:message code="wiki.content.label" text="Content"/>:
		</div>

		<wysiwyg:editor editorId="editor" entity="${wikiPage}" uploadConversationId="${wikiPageForm.uploadConversationId}" resizeEditorToFillParent="true"
		    insertNonImageAttachments="true" useAutoResize="false" hideQuickInsert="true" focus="${not isNew}">

		    <form:textarea path="pageContent" id="editor" rows="25" cols="90" autocomplete="off" />
		</wysiwyg:editor>
    </div>
	<div class="ui-layout-south" style="padding-right: 10px;">

		<c:if test="${not isNew}">
			<c:if test="${wikiPage.id gt 0}">
				<form:textarea cssClass="expandTextAreaSpec" rows="3" cols="90" path="commitComment" />
				<spring:message var="commentsHint" code="wiki.edit.comments.watermark" text="Comment (optional)"/>
				<script type="text/javascript">
						applyHintInputBox("#commitComment", "${commentsHint}");
						codebeamer.NavigationAwayProtection.init();
				</script>
			</c:if>
		</c:if>
	</div>

	</form:form>

</div>

</c:if>
