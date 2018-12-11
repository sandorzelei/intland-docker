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
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="taglib" prefix="tag" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>

<%@ page import="com.intland.codebeamer.taglib.TableCellCounter"%>
<%@ page import="com.intland.codebeamer.persistence.util.TrackerItemFieldHandler" %>
<%@ page import="com.intland.codebeamer.controller.ControllerUtils" %>
<%@ page import="com.intland.codebeamer.persistence.dto.TrackerItemRevisionDto"%>
<%@ page import="com.intland.codebeamer.persistence.dto.TrackerItemDto"%>
<%@ page import="com.intland.codebeamer.ui.view.table.TrackerSimpleLayoutDecorator" %>

<meta name="decorator" content="popup"/>

<style type="text/css">
	.itemDescription {
		width: 540px;
		height: 140px;
		overflow: auto;
		margin-bottom: 10px;
	}
</style>

<spring:message var="editLabel" code="action.edit.label" text="Edit"/>
<c:url value="${issue.updateUrlLink}" var="editUrl"/>
<c:url value="${issue.urlLink}" var="viewUrl"/>
<div style="padding-top:10px;">
	<a href="${viewUrl}" class="breadcrumbs"><c:out value='${issue.name}'/></a><a href="${editUrl}" style="float:right;">${editLabel}</a>
</div>
<table border="0">
	<tr>
		<td>
			<%
				TrackerSimpleLayoutDecorator decorated = new TrackerSimpleLayoutDecorator(request);
				TableCellCounter tableCellCounter = new TableCellCounter(out, pageContext, 2, 2);
				decorated.initRow(new TrackerItemRevisionDto((TrackerItemDto) request.getAttribute("issue"), null, null), 0, 0);
				TrackerItemFieldHandler fieldHandler =  TrackerItemFieldHandler.getInstance(ControllerUtils.getCurrentUser(request));
			%>
			<div class="attributes">
			<table class="propertyEditor" border="0" cellspacing="0" cellpadding="0">
				<c:forEach items="${layoutList}" var="field">
					<jsp:useBean id="field" beanName="field" type="com.intland.codebeamer.persistence.dto.TrackerLayoutLabelDto" />
					<spring:message var="label" code="tracker.field.${field.labelWithoutBR}.label" text="${field.labelWithoutBR}"/>

					<c:set var="breakRow" value="${field.breakRow}" />
					<c:set var="colspan"  value="${field.colspan}" />
					<c:set var="xcolspan" value="${empty colspan or colspan < 1 ? 1 : colspan}" />

					<c:if test="${colspan gt 1}">
						<c:set var="xcolspan" value="${colspan * 2 - 1}" />
					</c:if>

					<c:choose>
						<%-- choice fields, user defined fields, status, priority, startDate, endDate --%>
						<c:when test="${field.choiceField or field.userDefined or field.id eq 2 or (field.id ge 7 and field.id le 12)}">
							<% tableCellCounter.insertNewRow(); %>

							<td class="tableItem optional"><c:out escapeXml="false" value="${label}" />:</td>
							<td class="tableItem" colspan="${xcolspan}">
								<c:out escapeXml="false" value="<%= decorated.getRenderValue(field) %>" default="--" />
							</td>
						</c:when>

						<%-- Submitted by --%>
						<c:when test="${field.id eq 6}">
							<% tableCellCounter.insertNewRow(); %>
							<td class="tableItem optional"><c:out value="${label}" escapeXml="false" />:</td>
							<td class="tableItem">
								<tag:userLink user_id="${issue.submitter.id}" />
								<tag:formatDate value="${issue.submittedAt}" />
							</td>
						</c:when>

						<%-- Modified by --%>
						<c:when test="${field.id eq 75}">
							<% tableCellCounter.insertNewRow();	%>
							<td class="tableItem optional"><c:out value="${label}" escapeXml="false" />:</td>
							<td class="tableItem">
								<tag:userLink user_id="${issue.modifier.id}" />
								<tag:formatDate value="${issue.modifiedAt}" />
							</td>
						</c:when>
					</c:choose>
				</c:forEach>

				<% tableCellCounter.finishRow(); %>
			</table>
			</div>
		</td>
	</tr>
	<tr>
		<td>
			<div id="itemDescription" class="itemDescription">
				<%--<tag:transformText value="${issue.description}" format="${issue.descriptionFormat}" />--%>
				<% out.write(decorated.getDescription()); %>
			</div>
		</td>
	</tr>
</table>