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

<ui:showErrors errors="${errors}"/>

<link rel="stylesheet" href="<ui:urlversioned value="/diff/diff.less" />" type="text/css" media="all" />

<div class="contentWithMargins">

	<spring:message code="diffTool.summaryStat" arguments="${diff.differenceCount},${diff.totalCount + 1}" />

	<span class="showDifferentOnlyContainer">
		<label>
			<input type="checkbox" class="showDifferentFieldsOnly" checked="checked">
			<spring:message code="diffTool.showDifferentFieldsOnly" text="Show different fields only" />
		</label>
	</span>

	<ui:globalMessages/>

	<c:set var="ignoreOmittedFields" scope="request" value="${param.showOmittedFields == 'true'}"/>

	<table class="diffTable">
		<c:set value="false" var="hideApplyAll" scope="request"/>
		<%@ include file="diffTableHeader.jsp"%>
		<tbody>
		<tr class="fixed-id different">
			<td class="copy label">ID</td>
			<td class="copy value">
			<span>
				<img class="issueIcon" style="background-color: ${copyIconBgColor}" src="${copyIconUrl}" alt="icon">
				<a class="issueLink" href="${pageContext.request.contextPath}${copy.urlLinkVersioned}">${copy.keyAndId}</a>
				<span class="referenceSettingBadge versionSettingBadge">v${copy.version}</span>
				<c:if test="${copy.modifiedAt != null }">
					<span class="subtext">
						<spring:message code="tracker.modified.label" text="Modified"/>:
						<tag:userLink user_id="${copy.modifier.id}"/>,
						<tag:formatDate value="${copy.modifiedAt}" />

					</span>
				</c:if>
			</span>
			</td>
			<td class="controls"></td>
			<td class="original label">ID</td>
			<td class="original value">
			<span>
				<img class="issueIcon" style="background-color: ${originalIconBgColor}" src="${originalIconUrl}" alt="icon">
				<c:set var="displayedOriginal" value="${originalRevision == null ? original : originalRevision}"/>
				<a class="issueLink" href="${pageContext.request.contextPath}${originalRevision == null ? original.urlLinkVersioned : originalRevision.urlLink}">${original.keyAndId}</a>
				<span class="referenceSettingBadge versionSettingBadge">v${displayedOriginal.version}</span>
				<c:if test="${displayedOriginal.modifiedAt != null }">
					<span class="subtext">
					<spring:message code="tracker.modified.label" text="Modified at"/>:
						<tag:userLink user_id="${original.modifier.id}"/>,
					<tag:formatDate value="${displayedOriginal.modifiedAt}" />
				</span>
				</c:if>
			</span>
			</td>
		</tr>

		<c:set var="diff" scope="request" value="${diff}"/>
		<c:set var="showOmittedFields" scope="request" value="false"/>
		<%@ include file="diffTableRows.jsp" %>
		</tbody>
	</table>

	<%-- show the fields that are not merged automatically in a separate box --%>
	<c:if test="${!ignoreOmittedFields and diff.hasOmittedFieldChanges()}">
		<div>
			<spring:message code="tracker.branching.merge.omitted.fields.label" text="Fields not merged automatically"
							var="omitedLabel"/>
			<ui:collapsingBorder label="${omitedLabel }" open="false" cssClass="scrollable">
				<span class="hint" style="margin-left: 5px; display: inline-block;">
					<spring:message code="tracker.branching.merge.omitted.fields.hint"/>
				</span>
				<%-- show the omited fields only --%>
				<table class="diffTable">
					<c:set value="true" var="hideApplyAll" scope="request"/>
					<%@ include file="diffTableHeader.jsp"%>

					<c:set var="showOmittedFields" scope="request" value="true"/>
					<c:set var="diff" scope="request" value="${diff}"/>
					<%@ include file="diffTableRows.jsp" %>
				</table>
			</ui:collapsingBorder>
		</div>
	</c:if>
</div>