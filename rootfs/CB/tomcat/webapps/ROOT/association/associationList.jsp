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
<%@page import="com.intland.codebeamer.taglib.ItemDependencyResult"%>
<%@page import="com.intland.codebeamer.persistence.dto.ProjectDto"%>
<%@page import="com.intland.codebeamer.persistence.dto.ArtifactDto"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@ taglib uri="taglib" prefix="tag" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="bugstaglib" prefix="bugs" %>
<%@ taglib uri="callTag" prefix="ct"%>

<%@ page import="com.intland.codebeamer.ui.view.table.TrackerSimpleLayoutDecorator" %>

<%
	TrackerSimpleLayoutDecorator decorator = new TrackerSimpleLayoutDecorator(request);
pageContext.setAttribute("decorator", decorator);
%>
<%-- JSP fragment shows a displaytag table, with both the outgoing and the incoming associations to the current object
	Expects following parameters:
	request.itemDependency	- The item's dependencies as List of ItemDependencyResult objects. This is created by the <tag:itemDependecy/> tag
--%>
<script type="text/javascript" src="<ui:urlversioned value="/bugs/tracker/docview/documentView.js"/>"></script>

<style type="text/css">
	.assocSubmitterCol {
		width:9% !important;
		min-width: 9% !important;
		padding-top:2px;
		padding-bottom:15px;
	}
	.assocWikiLinkCol {
		width: 7% !important;
		min-width: 7% !important;
	}
	.assocCMenuCol {
		width: 15px; !important;
		min-width: 15px; !important;
	}
</style>

<%-- TODO: include this js only once! --%>
<%--
<c:set var="INCLUDE_confirmDeleteAssociation" value="${requestScope.INCLUDEconfirmDeleteAssociation}" />
<c:if test="${INCLUDE_confirmDeleteAssociation == null}" >
--%>
	<script type="text/javascript">
		// @param url The url to call if the confirm successful to delete the association
		function confirmDeleteAssociation(url) {
			if (showFancyConfirmDialogWithCallbacks(i18n.message('delete.association.confirm'), function() {
				document.location.href = url;
			}));
		}

		$(document).ready(function() {
			$(".viewComments").on("click", function(event) {
				var element, id, version, parameters;

				element = event.currentTarget;
				id = $(element).data("item-id");
				version = $(element).data("version-id");

				parameters = "task_id=" + id;
				if (version) {
					parameters += "&version=" + version;
				}

				inlinePopup.show(contextPath + "/proj/tracker/listComments.do?" + parameters, { cssClass: "overlayButtonsOnWhite"});

				event.stopPropagation();
				event.preventDefault();
			});
			codebeamer.UnresolvedDependenciesBadges.init($('#task-details-associations'));
		});
	</script>
<%--</c:if>--%>

<ui:UserSetting var="alwaysDisplayContextMenuIcons" setting="ALWAYS_DISPLAY_CONTEXT_MENU_ICONS" defaultValue="true" />

<display:table class="expandText" requestURI="" name="${itemDependency.dependencies}" id="item" cellpadding="0"
	defaultsort="1" defaultorder="descending" export="false" excludedParams="orgDitchnetTabPaneId">

	<spring:message var="associationSubmitter" code="association.submitter.label" text="Submitter"/>
	<display:column title="${associationSubmitter}" sortProperty="submittedAt" sortable="true" headerClass="textData assocSubmitterCol"
	 	class="textData columnSeparator assocSubmitterCol">
		<ui:submission userId="${item.submitter.id}" userName="${item.submitter.name}" date="${item.submittedAt}"/>
	</display:column>

	<spring:message var="referenceTitle" code="association.label" text="Association"/>
	<display:column title="${referenceTitle}" headerClass="textData" class="textDataWrap" style="width:50%">
		<div class="associationRow">
			<c:if test="${item.outgoing}">
				<div class="associationText"><spring:message code="association.typeId.outgoing.${item.associationType}.prefix" text="${item.associationType}"/></div>
			</c:if>

			<c:choose>
				<c:when test="${item.urlReference}">
					<html:link target="_top" href="${item.url}">
						<c:out value="${item.url}"/>
					</html:link>
				</c:when>
				<c:otherwise>
					<c:set var="itemCss" value="${item.closed ? 'closedItem' : ''}" />

					<c:catch var="propertyNotFound"><c:set var="versionNumber" value="${item.endPoint.version}"></c:set></c:catch>

					<c:set var="hasVersionNumber" value="${false}" />
					<c:set var="versionNumber" value="${null}" />
					<c:if test="${ui:isPropertyPresent(item.endPoint, 'version')}">
						<c:set var="hasVersionNumber" value="${true}" />
						<c:set var="versionNumber" value="${item.endPoint.version}" />
					</c:if>
					<c:choose>
						<c:when test="${hasVersionNumber && versionNumber != null && versionNumber > 0}">
							<ui:wikiLink item="${item.endPoint}" showSuspectedBadge="${true}" showDependenciesBadge="${true}" association="${item}" associationIsIncoming="${item.incoming}"/>
						</c:when>
						<c:otherwise>
							<c:choose>
								<c:when test="${!empty item.referable }">
									<ui:wikiLink item="${item.endPoint}" showSuspectedBadge="${true}" showDependenciesBadge="${true}" association="${item}" associationIsIncoming="${item.incoming}"/>
								</c:when>
								<c:otherwise>
										<html:link target="_top" page="${item.endPoint.urlLink}" title="${item.endPoint.interwikiLink}" styleClass="${itemCss}">
										<%
											ItemDependencyResult.AssociationWrapper association = (ItemDependencyResult.AssociationWrapper) pageContext.getAttribute("item");
											String associationName = "";

											if (association != null) {
												Object associationReferable = association.getReferable();

												if (associationReferable != null) {
													if (associationReferable instanceof ArtifactDto) {
														associationName = ((ArtifactDto) associationReferable).getName();
													} else if (associationReferable instanceof ProjectDto) {
														associationName = ((ProjectDto) associationReferable).getName();
													} else {
														associationName = associationReferable.toString();
													}
												}
											}
										%>
										<c:out value="<%=associationName%>"/>
									</html:link>
								</c:otherwise>
							</c:choose>

						</c:otherwise>
					</c:choose>
				</c:otherwise>
			</c:choose>

			<c:if test="${item.outgoing}">
				<div class="associationText"><spring:message code="association.typeId.outgoing.${item.associationType}.postfix" text="${item.associationType}"/></div>
			</c:if>

			<c:if test="${item.incoming}">
				<div class="associationText"><spring:message code="association.typeId.incoming.${item.associationType}" text="${item.associationType}"/></</div>
			</c:if>
		</div>
	</display:column>

	<display:column title="" decorator="com.intland.codebeamer.ui.view.table.TrimmedColumnDecorator" media="html"
		class="action-column-minwidth columnSeparator">

		<c:choose>
			<c:when test="${ui:isTrackerItem(item.endPoint.dto)}">
				<tag:trackerItemPermissions item="${item.endPoint.dto}" var="itemPermissions" />

				<c:if test="${itemPermissions.allowedToViewComment}">
					<a href="#" class="viewComments" data-item-id="${item.endPoint.id}" data-version-id="${item.endPoint.version}">
						<spring:message code="comments.view.label" text="Comments"/>
					</a>
				</c:if>
			</c:when>
		</c:choose>

	</display:column>

	<display:column title="" decorator="com.intland.codebeamer.ui.view.table.TrimmedColumnDecorator" media="html"
		class="action-column-minwidth columnSeparator assocCMenuCol">
		<c:if test="${item.outgoing}">
			<ui:actionMenu builder="associationListContextActionMenuBuilder" subject="${item}" alwaysDisplayContextMenuIcons="${alwaysDisplayContextMenuIcons}"/>
		</c:if>
	</display:column>

	<spring:message var="associationComment" code="association.description.label" text="Comment"/>
	<display:column title="${associationComment}" sortProperty="description" sortable="true" headerClass="textData" class="textDataWrap columnSeparator" style="width:40%">
		<tag:transformText value="${item.description}" format="${item.descriptionFormat}" />
	</display:column>

</display:table>
