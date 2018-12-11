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
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>

<script type="text/javascript" src="<ui:urlversioned value='/agile/selectTracker.js'/>"></script>
<script type="text/javascript">
	$(document).ready(function () {
		selectTracker.showProjectTrackers();
	})
</script>


<style type="text/css">
	select {
		border: 1px solid #d1d1d1;
		padding: 4px;
	}
	#project {
		min-width: 16em;
		width: 38%;
	}
	.trackerSelector {
		min-width: 16em;
		width: 38%;
	}
	.trackerSelector .branchTracker {
		color: #187a6d !important;
	}
</style>

<label for="project" class="labelCell optional"><spring:message code="project.label" text="Project"></spring:message>:</label>
<select id="project" name="project" onchange="selectTracker.showProjectTrackers();" class="dataCell">
	<c:forEach items="${projects}" var="project">
		<option value="${project.id}">
			<c:out value="${project.name}"/>
		</option>
	</c:forEach>
</select>

<span>
	<label for="project" class="labelCell optional"><spring:message code="tracker.label.general" text="Tracker"></spring:message>:</label>
	<select id="tracker" class="dataCell">
		<c:forEach items="${projects}" var="project">
			<c:forEach items="${trackersByProject[project]}" var="tracker"  varStatus="loop">
				<c:if test="${not empty iconProvider}">
					<c:url var="iconUrl" value="${iconProvider.getIconUrl(tracker.type)}"/>
				</c:if>
				<option class="${tracker.branch ? 'branchTracker' : ''}" value="${tracker.id}" data-projectid="${project.id}"<c:if test="${not empty iconProvider}"> data-icon-url="${iconUrl}" data-bg-color="${iconProvider.getIconBgColor(tracker.type)}"</c:if>>
					<c:if test="${not empty branchLevels && tracker.branch}">
						<c:set var="level" value="${branchLevels[tracker.id]}"></c:set>
						<c:forEach var="i" begin="1" end="${level*3}">&nbsp;</c:forEach>
					</c:if>
					<c:out value="${tracker.name}"/>
				</option>
			</c:forEach>
		</c:forEach>
	</select>
</span>

