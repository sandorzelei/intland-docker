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
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="taglib" prefix="tag" %>
<%@ taglib uri="bugstaglib" prefix="bugs" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%@ taglib uri="callTag" prefix="ct" %>
<%@ taglib uri="uitaglib" prefix="ui" %>

<%@ page import="com.intland.codebeamer.persistence.dto.TrackerLayoutLabelDto"%>
<%@ page import="com.intland.codebeamer.servlet.bugs.AddUpdateTaskForm" %>
<%@ page import="com.intland.codebeamer.ui.view.table.TrackerSimpleLayoutDecorator" %>

<%--
Parameters (from request scope):
 - layout_addUpdateTaskForm
 - layout_decorator
 - layout_fieldLayout
 - layout_task_id
 - layout_tracker_id
 - layout_templateLabelId
 - layout_canConfigChoiceList
 - layout_targetURL
 - layout_tooltip
 - layout_hiddenFields
 - layout_labelIdsToHighlight
 - layout_isTestCase
 - param.postfixItemId: when this is true the htmlId of the reference field selector will be postfixed with the tracker item id. this is useful when there are
     multiple reference field selectors for different items on the same page
--%>

<%
	AddUpdateTaskForm addUpdateTaskForm = (AddUpdateTaskForm) request.getAttribute("layout_addUpdateTaskForm");
	TrackerSimpleLayoutDecorator decorator = (TrackerSimpleLayoutDecorator) request.getAttribute("layout_decorator");
%>

<c:set var="addUpdateTaskForm" value="${layout_addUpdateTaskForm}" scope="page" />
<c:set var="fieldLayout" value="${layout_fieldLayout}" scope="page" />
<c:set var="task_id" value="${layout_task_id}" scope="page" />
<c:set var="tracker_id" value="${layout_tracker_id}" scope="page" />
<c:set var="templateLabelId" value="${layout_templateLabelId}" scope="page" />
<c:set var="canConfigChoiceList" value="${layout_canConfigChoiceList}" scope="page" />
<c:set var="targetURL" value="${layout_targetURL}" scope="page" />
<c:set var="tooltip" value="${layout_tooltip}" scope="page" />
<c:set var="hiddenFields" value="${layout_hiddenFields}" scope="page" />
<c:set var="labelIdsToHighlight" value="${layout_labelIdsToHighlight}" scope="page" />
<c:set var="isTestCase" value="${layout_isTestCase}" scope="page" />

<%-- this is the postfix that will be appended to the id of some of the fields to make them unique when there are multiple editors of the same
field on the page --%>
<c:set var="htmlIdPostfix" value="${task_id }"/>
<c:if test="${empty htmlIdPostfix}">
	<c:set var="htmlIdPostfix" value="${addUpdateTaskForm.uploadConversationId}"/>
</c:if>

<%-- --------------------------------------------------------------- --%>

<spring:message var="unsetButton" code="tracker.field.value.unset.label" text="Unset"/>
<spring:message var="setToDefaultButton" code="tracker.field.defaultValue.label" text="Unset"/>

<spring:message var="label" code="tracker.field.${fieldLayout.label}.label" text="${fieldLayout.label}" htmlEscape="false"/>
<c:set var="tooltip" value=""/>
<c:set var="label_id" value="${fieldLayout.id}" />

<c:set var="disabled" value="${disableEditing || (fieldLayout.id == 7 and addUpdateTaskForm.tracker.usingWorkflow) or !addUpdateTaskForm.editable[label_id]}" />

<c:set var="rows" value="${fieldLayout.rows}" />
<c:set var="cols" value="${fieldLayout.cols}" />
<c:if test="${empty cols || cols < 1}">
	<c:set var="cols=" value="10" />
</c:if>
<c:set var="inputType" value="${fieldLayout.inputType}" />
<c:set var="multiValue" value="${fieldLayout.multipleSelection}" />

<c:set var="textStyle" value="inputText" />

<c:remove var="currentField" />

<c:if test="${!empty fieldLayout.description}">
	<c:set var="tooltip"><c:out value="${fieldLayout.description}"/></c:set>
</c:if>
<c:if test="${empty tooltip}">
	<c:set var="tooltip">${label}</c:set>
</c:if>

<c:set var="labelStyle" value="optional" />
<c:set var="extraClass" value=""/>
<c:if test="${fieldLayout.required}">
	<c:set var="labelStyle" value="mandatory" />
	<%-- check if the mandatory field is empty; if yes then mark it wit an extra class --%>
	<ct:call object="${fieldLayout}" method="getValue" param1="${addUpdateTaskForm.trackerItem}" return="fieldValue"/>
	<c:if test="${empty fieldValue && hasErrors}">
		<c:set var="extraClass" value="nullValue"/>
	</c:if>
</c:if>
<c:if test="${not empty labelIdsToHighlight}">
	<ct:call object="${labelIdsToHighlight}" method="contains" param1="${label_id}" return="toBeHighlighted" />
	<c:if test="${toBeHighlighted}">
		<c:set var="extraClass" value="highlightedValue ${extraClass}"/>
	</c:if>
</c:if>
<c:set var="extraClass" value="${extraClass} fieldType_${fieldLayout.typeName}" />

<c:if test="${!disabled}">
	<c:set var="labelStyle" value="${labelStyle} editable" />
</c:if>
<c:set var="labelStyle">fieldInputControl ${labelStyle} ${extraClass} ${fieldLayout.breakRow ? 'breakRow' : ''}</c:set>
<c:set var="colspanAttr" value="" />
<c:if test="${fieldLayout.colspan != null && fieldLayout.colspan > 1}">
	<c:set var="colspanAttr">data-colspan="${fieldLayout.colspan}"</c:set>
</c:if>

<c:set var="isCalendarCell" value="${!disabled and inputType == 3}" />

<jsp:useBean id="fieldLayout" beanName="fieldLayout" type="com.intland.codebeamer.persistence.dto.TrackerLayoutLabelDto" />

<c:choose>

	<%-- Member choice fields --%>
	<c:when test="${fieldLayout.memberChoice}">
		<div style="white-space: nowrap" class="${labelStyle}">
			<div class="fieldLabel" title="${tooltip}"><span class="labelText">${label}:</span></div>
			<div style="white-space: nowrap" class="fieldValue dataCell ${extraClass}" ${colspanAttr} title="${tooltip}">
				<spring:message var="title" code="tracker.field.value.choose.tooltip" text="Choose {0}" arguments="${label}"/>
				<c:if test="${disabled}">
					<c:set var="title" value="${label}"/>
				</c:if>

				<tag:joinLines>
					<c:set var="ids" value="<%=addUpdateTaskForm.getReferenceFieldIds(fieldLayout.getId())%>" />
					<c:set var="defaultValues" value="<%=addUpdateTaskForm.getDefaultValue(fieldLayout.getId())%>" />
					<c:set var="propertyName" value="<%=addUpdateTaskForm.getReferenceFieldName(fieldLayout)%>" />
					<bugs:userSelector htmlId="${fieldLayout.id}${param.postfixItemId ? htmlIdPostfix : '' }" task_id="${task_id}" field="${fieldLayout}" fieldName="${propertyName}" ids="${ids}"
									   disabled="${disabled}" singleSelect="${!multiValue}" memberType="${fieldLayout.memberType}"
									   onlyUsersAndRolesWithPermissionsOnTracker="true" tracker_id="${tracker_id}"
									   status_id="${addUpdateTaskForm.trackerItem.status.id}" transition_id="${addUpdateTaskForm.transition.id}" title="${title}"
									   setToDefaultLabel="${setToDefaultButton}" defaultValue="${defaultValues}"
									   decorator="<%=decorator%>"
							/>
				</tag:joinLines>
			</div>
		</div>
	</c:when>

	<%-- dynamic/multiple choice fields --%>
	<c:when test="${fieldLayout.dynamicChoice or (fieldLayout.referenceFieldConfigurationAllowed and fieldLayout.multipleSelection) or fieldLayout.languageField or fieldLayout.countryField}">
		<div style="white-space: nowrap" class="${labelStyle}">
			<div class="fieldLabel" title="${tooltip}"><span class="labelText">${label}:</span></div>
			<div class="fieldValue dataCell ${extraClass}" ${colspanAttr} title="${tooltip}">
				<spring:message var="title" code="tracker.field.value.choose.tooltip" text="Choose {0}" arguments="${label}"/>
				<c:if test="${disabled}">
					<c:set var="title" value="${label}"/>
				</c:if>
				<c:set var="ids" value="<%=addUpdateTaskForm.getReferenceFieldIds(fieldLayout.getId())%>" />
				<c:set var="propertyName" value="<%=addUpdateTaskForm.getReferenceFieldName(fieldLayout)%>" />
				<c:set var="onChangeHandler" value=""/>
				<c:if test="${fieldLayout.id == templateLabelId && empty task_id}">
					<c:set var="onChangeHandler" value="reloadWithTemplate"/>
				</c:if>
				<c:set var="defaultValues" value="<%=addUpdateTaskForm.getDefaultValue(fieldLayout.getId())%>" />
				<bugs:chooseReferences htmlId="${fieldLayout.id}${param.postfixItemId ? htmlIdPostfix : '' }" tracker_id="${tracker_id}" label="${fieldLayout}" ids="${ids}" disabled="${disabled}" title="${title}"
									   task_id="${task_id}" status_id="${addUpdateTaskForm.trackerItem.status.id}" transition_id="${addUpdateTaskForm.transition.id}"
									   setToDefaultLabel="${setToDefaultButton}" defaultValue="${defaultValues}"
									   onChangeHandler="${onChangeHandler}" decorator="<%=decorator%>"
						/>
			</div>
		</div>
	</c:when>

	<%-- static/single choice fields --%>
	<c:when test="${fieldLayout.choiceField}">
		<c:set var="cascadeField" value='<%=addUpdateTaskForm.getLayout().getField(fieldLayout.getInteger("cascade"))%>' />

		<div class="${labelStyle}" style="white-space: nowrap">
			<div class="fieldLabel" title="${tooltip}"><span class="labelText"><c:out value="${label}" escapeXml="false" />:</span></div>

			<div class="fieldValue ${cascadeField != null and cascadeField.hidden ? 'multiSelectorCell' : 'dataCell'} dataCellContainsSelectbox ${extraClass}" ${colspanAttr} title="${tooltip}">
				<bugs:chooseOptions id="${fieldLayout.id}" property="fieldValues[${fieldLayout.id}].choiceFieldValues" tracker="${tracker_id}" field="${fieldLayout}"
									status="${addUpdateTaskForm.trackerItem.status.id}" options="<%=addUpdateTaskForm.getChoiceOptions(String.valueOf(fieldLayout.getId()))%>"
									disabled="${disabled}" decorator="<%=decorator%>"/>

				<c:if test="${cascadeField != null and cascadeField.hidden}">
					<bugs:chooseOptions id="${cascadeField.id}" property="fieldValues[${cascadeField.id}].choiceFieldValues" tracker="${tracker_id}" field="${cascadeField}"
										status="${addUpdateTaskForm.trackerItem.status.id}" options='<%=addUpdateTaskForm.getChoiceOptions(fieldLayout.getString("cascade"))%>'
										disabled="${disabled}" decorator="<%=decorator%>"/>
				</c:if>
			</div>
		</div>
	</c:when>

	<%-- color fields --%>
	<c:when test="${fieldLayout.colorField}">
		<div style="white-space: nowrap" class="${labelStyle}">
			<div class="fieldLabel" title="${tooltip}"><span class="labelText">${label}:</span></div>
			<div class="fieldValue dataCell ${extraClass}" ${colspanAttr} title="${tooltip}">
			<ct:call object="${addUpdateTaskForm}" method="getCustomFieldValue" param1="${fieldLayout.id}" return="colorValue"/>
				<c:choose>
					<c:when test="${disabled}">
						<span class="color-preview" style="background-color: <c:out value="${colorValue}" />"></span> <c:out value="${colorValue}" />
					</c:when>
					<c:otherwise>
						<div id="color_indicator_${fieldLayout.id}" class="colorField" style="${not empty colorValue ? 'background-color: '.concat(colorValue) : 'display: none'};"></div>
						<c:set var="currentField" value="fieldValues[${fieldLayout.id}].customFieldValue" />
						<form:input path="${currentField}" id="color_${fieldLayout.id}" cssStyle="width: 6em;" readonly="true" />
						<ui:colorPicker fieldId="color_${fieldLayout.id}" indicatorId="color_indicator_${fieldLayout.id}"/>
					</c:otherwise>
				</c:choose>
			</div>
		</div>
	</c:when>
	
	<%-- url fields --%>
	<c:when test="${fieldLayout.urlField}">
		<div style="white-space: nowrap" class="fieldInputControl optional editable  fieldType_language">
			<c:set var="currentField" value="fieldValues[${fieldLayout.id}].customFieldValue" />
			<div class="fieldLabel" title="${tooltip}"><span class="labelText">${label}:</span></div>
			<div class="fieldValue dataCell  fieldType_language" title="Language">
			 	<table border="0" cellspacing="0" cellpadding="0" class="chooseReferences fullExpandTable" title="${urlFieldTooltip}">
					<tbody>
						<tr>
							<td style="white-space: normal;">
								<spring:message var="urlFieldTooltip" code="tracker.field.valueType.url.tooltip" />
								<div style="white-space: nowrap;padding: 3px;" class="fieldValue dataCell <c:out value="${textStyle}" />" ${colspanAttr} title="${urlFieldTooltip}">
									<form:input style="border: none;" cssClass="${textStyle} urlField" disabled="${disabled}" path="${currentField}" size="${cols}" id="custom_field_${fieldLayout.id}_${htmlIdPostfix}" autocomplete="off" autocorrect="off" autocapitalize="off"/>
								</div>
							</td>
							<td style="width: 1%;" valign="top">
								<span title="${urlFieldTooltip}"
									  onclick="showPopupInline(contextPath + '/wysiwyg/plugins/plugin.spr?pageName=wikiHistoryLink&fieldId=' + 'custom_field_${fieldLayout.id}_${htmlIdPostfix}', { geometry: '90%_90%' }); return false;">
									  <a href="#" class="popupButton">&nbsp;</a>
								</span>
							</td>
						</tr>
					</tbody>
				</table>
			</div>
		</div>
	</c:when>

	<%-- user defined/custom fields --%>
	<c:when test="${fieldLayout.userDefined}">
		<div style="white-space: nowrap" class="${labelStyle}">
			<c:set var="currentField" value="fieldValues[${fieldLayout.id}].customFieldValue" />
			<div class="fieldLabel" title="${tooltip}"><span class="labelText">${label}:</span></div>
			<c:choose>
				<c:when test="${fieldLayout.booleanField}">
					<div class="fieldValue dataCell dataCellContainsSelectbox ${extraClass}" ${colspanAttr} title="${tooltip}">
						<bugs:chooseOptions id="${fieldLayout.id}" property="${currentField}" tracker="${tracker_id}" field="${fieldLayout}"
											status="${addUpdateTaskForm.trackerItem.status.id}" options="${addUpdateTaskForm.booleanOptions}"
											disabled="${disabled}" decorator="<%=decorator%>"/>
					</div>
				</c:when>

				<c:when test="${fieldLayout.wikiTextField}">
					<spring:bind path="${currentField}"><c:set var="wiki" value="${status.value}"/></spring:bind>
					<div class="fieldValue dataCell ${extraClass} <c:out value="${textStyle}" />" ${colspanAttr} data-field-id="${fieldLayout.id}">
						<c:choose>
							<c:when test="${disabled}">
								<tag:transformText value="${wiki}" format="W" default="--"/>
							</c:when>
							<c:otherwise>
								<ui:editWikiInOverlay id="${fieldLayout.id}${param.postfixItemId ? htmlIdPostfix : '' }-editor" wiki="${wiki}" owner="${addUpdateTaskForm.trackerItem}" disabled="${disabled}"
								    uploadConversationId="${addUpdateTaskForm.uploadConversationId}" title="${tooltip}" forceOverlayEdit="${param.extendedDocumentView}" allowTestParameters="${isTestCase}">
									<form:textarea id="${fieldLayout.id}${param.postfixItemId ? htmlIdPostfix : '' }-editor" cssClass="${textStyle}" disabled="${disabled}" path="${currentField}" rows="${rows}" cols="${cols}" />
								</ui:editWikiInOverlay>
							</c:otherwise>
						</c:choose>
					</div>
				</c:when>

				<c:when test="${fieldLayout.label eq 'Password' or fieldLayout.label eq 'Signature'}">
					<div class="fieldValue dataCell ${extraClass} <c:out value="${textStyle}" />" ${colspanAttr}>
						<form:password cssClass="${textStyle}" disabled="${disabled}" path="${currentField}" showPassword="true" rows="${rows}" cols="${cols}" autocomplete="off" autocorrect="off" autocapitalize="off"/>
					</div>
				</c:when>

				<c:when test="${rows gt 1}">
					<div class="fieldValue dataCell ${extraClass} <c:out value="${textStyle}" />" ${colspanAttr}>
						<form:textarea cssClass="${textStyle}" disabled="${disabled}" path="${currentField}" rows="${rows}" cols="${cols}" autocomplete="off" autocorrect="off" autocapitalize="off"/>
					</div>
				</c:when>

				<c:otherwise>
					<div style="white-space: nowrap" class="fieldValue dataCell <c:if test="${isCalendarCell}">calendarCell</c:if> <c:out value="${textStyle}" />" ${colspanAttr} title="${tooltip}">
						<ui:calendarPopup textFieldId="custom_field_${fieldLayout.id}" disabled="${disabled || !isCalendarCell}"  fieldLabel="${label}" >
							<form:input cssClass="${textStyle}" disabled="${disabled}" path="${currentField}" size="${cols}" id="custom_field_${fieldLayout.id}" autocomplete="off" autocorrect="off" autocapitalize="off"/>
						</ui:calendarPopup>
					</div>
				</c:otherwise>
			</c:choose>
		</div>
	</c:when>

	<%-- user defined/custom fields in a table ! --%>
	<c:when test="${fieldLayout.table}">
		<div class="${labelStyle}" style="vertical-align: top; white-space: nowrap;">
			<div class="fieldLabel" title="${tooltip}"><span class="labelText">${label}:</span></div>

			<div id="embeddedTable${fieldLayout.tableIndex}${param.postfixItemId ? htmlIdPostfix : '' }" class="fieldValue dataCell ${extraClass}" ${colspanAttr} title="${tooltip}">
				<%= decorator.getEditableTable(fieldLayout, addUpdateTaskForm.getTransition_id()) %>
			</div>
		</div>
	</c:when>

	<c:otherwise>

		<%-- Story Points --%>
		<c:set var="STORY_POINTS_LABEL_ID" value="<%=Integer.toString(TrackerLayoutLabelDto.STORY_POINTS_LABEL_ID)%>" />
		<c:if test="${label_id == STORY_POINTS_LABEL_ID}" >
			<div class="${labelStyle}" title="${tooltip}" style="white-space: nowrap">
				<div class="fieldLabel" title="${tooltip}"><span class="labelText">${label}:</span></div>
				<div class="fieldValue dataCell ${extraClass}" ${colspanAttr} title="${tooltip}">
					<form:input disabled="${disabled}"  path="storyPoints" size="10" />
				</div>
				<c:set var="currentField" value="storyPoints" />
			</div>
		</c:if>

		<%-- Estimated Hours--%>
		<c:set var="ESTIMATED_H_LABEL_ID" value="<%=Integer.toString(TrackerLayoutLabelDto.ESTIMATED_H_LABEL_ID)%>" />
		<c:if test="${label_id == ESTIMATED_H_LABEL_ID}" >
			<div class="${labelStyle}" style="white-space: nowrap">
				<div class="fieldLabel" title="${tooltip}"><span class="labelText">${label}:</span></div>
				<div class="fieldValue dataCell ${extraClass}" ${colspanAttr} title="${tooltip}">
					<form:input disabled="${disabled}" path="estimatedMillis" size="12" />
				</div>
				<c:set var="currentField" value="estimatedMillis" />
			</div>
		</c:if>

		<%-- Spent Hours--%>
		<c:set var="SPENT_H_LABEL_ID" value="<%=Integer.toString(TrackerLayoutLabelDto.SPENT_H_LABEL_ID)%>" />
		<c:if test="${label_id == SPENT_H_LABEL_ID}">
			<div class="${labelStyle}" style="white-space: nowrap">
				<div class="fieldLabel" title="${tooltip}"><span class="labelText">${label}:</span></div>
				<div class="fieldValue dataCell ${extraClass}" ${colspanAttr} title="${tooltip}">
					<form:input disabled="${disabled}" path="spentMillis" size="12" />
				</div>
				<c:set var="currentField" value="spentMillis" />
			</div>
		</c:if>

		<%-- Start Date--%>
		<c:set var="START_DATE_LABEL_ID" value="<%=Integer.toString(TrackerLayoutLabelDto.START_DATE_LABEL_ID)%>" />
		<c:if test="${label_id == START_DATE_LABEL_ID}">
			<div style="white-space: nowrap" class="${labelStyle}">
				<div class="fieldLabel" title="${tooltip}"><span class="labelText">${label}:</span></div>
				<div style="white-space: nowrap" class="fieldValue dataCell calendarCell ${extraClass}" ${colspanAttr} title="${tooltip}">
					<ui:calendarPopup textFieldId="startDate" otherFieldId="closeDate" disabled="${disabled}" fieldLabel="${label}" >
						<form:input path="startDate" id="startDate" disabled="${disabled}" size="12" maxlength="30" />
					</ui:calendarPopup>
				</div>
				<c:set var="currentField" value="startDate" />
			</div>
		</c:if>

		<%-- Close Date--%>
		<c:set var="END_DATE_LABEL_ID" value="<%=Integer.toString(TrackerLayoutLabelDto.END_DATE_LABEL_ID)%>" />
		<c:if test="${label_id == END_DATE_LABEL_ID}" >
			<div style="white-space: nowrap" class="${labelStyle}">
				<div class="fieldLabel" title="${tooltip}"><span class="labelText">${label}:</span></div>
				<div style="white-space: nowrap" class="fieldValue dataCell calendarCell ${extraClass}" ${colspanAttr} title="${tooltip}">
					<ui:calendarPopup textFieldId="closeDate" otherFieldId="startDate" disabled="${disabled}" fieldLabel="${label}" >
						<form:input disabled="${disabled}" path="closeDate" id="closeDate" size="12" maxlength="30" />
					</ui:calendarPopup>
				</div>
				<c:set var="currentField" value="closeDate" />
			</div>
		</c:if>
	</c:otherwise>
</c:choose>

<%--
   Send all disabled fields as hidden parameters.
   It's necessary because they will not be transfered in normal mode and will be
   set to previous value by reset() method in the form.
   Note. The TrackerItemManager has a special logic to process such fields.
   Works only for Transition mode.
   --%>
<c:if test="${!empty addUpdateTaskForm.transition_id and !empty currentField and disabled}">
	<c:set var="hiddenFields" scope="request">${hiddenFields}
		<%-- Insert hidden field in case of field is disabled Tracker Workflow used --%>
		<form:hidden path="${currentField}"/>
	</c:set>
</c:if>

<ui:delayedScript avoidDuplicatesOnly="true">
<script type="text/javascript">
	function reloadWithTemplate(event, item, inputFieldId) {

		// If template field is auto filled (e.g. by opening the editor form with a source_task_id parameter set), this
		// event handler will get triggered on page load, not only on field value change.
		// To prevent this, we check a URL parameter and make sure it will only taken into consideration exactly once.
		var body = $("body");
		var isPopup = body.hasClass("insideInlinedPopup");
		var autoDiscardConfirmation = false;
		if (!isPopup) {
			var discardParam = getUrlParameter("discard_template_field") == "true";
			var autoDiscardConfirmation = discardParam && !body.data("isDiscardParamProcessed");
			body.data("isDiscardParamProcessed", true);
		}

		var templateId = null;
		var typeAndId = null;
		if (event == "onAdd") {
			templateId = item.id;
			if (templateId.length > 0) {
				typeAndId = templateId;
				templateId = templateId.substring(templateId.indexOf("-") + 1);
			}
		}

		var input = $('#' + inputFieldId);
		if (templateId != null && templateId != "") {
			if (autoDiscardConfirmation) {
				input.tokenInput('clear');
			} else {
				$(window).off("beforeunload");
				if (confirm(i18n.message('issue.template.overwrite.confirm'))) {
					var url = contextPath + "${addUpdateTaskForm.tracker.createContainedUrlLink}?" + (isPopup ? "isPopup=true&" : "") + "template_id=" + templateId + "&fieldReferenceData%5B${addUpdateTaskForm.tracker.id}_${templateLabelId}%5D=" + typeAndId;
					window.location.href = url;
				} else {
					input.tokenInput('clear');
				}
			}
		}
	}

	$(document).ready(function() {
		codebeamer.prefill.prevent($("input[type=password]"), getBrowserType());
	});
</script>
</ui:delayedScript>
