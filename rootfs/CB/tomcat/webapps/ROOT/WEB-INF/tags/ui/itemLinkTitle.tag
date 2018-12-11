<%--
*
*
*
*
*
*
*
*   _____ _                        _     _____                                             _
*  / ____| |                      | |   / ____|                                           | |
* | (___ | |__   __ _ _ __ ___  __| |  | |     ___  _ __ ___  _ __   ___  _ __   ___ _ __ | |_
*  \___ \| '_ \ / _` | '__/ _ \/ _` |  | |    / _ \| '_ ` _ \| '_ \ / _ \| '_ \ / _ \ '_ \| __|
*  ____) | | | | (_| | | |  __/ (_| |  | |___| (_) | | | | | | |_) | (_) | | | |  __/ | | | |_
* |_____/|_| |_|\__,_|_|  \___|\__,_|   \_____\___/|_| |_| |_| .__/ \___/|_| |_|\___|_| |_|\__|
*                                                            | |
*                                                            |_|
*
*  _____  _                                  _       _           __                                       _ _  __ _           _   _
* |  __ \| |                                | |     | |         / _|                                     | (_)/ _(_)         | | (_)
* | |__) | | ___  __ _ ___  ___     __ _ ___| | __  | |__   ___| |_ ___  _ __ ___     _ __ ___   ___   __| |_| |_ _  ___ __ _| |_ _  ___  _ __  ___
* |  ___/| |/ _ \/ _` / __|/ _ \   / _` / __| |/ /  | '_ \ / _ \  _/ _ \| '__/ _ \   | '_ ` _ \ / _ \ / _` | |  _| |/ __/ _` | __| |/ _ \| '_ \/ __|
* | |    | |  __/ (_| \__ \  __/  | (_| \__ \   <   | |_) |  __/ || (_) | | |  __/   | | | | | | (_) | (_| | | | | | (_| (_| | |_| | (_) | | | \__ \
* |_|    |_|\___|\__,_|___/\___|   \__,_|___/_|\_\  |_.__/ \___|_| \___/|_|  \___|   |_| |_| |_|\___/ \__,_|_|_| |_|\___\__,_|\__|_|\___/|_| |_|___/
*
*
*
*
*
*
*
--%>

<%--
*
* This component is used on many pages, altering the logic might affect various pieces of the application. Handle with care!
* This tag renders a standardized title content for tracker items.
*
--%>

<%@tag import="com.intland.codebeamer.persistence.dto.base.ReferableDto"%>
<%@tag import="com.intland.codebeamer.ui.view.table.TrackerSimpleLayoutDecorator"%>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="taglib" prefix="tag" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>

<%@ attribute name="item" required="true" type="com.intland.codebeamer.persistence.dto.base.NamedDto" rtexprvalue="true" description="Dto to render."  %>
<%@ attribute name="decorator" required="true" type="com.intland.codebeamer.ui.view.table.TrackerSimpleLayoutDecorator" rtexprvalue="true" description="Decorator instance initialized with the dtor."  %>

<c:if test="${(ui:isTrackerItem(item) || (isReference && ui:isTrackerItem(item.dto)))}">
		<c:if test="${isReference}">
			<c:set var="item" value="${item.dto}"></c:set>
		</c:if>

		<spring:message var="statusName" code="tracker.choice.${item.status.name}.label" text="${item.status.name != null ? item.status.name : '--'}"/>
		<c:if test="${decorator.statusVisible}">
			<spring:message var="statusForTitle" code="wikilink.title.status" text="Status: {0}" arguments="${statusName}"/>
		</c:if>

		<c:choose>
			<c:when test="${decorator.modifiedByVisible && decorator.modifiedAtVisible}">
				<tag:formatDate var="modifiedAt" value="${item.modifiedAt}"/>
				<spring:message var="modifiedByForTitle" code="wikilink.title.modified.by.combined" text="Modified by: {0} {1}"
					arguments="${item.modifier.name},${modifiedAt}" />
			</c:when>
			<c:otherwise>
				<c:if test="${decorator.modifiedByVisible}">
					<spring:message var="modifiedByForTitle" code="wikilink.title.modified.by" text="Modified by: {0}" arguments="${item.modifier.name}"/>
				</c:if>
				<c:if test="${decorator.modifiedAtVisible}">
					<tag:formatDate var="modifiedAt" value="${item.modifiedAt}"/>
					<spring:message var="modifiedAtForTitle" code="wikilink.title.modified.at" text="Modified on: {0}" arguments="${modifiedAt}"/>
				</c:if>
			</c:otherwise>
		</c:choose>

		<c:set var="branchForTitle" value="" />
		<c:if test="${not empty item.branch}">
			<spring:message var="branchForTitle" code="wikilink.title.branch" text="Branch: {0}" arguments="${item.branch.name}"/>
		</c:if>

		<c:if test="${not empty statusForTitle}">${statusForTitle}; </c:if><c:if test="${not empty branchForTitle}">${branchForTitle}; </c:if>${modifiedByForTitle}<c:if test="${not empty modifiedByForTitle && not empty modifiedAtForTitle}">; </c:if>${modifiedAtForTitle}
</c:if>