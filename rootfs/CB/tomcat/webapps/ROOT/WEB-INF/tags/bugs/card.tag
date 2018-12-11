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
<%@tag language="java" pageEncoding="UTF-8" %>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="taglib" prefix="tag" %>

<%@ taglib uri="callTag" prefix="ct" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<%@ tag import="com.intland.codebeamer.ui.view.PriorityRenderer"%>
<%@ tag import="com.intland.codebeamer.ui.view.table.TrackerSimpleLayoutDecorator" %>
<%@ tag import="com.intland.codebeamer.manager.TrackerItemManager" %>
<%@ tag import="com.intland.codebeamer.controller.ControllerUtils" %>

<%@ attribute name="isEditable" required="false" type="java.lang.Boolean" %>
<%@ attribute name="disableEditing" required="false" type="java.lang.Boolean" description="disables moving/editing the card even if it's editable"%>
<%@ attribute name="story" required="false" type="com.intland.codebeamer.persistence.dto.TrackerItemDto" %>
<%@ attribute name="explanation" required="false" %>
<%@ attribute name="groupIndex" required="false" %>
<%@ attribute name="cssClass" required="false" %>
<%@ attribute name="color" required="false" %>
<%@ attribute name="colorItem" required="false" type="com.intland.codebeamer.persistence.dto.TrackerItemDto" %>

<%
	PriorityRenderer priorityRenderer = new PriorityRenderer(request);
	priorityRenderer.setHandleCustomPriorityAsDefaultValue(true);
	TrackerSimpleLayoutDecorator decorated = new TrackerSimpleLayoutDecorator(request);
	jspContext.setAttribute("currentUser", ControllerUtils.getCurrentUser(request));
	jspContext.setAttribute("trackerItemManager", TrackerItemManager.getInstance());
	decorated.initForTrackerItem(story);
	jspContext.setAttribute("decorated", decorated);
%>

<ui:UserSetting var="newWindowTarget" setting="NEW_BROWSER_WINDOW_TARGET" />

<c:choose>
	<c:when test="${decorated.nameVisible && not empty story.name}">
		<c:set var="cardName"><c:out value="${story.name}"/></c:set>
	</c:when>
	<c:when test="${!decorated.nameVisible}">
		<spring:message code="tracker.view.layout.document.summary.not.readable" text="[Summary not readable]" var="cardName"/>
	</c:when>
	<c:otherwise>
		<spring:message code="tracker.view.layout.document.no.summary" text="[No Summary]" var="cardName"/>
	</c:otherwise>
</c:choose>

<c:if test="${displayUserStory}">
	<c:set var="userStoryName" value="${not empty colorItem ? colorItem.name: ''}" />
</c:if>

<c:set var="notScheduled" value="false"/>
<c:if test="${empty story.versions}">
	<c:set var="notScheduled" value="true"/>
</c:if>

<c:url var="storyUrl" value="/cardboard/editCard.spr">
	<c:param name="task_id" value="${story.id}"/>
	<c:param name="noCancel" value="true"/>
	<c:param name="swimlanes" value="${swimlanes}"/>
</c:url>

<c:if test="${story.status == null}">
	<spring:message code="tracker.field.value.unset.label" text="Unset" var="statusName"/>
</c:if>
<c:if test="${story.status != null}">
	<c:set var="statusName" value="${story.status.name}"/>
</c:if>
<ct:call object="${statusName}" method="toUpperCase" return="statusName"/>

<c:if test="${displayStoryPoint}">
	<ct:call object="${trackerItemManager}" method="isStoryPointAggregated" param1="${currentUser}" param2="${story}" return="isStoryPointAggregated"/>
	<spring:message var="aggregatedStoryPointHint" code="planner.storyPointsAggregated.tooltip" />
</c:if>

<ui:coloredEntityIcon subject="${story}" iconBgColorVar="bgColor" iconUrlVar="iconUrl"/>

<c:if test="${!empty color || (empty color && not empty colorItem && not empty colorItem.name)}">
	<c:if test="${empty colorItem or colorItem.id < 0}">
		<%-- if item is virtual or missing, add link to self --%>
		<c:set var="colorItem" value="${story}" />
	</c:if>
	<c:set var="colorItemUrlAttribute" value="href='${pageContext.request.contextPath}${colorItem.urlLink}' target='${newWindowTarget}'" />
</c:if>

<div class="userStory ${notScheduled ? 'notScheduled' : ''} ${cssClass}" id="${story.id}" name="${story.id}" trackerId="${story.tracker.id}"
	statusId="${story.status == null ? '-1' : story.status.id }" group="${groupIndex}">

	<c:set var="handleTitle" value=""/>
	<c:if test="${disableEditing || !isEditable}">
		<spring:message var="handleTitle" code="${explanation}"/>
	</c:if>

	<div class="dragHandle userStoryHandle ${isEditable && !disableEditing ? 'editable' : 'notEditable' }" style="background-color: ${bgColor}" title="${handleTitle}"> </div>

	<div class="card-content">

		<div class="card-header">

			<div class="key-and-id-container">

				<div class="item-icon">
					<c:url var="iconLink" value="${iconUrl}"/>
					<ui:tooltipWrapper dto="${story}">
						<img src="${iconLink}" style="background-color:${bgColor}" class="issueIcon"/>
					</ui:tooltipWrapper>
				</div>

				<div class="item-link ellipsis">
					<ui:itemLink item="${story}" showItemName="${false}" showItemDescription="${false}" target="${newWindowTarget}"/>
				</div>

			</div>

			<c:if test="${displayUserPhoto}">

				<div class="user-photo-container">

					<c:if test="${fn:length(story.assignedTo) > 0}">
						<c:forEach items="${story.assignedTo}" var="assignee">
							<c:if test="${empty firstAssignee && ui:isUser(assignee)}">
								<c:set var="firstAssignee" value="${assignee}" />
							</c:if>
						</c:forEach>

						<ui:userPhoto userId="${firstAssignee.id}" placeholderGeneration="${true}"/>
					</c:if>

				</div>

			</c:if>

		</div>

		<div class="main-section">

			<div class="main-section-icon-container">

				<c:if test="${displayPriority}">
					<div class="priorityIcon">
						<%
							out.print(priorityRenderer.renderNamedPriority(story.getNamedPriority()));
						%>
					</div>
				</c:if>

				<c:if test="${!disableEditing }"><a class="card-issue-editor-icon details-arrow" href="javascript:showPopupInline('${storyUrl}',{geometry: 'large'});" title="<c:out value="${statusName}: ${cardName}"/>"></a></c:if>

			</div>

			<div class="dragHandle ${isEditable && !disableEditing ? 'editable' : 'notEditable' } main-section-content-container">
				<div class="card-name">${cardName}</div>
			</div>

		</div>

		<c:if test="${displayUserStory || displayStoryPoint}">

			<div class="user-story-section dragHandle ${isEditable && !disableEditing ? 'editable' : 'notEditable' }">

				<div class="user-story-section-icon-container">

					<c:if test="${displayStoryPoint}">

						<c:choose>
							<c:when test="${story.storyPoints != null}">
								<c:set var="ignore" value="${not empty story.parent }"/>
								<div class="storyPoints ${ignore ? 'ignore' : '' }" data-points="${story.storyPoints}" title="${isStoryPointAggregated ? aggregatedStoryPointHint : ''}">
									<span>${isStoryPointAggregated ? '&sum;<br>' : ''}${story.storyPoints}</span>
								</div>
							</c:when>
							<c:otherwise>
								<div class="storyPoints"><span>-</span></div>
							</c:otherwise>
						</c:choose>

					</c:if>

				</div>

				<div class="user-story-section-content-container ${displayUserStory ? 'badge': ''} ${empty color && not empty colorItem && not empty colorItem.name ? 'empty-badge' : ''}" <c:if test="${not empty color}">style="background-color: ${color}"</c:if>>

					<c:if test="${displayUserStory && not empty colorItem && not empty colorItem.name}">
						<div class="user-story-name ellipsis">
							<a ${colorItemUrlAttribute} title="<c:out value="${colorItem != null ? colorItem.name : ''}" />">
								<c:out value="${colorItem != null ? colorItem.name : ''}"/>
							</a>
						</div>
					</c:if>

				</div>

			</div>

		</c:if>

		<c:if test="${displayAssignees || displayReleases}">

			<div class="card-footer<c:if test="${!displayUserStory && !displayStoryPoint}"> footer-only</c:if>">

				<div class="card-footer-content-container">

					<c:if test="${displayReleases}">

						<div class="versionList ellipsis">
							<c:out escapeXml="false" value="<%= decorated.getVersions() %>" default="--"/>
						</div>

					</c:if>

					<c:if test="${displayAssignees}">

						<div class="assigneeList ellipsis">
							<c:choose>
								<c:when test="${fn:length(story.assignedTo) > 0}">
									<c:forEach items="${story.assignedTo}" var="assignee" varStatus="st">
										<c:if test="${not st.first}">
											<span class="comma-separator">,</span>
										</c:if>

										<c:choose>
											<c:when test="${ui:isUser(assignee)}">
												<tag:userLink user_id="${assignee.id}"/>
											</c:when>
											<c:otherwise>
												<span>${assignee.name}</span>
											</c:otherwise>
										</c:choose>

									</c:forEach>
								</c:when>
								<c:otherwise>
									<c:out value="--" />
								</c:otherwise>
							</c:choose>
						</div>

					</c:if>

				</div>

			</div>

		</c:if>

	</div>

</div>

