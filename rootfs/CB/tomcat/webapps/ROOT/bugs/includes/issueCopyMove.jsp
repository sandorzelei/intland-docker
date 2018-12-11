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

<link rel="stylesheet" type="text/css" href="<ui:urlversioned value='/bugs/tracker/includes/fieldUpdates.css'/>" />
<script type="text/javascript">

	var trackerItemsFieldMappingForm = {
		mappingLabel	: '<spring:message code="issue.paste.assign.hint"   text="Please map the following source and target fields manually:" javaScriptEscape="true" />',
		sourceFieldLabel: '<spring:message code="issue.paste.assign.source.label" text="Source Field" javaScriptEscape="true" />',
		targetFieldLabel: '<spring:message code="issue.paste.assign.target.label" text="Target Field" javaScriptEscape="true" />',
		targetFieldNone : '<spring:message code="issue.paste.assign.target.none"  text="--not available--" javaScriptEscape="true" />',
		lostLabel		: '<spring:message code="issue.paste.lost.warning" text="Warning! The content of following source fields will not be transferred and will get lost!" javaScriptEscape="true" />'
	};

	var trackerItemsCopyAssociation = {
		assocTypes      : [{ id : 0, name : '<spring:message code="tracker.reference.choose.none" text="None" javaScriptEscape="true"/>'}<c:forEach items="<%=com.intland.codebeamer.persistence.dao.impl.AssociationDaoImpl.getInstance().findTypes()%>" var="assocType">,
		  				   { id : ${assocType.id}, suspectedSupported: '${assocType.supportsSuspected()}', name : '<spring:message code="association.typeId.${assocType.name}" text="${assocType.name}" javaScriptEscape="true"/>'}</c:forEach>],
		assocTypeTitle	: '<spring:message code="issue.copy.association.hint"		text="What kind of association should be established between the copied items and their originals ?" javaScriptEscape="true" />',
		assocTypeLabel	: '<spring:message code="association.assocType.label" 		text="Association Type" javaScriptEscape="true" />',
		suspectedTitle	: '<spring:message code="association.propagatingSuspects.tooltip" text="Should this association be marked \'Suspected\' whenever the association target is modified?" javaScriptEscape="true" />',
		suspectedLabel	: '<spring:message code="association.propagatingSuspects.label" text="Propagate suspects" javaScriptEscape="true" />',
		commentLabel	: '<spring:message code="association.description.label" 	text="Comment"  javaScriptEscape="true" />'
	};

	var trackerItemsCopyMoveToDialog = {
		projectsUrl   	: '<c:url value="/proj/ajax/projects.spr"/>',
		trackersUrl   	: '<c:url value="/trackers/ajax/compatibleProjectTrackers.spr"/>',
		followUrl		: '<c:url value="/tracker/"/>',
		itemsLabel   	: '<spring:message code="tracker.type.Item.plural"			text="Items" javaScriptEscape="true" />',
		noItemsWarning	: '<spring:message code="no.item.selected"					text="Please select some items first!" javaScriptEscape="true" />',
		projectLabel   	: '<spring:message code="issue.destination.project.label"   text="Destination project" javaScriptEscape="true" />',
		projectTitle  	: '<spring:message code="issue.destination.project.tooltip" text="Select the destination project for the {0} operation" arguments="ABC" javaScriptEscape="true" />',
		trackerLabel  	: '<spring:message code="issue.destination.tracker.label"   text="Destination tracker" javaScriptEscape="true" />',
		trackerTitle  	: '<spring:message code="issue.destination.tracker.tooltip" text="Selected the destination tracker for the {0} operation" arguments="ABC" javaScriptEscape="true" />',
		noDestination   : '<spring:message code="issue.destination.missing" 		text="Please select the destination project and tracker" javaScriptEscape="true" />',
		switchToLabel 	: '<spring:message code="issue.destination.follow.label"    text="Switch to destination" javaScriptEscape="true" />',
		switchToTitle 	: '<spring:message code="issue.destination.follow.tooltip"  text="Should the browser view switch to the destination tracker after the {0} operation ?" arguments="ABC" javaScriptEscape="true" />',
		submitText    	: '<spring:message code="button.ok" 					   	text="OK" 		javaScriptEscape="true"/>',
		cancelText   	: '<spring:message code="button.cancel" 				   	text="Cancel" 	javaScriptEscape="true"/>',
		association		: trackerItemsCopyAssociation,
		mapping			: trackerItemsFieldMappingForm
	};

	var trackerItemReviewDialog = {
		submitUrl		: '<c:url value="/trackers/ajax/trackerItemReview.spr?task_id="/>',
		submitText    	: '<spring:message code="button.ok"     text="OK" javaScriptEscape="true"/>',
		cancelText   	: '<spring:message code="button.cancel" text="Cancel" javaScriptEscape="true"/>',

		rating : {
			title		: '<spring:message code="issue.rating.title"    text="Rating for {1}" arguments="XX,YY" javaScriptEscape="true" />',
			header		: '<spring:message code="issue.rating.header"   text="{0}, Please enter your rating for {1}" arguments="XX,YY" javaScriptEscape="true" />',
			label		: '<spring:message code="issue.rating.label"    text="Rating" javaScriptEscape="true"/>',
		    tooltip	 	: '<spring:message code="issue.rating.tooltip"  text="Your rating for the specified (work) item" javaScriptEscape="true"/>',
		    required	: '<spring:message code="issue.rating.required" text="Please enter your rating for the (work) item" javaScriptEscape="true"/>',
			ofLabel    	: '<spring:message code="my.open.issues.of" 	text="of" javaScriptEscape="true"/>'
		},

		approval : {
			title		: '<spring:message code="issue.approval.title" 	text="Approval of {1}" arguments="XX,YY" javaScriptEscape="true" />',
			header		: '<spring:message code="issue.approval.header" text="{0}, Please Approve or Decline {1}" arguments="XX,YY" javaScriptEscape="true" />',
			approve : {
			   "class" 	: "approveButton",
				text 	: '<spring:message code="issue.approve.label" 	text="Approve" javaScriptEscape="true"/>'
			},
			decline : {
			   "class" 	: "declineButton",
				text 	: '<spring:message code="issue.decline.label" 	text="Decline" javaScriptEscape="true"/>'
			}
		},

		signature : {
			label 	 : '<spring:message code="user.signature.label" 	text="Signature" javaScriptEscape="true"/>',
			tooltip  : '<spring:message code="user.signature.tooltip" 	text="Digital user signature" javaScriptEscape="true"/>',
			username : {
				label 	: '<spring:message code="user.signature.username.label" 	text="Username" javaScriptEscape="true"/>',
				tooltip : '<spring:message code="user.signature.username.tooltip" 	text="Please enter your login username, to verify your identity" javaScriptEscape="true"/>',
				required: '<spring:message code="user.signature.username.required" 	text="In order to verify your identity, please enter your account/login username" javaScriptEscape="true"/>'
			},
			password : {
				label 	: '<spring:message code="user.signature.password.label" 	text="Password" javaScriptEscape="true"/>',
				tooltip : '<spring:message code="user.signature.password.tooltip" 	text="Please enter your password, to verify your identity" javaScriptEscape="true"/>',
				required: '<spring:message code="user.signature.password.required" 	text="In order to verify your identity, please enter your account/login password" javaScriptEscape="true"/>'
			}
		}
	};

	var issueCopyMoveConfig = {
		"cut" : $.extend({}, trackerItemsCopyMoveToDialog, {
			copy			: false,
			action			: '<spring:message code="action.cut.label" 	text="Cut" javaScriptEscape="true" />',
			submitUrl		: '<c:url value="/trackers/ajax/moveTrackerItems.spr?tracker_id="/>'
		}),

		"copy" : $.extend({}, trackerItemsCopyMoveToDialog, {
			copy			: true,
			action			: '<spring:message code="action.copy.label"			text="Copy" javaScriptEscape="true" />',
			title			: '<spring:message code="issue.copyTo.dialog.title" text="Copy {0} {1} to ..." arguments="XX,YY" javaScriptEscape="true" />',
			width			: 680,
			submitUrl		: '<c:url value="/trackers/ajax/copyTrackerItems.spr?tracker_id="/>'
		}),

		"move" : $.extend({}, trackerItemsCopyMoveToDialog, {
			copy			: false,
			action			: '<spring:message code="issue.move.label" 			text="Move" javaScriptEscape="true" />',
			title			: '<spring:message code="issue.moveTo.dialog.title" text="Move {0} {1} to ..." arguments="XX,YY" javaScriptEscape="true" />',
			submitUrl		: '<c:url value="/trackers/ajax/moveTrackerItems.spr?tracker_id="/>'
		}),

		"paste" : $.extend({}, trackerItemsCopyMoveToDialog, {
			pasteUrl		: '<c:url value="/trackers/ajax/pasteTrackerItems.spr?tracker_id="/>',
			copyUrl			: '<c:url value="/trackers/ajax/copyTrackerItems.spr?tracker_id="/>',
			moveUrl			: '<c:url value="/trackers/ajax/moveTrackerItems.spr?tracker_id="/>',
			copyAction		: '<spring:message code="issue.copy.label" 				text="Copy" javaScriptEscape="true" />',
			copyTitle		: '<spring:message code="issue.copyFrom.dialog.title"	text="Copy {0} {1} to here ..." arguments="XX,YY" javaScriptEscape="true" />',
			moveAction		: '<spring:message code="issue.move.label" 				text="Move" javaScriptEscape="true" />',
			moveTitle		: '<spring:message code="issue.moveFrom.dialog.title" 	text="Move {0} {1} to here ..." arguments="XX,YY" javaScriptEscape="true" />',
			copyWidth		: 680
		}),

		"copyTo" : $.extend({}, trackerItemsCopyMoveToDialog, {
			copy			: true,
			action			: '<spring:message code="issue.copy.label" 			text="Copy" javaScriptEscape="true" />',
			title			: '<spring:message code="issue.copyTo.dialog.title" text="Copy {0} {1} to ..." arguments="XX,YY" javaScriptEscape="true" />',
			width			: 680,
			submitUrl		: '<c:url value="/trackers/ajax/copyTrackerItems.spr?tracker_id="/>'
		}),

		"moveTo" : $.extend({}, trackerItemsCopyMoveToDialog, {
			copy			: false,
			action			: '<spring:message code="issue.move.label" 			text="Move" javaScriptEscape="true" />',
			title			: '<spring:message code="issue.moveTo.dialog.title" text="Move {0} {1} to ..." arguments="XX,YY" javaScriptEscape="true" />',
			submitUrl		: '<c:url value="/trackers/ajax/moveTrackerItems.spr?tracker_id="/>'
		}),

		"delete" :  {
			noItemsWarning	: '<spring:message code="no.item.selected"					text="Please select some items first!" javaScriptEscape="true" />',
			confirmMsg		: '<spring:message code="tracker.delete.selected.item.confirm" text="Do you really want to delete the {0} selected items?" arguments="XX" javaScriptEscape="true" />',
			submitUrl		: '<c:url value="/trackers/ajax/removeTrackerItems.spr?tracker_id="/>'
		},

		"restore" :  {
			noItemsWarning	: '<spring:message code="no.item.selected"					text="Please select some items first!" javaScriptEscape="true" />',
			confirmMsg		: '<spring:message code="tracker.restore.selected.item.confirm" text="Do you really want to restore the {0} selected items?" arguments="XX" javaScriptEscape="true" />',
			submitUrl		: '<c:url value="/trackers/ajax/restoreTrackerItems.spr?tracker_id="/>'
		},

		"massEdit" : {
			noItemsWarning	: '<spring:message code="no.item.selected" text="Please select some items first!" javaScriptEscape="true" />',
			initUrl			: '<c:url value="/trackers/ajax/initMassEdit.spr?tracker_id="/>',
			submitUrl		: '<c:url value="/trackers/ajax/massEditTrackerItems.spr?tracker_id="/>',
			title			: '<spring:message code="issue.massEdit.title" text="{0} - Mass Edit" arguments="XX,YY" javaScriptEscape="true" />',
			header			: '<spring:message code="issue.massEdit.header" text="The following field updates will be applied to the {0} selected {1}" arguments="YY,XX" javaScriptEscape="true" />',
			help			: {
					URL		: 'https://codebeamer.com/cb/wiki/825406',
					title	: 'Mass Edit in the CodeBeamer Knowledge Base'
			},
			removedInfo		: '<spring:message code="issue.massEdit.fieldsWithHierarchyRule.info" arguments="XX" javaScriptEscape="true" />',
			valueTypes 		: [{
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
			updatesLabel	: '<spring:message code="tracker.action.fieldUpdates.label" text="Field Updates" javaScriptEscape="true"/>',
			updatesTooltip	: '<spring:message code="tracker.action.fieldUpdates.tooltip" text="Field values to update upon transition" javaScriptEscape="true"/>',
			updatesNone		: '<spring:message code="tracker.action.fieldUpdates.none" text="None" javaScriptEscape="true"/>',
			updatesMore		: '<spring:message code="tracker.action.fieldUpdates.more" text="More..." javaScriptEscape="true"/>',
			updatesEdit		: '<spring:message code="tracker.action.fieldUpdates.edit" text="Edit" javaScriptEscape="true"/>',
			updatesRemove	: '<spring:message code="tracker.action.fieldUpdates.remove" text="Remove" javaScriptEscape="true"/>',
			updatesDblClick	: '<spring:message code="tracker.action.fieldUpdates.dblclick.hint" text="Double click to edit the fields to update" javaScriptEscape="true"/>',
			unsetLabel		: '<spring:message code="tracker.field.value.unset.tooltip" text="Clear field value" javaScriptEscape="true"/>',
			checkAllText	: '<spring:message code="tracker.field.value.choose.all" text="Check all" javaScriptEscape="true"/>',
			filterText		: '<spring:message code="tracker.field.value.filter.label" text="Filter" javaScriptEscape="true"/>',
			trueValueText	: '<spring:message code="boolean.true.label" text="true" javaScriptEscape="true"/>',
			falseValueText	: '<spring:message code="boolean.false.label" text="false" javaScriptEscape="true"/>',
			submitText    	: '<spring:message code="button.save" text="Save" javaScriptEscape="true"/>',
			cancelText   	: '<spring:message code="button.cancel" text="Cancel" javaScriptEscape="true"/>',
			nextText		: '<spring:message code="issue.massEdit.baseline.continue.button" text="Create baseline..." javaScriptEscape="true"/>',
			prevText		: '<spring:message code="button.back" text="Back" javaScriptEscape="true"/>',
			commentText		: '<spring:message code="comment.label" text="Comment" javaScriptEscape="true"/>',
			separatorLabel	: '<spring:message code="tracker.field.op.separator.label" text="Separator" javaScriptEscape="true"/>',
			separatorTooltip: '<spring:message code="tracker.field.op.separator.tooltip" text="The optional separator between the existing text and the additional text to prepend/append" javaScriptEscape="true"/>',
			mandatoryValue	: '<spring:message code="issue.mandatory.field.missing" text="Mandatory {0} value is missing" arguments="XX" javaScriptEscape="true"/>',
			baselineHeader	: '<spring:message code="issue.massEdit.baseline.header" text="Create the following Baseline after applying field updates" javaScriptEscape="true"/>',
			baselineHint	: '<spring:message code="issue.massEdit.baseline.notice" text="These field updates necessitate creating a new Baseline." javaScriptEscape="true"/>',
			baselineName	: '<spring:message code="baseline.name.label" text="Name" javaScriptEscape="true"/>',
			baselineDescription	: '<spring:message code="baseline.description.label" text="Description" javaScriptEscape="true"/>',
			baselineSignature	: '<spring:message code="baseline.signature.label" text="Signature" javaScriptEscape="true"/>',
			baselineFieldMandatory	: '<spring:message code="baseline.mandatory.field.notice" text="Field is mandatory" javaScriptEscape="true"/>',
			baselineMode: '<spring:message code="baseline.tracker.mode.label" text="Create Tracker Baseline" javaScriptEscape="true"/>',
			submitWarning: '<spring:message code="tracker.action.fieldUpdates.warning" text="You haven\'t selected any Field to update." javaScriptEscape="true"/>'
		}
	};

	var issueCopyMoveContext = {
		id		: ${task != null ? task.id : 'null'},
		tracker : {
			id		: ${branch != null ? branch.id : tracker.id},
			type	: ${tracker.issueTypeId},
			path	: '<spring:escapeBody javaScriptEscape="true">${tracker.scopeName}</spring:escapeBody>',
			name	: '<spring:escapeBody javaScriptEscape="true">${tracker.name}</spring:escapeBody>',
			title	: '<spring:escapeBody javaScriptEscape="true">${tracker.description}</spring:escapeBody>',
			project	: {
				id   : ${tracker.project.id},
				name : '<spring:escapeBody javaScriptEscape="true">${tracker.project.name}</spring:escapeBody>'
			},
			baseline : <c:choose><c:when test="${baseline == null}">null</c:when><c:otherwise>{
				id   : ${baseline.id},
				name : '<spring:escapeBody javaScriptEscape="true">${baseline.name}</spring:escapeBody>'
			}</c:otherwise></c:choose>
		}
	};


</script>
