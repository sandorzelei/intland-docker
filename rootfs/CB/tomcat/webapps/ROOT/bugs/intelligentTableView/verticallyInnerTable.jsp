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

<table class="trackerItems displaytag innerTable" style="margin-left: ${innerTableHeaderCell.level * 30}px">
	<thead>
	<tr>
		<c:forEach items="${headerCells.get(innerTableCell.level)}" var="headerCell">
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
					<th class="referenceHeaderCell column-minwidth">Level ${innerTableCell.level}</th>
				</c:otherwise>
			</c:choose>
		</c:forEach>
	</tr>
	</thead>
	<tbody>
	<c:forEach var="row" items="${innerTableCell.innerTable.rows}">
		<tr class="odd">
			<c:forEach var="cell" items="${row.cells}">
				<c:if test="${cell.firstCellOnLevel}">
					<td class="referenceType column-minwidth">
						<c:if test="${cell.upstream}"><span title="<spring:message code="intelligent.table.view.upstream.label"/>">»</span></c:if>
						<c:if test="${cell.downstream}"><span title="<spring:message code="intelligent.table.view.downstream.label"/>">«</span></c:if>
					</td>
				</c:if>
				<td colspan="${not empty cell.innerTable ? cell.colSpan + 1 : cell.colSpan}" data-level="${cell.level}"
					data-field-id="${not empty cell.field ? cell.field.id : 'null'}"
					data-item-id="${not empty cell.item ? cell.item.id : 'null'}"
					class="${cell.field.styleClass} ${not empty cell.innerTable ? 'withInnerTable' : ''} ${not empty cell.field ? 'fieldColumn fieldId_' : ''}${not empty cell.field ? cell.field.id : ''} ${not empty cell.field || cell.field.id ne 3 ? ' column-minwidth' : ''}">
					<c:if test="${not empty cell.item}">${cell.value}</c:if>
					<c:if test="${cell.limitWarningNode}">
						<spring:message code="tracker.traceability.browser.limit.reached.label"/>
					</c:if>
					<c:if test="${not empty cell.innerTable}">
						<c:set var="innerTableCell" value="${cell}" scope="request"/>
						<jsp:include page="verticallyInnerTable.jsp"/>
					</c:if>
				</td>
			</c:forEach>
		</tr>
	</c:forEach>
	</tbody>
</table>