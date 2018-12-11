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
<meta name="module" content="wikispace"/>
<meta name="moduleCSSClass" content="wikiModule newskin"/>

<%--
Parameters:
  - doc_id   Wiki page ID
--%>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>

<ui:actionMenuBar>
	<ui:pageTitle prefixWithIdentifiableName="false">Import</ui:pageTitle>
</ui:actionMenuBar>

<ui:pageTitle printBody="false">Import from Word</ui:pageTitle>

<style>
	.wikiImportPopup {
		padding: 0 15px 15px 15px;
	}

	.wikiImportPopup .importMetaData {
		margin-bottom: 1em;
	}

	.wikiImportPopup.processing {
		width: 100%;
		margin: 0;
		text-align: center;
		padding: 4em 0 0;
	}

	.wikiImportPopup.processing .message {
		margin-bottom: 0.5em;
	}

</style>

<script type="text/javascript">

	var showImportProcessingAnimation = function() {
		var ajaxLoaderImageUrl = "${contextUrl}" + "/images/ajax_loading_horizontal_bar.gif";
		var img = $("<div class='message'><c:out value="${processingMessage}" /></div><img src='" + ajaxLoaderImageUrl + "'>");
		$(".wikiImportPopup").empty().addClass("processing").append(img);
	};
</script>

<div class="wikiImportPopup">

	<spring:message var="appendLabel" code="wiki.import.from.mode.append.label" text="Append" />
	<spring:message var="overwriteLabel" code="wiki.import.from.mode.overwrite.label" text="Overwrite" />

	<c:url var="uploadFormAction" value="/dndupload/saveasnote.spr">
		<c:param name="doc_id" value="${wikiPageId}"/>
	</c:url>

	<div class="importMetaData">
		<h2>Import method</h2>
		<form id="importMetaDataForm" action="${uploadFormAction}">
			<label><input type="radio" name="import_method" value="overwrite" checked> ${overwriteLabel}</label><br>
			<label><input type="radio" name="import_method" value="append"> ${appendLabel}</label>
		</form>
	</div>

	<ui:fileUpload uploadConversationId="importFromWord" single="true"
				   elastic="true" dndDropHereMessageCode="dndupload.dropFilesHereOrBrowse"
				   submitFormOnComplete="importMetaDataForm" onCompleteCallback="showImportProcessingAnimation" />
</div>
