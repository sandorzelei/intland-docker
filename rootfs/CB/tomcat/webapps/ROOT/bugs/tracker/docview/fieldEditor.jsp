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

<%--
	jsp fragment for inline editig of fields.
--%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%@ taglib uri="uitaglib" prefix="ui" %>

<%@ page import="com.intland.codebeamer.ui.view.table.TrackerSimpleLayoutDecorator"%>
<%@ page import="com.intland.codebeamer.persistence.dto.TrackerLayoutLabelDto"%>

<jsp:useBean id="addUpdateTaskForm" beanName="addUpdateTaskForm" scope="request" type="com.intland.codebeamer.servlet.bugs.AddUpdateTaskForm" />
<%
	TrackerSimpleLayoutDecorator decorator = new TrackerSimpleLayoutDecorator(request);
	pageContext.setAttribute("decorator", decorator);
	decorator.initRow(addUpdateTaskForm.getTrackerItem(), 0, 0);
%>

<%
	pageContext.setAttribute("DESCRIPTION_LABEL_ID", Integer.valueOf(TrackerLayoutLabelDto.DESCRIPTION_LABEL_ID));
%>

<c:set var="layout_addUpdateTaskForm" value="${addUpdateTaskForm}" scope="request" />
<c:set var="layout_decorator" value="${decorated}" scope="request" />
<c:set var="layout_fieldLayout" value="${field}" scope="request" />
<c:set var="layout_tracker_id" value="${tracker.id}" scope="request" />
<c:set var="layout_task_id" value="${task.id}" scope="request" />

<c:set var="compoundId" value="addUpdateTaskForm${not empty task ? task.id : '' }-${field.id }"/>
<form:form action="${actionUrl}" enctype="multipart/form-data" commandName="addUpdateTaskForm" method="POST" cssClass="ratingOnInlinedPopup
		field-editor-form ${field.required ? 'mandatory' : '' }" id="${param.compoundId ? compoundId : '' }">

	<jsp:include page="/bugs/includes/singleItemField.jsp?postfixItemId=true&extendedDocumentView=${param.extendedDocumentView ? 'true' : 'false' }" />
</form:form>