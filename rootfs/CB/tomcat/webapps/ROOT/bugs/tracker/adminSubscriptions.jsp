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
<%@ page import="com.intland.codebeamer.Config"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ page import="com.intland.codebeamer.chatops.ChatOpsPlatformImplHelper" %>
<%@ page import="com.intland.codebeamer.controller.ControllerUtils" %>
<%@ page import="com.intland.codebeamer.chatops.notifications.ChatOpsNotificationCreator" %>


<head>
	<style type="text/css">
		div.moreNotifications {
			margin-top: 15px;
		}

		h2 span.subtext {
			font-weight: normal !important;
			margin-left: 0.5em;
		}

		.notifications .status {
			text-align: center;
		}

		.notifications .status .issueStatus {
			text-transform: uppercase !important;
		}

	</style>
</head>

<form id="trackerItemSubscriptionForm" action="${configurationUrl}" method="post">
	<div class="actionBar">
		<spring:message var="cancelButton" code="button.cancel" text="Cancel"/>
		&nbsp;&nbsp;<input type="submit" class="cancelButton" name="_cancel" value="${cancelButton}"/>

		<div class="rightAlignedDescription">
			<spring:message code="tracker.notifications.tooltip" arguments="${TrackerTypeName}"/>
		</div>
	</div>
	<h2>
		<spring:message code="slack.notifications.notificationChannel.title"></spring:message>
		<span class="subtext">
			<spring:message code="slack.notifications.notificationChannel.hint"></spring:message>
		</span>
	</h2>
	<table class="displaytag notifications">
		<thead>
			<tr>
				<th class="textData columnSeparator">
					<spring:message code="slack.notifications.notificationChannel.subtitle"></spring:message>
				</th>
			</tr>
		</thead>
		<tbody>
			<tr>
				<td>
					<div id="chatOpsNotificationConfigurationDiv"></div>
				</td>
			</tr>
		</tbody>
	</table>
</form>

<script type="text/javascript" src="<ui:urlversioned value='/chatops/chatOpsNotificationConfiguration.js'/>"></script>
<script type="text/javascript" src="<ui:urlversioned value='/bugs/tracker/includes/notificationConfiguration.js'/>"></script>
<%
	pageContext.setAttribute("chatOpsEnabled", false);
	ChatOpsPlatformImplHelper chatOpsPlatformImplHelper = ControllerUtils.getSpringBean(request, null, ChatOpsPlatformImplHelper.class);
	ChatOpsNotificationCreator chatOpsNotificationCreator = chatOpsPlatformImplHelper.getNotificationCreator();
	if (chatOpsNotificationCreator != null) {
		pageContext.setAttribute("chatOpsEnabled", chatOpsNotificationCreator.isNotificationsEnabled());
	}
%>
<script type="text/javascript">

	$('#trackerItemSubscriptionForm').notificationList( {
		id : ${tracker.id},
		name : "<spring:escapeBody javaScriptEscape="true">${tracker.name}</spring:escapeBody>" },
		${notificationsJSON},
		${notificationConfigJSON});

<c:if test="${(canSubscribeSelf or canSubscribeOthers) and not tracker.branch}">

	$('#trackerItemSubscriptionForm > div.actionBar').ajaxSubmitButton({
	    submitText 	: '<spring:message code="button.save" text="Save" javaScriptEscape="true"/>',
	    submitUrl	: '${notificationsUrl}',
	    submitData	: function() {
	    					var notifications = $('#trackerItemSubscriptionForm').getNotifications();
	    					// workaround for bug #318260
	    					if (notifications){
	    						$.each(notifications, function( index, notification ) {
	    							if (notification.eventFilter){
		    							if (notification.eventFilter.eventMask == 0){
		    								notification.eventFilter.eventMask = null;
		    							}
		    						}
	    						});
	    					}
	    					return notifications;
	    			  }
	});

	$('#chatOpsNotificationConfigurationDiv').chatOpsNotificationChannelSelector({
		id : ${tracker.id},
		name : "<spring:escapeBody javaScriptEscape="true">${tracker.name}</spring:escapeBody>" },
	{
		chatOpsEnabled: ${chatOpsEnabled},
		formSubmitButton: $('#trackerItemSubscriptionForm > div.actionBar > input:nth-child(1)')
	});

</c:if>

</script>
