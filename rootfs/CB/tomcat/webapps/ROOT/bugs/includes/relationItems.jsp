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
<%@ taglib uri="taglib" prefix="tag" %>
<%@ taglib uri="bugstaglib" prefix="bugs" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>

<%@ page import=" com.intland.codebeamer.controller.support.relations.RelationItem" %>
<%@ page import="com.intland.codebeamer.ui.view.ColoredEntityIconProvider" %>
<%@ page import="com.intland.codebeamer.persistence.dto.base.BaseDto" %>
<%@ page import="com.intland.codebeamer.persistence.dto.TrackerItemDto" %>
<%@ page import="com.intland.codebeamer.persistence.dto.UserDto" %>
<%@ page import="com.intland.codebeamer.manager.ReferenceSettingManager" %>
<%--
Parameters in scope:
	- relationItems
	- cssClass
	- showDescription
--%>

<jsp:useBean id="taskRevision" beanName="taskRevision" scope="request" type="com.intland.codebeamer.persistence.dto.TrackerItemRevisionDto" />
<tag:itemDependecy var="itemDependency" item_id="${taskRevision.id}" item_type_id="${taskRevision.typeId}" item_rev="${taskRevision.baseline.id}" scope="request" />

<c:set var="revision" value="${taskRevision != null and taskRevision.baseline != null ? taskRevision.baseline.id : null}"/>

<div class="${cssClass}">
	<c:forEach items="${relationItems}" var="relationItem"><tag:joinLines>
		<%
			String renderedBadges = "";
			RelationItem relationItem = (RelationItem) pageContext.getAttribute("relationItem");
			BaseDto item = relationItem.getItem();
			if (relationItem.getWrapper() != null) {
				renderedBadges = ReferenceSettingManager.getInstance().renderReferenceSettingBadges(relationItem.getWrapper(), request);
			}
			if (relationItem.getIncomingWrapper() != null) {
				renderedBadges = ReferenceSettingManager.getInstance().renderReferenceSettingBadges(relationItem.getIncomingWrapper(), request);
			}
			pageContext.setAttribute("renderedBadges", renderedBadges);
			pageContext.setAttribute("item", item);
			pageContext.setAttribute("isClosedItem", Boolean.valueOf((item instanceof TrackerItemDto) && ((TrackerItemDto) item).isClosed()));
			pageContext.setAttribute("isUserItem", Boolean.valueOf(item instanceof UserDto));
		%>

		<c:if test="${relationItem.referable == true || (not empty relationItem.summary && not empty relationItem.url)}">
			<div class="relation-item">
				<c:choose>
					<c:when test="${item != null}">
						<c:set var="iconUrl"><%= request.getContextPath() + ColoredEntityIconProvider.getInstance().getIconUrl(item) %></c:set>
						<c:set var="iconBgColor"><%= ColoredEntityIconProvider.getInstance().getIconBgColor(item) %></c:set>
						<c:set var="titleHtml">
							<c:if test="${! empty relationItem.keyAndId}">
								<c:out value="${relationItem.projectName} - ${relationItem.trackerName}" />
							</c:if>
						</c:set>
						<c:set var="issueSummaryHtml">
							<ui:tooltipWrapper dto="${item}" cssClass="tooltip-middle-align">
								<img style="background-color: ${iconBgColor}" src="${iconUrl}" alt="icon">
							</ui:tooltipWrapper>
							<span class="summary${isClosedItem ? ' closedItem' : ''}">
								<c:choose>
									<c:when test="${isUserItem}">
										<tag:userLink user_id="${item.id}"/>
									</c:when>
									<c:otherwise>
										<c:url var="url" value="${item.urlLink}">
											<c:if test="${! empty param.revision}"><c:param name="revision" value="${param.revision}"  /></c:if>
										</c:url>

										<a href="${url}" title="${titleHtml}">
											<c:if test="${! empty relationItem.keyAndId}">[<c:out value="${relationItem.keyAndId}"/>]</c:if>
											<c:out value="${relationItem.summary}" />
										</a>
									</c:otherwise>
								</c:choose>
							</span>
						</c:set>
					</c:when>
					<c:otherwise>
						<c:set var="issueSummaryHtml">
							<span class="summary without-icon"><a href="${relationItem.url}" title="<c:out value="${relationItem.summary}"/>"><c:out value="${relationItem.summary}" /></a></span>
						</c:set>
					</c:otherwise>
				</c:choose>

				<c:if test="${showDescription}">
					<c:set var="descriptionHtml">
						<span class="description subtext">${relationItem.description}</span>
					</c:set>
				</c:if>

				${issueSummaryHtml} ${descriptionHtml}

				<c:if test="${relationItem.association}"><span class="remark"><spring:message code="relations.associationIndicator" text="association"/></span></c:if>

				<c:set var="association" value="${relationItem.associationObject}" />

				<c:if test="${relationItem.association and association.suspected and (empty task or task.id eq association.from.id or task.id eq association.to.id)}">
					<bugs:suspectedLinkBadge from="${association.from.id}" to="${association.to.id}" revision="${revision}"
											 clearable="${empty association.reference.version}" association="${association}" />
				</c:if>
				<c:if test="${relationItem.association and !association.suspected and association.propagatingSuspects and (empty task or task.id eq association.from.id or task.id eq association.to.id)}">
					<spring:message code="association.propagatingSuspects.info" var="propagatingSuspectsInfo"/>
					<spring:message var="suspectedLabel" code="association.suspected.label" text="Suspected" />
					<span class="suspectedLinkBadge suspect inactiveSuspectedLinkBadge" title="${propagatingSuspectsInfo}">  ${suspectedLabel} <c:if test="${association.reverse}"><span class="reverseSuspectImg"></span></c:if></span>
				</c:if>
				<c:if test="${not empty renderedBadges}">
					${renderedBadges}
				</c:if>
			</div>
		</c:if>
		</tag:joinLines>
	</c:forEach>

</div>
