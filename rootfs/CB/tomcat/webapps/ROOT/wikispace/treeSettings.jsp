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
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>

<meta name="decorator" content="popup"/>
<meta name="module" content="tracker"/>
<meta name="bodyCSSClass" content="newskin"/>

<link rel="stylesheet" href="<ui:urlversioned value='/stylesheet/treeSettings.less' />" type="text/css" media="all" />

<ui:actionMenuBar>
	<spring:message code="tracker.tree.settings.title"/>
</ui:actionMenuBar>

<form:form action="${pageContext.request.contextPath}/wikis/updateTreeConfig.spr" method="POST" modelAttribute="wikiSettings">

	<ui:actionBar>
		<spring:message var="buttonTitle" code="button.save" text="Save"/>
		<spring:message var="cancelTitle" code="button.cancel" text="Cancel"/>
		<input type="submit" class="button" title="${buttonTitle}" value="${buttonTitle}" name="submit"/>&nbsp;
		<input type="button" class="button cancelButton" title="${cancelTitle}" value="${cancelTitle}"
			   onclick="closePopupInline();"/>
	</ui:actionBar>

	<div class="contentWithMargins">
		<span class="group-header"><spring:message code="tracker.tree.settings.title" text="Settings"/></span>
		<div>
			<label class="title disableTextSelection">
				<spring:message code="wiki.recently.update.day.limit" text="Highlight recently updated Wiki pages. Day limit"/>:
				<form:input path="recentlyUpdatedDayCount" maxlength="3" size="3"/><br/>
				<span class="explanation">
					* <spring:message code="wiki.recently.update.day.limit.hint" text="Specify 0 or leave field blank to disable this feature."/>
				</span>
			</label>
			<label class="title disableTextSelection">
				<form:checkbox path="generateOutliners" id="generateOutliners" />
				<spring:message code="wiki.show.outliners" text="Show outliners"/>
			</label>
		</div>

		<span class="group-header"><spring:message code="search.scope.label" text="Search In"/></span>
		<label>
			<span class="explanation">
				<spring:message code="wiki.color.highlight.hint"
					text="The colored box after the checkbox shows the color used to highlight the item of that type in the tree"/>
			</span>
		</label>
		<div>
			<label class=" checkboxContainer disableTextSelection">
				<form:checkbox path="searchTitle" id="searchInTitle" />
				<spring:message code="wiki.page.name.label" text="Wiki Page name"/>
				<span class="color-box title"></span>
			</label>
			<label class=" checkboxContainer disableTextSelection">
				<form:checkbox path="searchInDescription" id="searchInDescription" />
				<spring:message code="wiki.wiki.content.label" text="Wiki Content"/>
				<span class="color-box description"></span>
			</label>
			<label class=" checkboxContainer disableTextSelection">
				<form:checkbox path="searchInId" id="searchInId" />
				<spring:message code="wiki.wiki.id.label" text="Wiki Id"/>
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