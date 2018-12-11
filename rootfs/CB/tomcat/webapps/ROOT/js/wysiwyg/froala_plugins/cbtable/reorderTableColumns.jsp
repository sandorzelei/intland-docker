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
<%@ taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@ taglib uri="taglib" prefix="tag" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>

<head>
	<meta name="decorator" content="popup"/>
	<meta name="moduleCSSClass" content="wikiModule newskin fr-modal"/>

	<script type="text/javascript" src="<ui:urlversioned value='/js/jquery/dragtable/jquery.dragtable.js'/>"></script>
    <script type="text/javascript" src="<ui:urlversioned value='/js/wysiwyg/froala_plugins/cbtable/js/cbReorderTableColumnsPopup.js'/>"></script>
    <link rel="stylesheet" type="text/css" href="<ui:urlversioned value='/js/wysiwyg/froala_plugins/froalaModal.less'/>"/>
	<link rel="stylesheet" type="text/css" href="<ui:urlversioned value='/js/jquery/dragtable/dragtable.css' />" />

	<spring:message var="title" code="wysiwyg.cb.table.plugin.reorder.button.label" />
	<ui:pageTitle printBody="false"> - ${title}</ui:pageTitle>

	<style type="text/css">
		.contentWithMargins * {
			font-size: 13px;
		}

		#tablePlaceHolder {
			margin-top: 10px;
		}

		.columnDraggable {
			cursor: move;
			min-width: 40px !important;
			padding-left: 16px !important;
			background-image: url("../../../../images/newskin/action/dragbar-small.png") !important;
			background-position: 5px 3px !important;
    		background-repeat: no-repeat !important;
		}
	</style>

</head>
<body>
	<c:set var="trackerId" value="${param.trackerId}" />

	<ui:actionMenuBar><b>${title}</b></ui:actionMenuBar>

	<spring:message var="cancelButtonLabel" code="wysiwyg.wiki.markup.plugin.cancel.button.label" />
	<spring:message var="createWorkItemLabel" code="button.save" text="Save" />

	<ui:actionBar>
		&nbsp;&nbsp;
		<input type="button" class="button saveButton" value="${createWorkItemLabel}" />
		<input type="button" class="button cancelButton" value="${cancelButtonLabel}" />
	</ui:actionBar>

	<div class="contentWithMargins">
		<div class="information"><spring:message code='wysiwyg.cb.table.plugin.hint'/></div>
		<div id="tablePlaceHolder"></div>
	</div>
</body>