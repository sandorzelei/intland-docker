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
 *
--%>

<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="taglib" prefix="tag" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>

<!--[if IE]><meta http-equiv="X-UA-Compatible" content="IE=5,IE=9" ><![endif]-->
<!DOCTYPE html>
<html>
<head>
    <title>Diagram Viewer</title>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
	<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
    <link rel="stylesheet" type="text/css" href="styles/grapheditor.css">
    <link rel="stylesheet" href="<ui:urlversioned value='/wro/newskin.css' />" type="text/css" media="all" />


    <script type="text/javascript" src="<ui:urlversioned value='/js/jquery/jquery.js'/>"></script>
	
</head>
<body class="popupBody newskin" style="margin: 0px;">
	<spring:message var="graphEditorTitleLabel" code="wysiwyg.wiki.markup.plugin.mxGraph.view.title" />
	<ui:actionMenuBar><b>${graphEditorTitleLabel}</b></ui:actionMenuBar>
	
	<img alt="" src="data:image/png;base64,${exportedImage}">

</body>
</html>
