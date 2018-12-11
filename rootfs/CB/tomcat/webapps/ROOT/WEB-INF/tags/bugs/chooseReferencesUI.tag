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
 * $Revision: 21471:828ad33f257b $ $Date: 2009-05-28 16:11 +0000 $
--%>
<%--
	Tag renders only GUI part of the chooseReferences widget, without any javascript attached etc.
	Use the chooseReferences tag to execute a real popup.
--%>

<%@ tag language="java" pageEncoding="UTF-8" body-content="scriptless" %>
<%@ tag import="com.intland.codebeamer.servlet.bugs.dynchoices.ReferenceHandlerSupport"%>
<%@ tag import="com.intland.codebeamer.controller.ControllerUtils"%>
<%@ tag import="org.springframework.context.MessageSource "%>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<%@ taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="bugstaglib" prefix="bugs" %>

<%@ attribute name="tracker_id" required="false" type="java.lang.Integer" rtexprvalue="true"
		 description="The current tracker's id"  %>
<%@ attribute name="field_id" required="false" type="java.lang.Integer" rtexprvalue="true"
		 description="The current field id"  %>
<%@ attribute name="label" required="false" type="com.intland.codebeamer.persistence.dto.TrackerLayoutLabelDto" rtexprvalue="true"
		 description="The label of which reference should be rendered"  %>
<%@ attribute name="ids" required="false" type="java.lang.String" rtexprvalue="true"
		 description="The comma separated list of ids in form of The comma separated ids of 'group-type-entityId'"  %>
<%@ attribute name="disabled" required="false" type="java.lang.Boolean" rtexprvalue="true"
		 description="If the editing of this reference list is disabled" %>
<%@ attribute name="labelMap" required="false" type="java.util.Map" rtexprvalue="true"
		 description="Map with String->String content, contains mapping about how the the special-id values of references will be displayed. For example __DO_NOT_CHANGE__ would translate to &lt;don't change&gt;"  %>
<%@ attribute name="specialValueResolver" required="false" type="java.lang.String" rtexprvalue="true"
		 description="class name of the class implements the ReferenHandlerSupport.SpecialValueResolver interface. That class must have a public default constructor." %>

<%@ attribute name="emptyValue" required="false" type="java.lang.String" rtexprvalue="true"
		 description="The value will be used when nothing is selected from the references popup. Defaults to empty string (ie:'')." %>

<%@ attribute name="htmlId" type="java.lang.String" rtexprvalue="true"
		description="Unique identifier of the HTML tag of the chooseReferences, will be only one part of the html-ids though!"  %>

<%@ attribute name="fieldName" required="true" type="java.lang.String" rtexprvalue="true"
		 description="The field name contains the current value, used for passing back the form value" %>
<%@ attribute name="cssClass" type="java.lang.String" rtexprvalue="true"
		description="CSS class attribute put on outermost container" %>
<%@ attribute name="title" type="java.lang.String" rtexprvalue="true"
		description="Optional tooltip/title for the selector" %>

<%@ attribute name="ajaxEnabled" type="java.lang.Boolean" rtexprvalue="true"
	description="If the ajax-autocompletion is enabled. Defaults to true."  %>
<%@ attribute name="ajaxURLParameters" type="java.lang.String" rtexprvalue="true"
	description="URL parameter to put on the ajax request for auto-completion" %>

<%@ attribute name="onclick" type="java.lang.String" rtexprvalue="true"
	description="Script executed when clicking on the popup button" %>

<%@ attribute name="showPopupButton" type="java.lang.Boolean" rtexprvalue="true"
	description="If the popup button is shown. If not provided the popup button will automatically disappear if the jsp:body is not empty" %>

<%@ attribute name="userSelectorMode" type="java.lang.Boolean" rtexprvalue="true"
	description="True for user selector mode, False for reference selector mode." %>

<%@ attribute name="acceptEmail" type="java.lang.Boolean" rtexprvalue="true"
	description="In user selector mode true if the field accept email addresses too." %>

<%@ attribute name="workItemMode" required="false" type="java.lang.Boolean" rtexprvalue="true"
	description="True if searching all work items." %>
<%@ attribute name="workItemTrackerIds" required="false" type="java.lang.String" rtexprvalue="true"
	description="Comma separated list of tracker IDs. If workItemMode, get work items only from these trackers." %>

<%@ attribute name="reportMode" required="false" type="java.lang.Boolean" rtexprvalue="true" description="True if searching in Reports." %>

<%@ attribute name="multiSelect" type="java.lang.Boolean" rtexprvalue="true"
	description="If multiselection is allowed for the ajax-widget." %>

<%@ attribute name="removeDoNotModifyBox" type="java.lang.Boolean" rtexprvalue="true"
	description="Optional boolean if showing the 'dont modify' special value. Defaults to false" %>

<%@ attribute name="existingJSON" type="java.lang.String" rtexprvalue="true" required="false"
	description="Existing JSON which should be displayed inside the selector. This will overwrite the field value data if field present." %>

<%@ attribute name="reqContext" type="java.lang.String" rtexprvalue="true" description="javascript code to be called before sending requests, to add context information" %>
<%@ attribute name="onChange"   type="java.lang.String" rtexprvalue="true" description="javascript code to execute on value change" %>
<%@ attribute name="onChangeHandler" description="the name of the javascript function that will be called after a new reference was added to the field" %>

<%-- default values for attributes --%>
<%
 if (disabled == null) {
	 disabled = Boolean.FALSE;
	 jspContext.setAttribute("disabled", disabled);
 }
 if (cssClass == null) {
 	jspContext.setAttribute("cssClass", "");
 }
 if (disabled.booleanValue()) {
	 ajaxEnabled = Boolean.FALSE;
 } else if(ajaxEnabled == null) {
	ajaxEnabled = Boolean.TRUE;
 }
 jspContext.setAttribute("ajaxEnabled", ajaxEnabled);

 if (ajaxEnabled.booleanValue() && ajaxURLParameters == null) {
	 throw new IllegalArgumentException("ajaxURLParameters is required when the ajaxEnabled is true");
 }

 if (ids == null) {
	 jspContext.setAttribute("ids", "");
 }
 if (userSelectorMode == null) {
	 userSelectorMode = Boolean.FALSE;
	 jspContext.setAttribute("userSelectorMode", userSelectorMode);
 }
 if (acceptEmail == null) {
	 acceptEmail = Boolean.FALSE;
	 jspContext.setAttribute("acceptEmail", acceptEmail);
 }
 if (workItemTrackerIds == null) {
	 jspContext.setAttribute("workItemTrackerIds", "");
 }
 if (workItemMode == null) {
	 workItemMode = Boolean.FALSE;
	 jspContext.setAttribute("workItemMode", workItemMode);
 }
 if (reportMode == null) {
	 reportMode = Boolean.FALSE;
	 jspContext.setAttribute("reportMode", reportMode);
 }
 if (multiSelect == null) {
	 jspContext.setAttribute("multiSelect", Boolean.TRUE);
 }

 // figure out what is shown when nothing is selected by the ajax-widget
 ReferenceHandlerSupport.SpecialValueResolver specialValueResolverInstance = ReferenceHandlerSupport.createSpecialValueResolver(labelMap, specialValueResolver);
 String emptyId = emptyValue == null ? "" : emptyValue;
 String emptyHTML = specialValueResolverInstance != null ? specialValueResolverInstance.renderAsHTML(emptyId) : null;
 if (emptyHTML == null || "".equals(emptyHTML)) {
	 emptyHTML = "";
 } else {
	 MessageSource messageSource = ControllerUtils.getMessageSource(request);
	 if (messageSource != null) {
		 emptyHTML = messageSource.getMessage(emptyHTML, null, emptyHTML, request.getLocale());
	 }
 }

 jspContext.setAttribute("emptyId", emptyId);
 jspContext.setAttribute("emptyHTML", emptyHTML);
%>

<%-- the jsp body is used instead of popup-button if not empty, otherwise the normal popupbutton link is rendered --%>
<c:set var="body"><jsp:doBody/></c:set>
<c:if test="${empty body && empty showPopupButton}"><c:set var="showPopupButton" value="true"/></c:if>
<c:if test="${showPopupButton eq true}"><c:set var="body">${body}<a href="#" class="popupButton" >&nbsp;</a></c:set></c:if>
<c:set var="body"><span title="${title}" <c:if test="${ajaxEnabled}"> onclick="${onclick}"</c:if> >${body}</span></c:set>

<c:set var="chooseReferencesDisabled" value="" />
<c:if test="${disabled}">
<c:set var="chooseReferencesDisabled" value="chooseReferencesDisabled" />
</c:if>

<c:if test="${ajaxEnabled}">
	<c:set var="cssClassReferencesForLabel" value="yui-multibox"/>
</c:if>

<c:set var="ids"><c:out value="${ids}"/></c:set>

<%-- span shows the references for the selected values --%>
<c:set var="referencesRendered"><bugs:renderReferences tracker_id="${tracker_id}" field_id="${field_id}" label="${label}" ids="${ids}"
										emptyText="${emptyHTML}" emptyValue="${emptyValue}" labelMap="<%=labelMap%>" specialValueResolver="${specialValueResolver}" editing="${ajaxEnabled}" /></c:set>
<c:set var="referencesForLabelBlock">
		<div id="referencesForLabel_${htmlId}" class="${cssClassReferencesForLabel} reference-box"
			<%--
				In case this page is dynamically loaded via jquery.load(), the delayed script below will not be executed.
				Instead the loading page has to call: chooseReferences.ajaxReferenceFieldAutoComplete(element);
				For this to work, we must add all necessary information via custom data attributes
			 --%>
			<c:if test="${ajaxEnabled}">
				data-htmlId="${htmlId}"
				data-userSelectorMode="${userSelectorMode}"
				data-acceptEmail="${acceptEmail}"
				data-workItemMode="${workItemMode}"
				data-workItemTrackerIds="${workItemTrackerIds}"
				data-reportMode="${reportMode}"
				data-multiSelect="${multiSelect}"
				data-emptyId="<c:out value='${emptyId}'/>"
				data-removeDoNotModifyBox="${removeDoNotModifyBox}"
				data-ajaxURLParameters="${ajaxURLParameters}"
				data-referencesJSON='${not empty existingJSON ? existingJSON : referencesRendered}'
			</c:if>
		>
			<c:if test="${!ajaxEnabled}">
				${not empty existingJSON ? existingJSON : referencesRendered}
			</c:if>
			<%-- values are comma sepearated 'ids'false of the referenced objects in form of "<grouptype>-<id>" --%>
			<input type="hidden" id="dynamicChoice_references_${htmlId}" value="${ids}" name="${fieldName}"/>
			<c:if test="${ajaxEnabled}">
				<input id="dynamicChoice_references_autocomplete_editor_${htmlId}" type="text" value="" class="yui-ac-input"></input>
				<%--<div id="dynamicChoice_references_autocomplete_container_${htmlId}" class="yui-ac-container" ></div>--%>
				<%--<div class="yui-multibox-clear"></div>--%>
			</c:if>
			<c:if test="${not workItemMode && not reportMode}">
			<div id="dynamicChoice_references_${htmlId}_setting_dialog" class="referenceSettingDialog">
				<h4 class="referenceSettingTitle"></h4>
				<span class="versionAjaxLoading"></span>
				<div class="referenceSettingVersionContainer">
					<span class="referenceSettingVersionLabel"><spring:message code="reference.setting.select.baseline.version"></spring:message></span>
					<div class="referenceSettingSelectorContainer">
						<span class="referenceSettingSelectorLabel baseline">
							<input type="radio" name="versionCheckbox" value="baseline" class="baselineSelectorCheckbox" id="dialog_baseline_${htmlId}">
							<label for="dialog_baseline_${htmlId}"><spring:message code="reference.setting.baselines"/></label>
						</span>
						<span>
							<select id="dialog_baselineSelector_${htmlId}" class="referenceDialogBaselineSelector"></select>
						</span>
					</div>
					<div class="referenceSettingSelectorContainer">
						<span class="referenceSettingSelectorLabel version">
							<input type="radio" name="versionCheckbox" value="version" class="versionSelectorCheckbox" id="dialog_version_${htmlId}" checked="checked">
							<label for="dialog_version_${htmlId}"><spring:message code="reference.setting.versions"/></label>
						</span>
						<span>
							<select id="dialog_versionSelector_${htmlId}" class="referenceDialogVersionSelector"></select>
						</span>
					</div>
				</div>
				<div class="propagation-settings" title="<spring:message code="reference.setting.propagate.suspects.tooltip"/>">
					<span class="propagateSuspectsContainer">
						<span><input type="checkbox" class="referenceDialogPropagateSuspects" id="dialog_propagetSuspects_${htmlId}"></span>
						<span><label for="dialog_propagetSuspects_${htmlId}"><spring:message code="association.propagatingSuspects.label"/></label></span>
					</span>
					<span class="propagation-options">
						<span class="reverseSuspectContainer">
							<span><input type="checkbox" class="referenceDialogReverseSuspect" id="dialog_reverseSuspect_${htmlId}"></span>
							<span><label for="dialog_reverseSuspect_${htmlId}"><spring:message code="reference.setting.reverse.suspect"/></label></span>
						</span><br>
						<span class="bidirectionalSuspectContainer">
							<span><input type="checkbox" class="referenceDialogBidirectionalSuspect" id="dialog_bidirectionalSuspect_${htmlId}"></span>
							<span><label for="dialog_bidirectionalSuspect_${htmlId}"><spring:message code="reference.setting.bidirectional.suspect"/></label></span>
						</span>
					</span>
				</div>
				<div class="propagateDependencies">
					<span class="propagateDependenciesContainer">
						<span><input type="checkbox" class="referenceDialogPropagateDependencies" id="dialog_propagateDependencies_${htmlId}"></span>
						<span><label for="dialog_propagateDependencies_${htmlId}"><spring:message code="reference.setting.propagatingDependencies.label"/></label></span>
					</span>
				</div>
				<div class="referenceDialogButtonContainer">
					<button class="button okButton"><spring:message code="button.ok"/></button>
					<button class="button cancelButton"><spring:message code="button.cancel"/></button>
				</div>
			</div>
			</c:if>
		</div>
</c:set>

<spring:message var="noPermissionForEdit" code="reference.field.no.permission" text="At this time you have no permission to modify this field."/>
<TABLE BORDER="0" CELLSPACING="0" CELLPADDING="0" class="chooseReferences fullExpandTable ${chooseReferencesDisabled} ${cssClass}" title="${ajaxEnabled ? title : noPermissionForEdit}"
	<c:if test="${! ajaxEnabled}">onclick="${onclick}"</c:if> <%-- TODO: remove this onclick when user selector fixed, only for user-selector popup --%>
>
	<tr>
		<td style="white-space:normal;">
			${referencesForLabelBlock}
		</td>
		<c:if test="${!disabled}">
			<td style="width:1%;" valign="top">${body}</td>
		</c:if>
	</tr>
</TABLE>

<c:if test="${!ajaxEnabled}">
	<script type="text/javascript">
		$(function() {
			var label = $('#referencesForLabel_' + '${htmlId}');
			label.find('.reference a').click(function() {
				var url = $(this).attr('href');
				showFancyConfirmDialogWithCallbacks(i18n.message("reference.field.redirect.alert"), function() { window.location.href = url; });
				return false;
			});
		});
	</script>
</c:if>

<%-- init autocomplete widget --%>
<c:if test="${ajaxEnabled and !clientSideBinding}">
	<script type="text/javascript" >
		setTimeout(function () {
			console.log("initializing ajax-reference-field of htmlId=${htmlId}. \nThe ajaxReferenceFieldAutoComplete javascript object should be available:" + ajaxReferenceFieldAutoComplete);
			var referencesForLabel${htmlId} = document.getElementById("referencesForLabel_${htmlId}");
			var onChangeCallback = null;
			<c:if test="${removeDoNotModifyBox}">
				onChangeCallback = ajaxReferenceFieldAutoComplete.removeDoNotModifyBox;
			</c:if>

			<c:if test="${not empty onChangeHandler}">
				if (onChangeCallback == null) {
					onChangeCallback = ${onChangeHandler};
				} else {
					onChangeCallback = function () {
						ajaxReferenceFieldAutoComplete.removeDoNotModifyBox();
						${onChangeHandler}();
					};
				}
			</c:if>

			ajaxReferenceFieldAutoComplete.init(contextPath, "dynamicChoice_references_autocomplete_editor_${htmlId}" , "dynamicChoice_references_autocomplete_container_${htmlId}", "${ajaxURLParameters}", referencesForLabel${htmlId}, "dynamicChoice_references_${htmlId}", ${multiSelect},
					${userSelectorMode}, ${acceptEmail}, ${workItemMode}, "${workItemTrackerIds}", ${reportMode}, "<c:out value='${emptyId}'/>", "<c:out value='${empty emptyHTML ? "--" : emptyHTML}'/>", onChangeCallback,
					<c:choose><c:when test="${empty reqContext or reqContext eq 'null'}">null</c:when><c:otherwise>function() { return ${reqContext}; }</c:otherwise></c:choose>,
					<c:choose><c:when test="${empty onChange}">null</c:when><c:otherwise>function() { ${onChange}; }</c:otherwise></c:choose>, ${not empty existingJSON ? existingJSON : referencesRendered} );
		}, 20);
	</script>
</c:if>

