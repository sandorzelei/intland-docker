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
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<script type="text/javascript">
	function deleteWikiPage(deleteWikiPageUrl) {
		var msg = '<spring:message javaScriptEscape="true" code="wiki.page.dashboard.delete.confirm" />';
		showFancyConfirmDialogWithCallbacks(msg, function() { document.location.href = deleteWikiPageUrl; });
	}
</script>
<ui:actionGenerator builder="dashboardActionMenuBuilder" actionListName="dashboardActions" subject="${dashboard}">
    <c:if test="${empty param.revision}">
		<ui:actionLink keys="addChildPage, addChildDashboard" actions="${ dashboardActions}"/>
		<ui:actionLink keys="dashboardActions" actions="${dashboardActions}"/>
		<c:if test="${dashboardActions.containsKey('dashboardActions')}">
		    <span class="menu-separator"></span>
		</c:if>
		<ui:actionLink keys="addWidget" actions="${dashboardActions}"/>
    </c:if>
	<!-- Only display layout selector when elements are present. (edit mode) and not viewing a baseline -->
	<c:if test="${dashboardActions.containsKey('selectLayoutsingle_column') && empty param.revision}">
		<spring:message code="dashboard.select.layout.label" text="Select Layout" var="selectLayoutLabel"/>
		<ui:actionMenu cssClass="selectLayoutAction" actionIconMode="true" iconUrl="/images/newskin/actionIcons/icon-layout.png" title="${selectLayoutLabel}" actions="${dashboardActions}" inline="true" keys="selectLayout*" />
		<span class="menu-separator"></span>
	</c:if>

	<ui:actionMenu cssClass="dpMoreMenu more dashboardLink" title="" subject="${dashboard }" actions="${dashboardActions }" inline="true"
		keys="properties, ----, comment, label, Favourite, [---], exportOneWikiPage, exportWikiPages, [---], Follow, lock, unlock, delete, copyWiki, paste, pasteWidget, [---], showParent" />

</ui:actionGenerator>

