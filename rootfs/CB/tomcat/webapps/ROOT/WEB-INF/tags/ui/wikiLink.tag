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
*
--%>

<%@tag import="com.intland.codebeamer.persistence.dto.base.ReferenceDto"%>
<%@tag import="com.intland.codebeamer.ui.view.table.TrackerSimpleLayoutDecorator"%>
<%@tag import="com.intland.codebeamer.ui.view.ColoredEntityIconProvider" %>
<%@tag body-content="scriptless" %>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="taglib" prefix="tag" %>
<%@ taglib uri="bugstaglib" prefix="bugs" %>


<%@ attribute name="item" required="true" type="com.intland.codebeamer.persistence.dto.base.NamedDto" rtexprvalue="true" description="Dto to render."  %>
<%@ attribute name="user" required="false" type="com.intland.codebeamer.persistence.dto.UserDto" rtexprvalue="true" description="User, reserved for future use."  %>
<%@ attribute name="showSuspectedBadge" required="false" type="java.lang.Boolean" rtexprvalue="true" description="When set to true, then suspected badge is also rendered."  %>
<%@ attribute name="alwaysShowVersionBadge" required="false" type="java.lang.Boolean" rtexprvalue="true" description="This tag by default decides whether to show the version tag or not render it. This flag bypasseses that logic and renders the version badge and also makes sure that versioned url is used." %>
<%@ attribute name="association" required="false" type="com.intland.codebeamer.persistence.dto.AssociationDto" rtexprvalue="true" description="Association DTO object, mandatory when showSuspectedBadge is true." %>
<%@ attribute name="associationIsIncoming" required="false" type="java.lang.Boolean" rtexprvalue="true" description="When set to true, then the association is incoming, otherwise it's outgoing. Default is false."  %>
<%@ attribute name="referenceWrapper" required="false" type="com.intland.codebeamer.persistence.dto.TrackerItemReferenceWrapperDto" rtexprvalue="true" description="TrackerItemReferenceWrapperDto object, mandatory when showSuspectedBadge is true." %>
<%@ attribute name="hideBadges" required="false" type="java.lang.Boolean" rtexprvalue="true" description="When set to true, then it does not render any badge." %>
<%@ attribute name="hideBranchBadge" required="false" type="java.lang.Boolean" rtexprvalue="true" description="When set to true, then it does not render the branch badge (in case of a branch item)." %>
<%@ attribute name="showItemName" required="false" type="java.lang.Boolean" rtexprvalue="true" description="When set to true, then it renders the name of the items as part of the link." %>
<%@ attribute name="showTooltip" required="false" type="java.lang.Boolean" rtexprvalue="true" description="When set to true, then it shows the description of the item, when the mouse is over the status icon. Default is true." %>
<%@ attribute name="forceBaselineAware" required="false" type="java.lang.Boolean" rtexprvalue="true" description="When set to true, then it forces the link to render with revision parameter in baseline mode. This can be used to properly render for example TrackerItemDto urls in baseline mode." %>
<%@ attribute name="excludeLink" required="false" type="java.lang.Boolean" rtexprvalue="true" description="If true, link will not be rendered." %>
<%@ attribute name="target" required="false" type="java.lang.String" description="Target attribute of HTML a tag, optional" %>
<%@ attribute name="hideJumpToDocViewBadge" required="false" type="java.lang.Boolean" rtexprvalue="true" description="If the passed item is a tracker item and the item's tracker supports document view, then this tag renders the jump to document view badge by default. With this flag this behaviour can be overwritten and if set to true, the jump to document view badge will not be shown." %>
<%@ attribute name="useKeyInLabel" required="false" type="java.lang.Boolean" rtexprvalue="true" description="If true then the tracker/project key will be used in the label of the link. Default is false." %>
<%@ attribute name="showDependenciesBadge" required="false" type="java.lang.Boolean" rtexprvalue="true" description="When set to true, then unresolved dependencies badge is also rendered."  %>

<c:if test="${empty hideBadges}">
	<c:set var="hideBadges" value="${false}" />
</c:if>

<c:if test="${empty alwaysShowVersionBadge}">
	<c:set var="alwaysShowVersionBadge" value="${false}" />
</c:if>

<c:if test="${empty showTooltip}">
	<c:set var="showTooltip" value="${true}" />
</c:if>

<c:if test="${empty showItemName}">
	<c:set var="showItemName" value="${true}" />
</c:if>

<c:if test="${empty showSuspectedBadge}">
	<c:set var="showSuspectedBadge" value="${false}" />
</c:if>

<c:if test="${empty forceBaselineAware}">
	<c:set var="forceBaselineAware" value="${false}" />
</c:if>

<c:if test="${empty excludeLink}">
	<c:set var="excludeLink" value="${false}" />
</c:if>

<c:if test="${empty hideJumpToDocViewBadge}">
	<c:set var="hideJumpToDocViewBadge" value="${false}" />
</c:if>

<c:if test="${empty useKeyInLabel}">
	<c:set var="useKeyInLabel" value="${false}" />
</c:if>

<c:if test="${empty showDependenciesBadge}">
	<c:set var="showDependenciesBadge" value="${false}" />
</c:if>

<c:if test="${empty associationIsIncoming}">
	<c:set var="associationIsIncoming" value="${false}" />
</c:if>

<tag:checkMutualExclusion object="${association}" otherObject="${referenceWrapper}" message="Only one from association or reference parameter is allowed to be non-null, not both at the same time."/>

<div class="wikiLinkContainer">

	<div class="wikiLink">

		<div class="itemIcon reficon">

			<ui:coloredEntityIcon subject="${item}" iconBgColorVar="referencedBgColor" iconUrlVar="referencedIconUrl"/>

			<c:if test="${ui:isTrackerItem(item) || (ui:isReference(item) && ui:isTrackerItem(item.dto))}">

				<%
					final TrackerSimpleLayoutDecorator temporaryDecorator = new TrackerSimpleLayoutDecorator(request);

					request.setAttribute("temporaryDecorator", temporaryDecorator);

					temporaryDecorator.initRow(item instanceof ReferenceDto ? ((ReferenceDto) item).getDto() : item, 0, 0);
				%>

				<c:if test="${!temporaryDecorator.statusVisible}">
					<c:set var="referencedBgColor" value="<%=ColoredEntityIconProvider.neutralColor %>" />
				</c:if>

			</c:if>

			<c:if test="${not empty referencedIconUrl }">
				<c:choose>
					<c:when test="${showTooltip}">
						<ui:tooltipWrapper dto="${item}">
							<img class="trackerImage" data-id="${item.id}"
								style="background-color:${referencedBgColor}" src="<c:url value="${referencedIconUrl}"/>"/>
						</ui:tooltipWrapper>
					</c:when>
					<c:otherwise>
						<img class="trackerImage" data-id="${item.id}"
							style="background-color:${referencedBgColor}" src="<c:url value="${referencedIconUrl}"/>"/>
					</c:otherwise>
				</c:choose>
			</c:if>

		</div>

		<c:set var="baselineId" value="" />
		<c:if test="${not empty param.revision && param.revision != 0}">
			<c:set var="baselineId" value="${param.revision}" />
		</c:if>

		<c:set var="currentItem" value="${item}"/>
		<c:set var="isFixedVersionReference" value="${false}"/>

		<%-- Determine whether a fix item reference is passed. --%>
		<c:choose>
			<c:when test="${ui:isReference(item) == true && item.version > 0 && ui:isBaseline(item.version) == false
							&& !ui:isPropertyPresent(item, 'baseline')}">
				<c:set var="isFixedVersionReference" value="${true}"/>
				<c:set var="baselineId" value="" />
			</c:when>
			<c:when test="${ui:isTrackerItemReferenceWrapper(item)}">
				<c:set var="referenceData" value="${item.referenceDataDto }"/>
				<c:set var="isFixedVersionReference" value="${referenceData != null && referenceData.revision != null}"/>
			</c:when>
		</c:choose>

		<%-- Determine whether to render version in the url. --%>
		<c:choose>
			<c:when test="${alwaysShowVersionBadge == true}">
				<c:set var="renderVersionedUrl" value="${true}" />
			</c:when>
			<c:when test="${!ui:isReference(item) && forceBaselineAware == true && not empty baselineId}">
				<c:set var="renderVersionedUrl" value="${true}" />
			</c:when>
			<c:otherwise>
				<c:set var="renderVersionedUrl" value="${isFixedVersionReference}" />
			</c:otherwise>
		</c:choose>

		<%-- Determine whether to render version badge. --%>
		<c:choose>
			<c:when test="${hideBadges == true}">
				<c:set var="renderVersionBadge" value="${false}" />
			</c:when>
			<c:when test="${alwaysShowVersionBadge == true}">
				<c:set var="renderVersionBadge" value="${true}" />
			</c:when>
			<c:otherwise>
				<c:set var="renderVersionBadge" value="${isFixedVersionReference}" />
			</c:otherwise>
		</c:choose>

		<%-- Determine whether to render jump to document view badge. --%>
		<c:choose>
			<c:when test="${hideBadges == true}">
				<c:set var="renderJumpToDocViewBadge" value="${false}" />
			</c:when>
			<c:when test="${hideJumpToDocViewBadge == true}">
				<c:set var="renderJumpToDocViewBadge" value="${false}" />
			</c:when>
			<c:otherwise>
				<!-- Only if the tracker supports doument view -->
				<c:choose>
					<c:when test="${ui:isTrackerItem(item)}">
						<c:set var="trackerItemDtoForCheck" value="${item}" />
					</c:when>
					<c:when test="${ui:isReference(item) && ui:isTrackerItem(item.dto)}">
						<c:set var="trackerItemDtoForCheck" value="${item.dto}" />
					</c:when>
				</c:choose>
				<c:choose>
					<c:when test="${not empty trackerItemDtoForCheck}">
						<c:set var="renderJumpToDocViewBadge" value="${ui:isItemsTrackerSupportsDocumentView(trackerItemDtoForCheck)}" />
					</c:when>
					<c:otherwise>
						<c:set var="renderJumpToDocViewBadge" value="${false}" />
					</c:otherwise>
				</c:choose>
			</c:otherwise>
		</c:choose>

		<jsp:doBody var="bodyText"/>

		<ui:itemLink item="${item}" text="${bodyText}" useVersionedUrl="${renderVersionedUrl}" showVersionBadge="${renderVersionBadge}"
			baselineId="${baselineId}" showItemName="${showItemName}" excludeLink="${excludeLink}" target="${target}" showItemDescription="${false}" useKeyInLabel="${useKeyInLabel}" />

		<%-- Render jump to document view badge. --%>
		<c:if test="${renderJumpToDocViewBadge == true}">
			<spring:message var="jumpToDocumentViewUrlTitle" code="wikilink.jumpToDocumentView.url.title" text="Navigate to Document View" />
			<div class="jumpToDocumentViewBadge">
				<a class="jumpToDocumentView" data-trackerId="${trackerItemDtoForCheck.tracker.id}" data-trackerItemId="${trackerItemDtoForCheck.id}" data-url="${bugs:createJumpToDocumentViewUrl(trackerItemDtoForCheck)}" title="${jumpToDocumentViewUrlTitle}">
					<img src="<c:url value="/images/jump_to_docview_small.png"/>"/></img>
				</a>
			</div>
		</c:if>

		<c:if test="${!hideBadges && showSuspectedBadge}">

			<%-- Render suspected badge for associations. --%>
			<c:if test="${not empty association}">

				<div class="itemBadge">
					<c:choose>
						<c:when test="${association.suspected}">
							<bugs:suspectedLinkBadge from="${association.from.id}" to="${association.to.id}" clearable="${empty baselineId ? true : false}" association="${association}" revision="${baselineId}"/>
						</c:when>
						<c:when test="${!association.suspected and association.propagatingSuspects}">
								<spring:message var="suspectedLabel" code="association.suspected.label" text="Suspected" />
								<spring:message var="propagatingSuspectsInfo" code="association.propagatingSuspects.info"/>
								<span class="suspectedLinkBadge suspect inactiveSuspectedLinkBadge" title="${propagatingSuspectsInfo}">  ${suspectedLabel} <c:if test="${association.reverse}"><span class="reverseSuspectImg"></span></c:if></span>
								<c:if test="${association.biDirectReferenceSupported && association.biDirectReference}">
									<span class="arrow arrow-up${association.biDirectOutgoingSuspected ? ' active' : ''}"></span> 
									<span class="arrow arrow-down${association.biDirectIncomingSuspected ? ' active' : ''}"></span>
								</c:if>								
						</c:when>
						<c:otherwise>
						</c:otherwise>
					</c:choose>
				</div>

			</c:if>

			<%-- Render suspected badge for reference. --%>
			<c:if test="${not empty referenceWrapper}">
				<%-- use this flag to make sure that the branch bedge is rendered only once
					this flag is necessary because the ui:renderSuspectedBadgeForReference tag renders the branch badges
					and if we also render them using bugs:trackerBranchBadge later then all badges will be duplicated
				 --%>
				<c:set var="branchRendered" value="true"></c:set>
				<ui:renderSuspectedBadgeForReference wrapper="${referenceWrapper}" />
			</c:if>

		</c:if>
		
		<c:if test="${showDependenciesBadge}">
			<spring:message var="unresolvedDependenciesTitle" code="association.unresolved.dependencies.label" text="Unresolved Dependencies" />
			<spring:message var="compactLabel" code="association.unresolved.dependencies.compact.label" text="UD" />
			
			<c:if test="${not empty association and association.propagatingDependencies}">
				<c:set var="isActive" value="${(not associationIsIncoming and association.toUnresolved) or (associationIsIncoming and association.fromUnresolved)}" />
				<span data-association-id="${association.id}" data-item-id="${item.id}" class="udBadge${isActive ? ' active' : ''}" title="${unresolvedDependenciesTitle}"><i class="fa fa-exclamation"></i>${compactLabel}</span>
			</c:if>
			
			<c:if test="${empty association}">
				<span class="udBadge${item.hasUnresolvedDependency ? ' active' : '' }" data-item-id="${item.id}" title="${unresolvedDependenciesTitle}"><i class="fa fa-exclamation"></i>${compactLabel}</span>
			</c:if>
		</c:if>

		<c:if test="${!branchRendered and !hideBranchBadge and !hideBadges and ui:isTrackerItem(item) and item.branchItem}">
			<bugs:trackerBranchBadge branch="${item.branch }"></bugs:trackerBranchBadge>
		</c:if>

		<c:if test="${!branchRendered and !hideBranchBadge and !hideBadges and ui:isReference(item) && ui:isTrackerItem(item.dto) and item.dto.branchItem}">
			<bugs:trackerBranchBadge branch="${item.dto.branch }"></bugs:trackerBranchBadge>
		</c:if>

	</div>

</div>

