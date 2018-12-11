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
<meta name="module" content="tracker"/>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="taglib" prefix="tag" %>
<%@ taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>

<style type="text/css">
	.dateData td {
		text-align: left;
	}
	td.textData {
		white-space: normal;
	}
	.diffTableWrapper {
		padding: 0 15px 15px 15px;
	}
	.diffTableWrapper > table {
		margin: 0 !important;
	}
	.showHideIcon {
		width: 9px;
		height: 9px;
		padding: 5px;
		background: url('../../images/plus.gif') no-repeat;
		display: inline-block;
	}
	.showHideIcon.open {
		background-image: url('../../images/minus.gif');
	}
	.showHideCheckbox {
		display: none;
	}
	.actionTablet,
	.trackerItemName {
		vertical-align: middle;
	}
	.trackerItemName img {
		display: inline-block;
		margin: 0 5px;
	}
	.trackerItemName img {
		vertical-align: text-bottom;
	}
</style>

<script type="text/javascript">
	function showHideModifications(checkbox, oldVersion, newVersion) {
		var itemId = checkbox.value;
		var itemDiff = document.getElementById('itemDiff_' + itemId);
		if (!checkbox.checked) {
			itemDiff.className = '';
			if ($('#itemDiff_' + itemId + ' > table').length == 0) {
				$('#itemDiff_' + itemId).load('<c:url value="/trackers/ajax/getTrackerItemDiff.spr"/>' + '?item_id=' + itemId + '&version1=' + oldVersion + '&version2=' + newVersion);
			}
		} else {
			itemDiff.className = 'invisible';
		}
	}

	jQuery(function($) {
		$(".showHideIcon").click(function() {
			$(this).toggleClass("open").siblings("input[type=checkbox]").click();
			return false;
		});
	});
</script>

<ui:actionMenuBar>
		<ui:breadcrumbs showProjects="false"><span class="breadcrumbs-separator">&raquo;</span>
		<ui:pageTitle>
		 	<spring:message code="baseline.diff.title" text="Compare baseline"/>
			<c:out value="${viewDiff.first.name}"/> --&gt;
			<c:out value="${viewDiff.second.name}"/>
		</ui:pageTitle>
		</ui:breadcrumbs>
</ui:actionMenuBar>

<spring:message var="showDiffTitle" code="document.modifications.show.title" text="Click to show/hide modifications" htmlEscape="true"/>

<%--
<ui:displaytagPaging defaultPageSize="50" items="${diffs}" excludedParams="page"/>
--%>

<%-- We need a dummy form because the function setAllStatesFrom() requires one  --%>
<form>
	<div class="diffTableWrapper">
		<display:table requestURI="" id="diff" name="${viewDiff.diffs}" cellpadding="0" sort="external" export="false" decorator="paragraphDiffDecorator" >

			<spring:message var="actionTitle" code="issue.history.action.label" text="Action"/>
			<display:column title="${actionTitle}" property="action" sortable="false" headerClass="textData" class="textData columnSeparator actionTablet"  style="width:5%"/>

			<display:column title="${viewDiff.first.name}" property="oldParagraph" sortable="false" headerClass="textData" class="textData columnSeparator trackerItemName" style="width:23%"/>

			<display:column title="${viewDiff.second.name}" property="newParagraph" sortable="false" headerClass="textData" class="textData columnSeparator trackerItemName"  style="width:23%"/>

			<c:if test="${showItemDiff}">
				<display:column title="" decorator="com.intland.codebeamer.ui.view.table.TrimmedColumnDecorator" media="html" headerClass="checkbox-column-minwidth" class="checkbox-column-minwidth">
					<c:if test="${!empty diff.oldRevision}">
						<a href="#" class="showHideIcon"></a>
						<input class="showHideCheckbox" type="checkbox" name="showItemDiff" checked value="${diff.id}" title="${showDiffTitle}" onclick="showHideModifications(this, ${diff.oldRevision.version}, ${diff.version});"/>
					</c:if>
				</display:column>

				<display:column headerClass="textData">
					<div id="itemDiff_${diff.id}">
						<%-- This is now loaded asynchronously and on demand via JQuery/Ajax
							<c:set var="itemHistory" value="${itemDiff[diff.id]}" scope="request"/>
							<c:if test="${!empty itemHistory}">
								<jsp:include page="/bugs/itemHistory.jsp" flush="true" />
							</c:if>
						--%>
					</div>
				</display:column>
			</c:if>
		</display:table>
	</div>
</form>
