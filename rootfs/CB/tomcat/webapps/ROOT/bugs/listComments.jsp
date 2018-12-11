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
<meta name="moduleCSSClass" content="trackersModule newskin"/>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="taglib" prefix="tag" %>

<%@ page import="com.intland.codebeamer.persistence.dto.UserDto"%>
<%@ page import="com.intland.codebeamer.persistence.dao.impl.TrackerItemDaoImpl"%>
<%@ page import="com.intland.codebeamer.persistence.dto.TrackerItemDto"%>
<%@ page import="com.intland.codebeamer.ui.view.table.TrackerSimpleLayoutDecorator"%>
<%@ page import="com.intland.codebeamer.utils.Common"%>
<%@ page import="com.intland.codebeamer.persistence.dto.TrackerItemRevisionDto"%>

<c:set var="task_id" scope="request" value="${param.task_id}" />
<c:set var="version" scope="request" value="${param.version}" />

<%
	final Integer task_id = new Integer(pageContext.findAttribute("task_id").toString());
	final Object versionAsObject = pageContext.findAttribute("version");
	Integer version = null;
	if (versionAsObject != null) {
		version = Common.tryToCreateInteger(versionAsObject.toString());
	}

	UserDto user = (UserDto) request.getUserPrincipal();

	Object trackerItem;
	if (version != null) {
		trackerItem = TrackerItemDaoImpl.getInstance().findRevision(user, task_id, version);
	} else {
		trackerItem = TrackerItemDaoImpl.getInstance().findById(user, task_id);
	}

	request.setAttribute("trackerItem", trackerItem);

	TrackerSimpleLayoutDecorator decorator = new TrackerSimpleLayoutDecorator(request);
	decorator.initRow(trackerItem, 0, 0);

	request.setAttribute("decorated", decorator);
	request.setAttribute("itemAttachments", decorator.getAttachments(false));
%>

<ui:actionMenuBar>
	<tag:issueKeyAndId var="issueKeyAndId" dto="${trackerItem}"></tag:issueKeyAndId>
	<c:choose>
		<c:when test="${decorated.nameVisible}">
			<c:set var="itemName" value='${trackerItem.name}'/>
		</c:when>
		<c:otherwise>
			<c:set var="itemName" value='--'/>
		</c:otherwise>
	</c:choose>

	<ui:pageTitle>[${issueKeyAndId}] ${itemName}</ui:pageTitle>
</ui:actionMenuBar>
<div class="contentWithMargins" >
	<span class="titlenormal" style="margin-left:5px;">
		<ui:pageTitle><spring:message code="tracker.field.Attachments.label" text="Comments/Attachments"/></ui:pageTitle>
	</span>

	<jsp:include page="itemAttachments.jsp" flush="true" >
		<jsp:param name="showActionBar" value="false" />
	</jsp:include>
</div>
