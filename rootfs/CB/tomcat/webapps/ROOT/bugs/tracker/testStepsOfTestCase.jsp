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
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<input type="hidden" value="false" name="editingEnabled"/>
<input type="hidden" value="${editable}" name="editable"/>

<spring:message code="testcase.editor.edit.test.steps" var="editTitle" text="Edit Test Steps"/>

<c:if test="${editable}">
	<div class="testStepTopContainer">
		<c:if test="${!editingEnabled and fn:length(steps) > 10}">
			<input style="display: inline-block;"  type="button" value="${editTitle}" class="button" onclick="reloadTestCase('${item.id}', true)"/>
		</c:if>
		<c:if test="${editingEnabled}">
			<spring:message code="button.save" var="saveTitle" text="Save"/>
			<input style="display: inline-block;"  type="button" value="${saveTitle}" class="button" data-purpose="save" onclick="saveSteps('${item.id}')"/>
			<spring:message code="button.cancel" var="cancelTitle" text="Cancel"/>
			<input style="display: inline-block;"  type="button" value="${cancelTitle}" class="button cancelButton" onclick="reloadTestCase('${item.id}', false)"/>
		</c:if>
	</div>
</c:if>

<ui:testSteps owner="${item}" testSteps="${steps}" tableId="et_${item.id}" uploadConversationId="${uploadConversationId}" readOnly="${!editable || (editable && !editingEnabled)}"/>

<input type="hidden" name="uploadConversationId" value="${uploadConversationId}"/>

<c:if test="${editable}">
	<div class="testStepBottomContainer">
		<c:if test="${!editingEnabled}">
			<input style="display: inline-block;"  type="button" value="${editTitle}" class="button cancelButton" onclick="reloadTestCase('${item.id}', true)"/>
		</c:if>
		<c:if test="${editingEnabled}">
			<input style="display: inline-block;"  type="button" value="${saveTitle}" class="button" data-purpose="save" onclick="saveSteps('${item.id}')"/>
			<input style="display: inline-block;"  type="button" value="${cancelTitle}" class="button cancelButton" onclick="reloadTestCase('${item.id}', false)"/>
		</c:if>
	</div>
</c:if>
