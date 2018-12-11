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
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<html>
<head>
	<meta name="decorator" content="popup"/>
	<meta name="moduleCSSClass" content="wikiModule newskin fr-modal"/>

	<script type="text/javascript" src="<ui:urlversioned value='/js/wysiwyg/froala_plugins/cbwikimarkup/js/wikiMarkupPopup.js'/>"></script>
	<link rel="stylesheet" type="text/css" href="<ui:urlversioned value='/js/wysiwyg/froala_plugins/froalaModal.less'/>"/>

	<style type="text/css">
		.fr-modal .textAreaContainer {
		    height: 250px;
		    margin-top: 5px;
		    margin-bottom: 5px;
		    margin-right: 6px;
		}

		.fr-modal .textAreaLabel {
			text-align: left !important;
		}

		.fr-modal .textAreaContainer textarea {
		    font-size: 13px;
		    width: 100%;
		    height: 100%;
		}

		#style {
			float: right;
			white-space: normal;
			margin-top: 3px;
		}

		#style select {
			margin-top: -3px;
		}

		.actionBar * {
			font-size: 13px;
		}
	</style>

</head>

<body>
	<spring:message var="title" code="wysiwyg.wiki.markup.plugin.title"/>
	<ui:pageTitle printBody="false">${title}</ui:pageTitle>

	<spring:message var="insertMarkupButtonLabel" code="wysiwyg.wiki.markup.plugin.insertMarkup.button.label" />
	<spring:message var="cancelButtonLabel" code="wysiwyg.wiki.markup.plugin.cancel.button.label" />

	<ui:actionMenuBar><b>${title}</b></ui:actionMenuBar>

	<ui:actionBar>
		&nbsp;&nbsp;<input type="button" class="button" name="insertMarkupButton" value="${insertMarkupButtonLabel}"/>
		<input type="button" class="button cancelButton" value="${cancelButtonLabel}" />

		<c:set var="style" value="${param.style}" />
		<div id="style">
			<spring:message code="wysiwyg.wiki.markup.plugin.style.label" text="Style"/>:
			<select id="style" style="margin-left: 10px;">
				<option value=""><spring:message code="wysiwyg.wiki.markup.plugin.style.label" text="None"/></option>
				<option value="information" <c:if test="${style == 'Information'}"> selected="selected" </c:if> ><spring:message code="wysiwyg.wiki.markup.plugin.style.Information" text="Information"/></option>
				<option value="warning" <c:if test="${style == 'Warning'}"> selected="selected" </c:if> ><spring:message code="wysiwyg.wiki.markup.plugin.style.Warning" text="Warning"/></option>
				<option value="error" <c:if test="${style == 'Error'}"> selected="selected" </c:if> ><spring:message code="wysiwyg.wiki.markup.plugin.style.Error" text="Error"/></option>
				<option value="preformatted" <c:if test="${style == 'Preformatted'}"> selected="selected" </c:if> ><spring:message code="wysiwyg.wiki.markup.plugin.style.Preformatted" text="Preformatted"/></option>
			</select>
		</div>
		<div style="clear:both;"></div>
	</ui:actionBar>

	<div class="contentWithMargins" style="margin-top: 5px;">
		<div class="optional textAreaLabel">
			<spring:message code="wiki.content.label" text="Content"/>:
		</div>
		<div class="textAreaContainer">
			<textarea name="wikiMarkup"></textarea>
		</div>
	</div>

</body>
</html>