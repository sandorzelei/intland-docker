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
<meta name="moduleCSSClass" content="newskin"/>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="taglib"   prefix="tag" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>


<style>
	ul.user-preferences-list {
		list-style: none;
		margin-bottom: 40px;
		padding-left: 0;
	}

	ul.user-preferences-list li {
		margin-bottom: 10px;
	}

	ul.user-preferences-list li.header {
		font-weight: bold;
		margin-top: 20px;
	}

	ul.user-preferences-list input[type="checkbox"] {
		position: relative;
		top: 2px;
	}

	body.isMac ul.user-preferences-list input[type="checkbox"] {
		top: -1px;
	}

	ul.user-preferences-list a {
		position: relative;
		top: 3px;
	}

</style>

<form:form commandName="userPreferencesCommand">
	<ui:actionMenuBar>
		<ui:pageTitle>
			<spring:message code="user.preferences.label" text="User Preferences" />
		</ui:pageTitle>
	</ui:actionMenuBar>

	<ui:actionBar>
		<spring:message var="buttonTitle" code="button.save" text="Save"/>
		<spring:message var="cancelTitle" code="button.cancel" text="Cancel"/>
		<input type="submit" class="button" title="${buttonTitle}" value="${buttonTitle}" name="submit" />&nbsp;
		<input type="button" class="button cancelButton" title="${cancelTitle}" value="${cancelTitle}" onclick="closePopupInline();" />
	</ui:actionBar>

	<div class="contentWithMargins">
		<ul class="user-preferences-list">
			<li class="header"><spring:message code="user.preference.general.label"/></li>
			<li>
				<label for="browserTabOpeningSupported">
					<form:checkbox id="browserTabOpeningSupported" path="browserTabOpeningSupported" />
					<spring:message code="user.preferences.browser.tab.opening.label" text="Open new browser tabs" />
				</label>
				<a href="https://codebeamer.com/cb/wiki/4865153#section-Open+links+in+new+browser+tab" target="_blank">
					<img title='<spring:message code="user.preferences.browser.tab.opening.hint" text="This setting is applied on Planner, Reports and other Agile pages. Please click for more information." />' src="<c:url value='/images/newskin/action/help.png' />">
				</a>
			</li>
			<li>
				<label for="alwaysDisplayContextMenuIcons">
					<form:checkbox id="alwaysDisplayContextMenuIcons" path="alwaysDisplayContextMenuIcons" />
					<spring:message code="user.preferences.always.display.context.menu.icons.label" text="Always display context menu icon" />
				</label>
			</li>
			<li>
				<label for="doubleClickEditOnDocView">
					<form:checkbox id="doubleClickEditOnDocView" path="doubleClickEditOnDocView" />
					<spring:message code="user.preference.doubleclick.edit.document.view.label" text="Edit item when double clicking on Document View" />
				</label>
			</li>
			<li>
				<label for="doubleClickEditOnWikiSection">
					<form:checkbox id="doubleClickEditOnWikiSection" path="doubleClickEditOnWikiSection" />
					<spring:message code="user.preference.doubleclick.edit.wiki.section.label" text="Edit wiki section when double clicking" />
				</label>
			</li>
			<c:if test="${hasAgileLicense}">
				<li class="header"><spring:message code="user.preference.agile.label"/></li>
				<li>
					<label for="openPlannerProductBacklog">
						<form:checkbox id="openPlannerProductBacklog" path="openPlannerProductBacklog" />
						<spring:message code="user.preference.open.planner.backlog.label" text="Show Product Backlog by opening Planner" />
					</label>
				</li>
				<li>
					<label for="releaseView">
						<spring:message code="user.preference.open.release.view.label" text="Default view for Releases" />
						<spring:message var="releaseDashboardLabel" code="user.preference.open.release.view.release.dashboard"/>
						<spring:message var="plannerLabel" code="user.preference.open.release.view.planner"/>
						<form:select id="releaseView" path="releaseView">
							<form:option value="RELEASE_DASHBOARD" label="${releaseDashboardLabel}"/>
							<form:option value="PLANNER" label="${plannerLabel}"/>
						</form:select>
					</label>
				</li>
			</c:if>
			<li class="header"><spring:message code="user.preference.report.label"/></li>
			<li>
				<label for="expandDefaultViewsSection">
					<form:checkbox id="expandDefaultViewsSection" path="expandDefaultViewsSection" />
					<spring:message code="user.preference.expand.default.views.section.label" text="Expand Default Views section by default on View Picker overlay" />
				</label>
			</li>
		</ul>
	</div>
</form:form>
