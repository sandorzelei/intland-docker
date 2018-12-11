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
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="uitaglib" prefix="ui" %>

<meta name="decorator" content="popup"/>

<link rel="stylesheet" href="<ui:urlversioned value="/bugs/remoteIssue/remoteIssue.less" />" type="text/css" media="all" />
<link rel="stylesheet" href="<ui:urlversioned value="/stylesheet/installer/installer.css" />" type="text/css" media="all" />

<div class="header">
	<div class="actionBar">
		<div class="step-icon main"></div>
		<span class="main-title"><spring:message code="remote.issue.report.page.title" text="codeBeamer Contact Form"/></span>
	</div>
</div>

<div class="container">
	<div class="info">
		<spring:message code="remote.issue.report.disabled.message"/>
	</div>

	<div class="footer">
		<spring:message code="button.close" text="Close" var="closeLabel"/>
		<input type="button" id="close" value="${closeLabel}" class="next-button link-button" onclick="window.parent.postMessage('closePopup', '*');"/>
	</div>
</div>

