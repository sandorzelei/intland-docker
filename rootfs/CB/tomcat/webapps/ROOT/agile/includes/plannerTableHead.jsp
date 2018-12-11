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

<%@ taglib uri="taglib" prefix="tag"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>

<thead>
<tr class="tableHeader">
	<c:if test="${hasAgileLicense}"><th></th></c:if>

	<th title="<spring:message code="planner.tableHead.rank" text="Rank"/>"><span><spring:message code="planner.tableHead.rank" text="Rank" /></span></th>
	<th title="<spring:message code="tracker.field.Priority.label" text="Priority" />"><span><spring:message code="planner.tableHead.priority" text="P" /></span></th>
	<th><span><spring:message code="planner.tableHead.id" text="ID" /></span></th>
	<th></th>
	<th class="summary"><span><spring:message code="planner.tableHead.summary" text="Summary" /></span></th>
	<th></th>
	<th title="<spring:message code="tracker.field.Story Points.label" text="Story Points" />" class="sp"><span><spring:message code="planner.tableHead.storyPoints" text="SP" /></span></th>
	<th title="<spring:message code="planner.teams" text="Teams" />" class="teams"><span><spring:message code="planner.teams" text="Teams" /></span></th>
	<th><span><spring:message code="planner.tableHead.assignees" text="Assignees" /></span></th>
	<th><span><spring:message code="planner.tableHead.release" text="Release" /></span></th>
</tr>
</thead>
<tbody>
