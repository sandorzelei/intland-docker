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
* This tag only renders a link, please consider using wikiLink.tag if you need status icon, description on hover, suspected badge etc.
*
--%>

<%@tag import="com.intland.codebeamer.persistence.dto.TrackerItemDto"%>
<%@tag import="com.intland.codebeamer.persistence.dto.base.ReferableDto"%>
<%@tag import="com.intland.codebeamer.persistence.dto.base.ReferenceDto"%>
<%@tag import="com.intland.codebeamer.ui.view.table.TrackerSimpleLayoutDecorator"%>
<%@ tag language="java" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="taglib" prefix="tag" %>
<%@ taglib uri="callTag" prefix="ct" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>

<%-- This can be an ArtifactDto, TrackerItemDto, VersionReferenceDto or TrackerItemReferenceWrapperDto. --%>
<%@ attribute name="item" required="true" type="com.intland.codebeamer.persistence.dto.base.NamedDto" rtexprvalue="true" description="Dto to render."  %>
<%@ attribute name="text" required="false" type="java.lang.String" description="Text to add to the link. If not set, then it renders like this: [ISSUE:1111] SUMMARY" %>
<%@ attribute name="showKeyAndId" required="false" type="java.lang.Boolean" rtexprvalue="true" description="Show or not show the key and id."  %>
<%@ attribute name="showItemName" required="false" type="java.lang.Boolean" rtexprvalue="true" description="Show or not show name after the key and id."  %>
<%@ attribute name="showItemDescription" required="false" type="java.lang.Boolean" rtexprvalue="true" description="Show or not show description in a hidden div."  %>
<%@ attribute name="useVersionedUrl" required="false" type="java.lang.Boolean" description="Adds the item version to the item url" %>
<%@ attribute name="showVersionBadge" required="false" type="java.lang.Boolean" description="Renders the version badge. Explicitly sets useVersionedUrl to true." %>
<%@ attribute name="baselineId" required="false" type="java.lang.Integer" description="Appends the baseline id to the url" %>
<%@ attribute name="excludeLink" required="false" type="java.lang.Boolean" rtexprvalue="true" description="If true, link will not be rendered." %>
<%@ attribute name="target" required="false" type="java.lang.String" description="Target attribute of HTML a tag, optional" %>
<%@ attribute name="useKeyInLabel" required="false" type="java.lang.Boolean" rtexprvalue="true" description="If true then the tracker/project key will be used in the label of the link. Default is false." %>

<c:if test="${empty useVersionedUrl}">
	<c:set var="useVersionedUrl" value="${false}" />
</c:if>

<c:choose>
	<c:when test="${showVersionBadge == true}">
		<c:set var="useVersionedUrl" value="${true}" />
	</c:when>
	<c:otherwise>
		<c:set var="showVersionBadge" value="${false}" />
	</c:otherwise>
</c:choose>

<c:if test="${empty showKeyAndId}">
	<c:set var="showKeyAndId" value="${true}" />
</c:if>

<c:if test="${empty showItemName}">
	<c:set var="showItemName" value="${true}" />
</c:if>

<c:if test="${empty showItemDescription}">
	<c:set var="showItemDescription" value="${true}" />
</c:if>

<c:if test="${empty excludeLink}">
	<c:set var="excludeLink" value="${false}" />
</c:if>

<c:if test="${empty useKeyInLabel}">
	<c:set var="useKeyInLabel" value="${false}" />
</c:if>

<c:set var="hasInterwikiLink" value="${false}" />
<c:set var="interwikiLink" value="${null}" />

<c:if test="${ui:isPropertyPresent(item, 'interwikiLink')}">
	<c:set var="hasInterwikiLink" value="${true}" />
	<c:set var="interwikiLink" value="${item.interwikiLink}" />
</c:if>

<c:if test="${ui:isPropertyPresent(item, 'version') && item.version != null}">
	<c:set var="supportsVersionedUrl" value="${true}" />
</c:if>

<c:set var="isTrackerItem" value="${ui:isTrackerItem(item)}" />
<c:set var="isReferable" value="${ui:isReferable(item)}" />
<c:set var="isReference" value="${ui:isReference(item)}" />
<c:set var="isTrackerItemReferenceWrapper" value="${ui:isTrackerItemReferenceWrapper(item)}" />

<c:if test="${isReferable}">
	<tag:issueKeyAndId var="issueKeyAndId" dto="${item}" useKeyInLabel="${useKeyInLabel}"></tag:issueKeyAndId>
</c:if>

<c:choose>

	<c:when test="${(isTrackerItem || (isReference && ui:isTrackerItem(item.dto))) && hasInterwikiLink && not empty issueKeyAndId}">

		<c:if test="${empty decorated}">
			<%
				TrackerSimpleLayoutDecorator decorator = new TrackerSimpleLayoutDecorator(request);

				request.setAttribute("decorated", decorator);
			%>
		</c:if>

		<jsp:useBean id="decorated" beanName="decorated" scope="request" type="com.intland.codebeamer.ui.view.table.TrackerSimpleLayoutDecorator" />
		<%
			decorated.initRow(item instanceof ReferenceDto ? ((ReferenceDto) item).getDto() : item, 0, 0);
		%>

		<c:choose>
			<%-- Only allow versioned urls by default for VersionReferenceDto or TrackerItemReferenceWrapperDto. --%>
			<c:when test="${useVersionedUrl &&
							((isReference && item.version != null && item.dto.version != null && item.version == item.dto.version && item.version > 0)
								|| (isTrackerItemReferenceWrapper && item.referenceDataDto != null && item.referenceDataDto.revision != null && item.referenceDataDto.revision > 0)
								|| (showVersionBadge == true))}">

				<c:choose>
					<c:when test="${isTrackerItemReferenceWrapper}">
						<c:set var="revisionNumber" value="${not empty item.referenceDataDto.revision ? item.referenceDataDto.revision : item.version}" />
					</c:when>
					<c:when test="${isReference}">
						<c:set var="revisionNumber" value="${item.version}" />
					</c:when>
					<c:otherwise>
						<c:set var="revisionNumber" value="${item.version}" />
					</c:otherwise>
				</c:choose>

				<tag:versionUrl var="itemUrl" urlLink="${isReference ? item.dto.urlLink : item.urlLink}" revisionNumber="${revisionNumber}" appendRequestParameters="false"></tag:versionUrl>

			</c:when>
			<c:when test="${baselineId != null && baselineId > 0}">
				<ct:call object="${item}" method="getUrlLinkBaselined" param1="${baselineId}" return="itemUrl"/>
			</c:when>
			<c:otherwise>
				<c:set var="itemUrl" value="${item.urlLink }"></c:set>
			</c:otherwise>
		</c:choose>

		<%-- Replace the item with the wrapped dto in case of a VersionReferenceDto, so the rest of the link renders as expected. --%>
		<c:set var="item" value="${item}"></c:set>
		<c:if test="${isReference}">
			<c:set var="item" value="${item.dto}"></c:set>
		</c:if>

		<c:set var="trackerItemTitle">
			<ui:itemLinkTitle item="${item}" decorator="${decorated}"/>
		</c:set>
		<c:choose>
			<c:when test="${!excludeLink}">
				<a href="<c:url value="${itemUrl}"/>" class="itemUrl ${item.closed ? "lineThrough" : ""}" data-id="${item.id}" <c:if test="${not empty target}">target="${target}"</c:if> title="${trackerItemTitle}" >
			</c:when>
			<c:otherwise>
				<span title="${trackerItemTitle}">
			</c:otherwise>
		</c:choose>
			<c:choose>
				<c:when test="${not empty text}">
					${text}
				</c:when>
				<c:when test="${decorated.nameVisible}">
					<c:if test="${showKeyAndId}">[<c:out value='${issueKeyAndId}'/>]</c:if>
					<c:if test="${showItemName}">&nbsp;<c:if test="${empty item.reqIfSummary}"><spring:message code="tracker.view.layout.document.no.summary" text="[No Summary]"/></c:if><c:out value='${item.reqIfSummary}'/></c:if>
				</c:when>
				<c:otherwise>
					<c:if test="${showKeyAndId}">[<c:out value='${issueKeyAndId}'/>]</c:if>
					<spring:message code="tracker.view.layout.document.summary.not.readable" text="[Summary not readable]"/>
				</c:otherwise>
			</c:choose>
		<c:choose>
			<c:when test="${!excludeLink}">
				</a>
			</c:when>
			<c:otherwise>
				</span>
			</c:otherwise>
		</c:choose>

		<c:if test="${showVersionBadge && supportsVersionedUrl}">
			<span class="referenceSettingBadge versionSettingBadge" data-item-id="${item.id}" data-version-id="${item.version}">v${item.version}</span>
		</c:if>

		<c:catch var="propertyNotFound">
			<c:if test="${not empty item.description && decorated.descriptionVisible && showItemDescription}">
				<div style="display:none" class="itemDescription" data-id="${item.id}"><tag:transformText value="${item.description}" owner="${item}" format="W"/></div>
			</c:if>
		</c:catch>

		<c:catch var="propertyNotFound">
			<c:if test="${not empty item.dto.description && decorated.descriptionVisible && showItemDescription}">
				<div style="display:none" class="itemDescription" data-id="${item.id}"><tag:transformText value="${item.dto.description}" owner="${item.dto}" format="W"/></div>
			</c:if>
		</c:catch>
	</c:when>

	<c:when test="${hasInterwikiLink && not empty issueKeyAndId}">
		<c:choose>
			<c:when test="${useVersionedUrl && isReference && item.version > 0}">
				<c:set var="revisionNumber" value="${item.version}" />

				<tag:versionUrl var="itemUrl" urlLink="${item.dto.urlLink}" revisionNumber="${revisionNumber}" appendRequestParameters="false"></tag:versionUrl>
			</c:when>
			<c:otherwise>
				<c:set var="itemUrl" value="${item.urlLink}"></c:set>
			</c:otherwise>
		</c:choose>

		<%-- Replace the item with the wrapped dto in case of a VersionReferenceDto, so the rest of the link renders as expected. --%>
		<c:set var="item" value="${item}"></c:set>
		<c:if test="${isReference}">
			<c:set var="item" value="${item.dto}"></c:set>
		</c:if>

		<c:choose>
			<c:when test="${ui:isPropertyPresent(item, 'lastModifiedBy') && ui:isPropertyPresent(item, 'lastModifiedAt')}">
				<tag:formatDate var="modifiedAt" value="${item.lastModifiedAt}"/>
				<spring:message var="modifiedByForTitle" code="wikilink.title.modified.by.combined" text="Modified by: {0} {1}"
					arguments="${item.lastModifiedBy.name}, ${modifiedAt}"/>
			</c:when>
			<c:otherwise>
				<c:if test="${ui:isPropertyPresent(item, 'lastModifiedBy')}">
					<spring:message var="modifiedByForTitle" code="wikilink.title.modified.by" text="Modified by: {0}"
						arguments="${item.lastModifiedBy.name}"/>
				</c:if>
				<c:if test="${ui:isPropertyPresent(item, 'lastModifiedAt')}">
					<tag:formatDate var="modifiedAt" value="${item.lastModifiedAt}"/>
					<spring:message var="modifiedAtForTitle" code="wikilink.title.modified.at" text="Modified on: {0}" arguments="${modifiedAt}"/>
				</c:if>
			</c:otherwise>
		</c:choose>

		<c:if test="${!excludeLink}">
			<a href="<c:url value="${itemUrl}"/>" <c:if test="${not empty target}">target="${target}"</c:if> title="${modifiedByForTitle}<c:if test="${not empty modifiedByForTitle && not empty modifiedAtForTitle}">; </c:if>${modifiedAtForTitle}" class="itemUrl" data-id="${item.id}">
		</c:if>
			<c:choose>
				<c:when test="${not empty text}">
					${text}
				</c:when>
				<c:otherwise>
					<c:if test="${showKeyAndId}">[<c:out value='${issueKeyAndId}'/>]</c:if><c:if test="${showItemName}">&nbsp;<c:out value='${item.name}'/></c:if>
				</c:otherwise>
			</c:choose>
		<c:if test="${!excludeLink}">
			</a>
		</c:if>

		<c:if test="${useVersionedUrl && supportsVersionedUrl}">
			<span class="referenceSettingBadge versionSettingBadge">v${item.version}</span>
		</c:if>
		<c:catch var="propertyNotFound">
			<c:if test="${not empty item.description && showItemDescription}">
				<div style="display:none" class="itemDescription" data-id="${item.id}"><tag:transformText value="${item.description}" owner="${item}" format="W"/></div>
			</c:if>
		</c:catch>

		<c:catch var="propertyNotFound">
			<c:if test="${not empty item.dto.description && decorated.descriptionVisible && showItemDescription}">
				<div style="display:none" class="itemDescription" data-id="${item.id}"><tag:transformText value="${item.dto.description}" owner="${item.dto}" format="W"/></div>
			</c:if>
		</c:catch>
	</c:when>


</c:choose>

<c:remove var="showItemName" />
<c:remove var="showItemDescription" />
<c:remove var="hasInterwikiLink" />
<c:remove var="interwikiLink" />
<c:remove var="supportsVersionedUrl" />
<c:remove var="isTrackerItem" />
<c:remove var="isReferable" />
<c:remove var="isReference" />
<c:remove var="isTrackerItemReferenceWrapper" />
<c:remove var="revisionNumber" />
<c:remove var="trackerItemTitle" />
