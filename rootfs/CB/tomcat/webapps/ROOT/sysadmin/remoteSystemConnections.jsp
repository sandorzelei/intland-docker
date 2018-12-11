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

<meta name="decorator" content="main"/>
<meta name="module" content="sysadmin"/>
<meta name="moduleCSSClass" content="sysadminModule newskin"/>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="uitaglib" prefix="ui" %>

<link rel="stylesheet" type="text/css" href="<ui:urlversioned value='/js/jquery/jquery-multiselect/jquery.multiselect.css'/>" />
<link rel="stylesheet" type="text/css" href="<ui:urlversioned value='/js/jquery/jquery-contextMenu/jquery.contextMenu.css'/>" />
<link rel="stylesheet" type="text/css" href="<ui:urlversioned value='/js/jquery/jquery-treetable/jquery.treetable.css'/>" />

<script type="text/javascript" src="<ui:urlversioned value='/js/jquery/jquery-contextMenu/jquery.contextMenu.js'/>"></script>
<script type="text/javascript" src="<ui:urlversioned value='/js/jquery/jquery-contextMenu/jquery.ui.position.js'/>"></script>
<script type="text/javascript" src="<ui:urlversioned value='/js/jquery/jquery-multiselect/jquery.multiselect.js'/>"></script>
<script type="text/javascript" src="<ui:urlversioned value='/js/jquery/jquery-treetable/jquery.treetable.js'/>"></script>
<script type="text/javascript" src="<ui:urlversioned value='/bugs/tracker/includes/userInfoLink.js'/>"></script>

<jsp:include page="/bugs/includes/remoteImport.jsp" />
<jsp:include page="/bugs/includes/doorsBridge.jsp" />
<jsp:include page="/bugs/includes/doorsProject.jsp" />
<jsp:include page="/bugs/includes/jiraImport.jsp" />

<ui:actionMenuBar>
	<ui:pageTitle>
		<spring:message code="sysadmin.remoteSystemConnections.label" text="External/Remote connections"/>
	</ui:pageTitle>
</ui:actionMenuBar>


<div id="remoteSystemConnections" class="contentWithMargins">
</div>

<script type="text/javascript">



$('#remoteSystemConnections').remoteSystemConnections({
	url			: '<c:url value="/sysadmin/ajax/remoteAssociations.spr"/>',
	validate    : true,
	title		: '<spring:message code="remote.connections.label"    text="Connections to the [selected external/remote systems]:" javaScriptEscape="true" />',
	loading		: '<spring:message code="remote.connections.loading"  text="Loading connections to the selected external/remote systems ..." javaScriptEscape="true" />',
	none		: '<spring:message code="remote.connections.none"     text="There are no connections to any of the selected external/remote systems !" javaScriptEscape="true" />',
	hint		: '<spring:message code="remote.connections.hint"     text="In order to see details about the connected external/remote systems, you must be an administrator of the target project and/or tracker!" javaScriptEscape="true" />',
	expandAll	: '<spring:message code="remote.connections.expand"   text="Expand all"   javaScriptEscape="true" />',
	collapseAll	: '<spring:message code="remote.connections.collapse" text="Collapse all" javaScriptEscape="true" />',

	help		: {
		title	: '"Connections with external systems" in codeBeamer Knowledge Base',
		URL		: 'https://codebeamer.com/cb/wiki/4078700'
	},

	connectors	: {
		list	: ${controllers},

		config	: {
			label		: '<spring:message code="remote.system.label"      text="External/remote system" javaScriptEscape="true" />',
			title		: '<spring:message code="remote.system.tooltip"    text="A connectable external/remote system" javaScriptEscape="true" />',
			none		: '<spring:message code="remote.connectors.none"   text="There are no external/remote system connectors deployed on this codeBeamer instance!" javaScriptEscape="true" />',
			toggleAll	: '<spring:message code="remote.system.toggleAll"  text="(De-)Select all external/remote systems" javaScriptEscape="true" />',
			toggleThis  : '<spring:message code="remote.system.toggleThis" text="(De-)Select this external/remote system" javaScriptEscape="true" />'
		},

		dialog	: {
			url			: '<c:url value="/sysadmin/ajax/remoteConnectors.spr"/>',
			label		: '<spring:message code="remote.connectors.label"   text="Connectors..." javaScriptEscape="true" />',
			title		: '<spring:message code="remote.connectors.title"   text="Available remote system connectors" javaScriptEscape="true" />',
			loading 	: '<spring:message code="remote.connectors.loading" text="Loading remote system connectors ..." javaScriptEscape="true" />',
			submitText  : '<spring:message code="button.ok" 	text="OK" 	  javaScriptEscape="true"/>',
			cancelText  : '<spring:message code="button.cancel" text="Cancel" javaScriptEscape="true"/>',
		    cancelUrl	: '<c:url value="/sysadmin.do" />'
		}
	},

	target		: {
		title	: '<spring:message code="remote.association.target.title" text="The Projects and/or Trackers, that are associated with external/remote systems" javaScriptEscape="true"/>',
		project	: {
			icon	: '<c:url value="/images/issuetypes/project.gif"/>',
			label	: '<spring:message code="project.label" text="Project" javaScriptEscape="true"/>',
		},
		tracker	: {
			icon	: '<c:url value="/images/issuetypes/issue.png"/>',
			label	: '<spring:message code="tracker.label"	text="Tracker" javaScriptEscape="true"/>'
		}
	},

	remote 		: {
		label	: '<spring:message code="remote.association.source.label" text="Connected with" javaScriptEscape="true"/>',
		title	: '<spring:message code="remote.association.source.title" text="The external/remote system, the project/tracker is associated with" javaScriptEscape="true"/>',

		server	: {
			label	: '<spring:message code="remote.connection.server.label"   text="Server" javaScriptEscape="true"/>',
			title	: '<spring:message code="remote.connection.server.tooltip" text="The URL (web address) of the remote server/host" javaScriptEscape="true"/>'
		},

		error	: {
			icon 	: '<c:url value="/images/warn.gif"/>',
			label	: '<spring:message code="remote.connection.failure.label"   text="Validation failed" javaScriptEscape="true"/>',
			title	: '<spring:message code="remote.connection.failure.tooltip" text="Validation of this external/remote connection failed"/>'
		}
	},

	createdBy	: {
		label	: '<spring:message code="remote.association.createdBy.label" 	text="Created by" javaScriptEscape="true"/>',
		title	: '<spring:message code="remote.association.createdBy.tooltip" 	text="The user, that created this remote association" javaScriptEscape="true"/>'
	},

	createdAt	: {
		label	: '<spring:message code="remote.association.createdAt.label" 	text="Created at" javaScriptEscape="true"/>',
		title	: '<spring:message code="remote.association.createdAt.tooltip" 	text="Date and time, this remote association was created" javaScriptEscape="true"/>'
	}

});

</script>

