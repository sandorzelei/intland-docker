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
<meta name="bodyCSSClass" content="newskin" />

<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="uitaglib" prefix="ui" %>

<link rel="stylesheet" href="<ui:urlversioned value='/stylesheet/treeSettings.less' />" type="text/css" media="all" />

<c:url var="actionUrl" value="/trackers/updateTreeConfig.spr">
	<c:param name="revision"><c:out value='${revision}'/></c:param>
</c:url>
<form:form action="${actionUrl}" method="POST">
	<input type="hidden" value="<c:out value='${trackerId}'/>" name="trackerId"/>
	<input type="hidden" value="<c:out value='${viewId}'/>" name="view_id"/>

	<c:if test="${not empty param.openEditableView}">
		<input type="hidden" value="<c:out value='${param.openEditableView}'/>" name="openEditableView"/>
	</c:if>

	<ui:actionMenuBar>
		<spring:message code="tracker.tree.settings.title" />
	</ui:actionMenuBar>

	<ui:actionBar>
		<spring:message var="buttonTitle" code="button.save" text="Save"/>
		<spring:message var="cancelTitle" code="button.cancel" text="Cancel"/>
		<input type="submit" class="button" title="${buttonTitle}" value="${buttonTitle}" name="submit" />&nbsp;
		<input type="button" class="button cancelButton" title="${cancelTitle}" value="${cancelTitle}" onclick="closePopupInline();" />
	</ui:actionBar>

	<div class="contentWithMargins">
		<div class="fields-container">
			<span class="group-header"><spring:message code="tracker.tree.show" text="Show"/></span>
			<label for="showIds">
				<form:checkbox path="showIds" id="showIds"/>
				<spring:message code="tracker.tree.showIds" text="Work item IDs"/>
			</label>
			<label for="showNumbering">
				<form:checkbox path="showNumbering" id="showNumbering"/>
				<spring:message code="tracker.tree.showNumbering" text="Numbering"/>
			</label>
			<label for="markSuspectedLinks">
				<form:checkbox path="markSuspectedLinks" id="markSuspectedLinks"/>
				<spring:message code="tracker.tree.markSuspected" text="Mark Work items with suspected links"/>
			</label>
			<label for="markUnresolvedDependencies">
				<form:checkbox path="markUnresolvedDependencies" id="markUnresolvedDependencies"/>
				<spring:message code="tracker.tree.mark.unresolved.dependencies.label" text="Mark Work items with unresolved dependencies"/>
			</label>
			<label for="showOnlyOpen">
				<form:checkbox path="showOnlyOpen" id="showOnlyOpen"/>
				<spring:message code="tracker.tree.showOnlyOpen" text="Only the open Work items"/>
			</label>
			<label for="enableRating">
				<form:checkbox path="enableRating" id="enableRating"/>
				<spring:message code="tracker.tree.enableRating" text="Add Review / Rating option"/>
			</label>

			<label for="showCounts">
				<form:checkbox path="showCounts" id="showCounts"/>
				<spring:message code="tracker.tree.showCounts" text="Show Child Count"/>
			</label>

			<c:if test="${tracker.branch }">
				<label for="showBranchBadges">
					<form:checkbox path="showBranchBadges" id="showBranchBadges"/>
					<spring:message code="tracker.tree.showBranchBadges" text="Show branch badges"/>
				</label>
			</c:if>

			<label for="synchronizeTree">
				<form:checkbox path="synchronizeTree" id="synchronizeTree"/>
				<spring:message code="tracker.tree.synchronizeTree" text="Show branch badges"/>
			</label>
		</div>
		<div class="search-in">
			<span class="group-header"><spring:message code="search.scope.label" text="Search In"/></span>
			<label>
				<span class="explanation">
					<spring:message code="wiki.color.highlight.hint"
						text="The colored box after the checkbox shows the color used to highlight the item of that type in the tree"/>
				</span>
			</label>
			<label class="checkboxContainer disableTextSelection">
				<input name="searchInTitle" id="searchInTitle" type="checkbox"<c:if test="${searchInTitle}"> checked="checked"</c:if>>
				<spring:message code="tracker.tree.search.in.title" text="Work item Title"/>
				<span class="color-box title"></span>
			</label>
			<label class="checkboxContainer disableTextSelection">
				<input name="searchInDescription" id="searchInDescription" type="checkbox"<c:if test="${searchInDescription}"> checked="checked"</c:if>>
				<spring:message code="tracker.tree.search.in.description" text="Work item Description"/>
				<span class="color-box description"></span>
			</label>
			<label class="checkboxContainer disableTextSelection">
				<input name="searchInId" id="searchInId" type="checkbox"<c:if test="${searchInId}"> checked="checked"</c:if>>
				<spring:message code="tracker.tree.search.in.id" text="Work item Id"/>
				<span class="color-box id"></span>
			</label>
		</div>
	</div>
</form:form>

<script type="text/javascript">
	jQuery(function($) {
		var checkboxes = $('#searchInTitle, #searchInDescription, #searchInId');
		checkboxes.change(function() {
			var cb = $(this);
			var other = checkboxes.not(cb);
			if (!other.is(':checked')) {
				cb.prop('checked', true);
			}
		});
	});
</script>
