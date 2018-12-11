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
<%@page import="com.intland.codebeamer.ui.view.table.TrackerItemRevisionDecorator"%>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="taglib" prefix="tag" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>


<%
	request.setAttribute("historyDecorator", new TrackerItemRevisionDecorator(request));
%>

<link rel="stylesheet" href="<ui:urlversioned value='/stylesheet/itemHistoryTable.less' />" type="text/css" media="all" />
<script type="text/javascript" src="<ui:urlversioned value='/js/itemHistoryTable.js'/>"></script>
<script type="text/javascript">
	<c:if test="${not empty historyEntryVersionReferences}">
		$(document).ready(function() {
			var historyEntryVersionReferences = ${historyEntryVersionReferences};
			codebeamer.item.history.table.init(historyEntryVersionReferences);
		});
	</c:if>
</script>

<c:set var="latestVersion" value="${fn:length(itemHistory) > 0 ? itemHistory[0].version : 1}"/>
<c:set var="isHead" value="${latestVersion == currentHead.version}"/>

<%-- JSP fragment renders work-item's history table as displayed on the history tab --%>
<display:table excludedParams="orgDitchnetTabPaneId" class="expandTable"
		requestURI="${requestURI}"
		name="${itemHistory}" id="changeSet" cellpadding="0" sort="external" export="false"
		decorator="com.intland.codebeamer.ui.view.table.TrackerItemRevisionDecorator">

	<c:set var="extraClass" value="${fn:contains(originalHistory, changeSet) ? 'originalHistoryItem' : '' }"/>
	<%-- if the user can read this version --%>
	<c:set var="readableVersion" value="${historyWithPermissionCheck == null || historyWithPermissionCheck.contains(changeSet) }"></c:set>

	<display:column class="versionSelector">
		<c:if test="${readableVersion }">
			<input type="checkbox" name="selectedVersion" value="${changeSet.version}" data-item-id="${changeSet.id}"
				data-is-branch="${changeSet.id == task.id and task.branchItem }"/>
		</c:if>
	</display:column>

	<spring:message var="submittedTitle" code="issue.history.date.label" text="Submitted" />
	<display:column title="${submittedTitle}" headerClass="textData columnSeparator" class="${extraClass } textData columnSeparator">
		<ui:submission userId="${changeSet.submitter.id}" userName="${changeSet.submitter.name}" date="${changeSet.submittedAt}"/>
	</display:column>

	<c:set var="restored" value="${fn:contains(restoredRevisions, changeSet)}"/>
	<c:set var="deleted" value="${fn:contains(deletedRevisions, changeSet)}"/>
	<spring:message var="actionTitle" code="issue.history.action.label" text="Action" />

	<display:column title="${actionTitle}" headerClass="textData columnSeparator"
					class="${extraClass} textData columnSeparator actionDescriptionColumn">
		<c:choose>
			<c:when test="${restored}">
				<spring:message code="tracker.transition.Restore.label" text="Restore"/>
			</c:when>
			<c:when test="${deleted}">
				<spring:message code="tracker.transition.Delete.label" text="Delete"/>
			</c:when>
			<c:otherwise>
				<%
					((TrackerItemRevisionDecorator) request.getAttribute("historyDecorator")).initRow(changeSet, 0, 1);
				%>
				${historyDecorator.getTransition()}
			</c:otherwise>
		</c:choose>

	</display:column>

	<spring:message var="versionTitle" code="issue.version.label" text="Version" />
	<display:column title="${versionTitle}" property="version" headerClass="numberData columnSeparator" class="${extraClass } numberData versionColumn"/>

	<c:if test="${not changeSet.dto.tracker.testRun}">
		<spring:message var="revertLabel" code="issue.history.revert.label" text="Revert state of Field(s) back to this Version" />
		<display:column title="" decorator="com.intland.codebeamer.ui.view.table.TrimmedColumnDecorator" media="html"
			class="${extraClass} action-column-minwidth columnSeparator revertColumn">
				<c:if test="${isHead && changeSet.version != latestVersion && readableVersion}">
					<img class="action revert" title="${revertLabel}" data-item-id="${changeSet.id}" data-target-item-id="${task.branchItem ? task.id : changeSet.id}"
						 data-version="${changeSet.version}" data-head-version="${task.branchItem ? task.version : itemHistory[0].version}" data-editable="${canRevertItem}" src="<ui:urlversioned value="/images/newskin/item/baseline-s.png"/>">
				</c:if>
		</display:column>
	</c:if>

	<display:column headerClass="textData fieldChanges" class="${extraClass } ">
		<display:table name="${changeSet.changes}" id="item" cellpadding="0" sort="external" export="false"
					   decorator="com.intland.codebeamer.ui.view.table.TrackerItemHistoryAbbreviatedDecorator" class="itemChangesTable">
			<display:setProperty name="basic.show.header" value="${showHeaders}" />

			<spring:message var="emptyChangeSetMessage" code="issue.history.empty.row.label"/>
			<spring:message var="emptyChangeSetTitle" code="issue.history.empty.row.title"/>
			<c:set var="emptyRow">
				<tr class="empty">
					<td title="${emptyChangeSetTitle}" colspan="{0}">
						${emptyChangeSetMessage}
					</td>
				</tr>
			</c:set>

			<display:setProperty name="basic.msg.empty_list_row" value="${emptyRow}" />

			<spring:message var="fieldTitle" code="issue.history.field.label" text="Field" />
			<display:column title="${fieldTitle}" headerClass="textData" class="textData field" property="fieldName"/>

			<spring:message var="newValueTitle" code="issue.history.newValue.label" text="New Value" />
			<spring:message var="oldValueTitle" code="issue.history.oldValue.label" text="Old Value" />

			<c:choose>
				<c:when test="${swapOldAndNew}">
					<display:column title="${oldValueTitle}" headerClass="textData" class="textDataWrap oldValue" property="oldValue"/>
					<display:column title="${newValueTitle}" headerClass="textData" class="textDataWrap newValue" property="newValue"/>
				</c:when>
				<c:otherwise>
					<display:column title="${newValueTitle}" headerClass="textData" class="textDataWrap newValue" property="newValue"/>
					<display:column title="${oldValueTitle}" headerClass="textData" class="textDataWrap oldValue" property="oldValue"/>
				</c:otherwise>
			</c:choose>
		</display:table>

		<c:if test="${not readableVersion }">
			<spring:message code="issue.history.not.readable.version.title" var="notReadableTitle"
				text="You do not have permission to this version of the item. Probably the item was deleted in this version."/>
			<div class="smallWarning" title="${notReadableTitle }">
				<spring:message code="issue.history.not.readable.version.label" text="You do not have permission to this version of the item."/>
			</div>
		</c:if>

		<c:if test="${truncatedRevisionItems[changeSet.version] != null }">
			<%-- the list of changes for this item was truncated --%>
			<div class="warning">
				<spring:message code="issue.history.changes.truncated" arguments="${maximumChangesDisplayed },${maximumChangesDisplayed }"/>
			</div>
		</c:if>
	</display:column>
</display:table>
