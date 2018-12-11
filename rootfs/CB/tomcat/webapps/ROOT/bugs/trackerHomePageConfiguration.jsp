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
<meta name="module" content="tracker"/>
<meta name="bodyCSSClass" content="newskin" />

<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="uitaglib" prefix="ui" %>

<link rel="stylesheet" href="<ui:urlversioned value='/stylesheet/treeSettings.less' />" type="text/css" media="all" />

<c:url var="actionUrl" value="/trackers/trackerHomePageConfiguration.spr">
	<c:param name="proj_id">${projectId}</c:param>
</c:url>
<form action="${actionUrl}" method="POST">

	<ui:actionMenuBar>
		<spring:message code="tracker.homepage.configuration.label" />
	</ui:actionMenuBar>

	<ui:actionBar>
		<spring:message var="buttonTitle" code="button.save" text="Save"/>
		<spring:message var="cancelTitle" code="button.cancel" text="Cancel"/>
		<input type="submit" class="button" title="${buttonTitle}" value="${buttonTitle}" name="submit" />&nbsp;
		<input type="button" class="button cancelButton" title="${cancelTitle}" value="${cancelTitle}" onclick="closePopupInline();return false;" />
	</ui:actionBar>

	<c:if test="${not empty errorMessage}">
		<div class="error">${ui:sanitizeHtml(errorMessage)}</div>
	</c:if>

	<div class="contentWithMargins">
		<div class="fields-container">
			<span class="group-header"><spring:message code="tracker.homepage.configuration.settings.label"/></span>
			<label for="showHiddenTrackers">
				<input id="showHiddenTrackers" type="checkbox" name="showHiddenTrackers"<c:if test="${command.showHiddenTrackers}"> checked="ckecked"</c:if>>
				<spring:message code="tracker.homepage.configuration.show.hidden.label" text="Work item IDs"/>
			</label>
		</div>
	</div>
</form>
