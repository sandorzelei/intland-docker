<%-- This JSP is generated by com.intland.codebeamer.taglib.TagFileWrapperGenerator, DO NOT_EDIT, your changes will be lost! --%>
<%-- generated on --%>
<%-- Copyright by Intland Software --%>

<%-- JSP wrapper for .tag file '/WEB-INF/tags/wiki/editor.tag' --%>
<%@ taglib uri="wysiwyg" prefix="gen" %>

<%@ page session="false" import="com.intland.codebeamer.taglib.tagwrappers.wiki.EditorWrapper" %>

<% EditorWrapper a = ((EditorWrapper) request.getAttribute("tagFileWrapper")); %>

<gen:editor
	editorId="<%=a.editorId%>"
	entity="<%=a.entity%>"
	entityRef="<%=a.entityRef%>"
	height="<%=a.height%>"
	heightMin="<%=a.heightMin%>"
	heightMax="<%=a.heightMax%>"
	footerHeight="<%=a.footerHeight%>"
	uploadConversationId="<%=a.uploadConversationId%>"
	insertNonImageAttachments="<%=a.insertNonImageAttachments%>"
	formatSelectorSpringPath="<%=a.formatSelectorSpringPath%>"
	formatSelectorStrutsProperty="<%=a.formatSelectorStrutsProperty%>"
	formatSelectorDisabled="<%=a.formatSelectorDisabled%>"
	formatSelectorName="<%=a.formatSelectorName%>"
	formatSelectorValue="<%=a.formatSelectorValue%>"
	mode="<%=a.mode%>"
	useAutoResize="<%=a.useAutoResize%>"
	showSaveCancel="<%=a.showSaveCancel%>"
	resizeEditorToFillParent="<%=a.resizeEditorToFillParent%>"
	hideQuickInsert="<%=a.hideQuickInsert%>"
	getMarkup="<%=a.getMarkup%>"
	toolbarSticky="<%=a.toolbarSticky%>"
	focus="<%=a.focus%>"
	overlayHeaderKey="<%=a.overlayHeaderKey%>"
	overlayDefaultHeaderKey="<%=a.overlayDefaultHeaderKey%>"
	disablePreview="<%=a.disablePreview%>"
	readonly="<%=a.readonly%>"
	disableFormattingOptionsOpening="<%=a.disableFormattingOptionsOpening%>"
	hideUndoRedo="<%=a.hideUndoRedo%>"
	hideOverlayEditor="<%=a.hideOverlayEditor%>"
	ignorePreviouslyUploadedFiles="<%=a.ignorePreviouslyUploadedFiles%>"
	allowTestParameters="<%=a.allowTestParameters%>"
>${tagFileWrapper.jspBody}</gen:editor>
