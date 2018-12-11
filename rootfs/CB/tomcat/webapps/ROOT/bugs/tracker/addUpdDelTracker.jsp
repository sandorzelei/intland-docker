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

@see TrackerController.java
--%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="wysiwyg" prefix="wysiwyg" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>

<meta name="decorator" content="main"/>
<meta name="module" content="${module}"/>
<meta name="moduleCSSClass" content="newskin ${moduleCSSClass} ${not empty baseline ? 'tracker-baseline' : ''} ${empty baseline && (branch != null || tracker.branch) ? 'tracker-branch' : ''}"/>

<script type="text/javascript">

function confirmDeleteTracker(button) {
<c:choose>
  <c:when test="${derivedTrackerCount gt 0}">
	var msg = '<spring:message code="tracker.admin.delete.template.confirm" arguments="${derivedTrackerCount},${derivedDeletedCount}" javaScriptEscape="true"/>';
  </c:when>
  <c:otherwise>
	var msg = '<spring:message code="tracker.admin.delete.confirm" javaScriptEscape="true"/>';
  </c:otherwise>
</c:choose>
	return showFancyConfirmDialog(button, msg);
}

$(function() {
	var optionElements;

	$(document).ready(function() {
		optionElements = $("#templateTrackerId option").clone();
		$("#templateTrackerId option[disabled=true]").remove();
	});

    var originalWorkflowValue = null;
	var updateByTrackerType = function(typeId) {

		function updateHint(){
			var title = $( "#availableTypes option:selected" ).attr("title");
			$("#availableTypeHint").text(title);
		}

		/* Disable workflow for Team trackers (temporary) */
		function disableWorkflowForTeamTracker(typeId) {
			if (${canAdminTracker}) {
				var workflowCheckbox = $("#usingWorkflow");
				var informationLabel = $(".workflowInformation");
				var teamTypeId = ${teamTrackerTypeId};
				if (teamTypeId == typeId) {
					originalWorkflowValue = workflowCheckbox.prop("checked");
					workflowCheckbox.prop("checked", false).prop("disabled", true);
					informationLabel.show();
				} else {
					if (originalWorkflowValue != null) {
						workflowCheckbox.prop("checked", originalWorkflowValue);
						originalWorkflowValue = null;
					}
					workflowCheckbox.prop("disabled", false);
					informationLabel.hide();
				}
			}
		}

		updateHint();
		var workflowDisabledByLicense = ${workflowDisabled};
		if (!workflowDisabledByLicense) {
			disableWorkflowForTeamTracker(typeId);
		}
	};

	var typeDropDown = $("#availableTypes");
	typeDropDown.change(function () {
		updateByTrackerType($(this).val());
	});
	updateByTrackerType(typeDropDown.val());

	$("#availableTypes").on("change", onTypeChanged);

	function onTypeChanged(event) {
		var trackerTypeId = event.currentTarget.value;

		$("#templateTrackerId option").remove();

		$("#templateTrackerId").append(optionElements.filter("option[value=-1]").clone());
		$("#templateTrackerId").append(optionElements.filter("option[data-tracker-type= " + trackerTypeId + "]").clone());

		$("#templateTrackerId option[value=-1]").attr("selected", "selected");
		$("#templateTrackerId option").removeAttr("disabled");
	}

	$("#existingInheritanceConfig").on("change", function() {
		var templateTrackerId;

		// Going to change to unchecked
		if ($("#existingInheritanceConfig").is(":checked")) {
			templateTrackerId = $("input[name=templateTrackerId]").data("original-value");
			$("input[name=templateTrackerId]").val(templateTrackerId);
			$(".parentTracker").removeClass("disabledText");
		} else {
			$(".parentTracker").addClass("disabledText");
			$("input[name=templateTrackerId]").val("");
		}

	});

	$("#existingInheritanceConfig").one("change", function() {
		showFancyAlertDialog(i18n.message("tracker.template.change.warning"));
	});

	$("input[name=SAVE]").click(function(event) {
		var originalTemplateId, currenTemplateId, msg, answer, selectedTemplateTrackerName, newTracker;

		newTracker = ${newTracker};

		function submitForm() {
			$("#trackerEditorForm").submit();
		};

		var $select = $("#templateTrackerId");
		originalTemplateId = $select.attr("data-original-value");
		currentTemplateId = $select.val();
		selectedTemplateTrackerName = $("#templateTrackerId :selected").text().trim();
		var disabled = $select.get(0).disabled;

		if (!newTracker && !disabled && originalTemplateId !== undefined && currentTemplateId !== undefined
			&& originalTemplateId !== null && currentTemplateId !== null
			&& originalTemplateId !== currentTemplateId) {

			event.stopPropagation();
			event.preventDefault();

			msg = i18n.message("tracker.admin.important.warning.changing.template.tracker", selectedTemplateTrackerName);
			answer = showFancyConfirmDialogWithCallbacks(msg, submitForm, function() {});
		}

	});

});

</script>

<style type="text/css">
	.tcFormSelect {
		width: 22em;
	}
	.expandWikiTextArea {
		width: 100%;
	}
	.smallLink a {
		margin-right: 20px;
	}
	.mandatory {
		padding-right: 5px !important;
	}
	.formatTypeSelector {
	 	float: right !important;
  		margin-right: 0px;
	}
	#tracker-customize-general {
		margin-left: 0px !important;
	}
	#tracker-customize-general .actionBar {
		margin-left: 0px !important;
		padding-left: 10px !important;
	}
	#tracker-customize-general .actionBar input {
		margin-right: 5px;
	}
	#tracker-customize-general .ditch-tab-skin-cb-box {
		margin-left: 0px !important;
		margin-top: 0px !important;
		margin-bottom: 0px !important;
	}
	#tracker-customize-general .formTableWithSpacing {
		margin: 10px;
	}
	#tracker-customize-general .rightAlignedDescription {
		padding-top: 3px;
	}
	#referencing-trackers-warning {
		padding-bottom: 0;
	}
	#referencing-trackers-warning table {
		margin: 10px;
	}
	#referencing-trackers-warning table td {
		vertical-align: middle;
		padding: 0.3em 0;
	}
	#referencing-trackers-warning table td:first-child {
		white-space: nowrap;
	}
	#referencing-trackers-warning table .delete-hint {
		margin-left: 3em;
		padding-left: 20px;
		background: url(../../images/newskin/message/info-stripes.png) no-repeat left center;
		min-height: 16px;
	}
	#referencing-trackers-warning table .delete-hint,
	#referencing-trackers-warning table .delete-hint a {
		font-size: 0.9em;
	}
	.workflowInformation {
		margin-left: 1em;
		display: none;
		color: #aaa;
		font-size: 11px;
	}

	.disabledText {
		color: #DDDBDD;
	}

	.tcFormSelect[name=templateTrackerId] {
		width: auto;
		min-width: 22em;
	}
    #trackerEditorForm .cell-with-hint label {
        display: inline-block;
        width: 80px;
    }

    #trackerEditorForm .tracker-icon img {
        width: 34px;
        height: 34px;
    }

    #icon-file-upload {
        display: inline-block;
		width: 50%;
		min-height: 50px;
    }
</style>

<c:if test="${newTracker or showTrackerBreadCrumbs}">
	<ui:actionMenuBar>
		<ui:breadcrumbs showProjects="false">
			<span class='breadcrumbs-separator'>&raquo;</span>
			<c:if test="${newTracker and empty tracker.parent.id}">
				<c:out value="${trackerPath}"/> &raquo;
			</c:if>
			<ui:pageTitle><c:out value="${action}"/></ui:pageTitle>
		</ui:breadcrumbs>
	</ui:actionMenuBar>
</c:if>

<wysiwyg:froalaConfig />

<c:set var="controlDisabled" value=""/>
<c:if test="${!canAdminTracker}">
	<c:set var="controlDisabled" value="disabled='disabled'"/>
</c:if>

<form id="trackerEditorForm" action="${trackerEditUrl}" method="post">

	<ui:actionBar>
		<c:if test="${canAdminTracker}">
			<spring:message var="saveButton" code="button.save" text="Save"/>
			<input type="submit" class="button" name="SAVE" value="${saveButton}"
				<c:if test="${newTracker}">onclick="return TemplateTrackerHandler.confirmSubmit();"</c:if>
			/>

			<c:if test="${!newTracker}">
				<spring:message var="deleteButton" code="button.delete" text="Delete"/>
				<input type="submit" class="button" name="DELETE" value="${deleteButton}" onclick="return confirmDeleteTracker(this);"/>
			</c:if>
		</c:if>

		<spring:message var="cancelButton" code="button.cancel" text="Cancel"/>
		<input type="submit" class="cancelButton" name="_cancel" value="${cancelButton}"/>

		<div class="rightAlignedDescription">
			<spring:message code="tracker.settings.tooltip" />
		</div>
	</ui:actionBar>

<div class="contentWithMargins">

	<ui:showErrors />

	<c:if test="${not empty derivedTrackers}">
		<div class="information" id="referencing-trackers-warning">
			<spring:message code="tracker.derived.trackers.hint" text="You can't delete this tracker because the following trackers use it as template"/>:
			<table>
				<c:forEach items="${derivedTrackers}" var="tracker" varStatus="loopStatus">
					<c:url value="${ui:removeXSSCodeAndHtmlEncode(tracker.urlLink)}" var="trackerUrl"/>

					<c:choose>
						<c:when test="${tracker.project.deleted}">
							<c:url var="projectAdminUrl" value="/proj/admin.spr?proj_id=${tracker.project.id}&options=IgnoreDeletedFlag" />
							<spring:message var="deleteHint" code="tracker.customize.deleted.project.warning" arguments="${ui:removeXSSCodeAndHtmlEncode(projectAdminUrl)}" />
						</c:when>
						<c:when test="${tracker.deletedLevel >= 9999}">
							<spring:message var="deleteHint" code="tracker.customize.deleted.tracker.permanently" />
						</c:when>
						<c:when test="${tracker.deleted}">
							<c:url var="projectTrashUrl" value="/trash.spr?projectId=${tracker.project.id}" />
							<spring:message var="deleteHint" code="tracker.customize.deleted.tracker.warning" arguments="${ui:removeXSSCodeAndHtmlEncode(projectTrashUrl)}" />
						</c:when>
						<c:otherwise>
							<c:set var="deleteHint" value="" />
						</c:otherwise>
					</c:choose>


					<tr>
						<td>
							<c:set var="parentTrackerName"><c:out value='${ui:removeXSSCodeAndHtmlEncode(tracker.name)}'/></c:set>

							<c:choose>
								<c:when test="${not empty deleteHint}">
									<c:out value='${ui:removeXSSCodeAndHtmlEncode(tracker.project.name)}'/> &rarr; ${ui:removeXSSCodeAndHtmlEncode(parentTrackerName)}
								</c:when>
								<c:otherwise>
									<a href="${ui:removeXSSCodeAndHtmlEncode(trackerUrl)}" title="${ui:removeXSSCodeAndHtmlEncode(parentTrackerName)}"><c:out value='${ui:removeXSSCodeAndHtmlEncode(tracker.project.name)}'/> &rarr; ${ui:removeXSSCodeAndHtmlEncode(parentTrackerName)}</a>
								</c:otherwise>
							</c:choose>

						</td>
						<td>
							<c:if test="${deleteHint != ''}">
								<div class="delete-hint">${deleteHint}</div>
							</c:if>
						</td>
					</tr>
				</c:forEach>
			</table>
		</div>
	</c:if>

	<c:if test="${not empty templateTrackerName}">
		<spring:message var="templateTrackerInfo" code="tracker.template.info" arguments="${templateTrackerName}"/>
		<div class="information">${ui:sanitizeHtml(templateTrackerInfo)}</div>
	</c:if>
	<table class="formTableWithSpacing" border="0" cellpadding="0">

		<c:if test="${tracker.branch and originalTracker != null}">
			<tr>
				<td class="optional labelcell"><spring:message code="tracker.parent.label" text="Tracker"/>:</td>
				<td>
					<spring:message code="tracker.parent.tooltip" var="originalTrackerTooltip"/>
					<c:url var="originalTrackerUrl" value="${originalTracker.urlLink}"/>
					<a href="${originalTrackerUrl}" title="${originalTrackerTooltip}"><c:out value="${originalTrackerName}"/></a>
				</td>
			</tr>
		</c:if>

		<tr>
			<td class="optional labelcell"><spring:message code="tracker.type.label" text="Type"/>:</td>
			<td>
				<c:if test="${newTracker}">
					<select id="availableTypes" class="tcFormSelect" name="type" ${controlDisabled}>
						<c:forEach items="${availableTypes}" var="availableType">
							<spring:message var="availableTypeTooltip" code="tracker.type.${availableType.name}.info" text=""/>
							<option value="${availableType.id}" title="${availableTypeTooltip}" <c:if test="${tracker.issueTypeId eq availableType.id}">selected="selected" <c:set var="selectedTrackerTypeId" value="${tracker.issueTypeId}" /></c:if>>
								<spring:message code="tracker.type.${availableType.name}" text="${availableType.name}" htmlEscape="true"/>
							</option>
						</c:forEach>
					</select>
				</c:if>

				<c:if test="${!newTracker}">
					<input type="hidden" value="${tracker.issueTypeId}" name="type" />
					<c:forEach items="${availableTypes}" var="availableType">
						<c:if test="${tracker.issueTypeId eq availableType.id}">
							<span class="strongText"><spring:message code="tracker.type.${availableType.name}" text="${availableType.name}" htmlEscape="true"/></span>
						</c:if>
					</c:forEach>
				</c:if>

				<spring:message var="availableTypesHelpTooltip" code="tracker.type.info" text="Information about different tracker types"/>
				<a title="${availableTypesHelpTooltip}" href="#" onclick="launch_url('https://codebeamer.com/cb/wiki/552836',null);return false;" style="padding-left: 16px; margin-right: 5px; margin-left: 14px; background: url(<ui:urlversioned value='/images/newskin/action/help.png'/>) no-repeat left center;" ></a>
				<span id="availableTypeHint"></span>
			</td>
		</tr>

		<tr>
			<td class="optional labelcell"><spring:message code="tracker.template.choose.label" text="Template" />:</td>
			<td class="expandText">

				<c:if test="${!newTracker}">
					<c:set var="selectedTrackerTypeId" value="${availableTypes[0].id}" />
				</c:if>

				<select id="templateTrackerId" class="tcFormSelect" name="templateTrackerId" ${controlDisabled} <c:if test="${tracker.branch}"> disabled="disabled"</c:if> <c:if test="${!newTracker}">data-original-value="${tracker.templateId != null && tracker.templateId > 0 ? tracker.templateId : "-1" }"</c:if>>
					<option value="-1">
						<spring:message code="tracker.template.choose.none" text="None"/>
					</option>

					<c:forEach var="availableTemplate" items="${availableTemplates}">
						<option value="${availableTemplate.id}" data-tracker-type="${availableTemplate.type.id}"
							<c:if test="${tracker.templateId eq availableTemplate.id}">selected="selected" </c:if>
							<c:if test="${availableTemplate.type.id != selectedTrackerTypeId}">disabled="true"</c:if>>
							<c:out value='${availableTemplate.project.name}'/> &raquo; <c:out value='${availableTemplate.scopeName}'/> &raquo; <c:out value='${availableTemplate.name}'/>
						</option>
					</c:forEach>
				</select>

				<spring:message var="availableTemplatesHelpTooltip" code="tracker.template.dropdown.tooltip" text="Shows only templates with type selected above."/>
				<span title="${availableTemplatesHelpTooltip}"  style="padding-left: 16px; margin-right: 5px; margin-left: 14px; background: url(<ui:urlversioned value='/images/newskin/action/help.png'/>) no-repeat left center;" ></span>

				&nbsp;&nbsp;
				<c:if test="${newTracker}">
					<spring:message var="inheritanceConfigTitle" code="tracker.template.inheritanceConfig.tooltip" text="Inherit template configuration. Default is off which means that tracker configuration is copied, and if the template tracker changes this tracker will not reflect changes."/>
					<span id="trackerInheritance" style="white-space: nowrap;" title="${inheritanceConfigTitle}">
						<input id="inheritanceConfig" type="checkbox" name="inheritanceConfig" checked="checked" value="true" style="vertical-align:middle;" />
						<label for="inheritanceConfig">
							<spring:message code="tracker.template.inheritanceConfig.label" text="Inherit template configuration"/>
						</label>
					</span>
				</c:if>


				<spring:message var="templateTitle" code="${baseproperty}.template.tooltip" />
				<input id="templateCheckbox" type="checkbox" name="template" value="true" <c:if test="${tracker.branch}"> disabled="disabled"</c:if> <c:if test="${tracker.template}">checked="checked"</c:if> title="${templateTitle}" style="vertical-align:middle;" ${controlDisabled} />
				<label for="templateCheckbox" title="${templateTitle}"><spring:message code="tracker.template.enabled" text="Available as template"/></label>
			</td>
		</tr>

		<tr>
			<td class="mandatory labelcell"><spring:message code="tracker.name.label" text="Name"/>:</td>
			<td class="expandText">
				<input type="text" name="name" value="<c:out value='${trackerName}' escapeXml="false" />" size="40" maxlength="80" tabindex="1" ${controlDisabled}/>
			</td>
		</tr>

		<tr>
			<td class="mandatory labelcell"><spring:message code="tracker.keyName.label" text="Key (short name)"/>:</td>
			<td class="expandText">
				<input type="text" name="keyName" value="<c:out value='${tracker.keyName}'/>" size="10" maxlength="20" tabindex="2" ${controlDisabled}/>
			</td>
		</tr>

		<tr>
			<td class="optional">
				<label for="color"><spring:message code="tracker.field.Color.label" text="Color"/>:</label>
			</td>
			<td>
				<input type="text" name="color" id="color" value="${tracker.color }" readonly="readonly" style="width: 6em;"/>
				<ui:colorPicker fieldId="color" showClear="${true}" disableReservedColors="${true }"/>
			</td>
		</tr>

        <c:if test="${not tracker.branch}">
            <%-- the icon upload is shown only for trackers (branches will inheerit the icon) --%>
            <tr>
                <td class="optional">
                    <label for="color"><spring:message code="tracker.icon.label" text="Icon"/>:</label>
                </td>
                <td>
                    <c:if test="${not empty tracker.icon }">
                        <c:url var="iconUrl" value="/displayDocument?doc_id=${tracker.icon}"/>
                        <label for="${icon}" class="tracker-icon" id="currentIcon">
                            <img src="${iconUrl}"/>
                        </label>

						<c:if test="${not newTracker}">
							<label style="position: relative; top: -12px;">
								<spring:message code="tracker.image.reset.default.title" var="resetTitle"/>
								<input type="checkbox" name="resetDefaultIcon" id="resetDefaultIcon" title="${resetTitle}">
								<spring:message code="tracker.image.reset.default.label" text="Reset default icon"/>
							</label>

						</c:if>
                    </c:if>
                    <div id="icon-file-upload">
                        <ui:fileUpload uploadConversationId="${uploadConversationId}" conversationFieldName="uploadConversationId" single="true"
                                       cssClass="inlactionMenuBarIconineFileUpload" onCompleteCallback="clearPreviousError"/>
                        <%-- validate --%>
                        <c:if test="${!empty fieldErrors['uploadConversationId']}"><span class="invalidfield"><c:out value="${fieldErrors['uploadConversationId']}" /></span><br><br></c:if>
                    </div>
                </td>
            </tr>
        </c:if>

		<c:choose>
			<c:when test="${newTracker}">
				<input name="defaultLayout" type="hidden" value="">
			</c:when>
			<c:otherwise>
				<tr>
					<td class="optional labelcell"><spring:message code="tracker.defaultViewType.label" text="Default layout" />:</td>
					<td class="expandText">
						<select name="defaultLayout" tabindex="3" ${controlDisabled}>
							<c:forEach items="${trackerViewLayouts}" var="layout">
								<option value="<c:out value='${layout.name}'/>" ${layout.name == trackerDefaultLayoutName ? 'selected' : ''}>
									<spring:message code="tracker.view.layout.${layout.name}" htmlEscape="true" />
								</option>
							</c:forEach>
						</select>
						<span class="trackerConfigTip"><spring:message code="tracker.layout.info" text="Please note that only those layouts will work that your current license covers"/></span>
					</td>
				</tr>
			</c:otherwise>
		</c:choose>

		<tr>
			<td class="mandatory labelcell"><spring:message code="tracker.description.label" text="Description"/>:</td>
			<td class="expandTextArea">
				<wysiwyg:editor editorId="editor" useAutoResize="false" height="250" formatSelectorName="descriptionFormat" formatSelectorValue="${tracker.descriptionFormat}"
                    formatSelectorDisabled="${!canAdminTracker}" uploadConversationId="" overlayHeaderKey="wysiwyg.tracker.description.editor.overlay.header">
				    <textarea name="description" id="editor" rows="15" cols="80" ${controlDisabled}><spring:escapeBody htmlEscape="true">${trackerDesc}</spring:escapeBody></textarea>
				</wysiwyg:editor>
			</td>
		</tr>
		<c:if test="${availableInboxes != null}">
			<spring:message var="trackerInboxTitle" code="tracker.inbox.tooltip"/>
			<tr>
				<td class="optional labelcell" title="${trackerInboxTitle}"><spring:message code="tracker.inbox.label" text="Inbox"/>:</td>
				<td>
					<select id="trackerInboxId" class="tcFormSelect" name="inboxId" ${controlDisabled}>
						<option value="-1"><spring:message code="tracker.inbox.none" text="None"/></option>
						<c:forEach var="availableInbox" items="${availableInboxes}">
							<option value="${availableInbox.id}" <c:if test="${inbox.id eq availableInbox.id}">selected="selected"</c:if>>
								<c:out value="${availableInbox.name}"/><c:if test="${!empty availableInbox.email}"> (<c:out value='${availableInbox.email}'/>)</c:if>
							</option>
						</c:forEach>
					</select>
				</td>
			</tr>
		</c:if>

		<tr>
			<td class="optional labelcell"><spring:message code="${baseproperty}.workflow.label" text="Workflow"/>:</td>
			<td class="cell-with-hint">
				<c:choose>
					<c:when test="${workflowDisabled}">
						<spring:message code="${baseproperty}.workflow.disabled" text="Workflow is not available with this License..."/>
					</c:when>
					<c:otherwise>
						<label for="usingWorkflow">
							<input type="checkbox" id="usingWorkflow" name="usingWorkflow" value="true" style="vertical-align:middle;" <c:if test="${tracker.usingWorkflow}">checked="checked"</c:if> ${controlDisabled}/>
							<spring:message code="${baseproperty}.workflow.enabled" text="Active"/>
							<!-- Disable workflow label for Team trackers (temporary) -->
							<span class="workflowInformation">
								<spring:message code="tracker.workflow.team.type.disabled" text="Workflow is not available in Team trackers."/>
							</span>
						</label>
						<span class="hint"><spring:message code="${baseproperty}.workflow.hint" htmlEscape="true" text="Should transitions and workflow actions be available in the tracker" /></span>
					</c:otherwise>
				</c:choose>
			</td>
		</tr>

		<tr valign="middle">
			<td class="optional labelcell"><spring:message code="${baseproperty}.visibility.label" text="Visibility"/>:</td>
			<td class="cell-with-hint">
				<label for="visibility">
                    <input type="checkbox" id="visibility" name="visible" value="true" style="vertical-align:middle;" <c:if test="${not tracker.visible}">checked="checked"</c:if> ${controlDisabled} <c:if test="${tracker.branch}"> disabled="disabled"</c:if>/>
					<spring:message code="${baseproperty}.visible.label" text="Hidden"/>
				</label>
				<span class="hint"><spring:message code="${baseproperty}.visibility.tooltip" htmlEscape="true" text="Should this tracker be hidden/not listed in the Trackers overview" /></span>
			</td>
		</tr>
	</table>

<c:if test="${newTracker}">
<script language ="JavaScript" type="text/javascript">

	// static class to handle template-tracker change
	var TemplateTrackerHandler = {
		originalValue_templateTrackerId : '${tracker.templateId}',
		newTracker : ${newTracker},

		templateTrackerElement: document.getElementById("templateTrackerId"),

		// check if the value for a tracker-template is for "None"
		isNoneTemplateValue: function(value) {
			return value == '-1' || value == '';
		},

		// script called when the tracker data would be submitted
		// @return if the submit can be executed
		confirmSubmit: function() {
			var select = this.templateTrackerElement;
			var value = select.value;
			var selectedTemplateTrackerName = select.options[select.selectedIndex].text;

			// check if changing template tracker from "None"->"<some-selected>" to show a warning!
			var templateSelected = ! this.isNoneTemplateValue(value);
			var originalwasNone = this.isNoneTemplateValue(this.originalValue_templateTrackerId);

			if ((!this.newTracker) && !select.disabled && originalwasNone && templateSelected) {
				var msg = i18n.message("tracker.admin.warning.changing.template.tracker", selectedTemplateTrackerName);
				var answerOk = confirm(msg);
				if (!answerOk) {
					return false;
				}
			}

			ajaxBusyIndicator.showBusyPage();
			return true;
		}
	}
</script>
</c:if>
</div>
</form>
