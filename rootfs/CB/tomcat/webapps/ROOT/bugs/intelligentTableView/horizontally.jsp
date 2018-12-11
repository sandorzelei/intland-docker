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

<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>

<script src="<ui:urlversioned value='/js/intelligentTableView.js'/>"></script>
<script src="<ui:urlversioned value='/js/displaytagTrackerItemsInlineEdit.js'/>"></script>

<textarea hidden="hidden" id="intelligentTableViewConfiguration" ><c:out value="${existingConfiguration}"/></textarea>

<table class="trackerItems displaytag inlineEditEnabled">
	<thead>
		<tr class="levelHeaderTr">
			<c:forEach var="levelHeaderCell" items="${levelHeaderCells}">
				<c:choose>
					<c:when test="${not empty levelHeaderCell.label}">
						<th class="levelHeaderCell" colspan="${levelHeaderCell.colspan}"><c:out value="${levelHeaderCell.label}"/></th>
					</c:when>
					<c:otherwise>
						<th class="levelHeaderCell referenceHeaderCell column-minwidth"></th>
					</c:otherwise>
				</c:choose>
			</c:forEach>
		</tr>
		<tr>
			<c:forEach var="headerCell" items="${headerCells}">
				<c:choose>
					<c:when test="${not empty headerCell.field}">
						<th class="${headerCell.field.id == 3 ? 'textSummaryData' : 'textData column-minwidth'}"
							data-level="${headerCell.level}" data-fieldlayoutid="${headerCell.field.id}"
							data-fieldlayoutname="${headerCell.field.name}" data-iscustom="${headerCell.field.isUserDefined()}"
							data-customfieldtrackerid="${headerCell.customFieldTrackerId}"
							data-entityIds="${headerCell.getEntityIdList()}">
							<c:choose>
								<c:when test="${headerCell.field.id == 2}">P</c:when>
								<c:otherwise><c:out value="${headerCell.label}"/></c:otherwise>
							</c:choose>
							<span class="tracker-context-menu action-column-minwidth">
								<img class="menuArrowDown menu-trigger" src="${contextPath}/images/space.gif"/>
								<span class="menu-container"></span>
							</span>
							<c:if test="${headerCell.field.id ne 3}">
								<span class="removeColumn" title="<spring:message code="queries.contextmenu.removecolumn"/>"></span>
							</c:if>
						</th>
					</c:when>
					<c:otherwise>
						<th class="referenceHeaderCell column-minwidth"></th>
					</c:otherwise>
				</c:choose>
			</c:forEach>
		</tr>
	</thead>
	<tbody>
	<c:forEach var="row" items="${rows}">
		<tr class="odd">
			<c:forEach var="cell" items="${row.cells}">
				<c:if test="${cell.firstCellOnLevel}">
					<td class="referenceType column-minwidth" rowspan="${cell.rowSpan}">
						<c:if test="${cell.upstream}"><span title="<spring:message code="intelligent.table.view.upstream.label"/>">»</span></c:if>
						<c:if test="${cell.downstream}"><span title="<spring:message code="intelligent.table.view.downstream.label"/>">«</span></c:if>
					</td>
				</c:if>
				<td data-level="${cell.level}" data-field-id="${not empty cell.field ? cell.field.id : 'null'}" data-item-id="${not empty cell.item ? cell.item.id : 'null'}" rowspan="${cell.rowSpan}" class="${cell.field.styleClass} ${not empty cell.field ? 'fieldColumn fieldId_' : ''}${not empty cell.field ? cell.field.id : ''} ${not empty cell.field || cell.field.id ne 3 ? ' column-minwidth' : ''}">
					<c:if test="${not empty cell.item}">${cell.value}</c:if>
					<c:if test="${cell.limitWarningNode}">
						<spring:message code="tracker.traceability.browser.limit.reached.label"/>
					</c:if>
				</td>
			</c:forEach>
		</tr>
	</c:forEach>
	</tbody>
</table>

<jsp:include page="pagebanner.jsp"/>

<script type="text/javascript">
	$(function() {
		codebeamer.IntelligentTableView.initInlineEdit();
	});
</script>