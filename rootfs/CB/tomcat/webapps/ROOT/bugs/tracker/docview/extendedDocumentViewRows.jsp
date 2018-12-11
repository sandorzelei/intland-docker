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
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>


<%@ page import="com.intland.codebeamer.persistence.util.TrackerItemFieldHandler" %>
<%@ page import="com.intland.codebeamer.persistence.dto.TrackerItemRevisionDto"%>
<%@ page import="com.intland.codebeamer.controller.ControllerUtils" %>
<%@ page import="com.intland.codebeamer.persistence.dto.TrackerItemRevisionDto"%>
<%@ page import="com.intland.codebeamer.persistence.dto.TrackerLayoutLabelDto"%>

	<jsp:useBean id="decorated" beanName="decorated" scope="request" type="com.intland.codebeamer.ui.view.table.TrackerSimpleLayoutDecorator" />

<%
	TrackerItemFieldHandler fieldHandler =  TrackerItemFieldHandler.getInstance(ControllerUtils.getCurrentUser(request));
%>

<%
	pageContext.setAttribute("NAME_LABEL_ID", Integer.valueOf(TrackerLayoutLabelDto.NAME_LABEL_ID));
%>


<c:forEach items="${paragraphs}" var="par" varStatus="loopStatus">


	<c:set var="paragraph" value="${par }" scope="request"/>
	<c:choose>
		<c:when test="${loopStatus.last}">
			<c:set var="dataAttribute" value='data-matching-ids="${matchingIds }" data-hasmore-before="${par.value.id != firstItem.value.id}" data-hasmore-after="${par.value.id != lastItem.value.id}"' scope="request"/>
		</c:when>
		<c:when test="${loopStatus.first }">
			<c:set var="dataAttribute" value='data-hasmore-before="${par.value.id != firstItem.value.id}" data-hasmore-after="${par.value.id != lastItem.value.id}" data-valueid="${firstItem.value.id }"' scope="request"/>
		</c:when>
		<c:otherwise>
			<c:set var="dataAttribute" value='data-hasmore-before="true" data-hasmore-after="true"' scope="request"/>
		</c:otherwise>
	</c:choose>

	<c:set var="item" value="${par.value }"/>
	<c:set var="addUpdateTaskForm" scope="request" value="${addUpdateTaskForms[item] }"/>

	<jsp:useBean id="item" beanName="item" type="com.intland.codebeamer.persistence.dto.TrackerItemDto" />
	<jsp:useBean id="addUpdateTaskForm" beanName="addUpdateTaskForm" scope="request" type="com.intland.codebeamer.servlet.bugs.AddUpdateTaskForm" />

	<%
		decorated.initRow(new TrackerItemRevisionDto(addUpdateTaskForm.getTrackerItem(), addUpdateTaskForm.getTrackerItem().getVersion(), null), 0, 0);
	%>

	<c:set var="editableAtAll" value="<%= fieldHandler.isEditable(item) %>"/>
	<c:set var="issueIsEditable" value="${(empty canEdit || canEdit) && editableAtAll}" />
 	<c:set var="thisSummaryEditable" value="${issueIsEditable && summaryEditable[item] && !locked[item]}" />
 	<c:set var="thisDescriptionEditable" value="${issueIsEditable && descriptionEditable[item] && !locked[item]}" />

	<tr class="requirementTr jstree-drop trackerItem ${not empty dirtyItems[item.id] ? 'dirty' : '' }" id="${item.id}"
		${dataAttribute} data-tracker-id="${tracker.id }" data-version="${item.version }">
		<%-- <td class="control-bar ${compactMode ? 'compact' : '' }"></td>--%>

		<td class="control-bar ${compactMode ? 'compact' : '' }"<c:if test="${resizeableColumns}"> style="width: 30px"</c:if>>
			<c:set var="item" value="${item }" scope="request"></c:set>
			<jsp:include page="documentViewControlButtons.jsp"/>
		</td>
		<c:forEach items="${selectedFields }" var="field" varStatus="loopStatus">
			<c:set var="fieldEditable" value="${decorated.isFieldEditable(field.id) }"/>
			<c:set var="percentageStyle">
				<c:if test="${resizeableColumns}"> style="width: ${fieldWidths.get(loopStatus.index)}%"</c:if>
			</c:set>

			<c:choose>
				<c:when test="${field.id == NAME_LABEL_ID }">

					<td class="description-field" ${percentageStyle}>
						<h${paragraph.key.level} class="name ${item.name != null ? '' : 'empty-name'}" data-issueid="${item.id }" issueid="${item.id }">
							<c:if test="${showParagraphId }">
								<span class="releaseid"><c:out value="${paragraph.key.release}" escapeXml="false"/></span>
							</c:if>
							<%-- always display the summary --%>
							<c:choose>
								<c:when test="${decorated.nameVisible}">
									<c:choose>
										<c:when test="${thisSummaryEditable }">
											<div class="editable field-editor summary-editor">
												<c:set var="summary" value="${addUpdateTaskForm.trackerItem.name }"/>

												<form class="field-editor-form">
													<input name="summary" class="expandText" value="<c:out value="${summary}"/>"/>
												</form>
											</div>
										</c:when>
										<c:otherwise>
											<div class="summary-editor field-editor">
												<c:out value="${item.name }"></c:out>
											</div>
										</c:otherwise>
									</c:choose>

								</c:when>
								<c:otherwise>
									<a class="noAccessPermsWarn" style="text-decoration: none"
										title="<spring:message code="reference.field.read.permission" text="At this time you have no permission to read this field."/>">
										<spring:message code="tracker.view.layout.document.summary.not.readable" text="[Summary not readable]"/>
									</a>
								</c:otherwise>
							</c:choose>
						</h${paragraph.key.level}>
						<div class="error-container">

						</div>
						<div class="field-editor">
							<form class="field-editor-form">
								<input type="hidden" id="description-editor-${item.id }" />
							</form>
						</div>
						<div class="field-editor editor-wrapper ${thisDescriptionEditable ? 'highlight-on-hover' : ''}"
							data-field-id="${field.id }" data-task-id="${item.id }"
							data-conversation-id="${fieldEditable ? addUpdateTaskForms[item].uploadConversationId : '' }" id="field-${item.id}-description"
							data-editor-mode="wysiwyg">

							<c:choose>
								<c:when test="${not empty editedDescriptions[item] }">
									${editedDescriptions[item] } <%-- renders the description restored from the local storage if available --%>
								</c:when>
								<c:otherwise>
									<c:choose>
										<c:when test="${thisDescriptionEditable }">
											<%-- when the description is editable use this special rendering --%>
											${decorated.getDescriptionForWysiwyg() }
										</c:when>
										<c:otherwise>
											${decorated.getDescription() }
										</c:otherwise>
									</c:choose>

								</c:otherwise>
							</c:choose>
						</div>
					</td>
				</c:when>
				<c:otherwise>
					<c:choose>
						<c:when test="${!resizeableColumns}">
							<c:set var="extraClass" value="column-minwidth"/>
						</c:when>
						<c:otherwise>
							<c:set var="extraClass" value="${field.id eq ID_LABEL_ID ? 'idColumn' : ''}${field.table ? ' tableField' : ''} fieldColumn fieldId_${field.id}"/>
						</c:otherwise>
					</c:choose>
					<td class="${fieldEditable && issueIsEditable ? '' : 'read-only' } ${extraClass}" ${percentageStyle}>
						<c:set var="fieldEditable" value="${decorated.isFieldEditable(field.id) }"/>
						<div class="field-editor ${fieldEditable ? '' : 'read-only'}" data-field-id="${field.id }" data-task-id="${item.id }">
							<%-- ${decorated.getRenderValue(field.id) }--%>

							<c:set var="field" scope="request" value="${field }"></c:set>
							<c:set var="decorated" scope="request" value="${decorated}"/>
							<c:set var="task" scope="request" value="${item}"/>
							<c:set var="tracker" scope="request" value="${tracker}"/>
							<c:set var="disableEditing" scope="request" value="${!issueIsEditable}"/>
							<jsp:include page="fieldEditor.jsp?compoundId=true&extendedDocumentView=true"/>
						</div>
					</td>
				</c:otherwise>
			</c:choose>
		</c:forEach>
	</tr>

</c:forEach>