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
<%-- validation errors and explanations must follow actionBar --%>

<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="taglib" prefix="tag" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="taglib" prefix="tag" %>

<ui:showErrors errors="${errors}"/>

<link rel="stylesheet" href="<ui:urlversioned value="/diff/diff.less" />" type="text/css" media="all" />

<div class="contentWithMargins">

	<spring:message code="diffTool.summaryStat" arguments="${diff.differenceCount},${diff.totalCount}" />

	<span class="showDifferentOnlyContainer">
		<label>
			<c:choose>
				<c:when test="${diff.differenceCount > 0}">
					<input type="checkbox" class="showDifferentFieldsOnly" checked="checked">
				</c:when>
				<c:otherwise>
					<input type="checkbox" class="showDifferentFieldsOnly">
				</c:otherwise>
			</c:choose>
			<spring:message code="diffTool.showDifferentFieldsOnly" text="Show different fields only" />
		</label>
	</span>

	<ui:globalMessages/>

	<table class="diffTable">
		<thead>
		<tr class="sizer">
			<th class="label"></th>
			<th class="value"></th>
			<th class="controls"></th>
			<th class="label"></th>
			<th class="value"></th>
		</tr>
		<tr class="header">
			<th colspan="2">
				<spring:message code="tracker.configuration.history.plugin.revert.head" text="Head" var="headLabel"/>
				<c:out value="${diff.trackerLabel}" /><span class="subtext"> (<spring:message code="tracker.field.Version.label" text="Version"/>: <c:out value="${headLabel}" />, <spring:message code="tracker.modifiedAt.label" text="Modified At" />: <tag:formatDate value="${diff.trackerCreatedAt}" />)</span>
			</th>
			<th class="controls"><c:if test="${enabled and diff.differenceCount > 0}"><ui:applyCheckbox initialState="false" name="all" /></c:if></th>
			<th colspan="2">
				<c:out value="${diff.trackerLabel}" /><span class="subtext"> (<spring:message code="tracker.field.Version.label" text="Version"/>: <c:out value="${diff.trackerVersionNumber}"/>, <spring:message code="tracker.modifiedAt.label" text="Modified At" />: <tag:formatDate value="${diff.trackerVersionCreatedAt}" />)</span>
			</th>
		</tr>
		</thead>
		<tbody>
		<c:forEach items="${diff.fields}" var="field" varStatus="status">
			<c:if test="${field.readable}">
				<tr ${field.different ? 'class="different highlighted"' : ''} style="${field.different or diff.differenceCount == 0 ? '' : 'display:none;'}">
					<td class="copy label">
						<spring:message code="${field.headLabel}" />
					</td>
					<td class="copy value">
						<span>
							<c:out value="${field.headValue}" />
						</span>
					</td>
					<td class="controls">
						<c:if test="${field.different}">
							<c:set var="fieldId" value="${field.id}" />
							<c:if test="${enabled and diff.editable and field.editable}"><ui:applyCheckbox initialState="false" fieldId="${fieldId}" name="apply_${fieldId}" /></c:if>
							<c:if test="${diff.editable}">
								<c:if test="${not field.editable}">
									<spring:message code="issue.import.roundtrip.field.not.editable" text="Not editable"/>
								</c:if>
							</c:if>
						</c:if>
					</td>
					<td class="original label">
						<spring:message code="${field.versionLabel}" />
					</td>
					<td class="original value">
						<span>
							<c:out value="${field.versionValue}" />
						</span>
					</td>
				</tr>
			</c:if>
		</c:forEach>
		</tbody>
	</table>
</div>
