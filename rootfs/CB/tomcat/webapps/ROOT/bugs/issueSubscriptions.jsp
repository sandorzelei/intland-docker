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
<meta name="moduleCSSClass" content="newskin trackersModule"/>

<%@ page import="com.intland.codebeamer.Config"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="uitaglib" prefix="ui" %>

<link rel="stylesheet" type="text/css" href="<ui:urlversioned value='/bugs/tracker/includes/choiceOptions.css'/>" />
<link rel="stylesheet" type="text/css" href="<ui:urlversioned value='/bugs/tracker/includes/viewConfiguration.css'/>" />
<link rel="stylesheet" type="text/css" href="<ui:urlversioned value='/bugs/tracker/includes/fieldAccessControl.css'/>" />

<script type="text/javascript" src="<ui:urlversioned value='/js/jquery/jquery-contextMenu/jquery.contextMenu.js'/>"></script>
<script type="text/javascript" src="<ui:urlversioned value='/js/jquery/jquery-contextMenu/jquery.ui.position.js'/>"></script>
<script type="text/javascript" src="<ui:urlversioned value='/js/colorPicker.js'/>"></script>

<script type="text/javascript" src="<ui:urlversioned value='/bugs/tracker/includes/userInfoLink.js'/>"></script>
<script type="text/javascript" src="<ui:urlversioned value='/bugs/tracker/includes/choiceOptions.js'/>"></script>
<script type="text/javascript" src="<ui:urlversioned value='/bugs/tracker/includes/viewConfiguration.js'/>"></script>
<script type="text/javascript" src="<ui:urlversioned value='/bugs/tracker/includes/fieldValueCombinations.js'/>"></script>
<script type="text/javascript" src="<ui:urlversioned value='/bugs/tracker/includes/referenceFieldConfiguration.js'/>"></script>
<script type="text/javascript" src="<ui:urlversioned value='/bugs/tracker/includes/fieldMandatoryControl.js'/>"></script>
<script type="text/javascript" src="<ui:urlversioned value='/bugs/tracker/includes/fieldDefaultValues.js'/>"></script>
<script type="text/javascript" src="<ui:urlversioned value='/bugs/tracker/includes/fieldAccessControl.js'/>"></script>
<script type="text/javascript" src="<ui:urlversioned value='/bugs/tracker/includes/fieldConfiguration.js'/>"></script>
<script type="text/javascript" src="<ui:urlversioned value='/bugs/tracker/includes/ajaxSubmitButton.js'/>"></script>

<style type="text/css">

.notifications {
	width: 95% !important;
}
.moreNotifications {
	margin-left: 15px !important;
}

h2 {
	margin-left: 15px;
}

h2 span.subtext {
	font-weight: normal !important;
	margin-left: 0.5em;
}

</style>

<%-- model initialized in TrackerItemController.getTrackerItemNotificationConfiguration --%>
<ui:actionMenuBar>
	<ui:pageTitle prefixWithIdentifiableName="false">
		<spring:message code="issue.subscribe.other.label" />
	</ui:pageTitle>
</ui:actionMenuBar>

<form id="trackerItemSubscriptionForm" action="${configurationUrl}" method="post">
	<div class="actionBar">
		<spring:message var="cancelButton" code="button.cancel" text="Cancel"/>
		&nbsp;&nbsp;<input type="button" class="cancelButton" name="_cancel" value="${cancelButton}" onclick="inlinePopup.close();"/>
	</div>
	<div class="information"><spring:message code="issue.subscribe.other.information" text="These roles and users will get notified if the issue's fields modified, or an association, comment, attachement added, removed or modified!"/></div>
</form>

<script type="text/javascript" src="<ui:urlversioned value='/bugs/tracker/includes/notificationConfiguration.js'/>"></script>
<script type="text/javascript">

	$('#trackerItemSubscriptionForm').notificationList( { id : ${tracker.id}, name : "<c:out value='${tracker.name}'/>" }, ${notificationsJSON}, ${notificationConfigJSON}, null, null);

	$('#trackerItemSubscriptionForm > div.actionBar').ajaxSubmitButton({
	    submitText 	: '<spring:message code="button.save" text="Save" javaScriptEscape="true"/>',
	    submitUrl	: '${notificationsUrl}',
	    onSuccess	: function(result) {
			window.parent.location.reload();
	   	 	inlinePopup.close();
		},
	    submitData	: function() {
	   		return $('#trackerItemSubscriptionForm').getNotifications();
	    }
	});

</script>
