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
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="bugstaglib" prefix="bugs" %>
<%@ taglib uri="taglib" prefix="tag" %>

<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="callTag" prefix="ct" %>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>

<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>

<c:set var="widthPerStatus" value="${100 / fn:length(columns)}%"/>
<c:url var="collapserIcon" value="/images/newskin/action/column-collapse.png"/>

<style type="text/css">
	#issuesPerStatus {
		width: 100%;
		min-height: 15px;
		border: 1px solid #d1d1d1;
	}

	#issuesPerStatus div {
		padding-top: 8px;
		padding-bottom: 8px;
	}

	#issuesPerStatus label {
		color: transparent;
		display:none;
	}

	#issuesPerStatus span {
		font-size: 13px;
	}

	.collapsedColumn {
		display: none;
	}

	.rotate {
		display: inline-block;
		width: 20px;
		white-space: nowrap;
		margin-top: 30px;
		float: right !important;

		-moz-transform:rotate(90deg); /* Firefox */
		-webkit-transform:rotate(90deg); /* Safari and Chrome */
		-o-transform:rotate(90deg); /* Opera */
		-ms-transform:rotate(90deg); /* IE */
		transform:rotate(90deg);
	}

	.IE8 .rotate {
		display: inline-block;
		width: 20px;
		white-space: nowrap;
		margin-top: 30px;
		float: right !important;
		-ms-writing-mode: tb-lr;
	}

	.IE .rotated.columnCollapser {
		margin-bottom: 0px !important;
	}

	.swimlaneContent .swimlaneToggler {
		vertical-align: middle;
		position: static !important;
	}

	.newskin table#userStories .swimlaneContent div.nameLabel {
		display: inline-block !important;
		vertical-align: middle;
		position: inherit;
		max-width: 300px;
	}

	.swimlaneContent div {
		width: auto !important;
		height: auto !important;
		padding-left: 0px !important;
	}

	.swimlaneContent .groupCount.numberLabel {
		vertical-align: middle;
		position: static !important;
	}

	.swimlaneContent .storyPointsLabel.cardboard {
		vertical-align: middle;
		position: static !important;
	}

	.swimlaneContent .loggedInIndicator {
		vertical-align: middle;
		position: relative;
		top: -2px;
	}

</style>


<c:choose>
	<c:when test="${not empty errorMessage}">
		<div class="error"><c:out value="${errorMessage}"/></div>
	</c:when>
	<c:when test="${empty stories}">
		<spring:message code="table.nothing.found" text="Nothing found to display"/>
	</c:when>
	<c:otherwise>
		<jsp:include page="setCardboardConfig.jsp"/>
		<c:if test="${trimmed}">
			<input type="hidden" id="trimmed" value="true"/>
		</c:if>
		<spring:message code="cardboard.story.points.title" var="storyPointsTitle" text="Story Points"/>
		<table id="userStories">
			<tbody>
				<tr class="infoHeader">
					<c:forEach items="${columns}" var="option" varStatus="iterationStatus">
						<c:set var="unfilteredCount" value="-1"/>
						<c:if test="${unfilteredCounts != null}">
							<c:set var="unfilteredCount" value="${unfilteredCounts[option]}"/>
						</c:if>
						<td class="info" id="info_${option.id}" data-unfilteredCount="${unfilteredCount}">
							<c:if test="${option.minimum  != null}"><input type="hidden" class="minimum" value="${option.minimum }"/></c:if>
							<c:if test="${option.maximum  != null}"><input type="hidden" class="maximum" value="${option.maximum }"/></c:if>
							<c:if test="${option.id != 3}">
								<!-- if not in the done column -->
								<div class="minMaxInfo" data-id="${option.id }"></div>
							</c:if>
							<c:if test="${(iterationStatus.last) and (!trackerCardboard)}">
								<spring:message code="tracker.view.layout.planner.for.release.title" arguments="${subject.name}" var="plannerTitle"/>
								<c:url value="/item/${subject.id}/planner" var="plannerUrl"/>
								<a href="${plannerUrl}" title="${plannerTitle}"><span class="planner-icon"></span></a>
							</c:if>
						</td>
					</c:forEach>
				</tr>
				<tr class="header">
					<spring:message code="tracker.view.layout.cardboard.column.toggle.tooltip" text="Click here to toggle the column" var="togglerTooltip"/>
					<spring:message code="cardboard.column.collapse" text="Click here to expand/collapse this swimlane" var="columnCollapserTitle"></spring:message>
					<c:forEach items="${columns}" var="option" varStatus="iterationStatus">
						<c:set var="isOpenStatus" value="${option.id eq 0 or option.id eq 1}" />
						<td class="${!iterationStatus.last ? 'notLast' : 'last' }" id="header_${option.id}" style="width:${widthPerStatus}; height: 20px;" data-id="${option.id}">
							<c:set var="headerName" value="${columnNames[option]}"></c:set>
							<div>${not empty headerName ? headerName : option.name} <div class="columnCollapser" title="${columnCollapserTitle}">
								</div> <span class="storyPointsLabel cardboard ${isOpenStatus ? 'open' : 'closed'}" title="${storyPointsTitle}"></span><span class="numberLabel">${fn:length(issuesGrouped[option])}</span></div>
						</td>
					</c:forEach>
				</tr>
				<c:set var="grouped" value="${!empty swimlanes}"/>
				<c:forEach items="${issueMatrix}" var="matrixEntry">
					<c:if test="${grouped}">
						<c:forEach items="${matrixEntry.key.headers}" var="matrixEntryHeader">
						<tr class="groupHeader headerLevel${matrixEntryHeader.key}" data-groupNumber="${matrixEntry.key.id}" data-groupLevel="${matrixEntryHeader.key}">
							<c:forEach items="${columns}" var="option" varStatus="iterationStatus">
								<td data-id="${option.id}" class="${!iterationStatus.last ? 'notLast' : 'last' }">
									<c:choose>
										<c:when test="${iterationStatus.first}">
											<div class="swimlaneHeader">
												<div class="swimlaneContent">
													<spring:message var="swimlaneCollapserTitle" code="cardboard.swimlane.collapse" text="Click here to expand/collapse this swimlane"/>
													<div class="swimlaneToggler" title="${swimlaneCollapserTitle}"></div>
													<div class="nameLabel ellipsis">
														<c:choose>
															<c:when test="${swimlanes == 'assignee'}">
																<ui:nameWithTeamIndicators auxiliaryTeamContext="${auxiliaryTeamContext}" userId="${matrixEntry.key.id}">
																	${matrixEntry.key.name}
																</ui:nameWithTeamIndicators>
															</c:when>
															<c:when test="${swimlanes == 'team' || swimlanes == 'requirement' || swimlanes == 'userStory'}">
																<span style="color: ${matrixEntry.key.wrappedDto.color};">
																	<c:choose>
																		<c:when test="${not empty matrixEntry.key.urlLink}">
																			<a href="${pageContext.request.contextPath}${matrixEntry.key.urlLink}" target="_blank">${matrixEntry.key.name}</a>
																		</c:when>
																		<c:otherwise>
																			${matrixEntry.key.name}
																		</c:otherwise>
																	</c:choose>
																</span>
															</c:when>
															<c:otherwise>
																${matrixEntryHeader.value}
															</c:otherwise>
														</c:choose>
													</div>
													<%--<c:set var="assigneeId" value="${matrixEntry.key.id}" />--%>
													<%--<tag:userLoginIndicator userId="${assigneeId}"></tag:userLoginIndicator>--%>
													<span class="groupCount numberLabel"></span>
													<span class="storyPointsLabel cardboard" title="${storyPointsTitle}"></span>
												</div>
											</div>
										</c:when>
										<c:when test="${iterationStatus.last and swimlanes == 'release'}">
											<spring:message code="tracker.view.layout.planner.for.release.title" arguments="${matrixEntry.key.name}" var="plannerTitle"/>
											<c:url value="/item/${matrixEntry.key.id}/planner" var="plannerUrl"/>
											<a href="${plannerUrl}" title="${plannerTitle}" class="planner-link"><span class="planner-icon"></span></a>
										</c:when>
									</c:choose>
								</td>
							</c:forEach>
						</tr>
						</c:forEach>
					</c:if>
					<tr class="body ${recursive ? 'recursive' : '' }">
						<c:forEach items="${columns}" var="option" varStatus="iterationStatus">
							<c:set var="id" value="${option.id }"/>
							<c:if test="${grouped}">
								<c:set var="id" value="${matrixEntry.key.groupId}_${option.id}"/>
							</c:if>
							<td class="lane ${!iterationStatus.last ? 'notLast' : 'last' } ${grouped ? 'grouped' : ''}"
							 id="${id}" name="${option.id}" group="${matrixEntry.key.groupId}" data-id="${option.id}">
								<c:forEach items="${matrixEntry.value[option]}" var="story">
									<ct:call object="${editableIssues}" method="contains" return="isEditable" param1="${story}"/>
									<c:if test="${!isEditable}">
										<c:set var="explanation" value="${explanations[story.id]}"/>
									</c:if>
									<c:set var="color" value="${colors[story]}"/>
									<c:set var="parent" value="${parents[story]}"/>
									<bugs:card isEditable="${isEditable }" disableEditing="${!hasAgileLicense || !isEditable }" story="${story}" explanation="${explanation }" groupIndex="${matrixEntry.key.groupId}"
											   color="${color}" colorItem="${parent}"/>

								</c:forEach>
								<div class="hiddenUserStory"></div>
							</td>
						</c:forEach>
					</tr>
				</c:forEach>
			</tbody>
		</table>
	</c:otherwise>
</c:choose>
