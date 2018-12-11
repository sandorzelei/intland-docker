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
	.newskin .optional, .newskin .mandatory {
		vertical-align: top;
	}

	label.targetType.undefined {
		color: FireBrick;
	}

	td.attributesLabel > span.ui-icon, td.attrName > span.ui-icon, td.relationName > span.ui-icon {
		display: none;
	}

	td.attributesLabel:hover > span.ui-icon, tr.attrib.expanded > td.attrName:hover > span.ui-icon, tr.linkType.expanded > td.relationName:hover > span.ui-icon {
		display: inline-block;
	}

	table.attribs, table.linkTypes {
		margin-left: 0px !important;
		margin-right: 0px !important;
	}

	tr.linkType td {
		padding-top: 0px !important;
		padding-bottom: 4px !important;
	}

	td.relationName {
		font-weight: bold;
	}

	tr.attrib, tr.option, tr.linkType {
		background-color: transparent !important;
	}

	tr.attrib td {
		padding-top: 4px !important;
		padding-bottom: 4px !important;
	}

	tr.option td {
		padding-top: 2px !important;
		padding-bottom: 2px !important;
	}

	td.optName {
		font-style: italic;
	}

	td.direction.import {
		background-image : url("./../images/exchange/export-thin.png");
		background-position: center center;
		background-repeat: no-repeat;
	}

	td.direction.export {
		background-image : url("./../images/exchange/import-thin.png");
		background-position: center center;
		background-repeat: no-repeat;
	}

	td.direction.bidirect {
		background-image : url("./../images/exchange/bidirect-thin.png");
		background-position: center center;
		background-repeat: no-repeat;
	}

	img.inlineEdit {
		margin-left: 6px;
		position: relative;
        top: 2px;
		display: none;
	}

	div.attrTarget:hover img.inlineEdit, div.optTarget:hover img.inlineEdit, td.linkTarget:hover img.inlineEdit, td.source:hover img.inlineEdit, td.direction:hover img.inlineEdit, td.log:hover img.inlineEdit {
		display: inline;
	}

	select.field {
		min-width: 12em;
		margin-right: 6px;
	}

	table.imports tr {
		border-top: 0px !important;
	}

	table.imports tr.import td {
		padding-top: 4px !important;
		padding-bottom: 4px !important;
	}

	table.imports table.statistics {
		border: 1px solid silver;
	}

	table.imports table.statistics th {
		padding-top: 1px !important;
		padding-bottom: 1px !important;
	}

	table.connectors th, table.projects th {
		font-weight: bold !important;
		padding-top: 2px !important;
		padding-bottom: 2px !important;
		margin-bottom: 4px !important;
	}

	tr.connector, tr.project, tr.connection {
		border-top: 0px !important;
	}

	tr.project td, tr.connector td {
		padding-top: 4px !important;
		padding-bottom: 4px !important;
	}

	tr.project td.projName {
		font-weight: bold !important;
	}

	tr.tracker td {
		padding-top: 2px !important;
		padding-bottom: 2px !important;
	}

	tr.secondary span.indenter {
		display: None;
	}

</style>

<%
	pageContext.setAttribute("fieldTypes", com.intland.codebeamer.persistence.dto.TrackerLayoutLabelDto.fieldTypeName);
	pageContext.setAttribute("issueTypes", com.intland.codebeamer.persistence.dto.TrackerTypeDto.TYPES);
%>

<script type="text/javascript" src="<ui:urlversioned value='/bugs/tracker/includes/userInfoLink.js'/>"></script>
<script type="text/javascript" src="<ui:urlversioned value='/bugs/includes/remoteImport.js'/>"></script>
<script type="text/javascript">

var remoteConnectionConfig = {
	server			: {
		label   	: '<spring:message code="remote.connection.server.label"      text="Server" javaScriptEscape="true"/>',
		title   	: '<spring:message code="remote.connection.server.tooltip"    text="The URL (web address) of the remote server/host" javaScriptEscape="true"/>',
		required	: '<spring:message code="remote.connection.server.required"   text="Please enter the URL (web address) of the remote server/host" javaScriptEscape="true"/>'
	},

	username		: {
		label 		: '<spring:message code="remote.connection.username.label"    text="Username" javaScriptEscape="true"/>',
		title		: '<spring:message code="remote.connection.username.tooltip"  javaScriptEscape="true"/>',
		required	: '<spring:message code="remote.connection.username.required" javaScriptEscape="true"/>'
	},

	password		: {
		label		: '<spring:message code="remote.connection.password.label"    text="Password" javaScriptEscape="true"/>',
		title		: '<spring:message code="remote.connection.password.tooltip"  text="The password to authenticate at the remote server/host. Can be ommitted, if the remote server allows anonymous access." javaScriptEscape="true"/>'
	}
};


var remoteImportSettingsConfig  = $.extend({}, remoteConnectionConfig, {
	attributes 			: {
		typeName 		: [<c:forEach items="${fieldTypes}" var="type">'<spring:message code="tracker.field.valueType.${type}.label" text="${type}" javaScriptEscape="true"/>', </c:forEach> 'undefined'],
		principalTypes	: [{
			id			: 2,
			name		: '<spring:message code="user.label" 				  text="User" javaScriptEscape="true"/>',
			plural		: '<spring:message code="tracker.field.Users.label" text="Users" javaScriptEscape="true"/>'
		}, {
			id			: 4,
			name		: '<spring:message code="group.name.label"  text="Group" javaScriptEscape="true"/>',
			plural		: '<spring:message code="user.groups.label" text="Groups" javaScriptEscape="true"/>'
		}, {
			id			: 8,
			name		: '<spring:message code="role.label" 			text="Role" javaScriptEscape="true"/>',
			plural		: '<spring:message code="project.roles.label" text="Roles" javaScriptEscape="true"/>'
		}],
		artifactTypes 	: {
			attachment	: {
				name	: '<spring:message code="comment.attachment.label" text="Attachment" javaScriptEscape="true"/>',
				plural	: '<spring:message code="attachments.label" 		 text="Attachments" javaScriptEscape="true"/>'
			},
			comment		: {
				name	: '<spring:message code="comment.label"  text="Comment" javaScriptEscape="true"/>',
				plural	: '<spring:message code="comments.label" text="Comments" javaScriptEscape="true"/>'
			},
			change		: {
				name	: '<spring:message code="tracker.field.Change.label"  text="Change" javaScriptEscape="true"/>',
				plural	: '<spring:message code="tracker.field.Changes.label" text="Changes" javaScriptEscape="true"/>'
			}
		},
		issueTypes		: {<c:forEach items="${issueTypes}" var="type"><c:if test="${type.id < 900}">
			"${type.id}"	: {
				name	: '<spring:message code="tracker.type.${type.name}" text="${type.name}" javaScriptEscape="true"/>',
				plural	: '<spring:message code="tracker.type.${type.name}.plural" text="${type.name}s" javaScriptEscape="true"/>'
			}, </c:if></c:forEach>
			"name" 		: {
				name	: '<spring:message code="tracker.field.Name.label" text="Name" javaScriptEscape="true"/>',
				plural	: '<spring:message code="tracker.field.Names.label" text="Names" javaScriptEscape="true"/>'
			},
			"sprint" 	: {
				name	: '<spring:message code="tracker.field.Sprint.label" text="Sprint" javaScriptEscape="true"/>',
				plural	: '<spring:message code="tracker.field.Sprint.plural.label" text="Sprints" javaScriptEscape="true"/>'
			}
		},
		notSupported 	: {
			image 		: '<c:url value="/images/error.gif"/>',
			label 		: '<spring:message code="import.config.unsupported.field.label"   text="Unsupported field" javaScriptEscape="true"/>',
			title 		: '<spring:message code="import.config.unsupported.field.tooltip" text="Fields of type {0} are not supported!" arguments="XXX" javaScriptEscape="true"/>'
		},
		multipleLabel		: '<spring:message code="tracker.choice.multiple.label" text="Multiple" javaScriptEscape="true"/>',
		selectFieldLabel	: '<spring:message code="import.config.select.field.label" text="Please select" javaScriptEscape="true"/>',
		selectFieldTitle	: '<spring:message code="import.config.select.field.tooltip" text="You must either choose a predefined field, or define a new field" javaScriptEscape="true"/>',
		selectAllLabel		: '<spring:message code="import.config.assign.all.label" text="Assign all" javaScriptEscape="true"/>',
		notPossible			: '<spring:message code="import.config.assign.not.possible" text="Not possible" javaScriptEscape="true"/>',
		clickToEditField	: '<spring:message code="import.config.edit.field.tooltip" text="(Double) Click, to choose a predefined field, or to define a new field" javaScriptEscape="true"/>',
		ignoreFieldLabel	: '<spring:message code="import.config.ignore.field.label" text="Ignore field" javaScriptEscape="true"/>',
		ignoreFieldTitle	: '<spring:message code="import.config.ignore.field.tooltip" text="The field value will be ignored (not imported)!" javaScriptEscape="true"/>',
		ignoreAllLabel		: '<spring:message code="import.config.ignore.all.label" text="Ignore all" javaScriptEscape="true"/>',
		newFieldLabel		: '<spring:message code="import.config.new.field.link"  text="New..." javaScriptEscape="true"/>',
		newFieldTitle		: '<spring:message code="import.config.new.field.label" text="New Field..." javaScriptEscape="true"/>',
		newFieldTooltip		: '<spring:message code="import.config.new.field.tooltip" text="Create a new custom target field for this attribute" javaScriptEscape="true"/>',
		fieldNameTitle		: '<spring:message code="import.config.new.field.title" text="The name of the new field (required)" javaScriptEscape="true"/>',
		duplicateFieldName	: '<spring:message code="import.config.new.field.duplicate" text="A field with the specified name already exists !" javaScriptEscape="true"/>',
		reservedFieldName	: '<spring:message code="import.config.new.field.reserved" text="The specified name is a reserved field name. Please choose another name !" javaScriptEscape="true"/>',
		clickToEditValue	: '<spring:message code="import.config.edit.value.tooltip" text="(Double) Click, to choose a predefined value, or to define a new value" javaScriptEscape="true"/>',
		selectValueLabel	: '<spring:message code="import.config.select.value.label" text="Please select" javaScriptEscape="true"/>',
		selectValueTitle	: '<spring:message code="import.config.select.value.tooltip" text="You must either choose a predefined value, or define a new value" javaScriptEscape="true"/>',
		newValueLabel		: '<spring:message code="import.config.new.value.link"  text="New..." javaScriptEscape="true"/>',
		newValueTitle		: '<spring:message code="import.config.new.value.label" text="New Value..." javaScriptEscape="true"/>',
		newValueTooltip		: '<spring:message code="import.config.new.value.tooltip" text="Create a new target value for this value" javaScriptEscape="true"/>',
		valueNameTitle 		: '<spring:message code="import.config.new.value.title" text="Please enter the name of the new value" javaScriptEscape="true"/>',
		duplicateValueName	: '<spring:message code="import.config.new.value.duplicate" text="A value with the specified name already exists !" javaScriptEscape="true"/>',
		createSimilarValue	: '<spring:message code="import.config.new.value.similar" text="A value with a name, that only differs in case, already exists ! Create the new value anyway ?" javaScriptEscape="true"/>',
		assignUnmappedOptions:'<spring:message code="import.config.new.value.assign" text="Automatically assign all unmapped values to matching or new target values" javaScriptEscape="true"/>',
		fieldMappingAmbigous: '<spring:message code="import.attribute.target.ambigous" text="Attribute {0} is mapped to the same field ({1}) as attribute {2}" arguments="XX,YY,ZZ" javaScriptEscape="true"/>',
		valueNotMapped		: '<spring:message code="import.attribute.option.target.missing" text="The value {1} of attribute {0} has not been mapped to a target value" arguments="XX,YY" javaScriptEscape="true"/>',
		valueMappingAmbigous: '<spring:message code="import.attribute.option.target.ambigous" text="The value {1} of attribute {0} has been mapped to the same target value ({2}) as value {3}" arguments="XX,YY,ZZ,WW" javaScriptEscape="true"/>',
		valuesLabel			: '<spring:message code="import.attribute.values.label" text="Values" javaScriptEscape="true"/>',
		requiredTitle		: '<spring:message code="import.attribute.mandatory.tooltip" text="This attribute is required/mandatory" javaScriptEscape="true"/>',
		requiredMissing		: '<spring:message code="import.attribute.mandatory.missing" text="Exporting new tracker items might fail, because required values for the mandatory attribute {0} are not exported!" arguments="XX" javaScriptEscape="true"/>',
		unmappedAttributes  : '<spring:message code="import.config.not.assigned.attributes.label" text="Attributes not mapped yet" javaScriptEscape="true"/>'
	},

	linkTypes				: {
		selectLinkLabel		: '<spring:message code="import.config.select.assoc.type.label" text="Please select" javaScriptEscape="true"/>',
		selectLinkTitle		: '<spring:message code="import.config.select.assoc.type.tooltip" text="Please choose, whether this type of relations should be mapped to a predefined association type, or not" javaScriptEscape="true"/>',
		ignoreLinkLabel		: '<spring:message code="import.config.select.assoc.type.ignore.label" text="Ignore links" javaScriptEscape="true"/>',
		ignoreLinkTitle		: '<spring:message code="import.config.select.assoc.type.ignore.tooltip" text="Links of this type will be ignored (not imported)!" javaScriptEscape="true"/>',
		linkMappingAmbigous	: '<spring:message code="import.config.select.assoc.type.ambigous" text="Link {0} is mapped to the same association type ({1}) as link {2}" arguments="XX,YY,ZZ" javaScriptEscape="true"/>',
		linksLabel			: '<spring:message code="import.links.label" text="Links" javaScriptEscape="true"/>'
	},

	direction		: {
		label		: '<spring:message code="import.config.direction.label"   text="Direction" javaScriptEscape="true"/>',
		title		: '<spring:message code="import.config.direction.tooltip" text="Whether to only import, export or synchronize bi-directionally" javaScriptEscape="true"/>',

		ignore		: {
			label	: '<spring:message code="import.config.direction.ignore.label"   text="Ignore {0}" arguments="XXX" javaScriptEscape="true"/>',
			title	: '<spring:message code="import.config.direction.ignore.tooltip" text="Ignore {0} from the remote system" arguments="XXX" javaScriptEscape="true"/>'
		},

		"import"	: {
			label	: '<spring:message code="import.config.direction.import.label"   text="Import {0}" arguments="XXX" javaScriptEscape="true"/>',
			title	: '<spring:message code="import.config.direction.import.tooltip" text="Only import {0} from the remote system" arguments="XXX" javaScriptEscape="true"/>'
		},

		"export"	: {
			label	: '<spring:message code="import.config.direction.export.label"   text="Export {0}" arguments="XXX" javaScriptEscape="true"/>',
			title	: '<spring:message code="import.config.direction.export.tooltip" text="Only export {0} to the remote system" arguments="XXX" javaScriptEscape="true"/>'
		},
		synchronize	: {
			label	: '<spring:message code="import.config.direction.synchronize.label"   text="Synchronize {0}" arguments="XXX" javaScriptEscape="true"/>',
			title	: '<spring:message code="import.config.direction.synchronize.tooltip" text="Synchronize {0} with the remote system" arguments="XXX" javaScriptEscape="true"/>'
		},
		unidirect 	: {
			label	: '<spring:message code="import.config.direction.only.label"   text="Only" javaScriptEscape="true"/>',
			title	: '<spring:message code="remote.data.label" text="Data" javaScriptEscape="true"/>'
		},
		bidirect	: {
			label	: '<spring:message code="import.config.direction.bidirect.label"   text="Bi-directionally" javaScriptEscape="true"/>',
			title	: '<spring:message code="remote.data.label" text="Data" javaScriptEscape="true"/>'
		}
	},

	enabled		: {
		label	: '<spring:message code="import.config.enabled.label"   text="Enabled" javaScriptEscape="true"/>',
		title	: '<spring:message code="import.config.enabled.tooltip" text="Whether the synchronization (in the specified direction) is enabled or not" javaScriptEscape="true"/>'
	},

	interval	: {
		label	: '<spring:message code="import.config.interval.label"    text="Interval" javaScriptEscape="true"/>',
		title	: '<spring:message code="import.config.interval.tooltip"  javaScriptEscape="true"/>',
		every	: '<spring:message code="import.config.interval.every"    text="every" javaScriptEscape="true"/>'
	},

	log	: {
		label	: '<spring:message code="import.log.label"    text="History" javaScriptEscape="true"/>',
		title   : '<spring:message code="import.log.tooltip"  text="How many synchronizations should be kept in the synchronization history ?" javaScriptEscape="true"/>',
		prefix	: '<spring:message code="import.log.prefix"   text="keep" javaScriptEscape="true"/>',
		all	 	: '<spring:message code="import.log.all"   	  text="all" javaScriptEscape="true"/>',
		lastX 	: '<spring:message code="import.log.lastX"	  text="the last {0}" arguments="XXX" javaScriptEscape="true"/>',
		suffix	: '<spring:message code="import.log.suffix"   text="synchronizations in the history" javaScriptEscape="true"/>'
	}

});

var remoteImportSettingsDialog = {
	label		: '<spring:message code="tracker.import.settings.label"   text="Settings..." javaScriptEscape="true" />',
	title		: '<spring:message code="tracker.import.settings.title"   text="Import Settings" javaScriptEscape="true" />',
	loading		: '<spring:message code="tracker.import.settings.loading" text="Loading settings, please wait ..." javaScriptEscape="true" />',
    fileText	: '<spring:message code="tracker.import.file.suffix" 	  text="file ..." javaScriptEscape="true"/>',
    saveAs		: {
    	label 	: '<spring:message code="tracker.import.settings.saveAs.label"   text="Save as" javaScriptEscape="true" />',
    	title	: '<spring:message code="tracker.import.settings.saveAs.tooltip" text="Save these settings as a file" javaScriptEscape="true" />'
    },
    loadFrom	: {
    	label	: '<spring:message code="tracker.import.settings.loadFrom.label"   text="Load from" javaScriptEscape="true" />',
    	title	: '<spring:message code="tracker.import.settings.loadFrom.tooltip" text="Load saved settings from a file" javaScriptEscape="true" />'
    },
	submitText  : '<spring:message code="button.ok" 	text="OK" 		javaScriptEscape="true"/>',
	cancelText  : '<spring:message code="button.cancel" text="Cancel" 	javaScriptEscape="true"/>',
    closeText	: '<spring:message code="button.close"  text="Close" 	javaScriptEscape="true"/>'
};

var remoteImportStatisticsConfig = {
	tracker 	  : {
		label	  : '<spring:message code="tracker.label"   			   text="Tracker" javaScriptEscape="true"/>',
		title	  : '<spring:message code="imported.tracker.items.tooltip" text="A project tracker, where items were created, updated or deleted by this import" javaScriptEscape="true"/>',
		items	  : {
			dialog    : {
				title : '<spring:message code="imported.tracker.items.title" text="Items, {0} in {1}" arguments="XXX,YYY" javaScriptEscape="true"/>'
			}
		}
	},
	"import"	  : {
		label	  : '<spring:message code="remote.import.label"   text="Import" javaScriptEscape="true"/>',
		title	  : '<spring:message code="remote.import.tooltip" text="Import from the remote system" javaScriptEscape="true"/>'
	},
	"export"	  : {
		label	  : '<spring:message code="remote.export.label"   text="Export" javaScriptEscape="true"/>',
		title	  : '<spring:message code="remote.export.tooltip" text="Export to the remote system" javaScriptEscape="true"/>',

		items	  : {
			title : '<spring:message code="exported.items.tooltip" text="The number of items, that were created, updated or deleted in the remote system by this export" javaScriptEscape="true"/>',
			dialog    : {
				link  : '<spring:message code="exported.items.link"  text="Show the items, that were {0} in the remote system" arguments="XXX" javaScriptEscape="true"/>',
				title : '<spring:message code="exported.items.title" text="Items, {0} in the remote system" arguments="XXX" javaScriptEscape="true"/>'
			}
		}
	},
	synchronization	: {
		label	  : '<spring:message code="remote.synchronization.label"   text="Synchronization" javaScriptEscape="true"/>',
		title	  : '<spring:message code="remote.synchronization.tooltip" text="Bi-directional synchronization with the remote system" javaScriptEscape="true"/>'
	},

	createdLabel  : '<spring:message code="activity.created" text="Created" javaScriptEscape="true"/>',
	updatedLabel  : '<spring:message code="activity.updated" text="Updated" javaScriptEscape="true"/>',
	deletedLabel  : '<spring:message code="activity.deleted" text="Deleted" javaScriptEscape="true"/>',
	failedLabel   : '<spring:message code="activity.failed"  text="Failed"  javaScriptEscape="true"/>',

	newValueLabel : '<spring:message code="issue.history.newValue.label" text="New Value"  javaScriptEscape="true"/>',
	oldValueLabel : '<spring:message code="issue.history.oldValue.label" text="Old Value"  javaScriptEscape="true"/>',

	operation	  : {
		label	  : '<spring:message code="tracker.field.op.label"   text="Operation" javaScriptEscape="true"/>',
		title	  : '<spring:message code="tracker.field.op.tooltip" text="The operation to perform on a field" javaScriptEscape="true"/>',
		"Set"	  : {
			label : '<spring:message code="tracker.field.op.Set.short"   text="Set" javaScriptEscape="true"/>',
			title : '<spring:message code="tracker.field.op.Set.tooltip" text="Set field value(s)" javaScriptEscape="true"/>'
		},
		"Add"	  : {
			label : '<spring:message code="tracker.field.op.Add.label"   text="Add" javaScriptEscape="true"/>',
			title : '<spring:message code="tracker.field.op.Add.tooltip" text="Add the specified value(s) to the current set of field values (if not already present)" javaScriptEscape="true"/>'
		},
		"Remove"  : {
			label : '<spring:message code="tracker.field.op.Remove.label"   text="Remove" javaScriptEscape="true"/>',
			title : '<spring:message code="tracker.field.op.Remove.tooltip" text="Remove the specified value(s) from the current field values" javaScriptEscape="true"/>'
		},
		failure  : {
			label : '<spring:message code="tracker.field.op.failure.label"  text="Failure" javaScriptEscape="true"/>',
			title : '<spring:message code="tracker.field.op.failed.tooltip" text="This operation failed. Click to get detailed information about the cause of the failure." javaScriptEscape="true"/>'
		}
	},

	users		  : {
		label	  : '<spring:message code="imported.users.label"   text="Users" javaScriptEscape="true"/>',
		title	  : '<spring:message code="imported.users.tooltip" text="The number of users, that were imported, updated or deleted in CodeBeamer" javaScriptEscape="true"/>',
		dialog    : {
			link  : '<spring:message code="imported.users.link"  text="Show the users, that were {0} in CodeBeamer" arguments="XXX" javaScriptEscape="true"/>',
			title : '<spring:message code="imported.users.title" text="Users, {0} in CodeBeamer" arguments="XXX" javaScriptEscape="true"/>'
		}
	},

	items		  : {
		label	  : '<spring:message code="imported.items.label"   text="Items" javaScriptEscape="true"/>',
		title	  : '<spring:message code="imported.items.tooltip" text="The number of items, that were created, updated or deleted in this tracker by this import" javaScriptEscape="true"/>',
		dialog    : {
			link  : '<spring:message code="imported.items.link"  text="Show the items, that were {0} in this tracker" arguments="XXX" javaScriptEscape="true"/>',
			title : '<spring:message code="imported.items.title" text="Items, {0} in this tracker" arguments="XXX" javaScriptEscape="true"/>',
		  changes : '<spring:message code="issue.history.changes.label"	text="Field changes (New value vs. Old value)" javaScriptEscape="true"/>'
		}
	}
};

var remoteImportHistoryDialog = {
	label		: '<spring:message code="tracker.import.history.label"   		text="History..." javaScriptEscape="true" />',
	title		: '<spring:message code="tracker.import.history.title"   		text="Import History" javaScriptEscape="true" />',
	loading		: '<spring:message code="tracker.import.history.loading" 		text="Loading Import History, please wait ..." javaScriptEscape="true" />',
	expandAll	: '<spring:message code="tracker.import.history.expandAll" 		text="Expand all" javaScriptEscape="true" />',
	collapseAll	: '<spring:message code="tracker.import.history.collapseAll" 	text="Collapse all" javaScriptEscape="true" />',
	more		: {
		label	: '<spring:message code="tracker.import.history.more.label"   	text="More ..." javaScriptEscape="true" />',
		title	: '<spring:message code="tracker.import.history.more.tooltip"   text="Load the next {0} of remaining {1} history entries" arguments="XX,YY" javaScriptEscape="true" />'
	},
	settings	: {
		label	: '<spring:message code="tracker.import.history.settings.label" text="Settings..." javaScriptEscape="true" />',
		title	: '<spring:message code="tracker.import.history.settings.title" text="Show the settings, that were used for this import" javaScriptEscape="true" />'
	}
};

</script>
