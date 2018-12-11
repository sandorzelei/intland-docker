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
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="taglib" prefix="tag" %>
<%@ taglib uri="wysiwyg" prefix="wysiwyg" %>

<%@ page import="com.intland.codebeamer.Config"%>

<%--
	JSP for editing wikis in overlay

	accepts following parameters:
	Note: lowercase parameters are used because Jquery's data() function converts them to lowercase
 --%>
<%--
<pre>
title: ${param.title}
uploadConversationId: ${param.uploadConversationId}
projectId: ${param.projectId}
entityTypeId: ${param.entityTypeId}
entityId: ${param.entityId}
entityRef: ${param.entityRef}
</pre>
--%>

<style type="text/css">
	textarea {
		box-sizing:border-box;
		-moz-box-sizing:border-box; /* Firefox */
		width: 100%;
	}

	.hidden-upload-control {
		display: none;
	}
</style>

<ui:actionMenuBar cssClass="ui-layout-north">
	<ui:pageTitle>${param.title}</ui:pageTitle>
</ui:actionMenuBar>


<div class="contentWithMargins">
	<wysiwyg:froalaConfig />
	<wysiwyg:editor editorId="wiki" entityRef="${param.entityRef}" uploadConversationId="${param.uploadConversationId}" showSaveCancel="true"
	                                insertNonImageAttachments="true" useAutoResize="false" resizeEditorToFillParent="true"
	                                getMarkup="wikiEditorOverlay.getWikiMarkup" hideQuickInsert="true" focus="true">
			<textarea class="expandWikiTextAreaSpec" rows="23" cols="90" id="wiki" ></textarea>
	</wysiwyg:editor>
</div>

<script type="text/javascript">
	$.FroalaEditor.COMMANDS.cbSave.callback = wikiEditorOverlay.save;
	$.FroalaEditor.COMMANDS.cbCancel.callback = wikiEditorOverlay.close;
</script>
