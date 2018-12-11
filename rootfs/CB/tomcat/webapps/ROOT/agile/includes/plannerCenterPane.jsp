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
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="callTag" prefix="ct" %>
<%@ taglib uri="uitaglib" prefix="ui" %>

<a href="#" class="left-pane-toggle"></a>

 <%--TODO --%>
<%--<div class="action-lane right">--%>
	<%--<c:set var="disabled" value="${hasAgileLicense ? '' : 'disabled=\"disabled\"'}"/>--%>
	<%--<input type="checkbox" id="showParentItems"<c:if test="${showParents == 'true'}"> checked="checked"</c:if>></input>--%>
	<%--<label for="showParentItems"><spring:message code="planner.showParentItems" text="Show Parent Items"/></label>--%>

	<%--<select id="tracker-select" multiple="multiple">--%>
		<%--<c:forEach items="${trackersByProject}" var="entry">--%>
			<%--<optgroup label="${entry.key.name }">--%>
				<%--<c:forEach items="${entry.value}" var="tracker">--%>
					<%--<ct:call object="${selectedTrackers }" method="contains" param1="${tracker.id }" return="selected"/>--%>
					<%--<option value="${tracker.id }" title="${tracker.name }" ${selected ? 'selected="selected"' : '' }>${tracker.name }</option>--%>
				<%--</c:forEach>--%>
			<%--</optgroup>--%>
		<%--</c:forEach>--%>
	<%--</select>--%>

    <%--<input ${disabled} class="filter-text" type="text" value="<c:out value="${filter.issueText}"/>">--%>
<%--</div>--%>

<div class="overflow">

	<c:if test="${isProjectBacklog}">
		<jsp:include page="/agile/includes/plannerBacklogControls.jsp" />
	</c:if>

	<c:choose>
		<c:when test="${!isProjectBacklog || projectBacklogState.tabIndex == 0}">

			<div class="subtext nothing-found-message" style="text-align: center;<c:if test="${!empty items}">display: none;</c:if>">
				<spring:message code="table.nothing.found" text="Nothing found to display"></spring:message>
			</div>

			<c:if test="${!empty items}"><jsp:include page="plannerIssueList.jsp" /></c:if>

			<script type="text/javascript">
				codebeamer.plannerConfig = jQuery.extend(codebeamer.plannerConfig || {}, {
					// updating the count of issues/story points as the content of the version changes
					"versionsViewModel": ${versionsViewModelJson}
				});
			</script>
		</c:when>
		<c:when test="${projectBacklogState.tabIndex == 1}">
			<jsp:include page="plannerBacklogHistory.jsp" />
		</c:when>
	</c:choose>
</div>
