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
<meta name="decorator" content="popup"/>
<meta name="moduleCSSClass" content="tackersModule newsin" />
<meta name="module" content="tracker"/>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="wysiwyg" prefix="wysiwyg" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>

<style type="text/css">
.qq-upload-button {
	left: 40%;
}
</style>
<wysiwyg:froalaConfig />

<ui:actionMenuBar >
	<ui:pageTitle>
		<spring:message code="tracker.type.User\ Story.create.label" text="New User Story"/>
	</ui:pageTitle>
</ui:actionMenuBar>
<c:url var="closeUrl" value="${tracker.urlLink}">
	<c:param name="view_id" value="-12"/>
	<c:param name="releaseId" value="${command.releaseId }"/>
	<c:param name="roleId" value="${command.roleId }"/>
	<c:param name="groupBy" value="${command.groupById }"/>
</c:url>
<script type="text/javascript">
	function closePage() {
		var url = "${closeUrl}";

		document.location.href = url;
	}

	$(document).ready(function() {
		$("#summaryField").focus();
	});
</script>
<c:choose>
	<c:when test="${param.close}">
		<script type="text/javascript">
			closePage();
		</script>
	</c:when>
	<c:otherwise>
		<c:url var="actionUrl" value="/proj/tracker/createStory.spr"/>
		<form:form action="${actionUrl}" method="POST" commandName="command">
			<input type="hidden" name="tracker_id" value="<c:out value='${trackerId}'/>"/>
			<input type="hidden" name="releaseId" value="<c:out value='${command.releaseId}'/>"/>
			<input type="hidden" name="statusId" value="<c:out value='${command.statusId}'/>"/>
			<input type="hidden" name="roleId" value="<c:out value='${command.roleId}'/>"/>
			<input type="hidden" name="groupById" value="<c:out value='${command.groupById}'/>"/>

			<table class="formTableWithSpacing">
				<tr>
					<td class="mandatory labelCell">
						<spring:message code="tracker.field.Summary.label" text="Summary"/>:
					</td>
					<td class="dataCell">
						<form:input path="summary" id="summary"/>
					</td>
				</tr>
				<tr>
					<td class="mandatory labelCell" style="vertical-align: top;">
						<spring:message code="tracker.field.Description.label" text="Description"/>:
					</td>
					<td class="dataCell">
						<wysiwyg:editor editorId="editor" entity="${issue}" uploadConversationId="${command.uploadConversationId}"
						    insertNonImageAttachments="true" useAutoResize="false">

						    <form:textarea path="description" id="editor" rows="12" cols="80" autocomplete="off" />
						</wysiwyg:editor>
					</td>
				</tr>
				<tr>
					<td colspan="2">
						<div style="float:right" class="okcancel">
							<spring:message var="saveButton" code="button.save"/>
							<input type="submit" class="button" name="save" value="${saveButton}" />

							<spring:message var="saveAndNewButton" code="button.saveAndNew"/>
							<input type="submit" class="button" name="saveAndNew" value="${saveAndNewButton}" />

							<spring:message var="cancelButton" code="button.cancel"/>
							<a onclick="closePage();">${cancelButton}</a>
						</div>
					</td>
				</tr>
			</table>
		</form:form>
	</c:otherwise>
</c:choose>

