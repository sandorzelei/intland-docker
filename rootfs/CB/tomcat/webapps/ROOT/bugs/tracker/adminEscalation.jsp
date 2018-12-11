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
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="uitaglib" prefix="ui" %>

<style type="text/css">
<!--
	#tracker-customize-escalation {
		margin: 0px !important;
	}
	#tracker-customize-escalation .actionBar {
		margin: 0px !important;
		padding-left: 15px !important;
		height: 25px;
	}
	#tracker-customize-escalation .actionBar input[type=button] {
		margin-left: 0px !important;
	}
	#tracker-customize-escalation .hint {
		background: white;
		padding: 20px 15px;
	}
	#tracker-customize-escalation .displaytag .textDataWrap {
		padding-left: 5px !important;
	}
	#tracker-customize-escalation .rightAlignedDescription {
		padding-top: 3px;
	}

	div.escalations {
		padding: 20px 20px;
	}

	ul.escalations {
		margin: 0px;
		padding: 0px 0px 0px 4px;
	}

	ul.escalations > li.escalation {
		list-style-type: none;
		margin: 0px 0px 3em 0px;
		padding: 0px 0px 0px 0px !important;
	}

	ul.escalations > li.escalation > span > a {
		font-weight: bold;
		text-decoration: underline;
	}

	ol.escalationRules > li.escalationRule {
		margin-top: 6px;
	}

	ol.escalationRules > li.moreRules {
		list-style-type: none;
		margin-top: 6px;
	}

	div.moreRules a {
			margin-right: 1em;
	}

	li.escalation .removeButton {
			margin-right: 0.5em;
	}

	li.escalation .moreRules {
			margin-top: 12px;
			display: block;
	}

	li.escalation .itemCont {
			margin-bottom: 12px;
			display: block;
	}

	.selector a {
			margin-left: 1em;
	}

	.selector {
			margin-bottom: 1em;
	}

-->
</style>

<form id="tracker-customize-escalation" action="${configurationUrl}" method="post">

	<div class="actionBar">
		<c:if test="${canAdminProject}">
			<input type="button" class="button newEscalationViewLink" value="<spring:message code="tracker.escalation.config.new.escalation.view"/>">
		</c:if>
		<spring:message var="cancelButton" code="button.cancel" text="Cancel"/>
		<input type="submit" class="cancelButton" name="_cancel" value="${cancelButton}" />

		<c:if test="${canAdminProject}">
			<spring:message var="projCalTitle" code="project.calendar.tooltip" text="View project calendar"/>
			<a href="${projectCalendarURL}" title="${projCalTitle}"><spring:message var="projCalTitle" code="project.calendar.label" text="Project Calendar"/></a>
		</c:if>

		<div class="rightAlignedDescription">
			<spring:message code="tracker.escalation.tooltip" arguments="${projectCalendarURL},${systemCalendarURL}"/>
		</div>
	</div>

	<div class="escalations">
	</div>

</form>

<script type="text/javascript" src="<ui:urlversioned value='/bugs/tracker/includes/escalationRules.js'/>"></script>
<script type="text/javascript">

	$('#tracker-customize-escalation > div.escalations').trackerEscalationRules({ id : ${tracker.id}, name : "<c:out value='${tracker.name}'/>" }, ${escalationsJSON}, {
		editable			: ${canAdminTracker},
		itemFiltersUrl		: '${escalationTrackerFilterUrl}',
		trackerViewUrl		: '${trackerViewUrl}',
		anchorFieldsUrl		: '${anchorFieldsUrl}',
		ruleValidationURL	: '${ruleValidationURL}',
				trackerCreateViewURL: '${trackerCreateViewURL}',
		anchors				: [<c:forEach items="${anchors}" var="anchor" varStatus="loop">{ value : "${anchor.key}", label : "${anchor.value}" }<c:if test="${!loop.last}">, </c:if></c:forEach>],
		units				: [<c:forEach items="${units}"   var="unit"   varStatus="loop">{ id : "${unit.id}", name : '<spring:message code="timeunit.${unit.name}" text="${unit.name}" javaScriptEscape="true"/>' }<c:if test="${!loop.last}">, </c:if></c:forEach>],
		statuses			: [<c:forEach items="${statuses}" var="status" varStatus="loop">{ id : "${status.id}", name : '<spring:message code="tracker.choice.${status.name}.label" text="${status.name}" javaScriptEscape="true"/>' }<c:if test="${!loop.last}">, </c:if></c:forEach>],
				rulesOfLabel        : '<spring:message code="tracker.escalation.rule_of.label"         text="Escalation rules of" 			 javaScriptEscape="true"/>',
		itemsLabel			: '<spring:message code="tracker.escalation.items.label"           text="For such items" 				 javaScriptEscape="true"/>',
		itemsNoneLabel		: '<spring:message code="tracker.escalation.items.none"            text="No items with escalation"	     javaScriptEscape="true"/>',
		itemsMoreLabel		: '<spring:message code="tracker.escalation.items.more"            text="More..." 						 javaScriptEscape="true"/>',
		itemsRemoveLabel	: '<spring:message code="tracker.escalation.items.remove.label"    text="Remove" 						 javaScriptEscape="true"/>',
		itemsRemoveConfirm	: '<spring:message code="tracker.escalation.items.remove.confirm"  text="Do you really want to remove the escalation rules for these items?" javaScriptEscape="true"/>',
		filterNewLabel		: '<spring:message code="tracker.escalation.filter.create.label"   text="New" 							 javaScriptEscape="true"/>',
		filterNewTitle		: '<spring:message code="tracker.escalation.filter.create.tooltip" text="Create a new item filter" 		 javaScriptEscape="true"/>',
		filterEditLabel		: '<spring:message code="tracker.escalation.filter.edit.label"     text="Edit" 							 javaScriptEscape="true"/>',
		filterEditTitle		: '<spring:message code="tracker.escalation.filter.edit.tooltip"   text="Edit the selected item filter"	 javaScriptEscape="true"/>',
		filterNameLabel		: '<spring:message code="tracker.escalation.filter.name.label"     text="Name" 							 javaScriptEscape="true"/>',
		ruleLabel			: '<spring:message code="tracker.escalation.rule.label"     	   text="Escalation rule" 				 javaScriptEscape="true"/>',
		rulesLabel			: '<spring:message code="tracker.escalation.rules.label"     	   text="Escalation rules" 				 javaScriptEscape="true"/>',
		rulesNoneLabel		: '<spring:message code="tracker.escalation.rules.none"     	   text="No escalation rules" 			 javaScriptEscape="true"/>',
		rulesMoreLabel		: '<spring:message code="tracker.escalation.rules.more"     	   text="More..." 						 javaScriptEscape="true"/>',
		rulesEditHint		: '<spring:message code="tracker.field.layout.inline.edit.hint"	   text="Click to edit" javaScriptEscape="true"/>',
		rulesRemoveLabel	: '<spring:message code="tracker.escalation.rules.remove.label"    text="Remove" 						 javaScriptEscape="true"/>',
		rulesRemoveConfirm	: '<spring:message code="tracker.escalation.rules.remove.confirm"  text="Do you really want to remove escalation rule?" javaScriptEscape="true"/>',
		rulesLastLabel		: '<spring:message code="tracker.escalation.anchor.after last escalation" text="after last escalation"   javaScriptEscape="true"/>',
		levelLabel			: '<spring:message code="tracker.escalation.level.label"     	   text="Level" 				 		 javaScriptEscape="true"/>',
		anchorLabel			: '<spring:message code="tracker.escalation.anchor.label"     	   text="Anchor" 				 		 javaScriptEscape="true"/>',
		offsetLabel			: '<spring:message code="tracker.escalation.offset.label" 		   text="Offset"  						 javaScriptEscape="true"/>',
		offsetTitle			: '<spring:message code="tracker.escalation.offset.tooltip" 	   text="Offset (of working time) relative to anchor (field)" javaScriptEscape="true"/>',
		updateStatusText	: '<spring:message code="tracker.escalation.action.update" 		   text="Update item status to {0}" arguments="XXX" javaScriptEscape="true"/>',
		updateStatusLabel   : '<spring:message code="tracker.escalation.config.header.update.status.to" text="Update status to" javaScriptEscape="true"/>',
		updateStatusTitle	: '<spring:message code="tracker.escalation.config.header.update.status.to.title" text="At this escalation level, update the item status to this value" javaScriptEscape="true"/>',
		sendEmailText		: '<spring:message code="tracker.escalation.action.alert" 		   text="Alert {0} by email" arguments="XXX" javaScriptEscape="true"/>',
		sendEmailLabel		: '<spring:message code="tracker.escalation.config.header.send.notification.mail" text="Send notification mail to" javaScriptEscape="true"/>',
			submitText    		: '<spring:message code="button.ok" 							   text="OK" 			javaScriptEscape="true"/>',
			cancelText   		: '<spring:message code="button.cancel" 						   text="Cancel" 		javaScriptEscape="true"/>',
			infobox				: {
			infoLabel		: '<spring:message code="tracker.escalation.rule.info.label" 		text="Administrative Information" javaScriptEscape="true" />',
			infoTitle		: '<spring:message code="tracker.escalation.rule.info.tooltip" 		text="Additional/administrative information about this escalation rule" javaScriptEscape="true" />',
			idLabel			: '<spring:message code="tracker.escalation.rule.id.label" 			text="ID" javaScriptEscape="true" />',
			versionLabel	: '<spring:message code="document.version.label" text="Version" javaScriptEscape="true" />',
			createdByLabel	: '<spring:message code="document.createdBy.label" text="Created by" javaScriptEscape="true" />',
			lastModifiedLabel: '<spring:message code="document.lastModifiedBy.tooltip" text="Last modified by" javaScriptEscape="true" />',
			commentLabel	: '<spring:message code="document.comment.label" text="Comment" javaScriptEscape="true" />'
			}
	});

<c:if test="${canAdminTracker}">
	$('#tracker-customize-escalation > div.actionBar').ajaxSubmitButton({
			submitText    		: '<spring:message code="button.save" text="Save" javaScriptEscape="true"/>',
			submitUrl			: '${trackerEscalationURL}',
			submitData			: function() {
						return $('#tracker-customize-escalation > div.escalations').getEscalationRules('${ruleValidationURL}');
				}
	});
</c:if>

</script>

