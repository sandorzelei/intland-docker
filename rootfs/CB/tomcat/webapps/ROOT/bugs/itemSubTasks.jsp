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
 * $Revision$ $Date$
--%>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<%@ taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@ taglib uri="taglib" prefix="tag" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="bugstaglib" prefix="bugs" %>

<c:set var="trackerUrl" value="${task.configItem ? '/category' : '/tracker'}" />

<c:url var="action" value="${trackerUrl}/${task.tracker.id}" />
<form action="${action}" id="subTaskForm" method="post" >
	<%-- tell the action that we're from subtask page --%>
	<input type="hidden" name="subTaskMode" value="true" />
	<input type="hidden" name="task_id" value="${task.id}" />

	<c:if test="${headRevision}">
	<%--
		Show subtasks on itemDetails page.
	--%>
	  <div class="actionBar">
		<%-- javascript called by actions for combo box --%>
		<script type="text/javascript">
			var trackerActionsHandler = new TrackerActionsHandler('selectedSubtaskIds', issueCopyMoveConfig, issueCopyMoveContext);
		</script>

		<ui:actionGenerator builder="${actionBuilder}" subject="${task}" actionListName="actions">
			<ui:actionLink keys="addSubTask" actions="${actions}" />
		</ui:actionGenerator>

		<%-- TODO: followings are nearly same as in browseTracker.jsp's actionBar, maybe consolidate to one tag file or jsp-incude? --%>
		<c:set var="actionBuilderTracker" value="trackerListContextActionMenuBuilder"/>
		<c:if test="${task.configItem}">
			<c:set var="actionBuilderTracker" value="categoryListContextActionMenuBuilder"/>
		</c:if>

		<ui:actionGenerator builder="${actionBuilderTracker}" actionListName="actions" subject="${task}">
			<ui:actionComboBox keys="cut, copy, paste, copyTo, moveTo, delete, massEdit" actions="${actions}"
				onchange="trackerActionsHandler.onSelectionChange(this);" id="actionCombo"
			/>
		</ui:actionGenerator>
	  </div>
	</c:if>

	<bugs:displaytagTrackerItems htmlId="subtasks" layoutList="${subTaskColumns}" items="${subTasks}"
		browseTrackerMode="true" export="false"	selection="${headRevision}" multiSelect="true" selectionFieldName="selectedSubtaskIds"
		paginationParamPrefix="subtasks-" includeBaselineInTtId="true" decorator="${subTasksDecorator}"
	/>
</form>
