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

<ol class="team-list">
	<c:forEach items="${teamHierarchy}" var="teamInfo">
		<li class="team filter ui-droppable ${teamInfo.id == -1 ? 'virtual-team' : '' } ${teamInfo.level != 0 ? 'subteam' : ''} ${!teamInfo.hasChildren ? 'noChildren' : '' }"
			 data-teamid="${teamInfo.team.id }" style="margin-left: ${teamInfo.level*10}px;" data-level="${teamInfo.level}">
			<div class="knob" style="background-color: ${teamInfo.color};"></div>
			<c:if test="${teamInfo.hasChildren }"><a class="expander expanded" data-teamid="${teamInfo.team.id }"></a></c:if>
			<div class="state-indicator"></div>
			<a class="project-status color-box big" data-teamid="${teamInfo.team.id}" style="background-color: ${teamInfo.color};"></a>
			<div class="team-info-container">
				<span class="title">${ui:escapeHtml(teamInfo.team.name)}</span>
				<span class="issue-count">
					<span class="issueCountContainer">${empty teamInfo.issueCount ? 0 : teamInfo.issueCount}</span>
					<div class="storyPointsContainer">
						<div class="storyPointsLabel open">${empty teamInfo.storyPoints ? 0 : teamInfo.storyPoints}<div class="storyPointsIcon"></div></div>
					</div>
				</span>
			</div>
			<c:if test="${teamInfo.editable}">
				<span class="simpleDropdownMenu"><img src="${pageContext.request.contextPath}/images/space.gif" class="menuArrowDown"></span>
			</c:if>
		</li>
	</c:forEach>
</ol>