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
<%@ tag language="java" pageEncoding="UTF-8" %>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="taglib" prefix="tag" %>

<%@ tag import="com.intland.codebeamer.remoting.GroupTypeClassUtils"%>
<%@ tag import="com.intland.codebeamer.controller.ControllerUtils"%>
<%@ tag import="com.intland.codebeamer.persistence.dto.UserDto"%>
<%@ tag import="org.springframework.context.ApplicationContext"%>
<%@ tag import="com.intland.codebeamer.manager.ObjectRatingManager"%>
<%@ tag import="com.intland.codebeamer.persistence.dto.ObjectRatingStatsDto"%>
<%@ tag import="com.intland.codebeamer.persistence.dto.ObjectRatingDto"%>
<%@ tag import="com.intland.codebeamer.persistence.dto.TrackerItemDto"%>
<%@ tag import="com.intland.codebeamer.persistence.dto.WikiPageDto"%>
<%@ tag import="com.intland.codebeamer.persistence.dto.base.IdentifiableDto"%>
<%@ tag import="com.intland.codebeamer.security.ProjectRequestWrapper"%>
<%@ tag import="org.apache.log4j.Logger"%>
<%@ tag import="com.fasterxml.jackson.databind.ObjectMapper"%>
<%@ tag import="com.intland.codebeamer.ajax.JsonView"%>
<%@ tag import="com.intland.codebeamer.persistence.dto.TrackerTypeDto"%>
<%@ tag import="java.util.Collections"%>

<c:catch var="throwable">

<%--
	Tag to render rating of an entity, with ajax calls allows changing the ratings.
--%>
<%@ attribute name="entity" required="false" type="com.intland.codebeamer.persistence.dto.base.IdentifiableDto"
	description="The entity object to rate/show rating for. If missing then automatically the current 'ProjectAwareDto' is used." %>
<%@ attribute name="voting" required="false" type="java.lang.Boolean"
	description="Set true if this widget should be in voting mode" %>
<%@ attribute name="onlyForWikiOrIssue" required="false" type="java.lang.Boolean"
	description="Show the rating widget only for wikis or issues" %>
<%@ attribute name="disabled" required="false" type="java.lang.Boolean"
	description="If the widget is disabled, defaults to false" %>
<%@ attribute name="cssClass" required="false"
	description="Optional css class to put on the top container for the rating/voting widget."%>
<%@ attribute name="title" required="false"
	description="Optional tooltip displayed when mouse moves over the widget."%>

<%
	if (disabled == null) {
		disabled = Boolean.FALSE;
		jspContext.setAttribute("disabled", disabled);
	}

	// query the rating statistics using the manager
	UserDto user = ControllerUtils.getCurrentUser(request);
	// only signed-in users can rate
	if (user == null) {
		return;
	}
	if (entity == null) {
		Object projectAware = request.getAttribute(ProjectRequestWrapper.PROJECT_AWARE_DTO);
		if (projectAware instanceof IdentifiableDto == false) {
			return;
		}
		entity = (IdentifiableDto) projectAware;
		jspContext.setAttribute("entity", entity);
	}
	if (Boolean.TRUE.equals(onlyForWikiOrIssue)) {
		// NOTE: rating is only available for issues, and only real issues not releases
		if (entity instanceof TrackerItemDto) {
			TrackerItemDto issue = (TrackerItemDto) entity;
			// dont' show rating for pull requests
			if (issue.getTracker().isPullRequest()) {
				return;
			}
			if (issue.isA(Collections.singleton(TrackerTypeDto.RELEASE))) {
				return;
			}
		} else {
			return;
		}
	}

	Integer entityTypeId = GroupTypeClassUtils.objectToGroupType(entity);
	Integer entityId = entity.getId();

	ApplicationContext ctx = ControllerUtils.getSpringDispatcherServletContext(request);
	ObjectRatingManager manager = ctx.getBean(ObjectRatingManager.class);
	ObjectRatingStatsDto objectRatingStats = manager.findRatingStatsForEntity(entityTypeId, entityId);
	// if no rating yet, just create an empty object
	if (objectRatingStats == null) {
		objectRatingStats = new ObjectRatingStatsDto();
	}
	jspContext.setAttribute("objectRatingStats", objectRatingStats);
	String statsJSON = new ObjectMapper().writeValueAsString(objectRatingStats);
	jspContext.setAttribute("objectRatingStatsJSON", statsJSON);

	// find the user's rating info
	ObjectRatingDto userRating = manager.getRating(user, entityTypeId, entityId);
	// don't send the user and dto over to JSON
	userRating.setSubmitter(null);
	userRating.setDto(null);

	jspContext.setAttribute("userRating", userRating);
	String userRatingJSON = JsonView.toJSON(userRating, true);	// html escape too because the comment goes there
	jspContext.setAttribute("userRatingJSON", userRatingJSON);

	jspContext.setAttribute("entityTypeId", entityTypeId);
%>

<c:set var="id" value="${entityTypeId}_${entity.id}" />

<c:choose>
	<c:when test="${voting}">
			<%
				if (cssClass == null) {
					cssClass = "";
				}

				if (userRating != null && userRating.getRate() != null && userRating.getRate() != 0) {
					cssClass += " voted-as-" + (userRating.getRate() > 0 ? "positive" : "negative");
				}
				if (objectRatingStats != null) {
					if (objectRatingStats.getRatingTotal() > 0) {
						cssClass += " voted-total-positive";
					}
					if (objectRatingStats.getRatingTotal() < 0) {
						cssClass += " voted-total-negative";
					}
				}
				jspContext.setAttribute("cssClass", cssClass);
			%>
			<span id='votingwidget_${id}' class="votingwidget ${cssClass} ${disabled ? 'votingwidget_disabled' :''}" title="${title}" >
				<a class="yes-vote" href="#" <c:if test="${disabled}">onclick="return false;"</c:if> >&nbsp;</a>
				<span id='votingtotal_${id}' class="votingtotal">${objectRatingStats.ratingTotal}</span>
				<a class="no-vote" href="#" <c:if test="${disabled}">onclick="return false;"</c:if> >&nbsp;</a>
			</span>

			<c:if test="${! disabled}">
			<SCRIPT LANGUAGE="JavaScript" type="text/javascript">
				$(function() {
					var objectRatingStats = ${objectRatingStatsJSON};
					var userRating = ${userRatingJSON};
					new Voting("#votingwidget_${id}", objectRatingStats, userRating, ${entityTypeId}, ${entity.id} );
				});
			</SCRIPT>
			</c:if>
	</c:when>
	<c:otherwise>
		<div id="ratingwidget_${id}" class="ratingwidget ${disabled ? 'ratingDisabled' : '' } ${cssClass}" title="${title}" ></div>
		<SCRIPT LANGUAGE="JavaScript" type="text/javascript">
			$(function(){
				var objectRatingStats = ${objectRatingStatsJSON};
				var userRating = ${userRatingJSON};
				new Rating("#ratingwidget_${id}", objectRatingStats, userRating, ${entityTypeId}, ${entity.id} );
			});
		</SCRIPT>
	</c:otherwise>
</c:choose>
</c:catch>
<c:if test="${!empty throwable}">
<%
	Logger logger = Logger.getLogger("com.intland.codebeamer.rating.tag");
	logger.warn("Exception in rating.tag", (Throwable) jspContext.findAttribute("throwable"));
%>
</c:if>