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
<%--
	Tag renders references and allow choosing/changing them for dynamic choices/references.
--%>

<%@ tag language="java" pageEncoding="UTF-8" body-content="scriptless" %>

<%@ tag import="com.intland.codebeamer.ui.view.table.TrackerSimpleLayoutDecorator"%>
<%@ tag import="com.intland.codebeamer.servlet.bugs.dynchoices.ReferenceHandlerSupport"%>
<%@ tag import="com.intland.codebeamer.servlet.bugs.dynchoices.LabelMapEncoder"%>
<%@ tag import="org.apache.commons.lang.StringUtils"%>
<%@ tag import="com.intland.codebeamer.utils.URLCoder"%>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<%@ taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="bugstaglib" prefix="bugs" %>

<%@ attribute name="tracker_id" required="false" type="java.lang.Integer" rtexprvalue="true"
		 description="The current tracker's id"  %>
<%@ attribute name="task_id" required="false" type="java.lang.Integer" rtexprvalue="true"
		 description="The current tracker item id"  %>
<%@ attribute name="status_id" required="false" type="java.lang.Integer" rtexprvalue="true"
		 description="The current tracker item status id"  %>
<%@ attribute name="transition_id" required="false" type="java.lang.Integer" rtexprvalue="true"
		 description="The id of the current task transition to execute." %>
<%@ attribute name="ids" required="false" type="java.lang.String" rtexprvalue="true"
		 description="The comma separated list of ids in form of The comma separated ids of 'group-type-entityId'"  %>
<%@ attribute name="label" required="true" type="com.intland.codebeamer.persistence.dto.TrackerLayoutLabelDto" rtexprvalue="true"
		 description="The label of which reference should be rendered"  %>
<%@ attribute name="title" required="false" type="java.lang.String" rtexprvalue="true"
		 description="The title to show for the reference field"  %>
<%@ attribute name="disabled" required="false" type="java.lang.Boolean" rtexprvalue="true"
		 description="If the editing of this reference list is disabled" %>
<%@ attribute name="forceMultiSelect" required="false" type="java.lang.Boolean" rtexprvalue="true"
		 description="if multi-selection is forced, even when the TrackerLabelLayoutDto says single-select" %>
<%@ attribute name="setToDefaultLabel" required="false" rtexprvalue="true"
		 description="The label for button resetting to default value, button only shown if it is not empty" %>
<%@ attribute name="defaultValue" required="false" rtexprvalue="true"
		 description="The default value can be reset to" %>
<%@ attribute name="labelMap" required="false" type="java.util.Map"
		 description="Map with String->String content, contains mapping about how the the special-id values of references will be displayed. For example __DO_NOT_CHANGE__ would translate to &lt;don't change&gt;"  %>
<%@ attribute name="specialValueResolver" required="false" type="java.lang.String" rtexprvalue="true"
		 description="class name of the class implements the ReferenHandlerSupport.SpecialValueResolver interface. That class must have a public default constructor." %>
<%@ attribute name="emptyValue" required="false" type="java.lang.String" rtexprvalue="true"
		 description="The value will be used when nothing is selected from the references popup. Defaults to empty string (ie:'')." %>
<%-- special value and its displayed label-text for "Unset" --%>
<%@ attribute name="showUnset" required="false" type="java.lang.Boolean" rtexprvalue="true"
		description="If the 'Unset' value is shown as one of the possible selections" %>
<%@ attribute name="unsetValue" required="false" type="java.lang.String" rtexprvalue="true"
		description="Value for 'Unset'" %>

<%@ attribute name="cssClass" type="java.lang.String" rtexprvalue="true"
		description="CSS class attribute put on outermost container" %>

<%@ attribute name="removeDoNotModifyBox" type="java.lang.Boolean" rtexprvalue="true"
	description="Optional boolean if showing the 'dont modify' special value. Defaults to false" %>

<%@ attribute name="showPopupButton" type="java.lang.Boolean" rtexprvalue="true"
	description="If the popup button is shown. If not provided the popup button will automatically disappear if the jsp:body is not empty" %>

<%@ attribute name="htmlId" required="false" type="java.lang.String" rtexprvalue="true"
		description="The html id used for the field. This should be unique on the whole page. If missing then it will be generated as a random number" %>
<%@ attribute name="fieldName" required="false" type="java.lang.String" rtexprvalue="true"
	description="the name of the HTML input field (hidden field), which contains and submits back selected users. If missing a default is generated to cooperate with ReferenceHandlerSupport" %>

<%@ attribute name="workItemMode" required="false" type="java.lang.Boolean" rtexprvalue="true"
	description="True if searching all work items." %>
<%@ attribute name="workItemTrackerIds" required="false" type="java.lang.String" rtexprvalue="true"
	description="Comma separated list of tracker IDs. If workItemMode, get work items only from these trackers." %>

<%@ attribute name="reportMode" required="false" type="java.lang.Boolean" rtexprvalue="true" description="True if searching in Reports." %>

<%@ attribute name="onChangeHandler" %>
<%@ attribute name="decorator" required="false" type="com.intland.codebeamer.ui.view.table.TrackerSimpleLayoutDecorator" rtexprvalue="true" description="The tracker item decorator"  %>

<%-- default values for attributes --%>


<c:if test="${empty ids}">
	<c:set var="ids" value="" />
</c:if>
<c:if test="${empty disabled}">
	<c:set var="disabled" value="false"/>
</c:if>

<%
	if (showUnset == null) {
		showUnset = Boolean.FALSE;
		jspContext.setAttribute("showUnset", showUnset);
	}
	if (showUnset.booleanValue() && unsetValue == null) {
		throw new IllegalArgumentException("If showUnset is 'true' then the unsetValue field is required!");
	}

	if (forceMultiSelect == null) {
		forceMultiSelect = Boolean.FALSE;
	}

	boolean multiSelect = forceMultiSelect.booleanValue() || (label != null && Boolean.TRUE.equals(label.getMultipleSelection()));
	jspContext.setAttribute("multiSelect", Boolean.valueOf(multiSelect));

	Integer valueId = label != null ? label.getId() : null;
	if (StringUtils.isEmpty(htmlId)) {
		// generate an unique html id for the field.
		htmlId = String.valueOf(Math.random()).replaceAll("\\.","");
		jspContext.setAttribute("htmlId", htmlId);
	} else {
		try {
			valueId = Integer.valueOf(htmlId, 10);
		} catch(Throwable ex) {
		}
	}
	jspContext.setAttribute("valueId", valueId);

	if (StringUtils.isEmpty(fieldName)) {
		// build the composite key for Label, which contains the Tracker-id and the label's id too
		String labelKey = tracker_id + ReferenceHandlerSupport.KEY_SEPARATOR + label.getId();

		fieldName = "fieldReferenceData[" + labelKey +"]";
		jspContext.setAttribute("fieldName", fieldName);
	}

	// build the static url parameters, because used for both the popup and both the ajax request
	StringBuilder urlparams = new StringBuilder(256);
	urlparams.append("tracker_id=").append(tracker_id);
	if (label != null){
		urlparams.append("&labelId=").append(label.getId());
		jspContext.setAttribute("field_id", label.getId());
	}

	if (task_id != null) {
		urlparams.append("&task_id=").append(task_id);
	}
	if (status_id != null && status_id.intValue() >= 0) {
		urlparams.append("&status_id=").append(status_id);
	}
	if (transition_id != null && transition_id.intValue() > 0) {
		urlparams.append("&transition_id=").append(transition_id);
	}
	if (forceMultiSelect != null) {
		urlparams.append("&forceMultiSelect=").append(forceMultiSelect);
	}
	if (setToDefaultLabel != null) {
		urlparams.append("&setToDefaultLabel=").append(setToDefaultLabel);
	}
	if (defaultValue != null) {
		urlparams.append("&defaultValue=").append(URLCoder.encode(defaultValue));
	}
	if (labelMap != null) {
		String encodedLabelMap = (new LabelMapEncoder()).encodeLabelMap(labelMap);
		urlparams.append("&labelMap=").append(URLCoder.encode(encodedLabelMap));
	}
	if (emptyValue == null) {
		emptyValue = "";
		jspContext.setAttribute("emptyValue", emptyValue);
	}
	urlparams.append("&emptyValue=").append(emptyValue);
	if (showUnset.booleanValue()) {
		urlparams.append("&showUnset=").append(showUnset);
		urlparams.append("&unsetValue=").append(unsetValue);
	}
	if (specialValueResolver != null) {
		urlparams.append("&specialValueResolver=").append(specialValueResolver);
	}
	urlparams.append("&htmlId=").append(htmlId);
	urlparams.append("&fieldName=").append(URLCoder.encode(fieldName));

	if (workItemMode != null) {
		urlparams.append("&workItemMode=").append(workItemMode);
	} else {
		jspContext.setAttribute("workItemMode", Boolean.FALSE);
	}
	if (workItemTrackerIds != null && !workItemTrackerIds.isEmpty()) {
		urlparams.append("&workItemTrackerIds=").append(workItemTrackerIds);
	} else {
		jspContext.setAttribute("workItemTrackerIds", "");
	}
	if (reportMode != null) {
		urlparams.append("&reportMode=").append(reportMode);
	} else {
		jspContext.setAttribute("reportMode", Boolean.FALSE);
	}

	jspContext.setAttribute("urlparams", urlparams.toString());
	jspContext.setAttribute("getContext", "null");
%>

<bugs:fieldDependency id="${valueId}" tracker="${tracker_id}" status="${status_id}" field="${label}" disabled="${disabled}" decorator="${decorator}" context="<%=jspContext%>"/>

<c:if test="${! disabled}">
	<c:set var="onclick">chooseReferences.selectReferences('${htmlId}', '${urlparams}', ${getContext}); return false;</c:set>
</c:if>

<bugs:chooseReferencesUI tracker_id="${tracker_id}" field_id="${field_id}" label="${label}" ids="${ids}"
	labelMap="${labelMap}" specialValueResolver="${specialValueResolver}" emptyValue="${emptyValue}"
	htmlId="${htmlId}" fieldName="${fieldName}" ajaxURLParameters="${urlparams}" disabled="${disabled}"
	title="${title}" onclick="${onclick}" cssClass="${cssClass}" multiSelect="${multiSelect}"
	removeDoNotModifyBox="${removeDoNotModifyBox}" showPopupButton="<%=showPopupButton%>"
	workItemMode="${workItemMode}" reportMode="${reportMode}" workItemTrackerIds="${workItemTrackerIds}"
	reqContext="${getContext}" onChange="${onChange}" onChangeHandler="${onChangeHandler}"
/>

