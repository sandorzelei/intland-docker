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
<%@ taglib uri="wysiwyg" prefix="wysiwyg" %>

<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<style type="text/css">
	#tracker-list li {
		list-style: none;
		border-top: 1px solid #ddd;
		cursor: move;
		padding: 0.5em;
	}

	#tracker-list li:last-child {
		border-bottom: 1px solid #ddd;
	}

	#tracker-list li:hover {
		background-color: #f5f5f5;
	}

	#tracker-list li .issueHandle {
		background-image: url("../images/newskin/action/dragbar-dark.png");
		background-color: #d1d1d1;
		width: 5px;
		height: 19px;
		background-repeat: no-repeat;
		display: inline-block;
		padding: 5px;
	    background-position: center;
	    margin-left: -7px;
	    margin-top: -10px;
	    margin-bottom: -10px;
	}

</style>

<wysiwyg:froalaConfig />

<ui:actionMenuBar>
	<ui:pageTitle><spring:message code="sysadmin.serviceDesk.config.label" text="Service Desk Configuration" /></ui:pageTitle>
</ui:actionMenuBar>

<form:form commandName="command">
	<form:hidden path="trackerOrder" id="trackerOrder"/>
	<ui:actionBar>
		<spring:message var="applyButton" code="button.save" text="Save" />
		<input type="submit" class="button" onclick="return submitServiceDeskForm();" value="${applyButton}" />

		<c:url value="/servicedesk/serviceDesk.spr" var="serviceDeskUrl"/>
		<spring:message code="tracker.serviceDesk.open.label" var="openLabel" text="Open Service Desk"/>
		<a href="${serviceDeskUrl}" class="button" title="${openLabel}" target="_blank">${openLabel }</a>

		<c:url var="cancelUrl" value="/sysadmin.do"/>
		<spring:message code="button.cancel" text="Cancel" var="cancelLabel"/>
		<input type="button" class="button cancelButton" value="${cancelLabel}" onclick="location.href = '${cancelUrl}';"/>

	</ui:actionBar>

	<form:errors cssClass="error" path="description"></form:errors>
	<form:errors cssClass="error" path="title"></form:errors>

	<c:if test="${licenseDisabled}">
		<div class="warning">
			<spring:message code="sysadmin.serviceDesk.no.license.warning" text="You cannot use this feature because you don't have the necessary license. To read more about this feature visit our <a href='https://codebeamer.com/cb/wiki/635003'>Knowledge base</a>."></spring:message>
		</div>
	</c:if>

	<table border="0" width="100%" cellpadding="2" class="formTableWithSpacing">
		<tr>
			<td class="optional"><spring:message code="sysadmin.serviceDesk.enabled.label" text="Enable service desk"/>:</td>
			<td><form:checkbox path="enabled"/></td>
		</tr>
		<tr>
			<td class="optional"><spring:message code="tracker.serviceDesk.field.title.label" text="Title"/>:</td>
			<td>
				<spring:message code="sysadmin.serviceDesk.title.tooltip" var="titleTooltip" text="The title that will be shown on the top of the service desk page"></spring:message>
				<form:input path="title" title="${titleTooltip }" size="80"/>
			</td>
		</tr>
		<tr>
			<td class="optional"><spring:message code="tracker.serviceDesk.description.title.label" text="Description"/>:</td>
			<td class="expandTextArea">
				<spring:message code="sysadmin.serviceDesk.description.tooltip" var="descriptionTooltip" text="The description of the service  desk that will be shown on the to of the page"></spring:message>
				<wysiwyg:editor editorId="serviceDeskDescriptionArea" useAutoResize="false" focus="true" height="200" uploadConversationId="" overlayHeaderKey="wysiwyg.service.desk.configuration.overlay.header">
				    <form:textarea path="description" id="serviceDeskDescriptionArea" rows="10" cols="120" title="${descriptionTooltip }" autocomplete="off" />
				</wysiwyg:editor>
			</td>
		</tr>
		<tr>
			<td class="optional">Tracker Order:</td>
			<td>
				<div class="hint">
					<spring:message code="sysadmin.serviceDesk.tracker.order.hint" text="You can change the order in which the trackers are shown on the service desk page. Set up the order of the trackers with Drag and Drop and"/>
				</div>
				<ul id="tracker-list">
					<spring:message code="cmdb.version.stats.drag.drop.hint" text="You can reorder items using drag-and-drop!" var="title"></spring:message>
					<c:forEach items="${trackers }" var="tracker">
						<li  data-id="${tracker.id }" title="${title }">
							<div class="issueHandle"></div>
							<c:url value="${tracker.urlLink }" var="trackerUrl"></c:url>
							<a href="${trackerUrl }" target="_blank"><c:out value="${tracker.project.name }"/> - <c:out value="${tracker.name }"/></a>
						</li>
					</c:forEach>
				</ul>
			</td>
		</tr>
	</table>
</form:form>

<script type="text/javascript">
	function submitServiceDeskForm() {
		var ids = [];
		$("#tracker-list li").each(function () {
			ids.push($(this).data("id"));
		});

		$("#trackerOrder").val(ids.join(","));

		return true;
	}

	$(function() {
	    $("#tracker-list").sortable();
	    $("#tracker-list").disableSelection();
	  });
</script>


