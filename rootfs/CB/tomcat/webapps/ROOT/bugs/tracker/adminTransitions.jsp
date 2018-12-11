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
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>

<link rel="stylesheet" type="text/css" href="<ui:urlversioned value='/bugs/tracker/includes/fieldUpdates.css'/>" />
<link rel="stylesheet" type="text/css" href="<ui:urlversioned value='/bugs/tracker/includes/stateTransition.css'/>" />

<head>
<style type="text/css">

	fieldset.collapsingBorder legend.collapsingBorder_legend a {
		font-weight: bold;
		font-size: 10pt;
		color: #000000;
	}

	.stateTransition .name .yuimenubaritemlabel {
		display: inline-block;
		position: relative;
    	left: -14px;
    	top: 2px;
	}

	.transitionLinkContainer {
		width: 100%;
		display: inline-block;
	}

	a.transitionLink.hidden {
		color: gray !Important;
	}

	a.transitionLink.event {
		font-style: italic !Important;
		color: green !Important;
	}

</style>
</head>

<form id="adminTransitionPermissionForm" action="${configurationUrl}" method="post">
	<div class="actionBar">
		<spring:message var="cancelButton" code="button.cancel" text="Cancel"/>
		<input type="submit" class="cancelButton" name="_cancel" value="${cancelButton}" />

		<label for="showObsolete">
			<input type="checkbox" id="showObsolete" style="margin-left: 15px;"/><spring:message code="tracker.state.transitiom.obsolete" />
		</label>

		<div class="rightAlignedDescription">
			<spring:message code="tracker.transitions.tooltip" />
		</div>
	</div>
</form>

<input type="hidden" id="statusOptions" value="${statusOptionsJSON}" />

<jsp:include page="/bugs/includes/issueReview.jsp" />

<script type="text/javascript" src="<ui:urlversioned value='/bugs/tracker/includes/workflowAction.js'/>"></script>
<script type="text/javascript" src="<ui:urlversioned value='/bugs/tracker/includes/stateTransition.js'/>"></script>
<script type="text/javascript">

	var obsoleteStates = [];
	<c:if test="${not empty obsoleteStatusList}">
		<c:forEach var="stateName" items="${obsoleteStatusList}">
			<c:set var="statusName"><spring:escapeBody javaScriptEscape="true">${stateName}</spring:escapeBody></c:set>
			var i18nName = i18n.message("tracker.choice.${statusName}.label");
			if (i18nName == "tracker.choice.${statusName}.label") {
				i18nName = "${statusName}";
			}
			obsoleteStates.push(i18nName);
		</c:forEach>
	</c:if>

	$('#adminTransitionPermissionForm').stateTransitionList({ id : ${tracker.id}, name : "<spring:escapeBody javaScriptEscape="true">${tracker.name}</spring:escapeBody>", project : { id : ${tracker.project.id} } }, ${transitionsJSON}, {
		typeId				: ${tracker.type.id},
		editable			: ${canAdminTracker},
		validationUrl		: '${transValidationUrl}',
		trackerFiltersUrl	: '${trackerFiltersUrl}',
		trackerViewUrl		: '${trackerViewUrl}',
		transitionFieldsUrl : '${transitionFieldsUrl}',
		statusOptions		: [<c:forEach items="${statusOptions}" var="status" varStatus="loop">{ id : ${status.id}, name : '<spring:message code="tracker.choice.${status.name}.label" text="${status.name}" javaScriptEscape="true"/>' }<c:if test="${!loop.last}">, </c:if></c:forEach>],
		events				: ${workflowEvents},
		predicates			: ${transitionPredicates},
		anyStatusLabel		: '<spring:message code="tracker.choice.***.label" text="***" javaScriptEscape="true" />',
		infoLabel			: '<spring:message code="tracker.transition.info.label" text="Administrative Information" javaScriptEscape="true" />',
		infoTitle			: '<spring:message code="tracker.transition.info.tooltip" text="Additional/administrative information about this transition" javaScriptEscape="true" />',
		idLabel				: '<spring:message code="tracker.transition.id.label" text="ID" javaScriptEscape="true" />',
		fromToSame			: '<spring:message code="error.tracker.transition.from.to.same" text="From and To status must be different." javaScriptEscape="true"/>',
		nameLabel			: '<spring:message code="tracker.transition.name.label" text="Name" javaScriptEscape="true" />',
		nameRequired		: '<spring:message code="tracker.transition.name.required" text="A transition name is required" javaScriptEscape="true" />',
		descriptionLabel	: '<spring:message code="tracker.transition.description.label" text="Description" javaScriptEscape="true" />',
		descriptionTooltip	: '<spring:message code="tracker.transition.description.tooltip" javaScriptEscape="true" />',
		versionLabel		: '<spring:message code="document.version.label" text="Version" javaScriptEscape="true" />',
		createdByLabel		: '<spring:message code="document.createdBy.label" text="Created by" javaScriptEscape="true" />',
		lastModifiedLabel	: '<spring:message code="document.lastModifiedBy.tooltip" text="Last modified by" javaScriptEscape="true" />',
		commentLabel		: '<spring:message code="document.comment.label" text="Comment" javaScriptEscape="true" />',
		fromLabel			: '<spring:message code="tracker.transition.from.label" text="From" javaScriptEscape="true"/>',
		obsolete			: obsoleteStates,
		toLabel				: '<spring:message code="tracker.transition.to.label" text="To" javaScriptEscape="true"/>',
		hiddenLabel			: '<spring:message code="tracker.transition.hidden.label" text="Hidden" javaScriptEscape="true"/>',
		hiddenTooltip		: '<spring:message code="tracker.transition.hidden.tooltip" text="A hidden state transition cannot be invoked interactively via the GUI." javaScriptEscape="true"/>',
		state				: {
			label			: '<spring:message code="tracker.workflow.state.label" text="State" javaScriptEscape="true" />',
			tooltip			: '<spring:message code="tracker.workflow.state.tooltip" text="A defined tracker workflow state" javaScriptEscape="true" />'
		},
		event				: {
			label			: '<spring:message code="tracker.workflow.event.label" text="Event" javaScriptEscape="true" />',
			tooltip			: '<spring:message code="tracker.workflow.event.tooltip" text="The workflow event to define or to handle" javaScriptEscape="true" />',
			none			: '<spring:message code="tracker.workflow.event.none.label" text="None" javaScriptEscape="true"/>',
			moreLabel		: '<spring:message code="tracker.workflow.event.more.label" text="More..." javaScriptEscape="true"/>',
			moreTitle		: '<spring:message code="tracker.workflow.event.more.tooltip" text="Add a new workflow event" javaScriptEscape="true"/>',
			deleteLabel		: '<spring:message code="tracker.workflow.event.delete.label" text="Delete" javaScriptEscape="true"/>',
			deleteConfirm	: '<spring:message code="tracker.workflow.event.delete.confirm" text="Do you really want to delete this {0}?" arguments="XXX" javaScriptEscape="true"/>',
		 	duplicateText   : '<spring:message code="tracker.workflow.event.duplicate" text="There is already a {0} for this status!" arguments="XXX" javaScriptEscape="true"/>'
		},
		predicate			: {
			label			: '<spring:message code="tracker.transition.predicate.label" text="Condition" javaScriptEscape="true" />',
			tooltip			: '<spring:message code="tracker.transition.predicate.tooltip" text="The transition condition determines, whether the transition is applicable for a specific subject item (in addition to user permissions and source and target status), or not." javaScriptEscape="true" />',
			expression 		: '<spring:message code="tracker.transition.predicate.expression" text="A boolean expression/formula, that must yield true or false" javaScriptEscape="true" />',
			validationUrl	: '<c:url value="/trackers/ajax/transition/validatePredicateExpression.spr?tracker_id=${tracker.id}"/>'
		},
		guard				: {
			label			: '<spring:message code="tracker.transition.guard.label" text="Guard" javaScriptEscape="true" />',
			tooltip			: '<spring:message code="tracker.transition.guard.tooltip" javaScriptEscape="true" />',
			none			: '<spring:message code="tracker.transition.guard.none" text="None" javaScriptEscape="true" />',
			newLabel		: '<spring:message code="tracker.transition.guard.create.label" text="New.." javaScriptEscape="true"/>',
			editLabel		: '<spring:message code="tracker.transition.guard.edit.label"   text="Edit..." javaScriptEscape="true"/>',
			deleteLabel     : '<spring:message code="tracker.transition.guard.delete.label" text="Delete" javaScriptEscape="true" />',
			deleteConfirm   : '<spring:message code="tracker.transition.guard.delete.confirm" text="Do you really want to delete this guard?" javaScriptEscape="true" />',
			filterRequired	: '<spring:message code="tracker.transition.guard.filter.required" text="The guard condition must contain at least one filter criteria!" javaScriptEscape="true" />'
		},
		changes				: {
			label			: '<spring:message code="tracker.field.Changes.label"  text="Changes" javaScriptEscape="true" />',
			tooltip			: '<spring:message code="tracker.workflow.event.FieldUpdate.tooltip" text="Actions to execute upon changing field values while in a status" javaScriptEscape="true" />',
			none			: '<spring:message code="tracker.workflow.event.FieldUpdate.any" text="Any" javaScriptEscape="true" />',
			newLabel		: '<spring:message code="tracker.workflow.event.FieldUpdate.new" text="New change filter" javaScriptEscape="true" />',
			editLabel		: '<spring:message code="tracker.workflow.event.FieldUpdate.edit" text="Edit change filter" javaScriptEscape="true" />',
			deleteLabel     : '<spring:message code="tracker.workflow.event.FieldUpdate.delete.label" text="Delete..." javaScriptEscape="true" />',
			deleteConfirm   : '<spring:message code="tracker.workflow.event.FieldUpdate.delete.confirm" text="Do you really want to delete this change filter?" javaScriptEscape="true" />',
			filterRequired	: '<spring:message code="tracker.workflow.event.FieldUpdate.filter.required" text="The change filter condition must contain at least one field updated criteria!" javaScriptEscape="true" />'
		},
		submitText    		: '<spring:message code="button.ok" text="OK" javaScriptEscape="true"/>',
		cancelText   		: '<spring:message code="button.cancel" text="Cancel" javaScriptEscape="true"/>',
		addStatus			: '<spring:message code="tracker.transition.add.status.title" text="Add Status..." javaScriptEscape="true"/>',
		editText			: '<spring:message code="tracker.transition.edit.label" text="Edit" javaScriptEscape="true"/>',
		editTitle			: '<spring:message code="tracker.transition.edit.title" text="Edit Transition" javaScriptEscape="true"/>',
		duplicateText		: '<spring:message code="tracker.transition.duplicate.error" text="A transition with the same From/To already exists!" javaScriptEscape="true"/>',

		permissions			: {
			editable			: ${canAdminTracker},
			memberFields		: [<c:forEach items="${memberFields}" var="field" varStatus="loop">{ id : ${field.id}, name : "<spring:message code='tracker.field.${field.label}.label' text='${field.label}' javaScriptEscape='true'/>" }<c:if test="${!loop.last}">, </c:if></c:forEach>],
			roles				: ${projectRoles},
			permissionsLabel	: '<spring:message code="tracker.transition.permissions.label" text="Permitted" javaScriptEscape="true"/>',
			permissionsTooltip	: '<spring:message code="tracker.transition.permissions.tooltip" text="Who is allowed to execute this state transition?" javaScriptEscape="true"/>',
			permissionsNone		: '<spring:message code="tracker.transition.permissions.none" text="None" javaScriptEscape="true" />',
			memberFieldsLabel	: '<spring:message code="tracker.fieldAccess.memberFields.label" text="Participants" javaScriptEscape="true"/>',
			rolesLabel		 	: '<spring:message code="tracker.fieldAccess.roles.label" text="Roles" javaScriptEscape="true"/>',
			checkAllText		: '<spring:message code="tracker.field.value.choose.all" text="Check all" javaScriptEscape="true"/>',
			uncheckAllText		: '<spring:message code="tracker.field.value.choose.none" text="Uncheck all" javaScriptEscape="true"/>'
		},

		actions				: {
			editable			: ${canAdminTracker and tracker.type.id != 9},
			roles				: ${projectRoles},
			trackerFieldsUrl	: '${trackerFieldsUrl}',
			newItemFieldsUrl	: '${newItemFieldsUrl}',
			trackerFiltersUrl	: '${trackerFiltersUrl}',
			trackerViewUrl		: '${trackerViewUrl}',
			actionClasses		: ${actionClasses},
			referenceTypes		: ${referenceTypesJSON},
			actionsLabel		: '<spring:message code="tracker.transition.actions.label" text="Actions" javaScriptEscape="true" />',
			actionsTooltip		: '<spring:message code="tracker.transition.actions.tooltip" text="Custom actions to execute upon this state transition" javaScriptEscape="true" />',
			actionsNone		    : '<spring:message code="tracker.action.none" text="None" javaScriptEscape="true" />',
			actionsMore		    : '<spring:message code="tracker.action.more" text="More..." javaScriptEscape="true" />',
			infoLabel			: '<spring:message code="tracker.action.info.label" text="Administrative Information" javaScriptEscape="true" />',
			infoTitle			: '<spring:message code="tracker.action.info.tooltip" text="Additional/administrative information about this action" javaScriptEscape="true" />',
			idLabel				: '<spring:message code="tracker.action.id.label" text="ID" javaScriptEscape="true" />',
			nameLabel			: '<spring:message code="tracker.action.name.label" text="Name" javaScriptEscape="true" />',
			descriptionLabel	: '<spring:message code="tracker.action.description.label" text="Description" javaScriptEscape="true" />',
			descriptionTooltip	: '<spring:message code="tracker.action.description.tooltip" javaScriptEscape="true" />',
			versionLabel		: '<spring:message code="document.version.label" text="Version" javaScriptEscape="true" />',
			createdByLabel		: '<spring:message code="document.createdBy.label" text="Created by" javaScriptEscape="true" />',
			lastModifiedLabel	: '<spring:message code="document.lastModifiedBy.tooltip" text="Last modified by" javaScriptEscape="true" />',
			commentLabel		: '<spring:message code="document.comment.label" text="Comment" javaScriptEscape="true" />',
			condition			: {
				label			: '<spring:message code="tracker.action.condition.label" 	   text="Condition" javaScriptEscape="true" />',
				tooltip			: '<spring:message code="tracker.action.condition.tooltip" 	   text="An optional condition, to only execute this action, if the condition yields true" javaScriptEscape="true" />',
				none			: '<spring:message code="tracker.action.condition.none" 		text="None" javaScriptEscape="true" />',
				newLabel		: '<spring:message code="tracker.action.condition.create.label" text="New" javaScriptEscape="true" />',
				newTitle		: '<spring:message code="tracker.action.condition.create.title" text="New condition" javaScriptEscape="true" />',
				editLabel		: '<spring:message code="tracker.action.condition.edit.label"   text="Edit" javaScriptEscape="true" />',
				deleteLabel     : '<spring:message code="tracker.action.condition.delete.label" text="Delete" javaScriptEscape="true" />',
				deleteConfirm   : '<spring:message code="tracker.action.condition.delete.confirm" text="Do you really want to delete this condition" javaScriptEscape="true" />'
			},
			executeAs  			: {
				name			: '<spring:message code="tracker.action.executeAs.label"   text="Execute as" javaScriptEscape="true" />',
				title			: '<spring:message code="tracker.action.executeAs.tooltip" text="The special user, the action should be executed as (with that user\'s privileges)." javaScriptEscape="true" />',
				defaultLabel	: '<spring:message code="tracker.action.executeAs.default" text="Default" javaScriptEscape="true" />'
			},
			executeAsEnabled: ${executeAsEnabled},
			association			: {
				assocTypes 		: ${associationTypes},
				assocTypeTitle	: '<spring:message code="issue.copy.association.hint"		text="What kind of association should be established between the copied items and their originals ?" javaScriptEscape="true" />',
				assocTypeLabel	: '<spring:message code="association.assocType.label" 		text="Association Type" javaScriptEscape="true" />',
				assocTypeNone	: '<spring:message code="tracker.reference.choose.none" 	text="None" javaScriptEscape="true"/>',
				suspectedTitle	: '<spring:message code="association.propagatingSuspects.tooltip" text="Should this association be marked \'Suspected\' whenever the association target is modified?" javaScriptEscape="true" />',
				suspectedLabel	: '<spring:message code="association.propagatingSuspects.label" text="Propagate suspects" javaScriptEscape="true" />',
				commentLabel	: '<spring:message code="association.description.label" 	text="Comment"  javaScriptEscape="true" />'
			},
			review 				: trackerItemReviewConfig,
			submitText    		: '<spring:message code="button.ok" text="OK" javaScriptEscape="true"/>',
			cancelText   		: '<spring:message code="button.cancel" text="Cancel" javaScriptEscape="true"/>',
			newText				: '<spring:message code="tracker.action.new.label" text="New..." javaScriptEscape="true"/>',
			newTitle			: '<spring:message code="tracker.action.new.title" text="New Action" javaScriptEscape="true"/>',
			editText			: '<spring:message code="tracker.action.edit.label" text="Edit..." javaScriptEscape="true"/>',
			editTitle			: '<spring:message code="tracker.action.edit.title" text="Edit Action" javaScriptEscape="true"/>',
			editHint			: '<spring:message code="tracker.action.edit.hint" text="Double click to edit this action, or right-click to get edit context menu." javaScriptEscape="true"/>',
			deleteText			: '<spring:message code="tracker.action.delete.label" text="Delete" javaScriptEscape="true"/>',
			deleteConfirm 		: '<spring:message code="tracker.action.delete.confirm" text="Do you really want to remove this action ?" javaScriptEscape="true" />',
			parametersMissing	: '<spring:message code="tracker.action.parameters.missing" text="The following required parameters are missing" javaScriptEscape="true" />',
			distributionMissing : '<spring:message code="tracker.action.referringItemCreator.distribution.missing" text="For each distribution field, there must also be a field update, that copies this field value to a target field" javaScriptEscape="true" />',
			stateChartTitle		: '<spring:message code="tracker.state.transition.chart.label" text="Workflow Graph" javaScriptEscape="true"/>',
			stateChartUrl		: '<c:url value="/proj/tracker/workflowGraph.spr"/>',
			stateChartImageUrl	: '<ui:urlversioned value="/images/state_diagram.gif"/>',
			refActionPatterns	: {
				referringItemCreator : '<spring:message code="tracker.action.referringItemCreator.pattern" text="Create new <refType> in <tracker>" javaScriptEscape="true" />',
				referringItemUpdater : '<spring:message code="tracker.action.referringItemUpdater.pattern" text="Update <refType> in <tracker> with status <status>" javaScriptEscape="true" />'
			},
			referenceSettingTooltip				: '<spring:message code="reference.setting.tooltip" text="Set Propagate suspects (Reverse direction) and/or Baseline" javaScriptEscape="true"/>',
			referenceSettingPropagateSuspects	: '<spring:message code="association.propagatingSuspects.label" text="Propagate suspects" javaScriptEscape="true"/>',
			referenceSettingReverseSuspect		: '<spring:message code="reference.setting.reverse.suspect" text="Reverse direction" javaScriptEscape="true"/>',
			referenceSettingBidirectionalSuspect: '<spring:message code="reference.setting.bidirectional.suspect" text="Bidirectional suspect" javaScriptEscape="true"/>',
			referenceSettingPropagateDependencies:'<spring:message code="reference.setting.propagatingDependencies.label" text="Propagate unresolved dependencies" javaScriptEscape="true"/>',
			referenceSettingBaseline			: '<spring:message code="tracker.field.defaultReferenceVersionType.label" text="Default version" javaScriptEscape="true"/>',
			referenceSettingHeadLabel			: '<spring:message code="tracker.field.defaultReferenceVersionType.HEAD.label" text="Current HEAD" javaScriptEscape="true"/>',
			referenceSettingNonLabel			: '<spring:message code="tracker.field.defaultReferenceVersionType.NONE.label" text="--" javaScriptEscape="true"/>',

			fieldUpdates		: {
				editable			: ${canAdminTracker},
				projectsUrl			: '<c:url value="/proj/ajax/projectsWithCategory.spr"/>',
				fieldOptionsUrl		: '${fieldOptionsUrl}',
				projectRolesUrl		: '${projectRolesUrl}',
				projectTrackersUrl  : '${projectTrackersUrl}',
				referringTrackersUrl: '${referringTrackersUrl}',
				exprValidationUrl   : '${exprValidationUrl}',
				fieldUpdateOps		: ${fieldUpdateOps},
				dateOptions			: ${dateOptions},
				countryOptions		: ${countryOptions},
				languageOptions		: ${languageOptions},
				valueTypes    		: [{
										 id     : 0,
										 name   : '<spring:message code="tracker.field.value.choose.none"     text="None" javaScriptEscape="true"/>'
									   }, {
										 id 	: 1,
										 name   : '<spring:message code="tracker.field.value.label"     	  text="Value" javaScriptEscape="true"/>'
									   }, {
										 id 	: 2,
										 name   : '<spring:message code="tracker.field.value.valueOf.label"   text="Value of" javaScriptEscape="true"/>',
		                    	   		 title  : '<spring:message code="tracker.field.value.valueOf.tooltip" text="The value of the selected subject field" javaScriptEscape="true"/>',
		                    	   		 option : {
		                    	   			name  : '<spring:message code="tracker.field.value.copyFrom.label"   text="Copy from" javaScriptEscape="true"/>',
			                    	   		title : '<spring:message code="tracker.field.value.copyFrom.tooltip" text="Copy the value from the selected subject field" javaScriptEscape="true"/>'
		                    	   		 }
				                       }, {
				                    	 id 	: 3,
										 name   : '<spring:message code="tracker.field.value.resultOf.label"   text="Result of" javaScriptEscape="true"/>',
		                    	   		 title  : '<spring:message code="tracker.field.value.resultOf.tooltip" text="The result of the specified computation/expression" javaScriptEscape="true"/>',
		                    	   		 option : {
		                    	   			name  : '<spring:message code="tracker.field.value.compute.label"   text="Compute as" javaScriptEscape="true"/>',
			                    	   		title : '<spring:message code="tracker.field.value.compute.tooltip" text="Compute the field value via the specified formula/expression" javaScriptEscape="true"/>'
		                    	   		 }
				                      }],
				updatesLabel		: '<spring:message code="tracker.action.fieldUpdates.label" text="Field Updates" javaScriptEscape="true"/>',
				updatesTooltip		: '<spring:message code="tracker.action.fieldUpdates.tooltip" text="Field values to update upon transition" javaScriptEscape="true"/>',
				updatesNone			: '<spring:message code="tracker.action.fieldUpdates.none" text="None" javaScriptEscape="true"/>',
				updatesMore			: '<spring:message code="tracker.action.fieldUpdates.more" text="More..." javaScriptEscape="true"/>',
				updatesEdit			: '<spring:message code="tracker.action.fieldUpdates.edit" text="Edit" javaScriptEscape="true"/>',
				updatesRemove		: '<spring:message code="tracker.action.fieldUpdates.remove" text="Remove" javaScriptEscape="true"/>',
				updatesDblClick		: '<spring:message code="tracker.action.fieldUpdates.dblclick.hint" text="Double click to edit the fields to update" javaScriptEscape="true"/>',
				unsetLabel			: '<spring:message code="tracker.field.value.unset.tooltip" text="Clear field value" javaScriptEscape="true"/>',
				checkAllText		: '<spring:message code="tracker.field.value.choose.all" text="Check all" javaScriptEscape="true"/>',
				filterText			: '<spring:message code="tracker.field.value.filter.label" text="Filter" javaScriptEscape="true"/>',
			    trueValueText		: '<spring:message code="boolean.true.label" text="true" javaScriptEscape="true"/>',
				falseValueText		: '<spring:message code="boolean.false.label" text="false" javaScriptEscape="true"/>',
			    submitText    		: '<spring:message code="button.ok" text="OK" javaScriptEscape="true"/>',
				cancelText   		: '<spring:message code="button.cancel" text="Cancel" javaScriptEscape="true"/>',
				commentText			: '<spring:message code="comment.label" text="Comment" javaScriptEscape="true"/>',
				separatorLabel		: '<spring:message code="tracker.field.op.separator.label" text="Separator" javaScriptEscape="true"/>',
				separatorTooltip	: '<spring:message code="tracker.field.op.separator.tooltip" text="The optional separator between the existing text and the additional text to prepend/append" javaScriptEscape="true"/>',
				mandatoryValue		: '<spring:message code="issue.mandatory.field.missing" text="Mandatory {0} value is missing" arguments="XX" javaScriptEscape="true"/>'
			},
            fieldValuesLabel	: '<spring:message code="tracker.field.values.label" text="Field values" javaScriptEscape="true"/>',
            fieldValuesTooltip	: '<spring:message code="tracker.field.values.tooltip" text="Item field values to set" javaScriptEscape="true"/>'
		}
	}, '${trackerLayoutLabelStatusId}');

<c:if test="${canAdminTracker}">

	$('#adminTransitionPermissionForm > div.actionBar').ajaxSubmitButton({
	    id          : 'saveStateTransitionsSubmitButton',
	    submitText  : '<spring:message code="button.save" text="Save" javaScriptEscape="true"/>',
	    submitUrl	: '${transitionsUrl}',
	    submitData	: function() {
							return $('#adminTransitionPermissionForm').getStateTransitions();
					  },
		onSuccess	: function(result) {
							showOverlayMessage(i18n.message("ajax.changes.successfully.saved"));

						    $('#adminTransitionPermissionForm').submit();
					  }
	});

</c:if>

</script>

<script type="text/javascript">
	$(document).ready(function() {

		toggleObsoleteStates(obsoleteStates, false);

		$("#showObsolete").change(function() {
			setTimeout(function() {
				toggleObsoleteStates(obsoleteStates, true);
			}, 10);

		});
	});

	function toggleObsoleteStates(obsoleteStates, refreshDiagram) {
		if ($("#showObsolete").is(':checked')) {
			$(".stateTransition").each(function(index) {
				$(this).show();
			});
		} else {
			$(".stateTransition").each(function(index) {
				var fromStatusName = $(this).find("td.fromStatus").text();
				var toStatusName = $(this).find("td.toStatus").text();
				var obsoleteText = i18n.message("issue.flag.Obsolete.label");
				if (obsoleteText == "issue.flag.Obsolete.label") {
					i18nName = "Obsolete";
				}
				for (var i = 0; i < obsoleteStates.length; ++i) {
					if (fromStatusName.indexOf(obsoleteText) != -1 || toStatusName.indexOf(obsoleteText) != -1) {
						$(this).hide();
					}
				}
			});
		}
		if (refreshDiagram) {
			$('#stateTransitionChartContainer').load(contextPath + '/trackers/ajax/getTrackerStateTransitionDiagram.spr?showObsolete=' + $("#showObsolete").is(':checked') + '&tracker_id=' + ${tracker.id} + '&distance=' + $("#stateTransitionChartDistanceSelector").val() + '&revision=${trackerRevision}', function( response, status, xhr ) {
			  if ( status == "error" ) {
			    var msg = "Sorry but there was an error: ";
			    $( "#error" ).html( msg + xhr.status + " " + xhr.statusText );
			  }
			});
		}
	}
</script>



<c:if test="${!empty stateTransitionChart}">
	<c:url var="trackerStateTransitionDiagramURL" value="/trackers/ajax/getTrackerStateTransitionDiagram.spr">
		<c:param name="tracker_id" value="${tracker.id}"/>
	</c:url>

	<script type="text/javascript">
		function showStateTransition(transitionId) {
			$('#adminTransitionPermissionForm').showStateTransitionEditor(transitionId);
		}

		function showStateNode(statusId) {
			$('#adminTransitionPermissionForm').showStateNodeEditor(statusId);
		}

		function changeDistance(selector) {
			$('#stateTransitionChartContainer').load('${trackerStateTransitionDiagramURL}&showObsolete=' + $("#showObsolete").is(':checked') + '&distance=' + selector.value + '&revision=${trackerRevision}', function( response, status, xhr ) {
				  if ( status == "error" ) {
					    var msg = "Sorry but there was an error: ";
					    $( "#error" ).html( msg + xhr.status + " " + xhr.statusText );
					  }
			});
		}
	</script>

	<spring:message var="chartTitle" code="tracker.state.transition.chart.label" text="Workflow Graph"/>
	<ui:collapsingBorder id="stateTransitionChart" label="${chartTitle}" open="true" cssStyle="margin-top: 24px;">
		<div class="distanceSelector" style="float: Right; position: relative; top: -24px; right: 10px; background-color: #ffffff; padding-left: 4px; padding-right: 4px;">
			<spring:message code="tracker.state.transition.chart.distance" text="Distance"/>:

			<select id="stateTransitionChartDistanceSelector" onchange="changeDistance(this);">
				<c:forEach begin="0" end="2" varStatus="status">
					<c:set var="selected" value=""/>
					<c:if test="${(empty param.distance ? 0 : param.distance) eq status.index}">
						<c:set var="selected" value="selected='selected'"/>
					</c:if>
					<option value="${status.index}" ${selected}>${status.index}</option>
				</c:forEach>
			</select>
		</div>

		<div id="stateTransitionChartContainer" style="margin: 5px;">
			${stateTransitionChart}
		</div>
	</ui:collapsingBorder>
</c:if>
