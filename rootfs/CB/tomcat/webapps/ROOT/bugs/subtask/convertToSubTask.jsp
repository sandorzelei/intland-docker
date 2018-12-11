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
<meta name="decorator" content="popup"/>
<meta name="module" content="tracker" />
<meta name="bodyCSSClass" content="newskin" />

<%--
	Popup page for moving Tasks to subtask.
	Allows selecting a tracker-item which will become parent of the existing tasks.
 --%>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<%@ taglib uri="taglib" prefix="tag" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="bugstaglib" prefix="bugs" %>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>

<ui:actionMenuBar showGlobalMessages="true">
		<ui:pageTitle>
		Changing selected Tasks/Items to SubTasks/Items of ...
		</ui:pageTitle>
</ui:actionMenuBar>

You have selected following <b>${fn:length(selectedTrackerItems)}</b> Issues to convert to <b>SubTask/SubItems.</b>

<bugs:displaytagTrackerItems layoutList="${selectedItemColumns}" items="${selectedTrackerItems}"
	browseTrackerMode="false" defaultsort="1" export="false"
/>
<br/>

<SCRIPT LANGUAGE="JavaScript" type="text/javascript">
<!-- Hide script from old browsers
function confirmSubmit(form) {
	var answer = submitIfSelected(form, 'parentTaskId');
	if (answer) {
		if (!confirm('<spring:message code="tracker.subtask.confirm.change.to.subtask" />')) {
			return false;
		}
	}
	return answer;
}
// -->
</SCRIPT>

<form:form>

	<spring:hasBindErrors name="command">
		<ui:showSpringErrors errors="${errors}" />
	</spring:hasBindErrors>

	<div class="actionBar">
		<c:if test="${canConvert}">
			<input type="submit" class="button" value="Convert to SubTask..." title="Converts Task to SubTasks of selected Task/Issue"
				onclick="return confirmSubmit(this.form);" name="submit"
			/>
		</c:if>

		&nbsp;&nbsp;
		<input type="submit" class="button" value="Cancel" name="_cancel" />
	</div>

<c:if test="${canConvert}">
	<ui:title style="sub-headline" >
			Please select new Parent Task/Item below!
		</ui:title>

	<bugs:displaytagTrackerItems layoutList="${selectedItemColumns}" items="${possibleParentItems}"
		browseTrackerMode="false" defaultsort="1" export="false"
		selection="true" selectionFieldName="parentTaskId" multiSelect="false"
		selectedItems="${selectedItems}" excludedParams="parentTaskId"
	/>
</c:if>

</form:form>
