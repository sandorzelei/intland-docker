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
<meta name="decorator" content="popup" />
<meta name="module" content="tracker" />
<meta name="moduleCSSClass" content="newskin" />

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="callTag" prefix="ct" %>

<spring:message var="saveText" code="button.save" />
<spring:message var="cancelText" code="button.cancel" />
<style>
	.cbModalDialog form {
		display: block !important;
	}
</style>

<script type="text/javascript">
	parent.codebeamer.copyTargetNodeId = "${pasteAssignFieldsForm.targetTrackerItemId}";
</script>

<ui:actionMenuBar>
	<jsp:body>
		<ui:breadcrumbs showProjects="false" projectAware="${copy}"><span class='breadcrumbs-separator'>&raquo;</span>
			<span><spring:message code="issue.import.mapping.label" text="Mapping" htmlEscape="true" /></span>
			<ui:pageTitle prefixWithIdentifiableName="false" printBody="false" >
				<spring:message code="issue.import.mapping.label" text="Mapping" htmlEscape="true" />
			</ui:pageTitle>
		</ui:breadcrumbs>
	</jsp:body>
</ui:actionMenuBar>

<c:url var="actionUrl" value="/trackers/library/resolveFieldProblems.spr"/>
<form:form action="${actionUrl}" id="fieldMapping">
	<c:forEach items="${pasteAssignFieldsForm.mappedTargetFieldIds}" var="item">
		<c:if test="${not empty item }">
			<ct:call object="${pasteAssignFieldsForm}" method="getFieldIdMapping" param1="${item}" return="mappedTo"/>
			<input type="hidden" name="fieldMapping[${item}]" value="${mappedTo}"/>
		</c:if>
	</c:forEach>
	<input type="hidden" value="${pasteAssignFieldsForm.sourceTrackerId}" name="sourceTrackerId" />
	<input type="hidden" value="${pasteAssignFieldsForm.targetTrackerId}" name="targetTrackerId" />
	<input type="hidden" value="${pasteAssignFieldsForm.targetTrackerItemId}" name="targetTrackerItemId" />
	<input type="hidden" value="${copiedId}" name="copied_id" />

	<input type="hidden" name="noReload" value="true"/>
	<input type="hidden" name="callback" value="reloadTree"/>

	<ui:actionBar>
		<span class="okcancel">
			<input type="submit" class="button" value="${saveText}" />
			<a href="#" onclick="parent.trackerObject.refreshNode(${pasteAssignFieldsForm.targetTrackerItemId}); closePopupInline(); return false;">${cancelText}</a>
		</span>
	</ui:actionBar>
	<div class="contentWithMargins">
		<div class="descriptionBox">
			<input type="checkbox" name="store_in_session" id="store_in_session"><label for="store_in_session">Remember these preferences</label>
		</div>
		<c:if test="${not empty pasteAssignFieldsForm.fieldsToAssign}">
			<div>
				<spring:message code="issue.paste.assign.hint"/>
			</div>
			<table class="formTableWithSpacing">
				<tr class="head">
					<th ALIGN="right"><spring:message code="issue.paste.assign.target.label" text="Target Field"/></th>
					<th ALIGN="left"><spring:message code="issue.paste.assign.source.label" text="Source Field"/></th>
				</tr>
	
				<c:forEach items="${pasteAssignFieldsForm.fieldsToAssign}" var="item">
					<tr>
						<td class="optional">
							<spring:message code="tracker.field.${item.label}.label" text="${item.label}"/>:
						</td>
	
						<td>
							<select class="fixWideSelectWidth" name="fieldMapping[${item.value}]">
								<option value="-1">
									<spring:message code="issue.paste.assign.target.none" text="--not available--"/>
								</option>
		
								<c:forEach items="${item.possibleFields}" var="opt">
									<option value="${opt.value}">
										<spring:message code="tracker.field.${opt.label}.label" text="${opt.label}"/>
									</option>
								</c:forEach>
							</select>
						</td>
					</tr>
				</c:forEach>
			</table>
		</c:if>
	
		<c:if test="${not empty pasteAssignFieldsForm.fieldsGettingLost}">
			<div class="warning">
				<spring:message code="issue.paste.lost.warning"/>
				<br/>
				<c:forEach items="${pasteAssignFieldsForm.fieldsGettingLost}" var="lostField">
					<br/>
					<b><spring:message code="tracker.field.${lostField.label}.label" text="${lostField.labelWithoutBR}"/></b>
				</c:forEach>
			</div>
		</c:if>
	</div>
</form:form>


