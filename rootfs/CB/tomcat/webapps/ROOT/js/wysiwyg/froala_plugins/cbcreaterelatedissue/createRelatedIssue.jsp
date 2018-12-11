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
<%@ page import="com.intland.codebeamer.controller.dndupload.UploadStorage"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@ taglib uri="taglib" prefix="tag" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>

<head>
	<meta name="decorator" content="popup"/>
	<meta name="moduleCSSClass" content="wikiModule newskin fr-modal"/>

    <script type="text/javascript" src="<ui:urlversioned value='/js/wysiwyg/froala_plugins/cbcreaterelatedissue/js/cbCreateRelatedIssuePopup.js'/>"></script>
    <link rel="stylesheet" type="text/css" href="<ui:urlversioned value='/js/wysiwyg/froala_plugins/froalaModal.less'/>"/>

	<spring:message var="title" code="wysiwyg.create.related.issue.plugin.title" />
	<ui:pageTitle printBody="false"> - ${title}</ui:pageTitle>

	<style type="text/css">
		body {
			overflow-x: hidden !important;
			overflow-y: hidden !important;
		}
		.contentWithMargins * {
			font-size: 13px;
		}
	</style>

</head>
<body>
	<c:set var="trackerId" value="${param.trackerId}" />

<c:choose>
	<c:when test="${! empty trackerId}">
        <input type="hidden" id="trackerId" value="${trackerId}" />
        <input type="hidden" id="useSelectionAsDescription" value="${param.useSelectionAsDescription}" />
	</c:when>
	<c:otherwise>

	<ui:actionMenuBar><b>${title}</b></ui:actionMenuBar>

	<spring:message var="cancelButtonLabel" code="wysiwyg.wiki.markup.plugin.cancel.button.label" />
	<spring:message var="createWorkItemLabel" code="wysiwyg.create.related.issue.plugin.label" />

	<ui:actionBar>
		&nbsp;&nbsp;<input type="button" class="button insertButton" name="insertMarkupButton" value="${createWorkItemLabel}" />
		<input type="button" class="button cancelButton" value="${cancelButtonLabel}" />
	</ui:actionBar>

<style type="text/css">
	.contentWithMargins label {
		margin-left: 15px;
		margin-bottom: 15px;
		display: inline-block;
		width: 50px;
	}
	.contentWithMargins select {
		margin-left: 10px;
		margin-bottom: 10px;
		min-width: 10em;
	}
</style>

<div class="contentWithMargins">
	<label>Project:</label><select id="chooseProject"></select><br/>
	<label>Tracker:</label><select id="chooseTracker"></select><br/>

	<label><spring:message code="wysiwyg.create.related.issue.plugin.content.select.label" text="Content"/>:</label><select id="useSelectionAsDescription">
		<option value="true" ><spring:message code="wysiwyg.create.related.issue.plugin.content.only.seleted"/></option>
		<option value="false"><spring:message code="wysiwyg.create.related.issue.plugin.content.all"/></option>
	</select>
</div>

<input type="hidden" id="projectId" value="${param.proj_id}" />

</c:otherwise>
</c:choose>
</body>
