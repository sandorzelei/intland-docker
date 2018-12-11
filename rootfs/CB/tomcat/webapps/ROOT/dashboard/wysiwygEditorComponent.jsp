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
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="wysiwyg" prefix="wysiwyg" %>

<style type="text/css">
	body {
		height: auto !important;
	}
</style>

<div class="wiki-editor-container">

	<wysiwyg:froalaConfig />
	<wysiwyg:editor editorId="editor" focus="true" entity="${entity}" uploadConversationId="${uploadConversationId}" resizeEditorToFillParent="true" useAutoResize="false">
		<textarea id="editor" name="params[markup]" rows="15" cols="80">${value}</textarea>
	</wysiwyg:editor>
</div>