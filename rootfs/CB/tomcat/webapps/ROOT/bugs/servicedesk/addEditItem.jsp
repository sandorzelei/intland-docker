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
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="callTag" prefix="ct" %>
<%@ taglib uri="wysiwyg" prefix="wysiwyg" %>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>

<%@ page import="com.intland.codebeamer.persistence.dto.TrackerLayoutLabelDto"%>

<meta name="decorator" content="main"/>
<meta name="module" content="tracker"/>
<meta name="moduleCSSClass" content="newskin trackersModule"/>

<%
	pageContext.setAttribute("NAME_LABEL_ID", Integer.valueOf(TrackerLayoutLabelDto.NAME_LABEL_ID));
	pageContext.setAttribute("DESCRIPTION_LABEL_ID", Integer.valueOf(TrackerLayoutLabelDto.DESCRIPTION_LABEL_ID));
	pageContext.setAttribute("DESCRIPTION_FORMAT_ID", Integer.valueOf(TrackerLayoutLabelDto.DESCRIPTION_FORMAT_ID));
%>

<link rel="stylesheet" href="<ui:urlversioned value="/bugs/servicedesk/serviceDesk.less" />" type="text/css" media="all" />
<script type="text/javascript" src="<ui:urlversioned value='/bugs/tracker/includes/embeddedTable.js'/>"></script>

<ui:actionMenuBar>
	<jsp:body>
		<c:url var="serviceDeskUrl" value="/servicedesk/serviceDesk.spr"/>
		<spring:message code="${serviceDeskTitle}" var="title"/>
		<a href="${serviceDeskUrl}" title="${title}">${title}</a><span class='breadcrumbs-separator'>&raquo;</span>
		<c:url var="trackerUrl" value="${tracker.urlLink }"/>
		<span><a href="${trackerUrl}">${trackerTitle}</a></span>
	</jsp:body>
</ui:actionMenuBar>

<form:form commandName="addUpdateTaskForm">
	<div class="actionBar">
		<spring:message var="buttonSave" code="button.save"/>
		<form:button class="button">${buttonSave}</form:button>

		<c:url value="/servicedesk/serviceDesk.spr" var="cancelUrl"/>
		<spring:message code="Cancel" text="Cancel" var="cancelLabel"/>
		<a href="${cancelUrl}" title="${cancelLabel }">${cancelLabel }</a>
	</div>

	<div class="contentWithMargins service-desk-add-task">
		<ui:globalMessages/>

		<c:choose>
			<c:when test="${trackerSettings.imageId != null}">
				<div class="left-aligned tracker-icon-edit">
					<c:url var="iconUrl" value="/displayDocument">
						<c:param name="doc_id" value="${trackerSettings.imageId}"></c:param>
					</c:url>
					<img src="${iconUrl}" class="icon-img" style="background-color:${trackerSettings.colorCode};"/>
				</div>
			</c:when>
			<c:otherwise>
				<div class="tracker-icon-edit">
					<ui:letterIcon elementId="${tracker_id}"
						elementName="${trackerTitle}"
						color="${trackerSettings.colorCode}" />
				</div>
			</c:otherwise>
		</c:choose>

		<div class="tracker-title">${trackerTitle}</div>
		<div class="large-title larger gap"><spring:message code="tracker.serviceDesk.${addUpdateTaskForm.trackerItem.id == null ? 'submit' : 'update'}.request.label"/></div>
		<c:set var="fieldLayout" value="${addUpdateTaskForm.layoutField[NAME_LABEL_ID]}" />
		<c:if test="${!empty fieldLayout.label}">
			<c:set var="disabled" value="${!addUpdateTaskForm.editable[NAME_LABEL_ID]}" />
			<c:if test="${!(disabled and empty task_id)}">
				<%-- Summary field (e.g. issue name) --%>
				<c:set var="cssClasses" value="fieldInputControl ${labelStyle} ${extraClass}" />
				<div class="field-label  ${fieldLayout.required != null && fieldLayout.required ? 'required': ''}">
					<c:choose>
						<c:when test="${fieldSettings[NAME_LABEL_ID] != null && fieldSettings[NAME_LABEL_ID].label != null}">
							<spring:message code="${fieldSettings[NAME_LABEL_ID].label}" text="${fieldSettings[NAME_LABEL_ID].label}" htmlEscape="true"/>
						</c:when>
						<c:otherwise>
							<spring:message code="tracker.field.${fieldLayout.label}.label" text="${fieldLayout.label}"/>
						</c:otherwise>
					</c:choose>
				</div>
				<div class="field-value">
					<form:input id="summary" disabled="${disabled}" path="summary" maxlength="254" size="80" tabindex="0" cssClass="expandText"/>
				</div>
				<c:if test="${fieldSettings[NAME_LABEL_ID] != null && fieldSettings[NAME_LABEL_ID].description != null}">
					<span class="field-description">
						<spring:message code="${fieldSettings[NAME_LABEL_ID].description}" text="${fieldSettings[NAME_LABEL_ID].description}" htmlEscape="true"/>
					</span>
				</c:if>
			</c:if>
		</c:if>

		<c:forEach items="${addUpdateTaskForm.layoutList}" var="fieldLayout">
			<c:set var="required" value="${fieldLayout.required != null && fieldLayout.required }"/>
			<c:if test="${fieldLayout.id != NAME_LABEL_ID && fieldLayout.id != DESCRIPTION_LABEL_ID &&
				(required ||
				 (fieldSettings[fieldLayout.id] != null && (fieldSettings[fieldLayout.id].label != null || fieldSettings[fieldLayout.id].description != null))) }">
				<div class="field-label ${required ? 'required' : '' }">
					<c:choose>
						<c:when test="${fieldSettings[fieldLayout.id] != null && fieldSettings[fieldLayout.id].label != null}">
							<spring:message code="${fieldSettings[fieldLayout.id].label}" text="${fieldSettings[fieldLayout.id].label}" htmlEscape="true"/>
						</c:when>
						<c:otherwise>
							<spring:message code="tracker.field.${fieldLayout.label}.label" text="${fieldLayout.label}"/>
						</c:otherwise>
					</c:choose>
				</div>
				<div class="field-value">
					<c:set var="layout_addUpdateTaskForm" value="${addUpdateTaskForm}" scope="request" />
					<c:set var="layout_decorator" value="${decorator}" scope="request" />
					<c:set var="layout_fieldLayout" value="${fieldLayout}" scope="request" />
					<c:set var="layout_tracker_id" value="${tracker_id}" scope="request" />
					<jsp:include page="/bugs/includes/singleItemField.jsp" />
				</div>
				<c:if test="${fieldSettings[fieldLayout.id] != null && fieldSettings[fieldLayout.id].description != null}">
					<span class="field-description">
						<spring:message code="${fieldSettings[fieldLayout.id].description}" text="${fieldSettings[fieldLayout.id].description}" htmlEscape="true"/>
					</span>
				</c:if>
			</c:if>
		</c:forEach>

		<c:set var="fieldLayout" value="${addUpdateTaskForm.layoutField[DESCRIPTION_LABEL_ID]}" />
		<c:if test="${!empty fieldLayout.label}">
			<div class="field-label ${fieldLayout.required != null && fieldLayout.required ? 'required': ''}">
				<c:choose>
					<c:when test="${fieldSettings[DESCRIPTION_LABEL_ID] != null && fieldSettings[DESCRIPTION_LABEL_ID].label != null}">
						<spring:message code="${fieldSettings[DESCRIPTION_LABEL_ID].label}" text="${fieldSettings[DESCRIPTION_LABEL_ID].label}" htmlEscape="true"/>
					</c:when>
					<c:otherwise>
						<spring:message code="tracker.field.${fieldLayout.label}.label" text="${fieldLayout.label}"/>
					</c:otherwise>
				</c:choose>
			</div>
			<div class="field-value">
				<c:set var="disabled" value="${!addUpdateTaskForm.editable[DESCRIPTION_LABEL_ID]}" />
				<c:if test="${!(disabled and empty task_id)}">
					<div id="descriptionField">
						<div id="descriptionCell" class="${extraClass}">
							<c:choose>
								<c:when test="${disabled}">
									<div class="descriptionBox scrollable">
										${decorator.description}
									</div>
								</c:when>
								<c:otherwise>
								    <wysiwyg:froalaConfig />
                                    <c:set var="descFormat" value="${addUpdateTaskForm.layoutField[DESCRIPTION_FORMAT_ID]}" />
                                    <c:set var="format_disabled" value="${!addUpdateTaskForm.editable[DESCRIPTION_FORMAT_ID]}" />
									<wysiwyg:editor editorId="editor" entity="${trackerItem}" uploadConversationId="${addUpdateTaskForm.uploadConversationId}" heightMin="400" toolbarSticky="true" useAutoResize="true"
									    insertNonImageAttachments="true" formatSelectorSpringPath="${empty descFormat ? '' : 'descriptionFormat'}" formatSelectorDisabled="${format_disabled}"
									    overlayHeaderKey="${isNew ? 'wysiwyg.new.service.desk.item.overlay.header' : ''}" >

									    <form:textarea disabled="${disabled}" path="details" rows="14" cols="80" id="editor" autocomplete="off" />
									</wysiwyg:editor>
								</c:otherwise>
							</c:choose>
						</div>
					</div>
				</c:if>
			</div>
			<c:if test="${fieldSettings[DESCRIPTION_LABEL_ID] != null && fieldSettings[DESCRIPTION_LABEL_ID].description != null}">
				<span class="field-description">
					<spring:message code="${fieldSettings[DESCRIPTION_LABEL_ID].description}" text="${fieldSettings[DESCRIPTION_LABEL_ID].description}"  htmlEscape="true"/>
				</span>
			</c:if>
		</c:if>
	</div>
</form:form>

