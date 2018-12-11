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


<script type="text/javascript" src="<ui:urlversioned value='/js/jquery/jquery-fileupload/jquery.iframe-transport.js'/>"></script>
<script type="text/javascript" src="<ui:urlversioned value='/js/jquery/jquery-fileupload/jquery.fileupload.js'/>"></script>
<script type="text/javascript" src="<ui:urlversioned value='/bugs/includes/jiraImport.js'/>"></script>
<script type="text/javascript">

var jiraIssuesSelectorConfig = {
	label		: '<spring:message code="jira.issues.select.label" text="Select..." javaScriptEscape="true"/>',
	title		: '<spring:message code="jira.issues.select.title" text="Please select the JIRA project and issue type to import" javaScriptEscape="true"/>',

	hierarchy	: {
		url		: '<c:url value="/ajax/jira/projectList.spr"/>',
		loading	: '<spring:message code="jira.projects.loading" text="Loading JIRA projects, Please wait..." javaScriptEscape="true"/>'
	},

	issueTypes	: {
		url 	: '<c:url value="/ajax/jira/project/XXX/issueTypes.spr"/>',
		loading : '<spring:message code="jira.issues.loading" text="Loading JIRA issue types, Please wait..." javaScriptEscape="true"/>'
	},

	validation	: {
		url		: '<c:url value="/ajax/jira/project/XXX/issueType/YYY/tracker.spr"/>',
		error 	: '<spring:message code="jira.issues.associated.with" text="The JIRA issue type {0} is already associated with tracker {1} in project {2}" arguments="XXX,YYY,ZZZ" javaScriptEscape="true"/>'
	},

	preview		: {
		label	: '<spring:message code="jira.issues.preview.label" text="Preview..." javaScriptEscape="true"/>'
	},

	submitText 	: '<spring:message code="button.ok" 	 text="OK" 	javaScriptEscape="true"/>',
	cancelText 	: '<spring:message code="button.cancel"  text="Cancel" javaScriptEscape="true"/>',
};


var jiraImportSettingsConfig = $.extend(true, {}, remoteImportSettingsConfig, {

	help		: {
		title	: '"Synchronizing trackers with Atlassian JIRA" in codeBeamer Knowledge Base',
		URL		: 'https://codebeamer.com/cb/wiki/3163101'
	},

	issues		: {
		label	: '<spring:message code="jira.issues.label"    text="Issues" javaScriptEscape="true"/>',
		title	: '<spring:message code="jira.issues.tooltip"  text="The JIRA project and issue type to import" javaScriptEscape="true"/>',
		selector: jiraIssuesSelectorConfig
	},

	schema		: {
		url		: '<c:url value="/ajax/jira/project/XXX/issueType/YYY/schema.spr?key=ZZZ"/>',
		loading	: '<spring:message code="jira.fields.loading" text="Loading fields of the selected JIRA issue type, please wait..." javaScriptEscape="true"/>'
	},

	references	: {
		label	: '<spring:message code="jira.references.label"	  text="References" javaScriptEscape="true"/>',
		title	: '<spring:message code="jira.references.tooltip"  text="How to handle specific JIRA issue references" javaScriptEscape="true"/>'
	},

	users		: {
		label	: '<spring:message code="jira.users.label"	  text="Users" javaScriptEscape="true"/>',
		title	: '<spring:message code="jira.users.tooltip"  text="Whether JIRA users referenced by issues, should be imported as CodeBeamer users, or should be simply referenced by name" javaScriptEscape="true"/>'
	},

	groups		: {
		label	: '<spring:message code="jira.groups.label"	  text="Groups" javaScriptEscape="true"/>',
		title	: '<spring:message code="jira.groups.tooltip" text="Whether JIRA groups referenced by issues, should be imported as CodeBeamer user groups, or should be simply referenced by name" javaScriptEscape="true"/>'
	},

	versions	: {
		label	: '<spring:message code="jira.versions.label"	text="Versions" javaScriptEscape="true"/>',
		title	: '<spring:message code="jira.versions.tooltip" text="Whether JIRA versions referenced by issues, should be imported as CodeBeamer Releases, or should be simply referenced by name" javaScriptEscape="true"/>'
	},

	components	: {
		label	: '<spring:message code="jira.components.label"	  text="Components" javaScriptEscape="true"/>',
		title	: '<spring:message code="jira.components.tooltip" text="Whether JIRA Components referenced by issues, should be imported as CodeBeamer Components or should be simply referenced by name" javaScriptEscape="true"/>'
	},

	teams		: {
		label	: '<spring:message code="jira.teams.label"	 text="Teams" javaScriptEscape="true"/>',
		title	: '<spring:message code="jira.teams.tooltip" text="Whether JIRA Teams referenced by issues, should be imported as CodeBeamer Teams or should be simply referenced by name" javaScriptEscape="true"/>',
		none	: '<spring:message code="jira.teams.none"	 text="There is no recognized JIRA Team field in this issue type" javaScriptEscape="true"/>',
		mismatch: '<spring:message code="jira.teams.mismatch" text="The values of the Team field of this JIRA issue type are not compatible with the Teams already imported into this project" javaScriptEscape="true"/>'
	},

	epics		: {
		label	: '<spring:message code="jira.epics.label"	 text="Epics" javaScriptEscape="true"/>',
		title	: '<spring:message code="jira.epics.tooltip" text="Whether JIRA Epic links should be imported as references to also imported Epics, or should be imported as simple JIRA Epic Keys" javaScriptEscape="true"/>'
	},

	attributes	: {
		label	: '<spring:message code="jira.fields.label"   text="Fields" javaScriptEscape="true"/>',
		title	: '<spring:message code="jira.fields.tooltip" text="The importable fields of the selected JIRA issue type" javaScriptEscape="true"/>',
		none	: '<spring:message code="jira.fields.none"    text="Theres are no importable fields of the selected JIRA issue type" javaScriptEscape="true"/>',

		issueTypes : {
			"103"  : {
				name	: '<spring:message code="jira.version.label"  text="Version" javaScriptEscape="true"/>',
				plural	: '<spring:message code="jira.versions.label" text="Versions" javaScriptEscape="true"/>'
			}
		},

		notSupported : {
			title : '<spring:message code="jira.field.unsupported.tooltip" text="Fields of custom type {0} are not supported, because they are not core JIRA fields, but add-ons via a JIRA plugin unknown to CodeBeamer!" arguments="XXX" javaScriptEscape="true"/>'
		}
	},

	linkTypes	: {
		label	: '<spring:message code="jira.links.label"   text="Links" javaScriptEscape="true"/>',
		title	: '<spring:message code="jira.links.tooltip" text="The importable JIRA issue link types" javaScriptEscape="true"/>',
		none	: '<spring:message code="jira.links.none"    text="There are no importable JIRA issue link types" javaScriptEscape="true"/>'
	}
});


var jiraWorkflowDialogConfig = {
	title		: '<spring:message code="jira.workflow.title" text="JIRA workflow synchronization" javaScriptEscape="true"/>',
	message		: '<spring:message code="jira.workflow.hint" arguments="XXX" javaScriptEscape="true"/>',

	resolution	: {
		required: '<spring:message code="jira.workflow.resolution.hint" javaScriptEscape="true"/>'
	},

	changeUser	: {
		label	: '<spring:message code="jira.workflow.user.label" 	 text="Change the user" javaScriptEscape="true"/>',
		title   : '<spring:message code="jira.workflow.user.tooltip" text="Change the user for the JIRA synchronization to a JIRA administrator" javaScriptEscape="true"/>'
	},

	syncFromFile: {
		label	: '<spring:message code="jira.workflow.file.label" 	text="Sync from file" javaScriptEscape="true"/>',
		title   : '<spring:message code="jira.workflow.file.tooltip" arguments="XXX,YYY"  htmlEscape="false"/>',
		url		: '<c:url value="/ajax/jira/workflow.spr"/>'
	},

	syncAsAdmin	: $.extend({}, remoteConnectionConfig, {
		label	: '<spring:message code="jira.workflow.admin.label"   text="Sync as admin" javaScriptEscape="true"/>',
		title   : '<spring:message code="jira.workflow.admin.tooltip" text="Synchronize the workflow with a one-time administrator login" javaScriptEscape="true"/>',
		url		: '<c:url value="/ajax/jira/project/XXX/issueType/YYY/workflow.spr"/>',
		submitText : '<spring:message code="button.ok" 	text="OK" 		javaScriptEscape="true"/>',
		cancelText : '<spring:message code="button.cancel" text="Cancel" 	javaScriptEscape="true"/>'
	}),

	dontSync	: {
		label	: '<spring:message code="jira.workflow.nosync.label" text="Don't sync" javaScriptEscape="true"/>',
		title   : '<spring:message code="jira.workflow.nosync.tooltip" text="The CodeBeamer workflow will not be synchronized with the JIRA workflow." htmlEscape="false"/>'
	}
};


var jiraSettingsDialogConfig = $.extend({}, remoteImportSettingsDialog, {
	label		: '<spring:message code="jira.tracker.sync.settings.label" 	text="Settings..." javaScriptEscape="true" />',
	title		: '<spring:message code="jira.tracker.sync.settings.title" 	text="JIRA Settings" javaScriptEscape="true" />',
	loading		: '<spring:message code="jira.tracker.sync.settings.loading" text="Loading settings, please wait ..." javaScriptEscape="true" />',
	settingsURL	: '<c:url value="/ajax/jira/settings.spr"/>',
	remove		: {
		label	: '<spring:message code="jira.tracker.sync.remove.label" 	text="Remove..." javaScriptEscape="true" />',
		confirm : '<spring:message code="jira.tracker.sync.remove.confirm" 	text="Do you really want to irreversible remove the synchronization of this tracker with Atlassian JIRA ?" javaScriptEscape="true" />'
	},
	workflow	: jiraWorkflowDialogConfig
});


var jiraImportStatisticsConfig = $.extend(true, {}, remoteImportStatisticsConfig, {
	nothing 	: '<spring:message code="jira.tracker.sync.nothing"	text="The import has finished successfully, but there was no new data to import" javaScriptEscape="true" />',

	"export"	: $.extend(true, {}, remoteImportStatisticsConfig["export"], {
		issues	  : {
			title : '<spring:message code="jira.issues.exported.tooltip" text="The number of issues, that were created, updated or deleted in JIRA by this export" javaScriptEscape="true"/>',
			dialog    : {
				link  : '<spring:message code="jira.issues.exported.link" text="Show the items, that were {0} in JIRA" arguments="XXX" javaScriptEscape="true"/>',
				title : '<spring:message code="jira.issues.exported.title" text="Items, {0} in JIRA" arguments="XXX" javaScriptEscape="true"/>'
			}
		},
		attachments	: {
			title	: '<spring:message code="jira.attachments.exported" text="The number of attachments, that were created, updated or deleted in JIRA" javaScriptEscape="true"/>'
		},
		comments	: {
			title	: '<spring:message code="jira.comments.exported" text="The number of comments, that were created, updated or deleted in JIRA" javaScriptEscape="true"/>'
		},
		worklog		: {
			title	: '<spring:message code="jira.worklog.exported" text="The number of issue worklog entries, that were created, updated or deleted in JIRA" javaScriptEscape="true"/>'
		},
		links		: {
			title	: '<spring:message code="jira.links.exported" text="The number of issue links, that were created, updated or deleted in JIRA" javaScriptEscape="true"/>'
		}
	}),

	issues		: remoteImportStatisticsConfig.items,

	remoteLink  : 'XXX/browse/YYY',

	groups		: {
		label	: '<spring:message code="jira.groups.label"	  text="Groups" javaScriptEscape="true"/>',
		title	: '<spring:message code="jira.groups.imported" text="The number of JIRA groups, that were imported, updated or deleted in CodeBeamer" javaScriptEscape="true"/>'
	},

	teams		: {
		label	: '<spring:message code="jira.teams.label"	  text="Teams" javaScriptEscape="true"/>',
		title	: '<spring:message code="jira.teams.imported" text="The number of JIRA teams, that were imported, updated or deleted in CodeBeamer" javaScriptEscape="true"/>'
	},

	versions	: {
		label	: '<spring:message code="jira.versions.label"	 text="Versions" javaScriptEscape="true"/>',
		title	: '<spring:message code="jira.versions.imported" text="The number of JIRA versions, that were imported, updated or deleted in CodeBeamer" javaScriptEscape="true"/>'
	},

	sprints		: {
		label	: '<spring:message code="jira.sprints.label"	 text="Sprints" javaScriptEscape="true"/>',
		title	: '<spring:message code="jira.sprints.imported"  text="The number of JIRA sprints, that were imported, updated or deleted in CodeBeamer" javaScriptEscape="true"/>'
	},

	components	: {
		label	: '<spring:message code="jira.components.label"	   text="Components" javaScriptEscape="true"/>',
		title	: '<spring:message code="jira.components.imported" text="The number of JIRA components, that were imported, updated or deleted in CodeBeamer" javaScriptEscape="true"/>'
	},

	attachments	: {
		label	: '<spring:message code="jira.attachments.label"	text="Attachments" javaScriptEscape="true"/>',
		title	: '<spring:message code="jira.attachments.imported" text="The number of JIRA issue attachments, that were imported, updated or deleted in CodeBeamer" javaScriptEscape="true"/>'
	},

	comments	: {
		label	: '<spring:message code="jira.comments.label"	 text="Comments" javaScriptEscape="true"/>',
		title	: '<spring:message code="jira.comments.imported" text="The number of JIRA issue comments, that were imported, updated or deleted in CodeBeamer" javaScriptEscape="true"/>'
	},

	history		: {
		label	: '<spring:message code="jira.history.label"	text="History" javaScriptEscape="true"/>',
		title	: '<spring:message code="jira.history.imported" text="The number of JIRA issue history entries, that were imported to CodeBeamer" javaScriptEscape="true"/>'
	},

	worklog		: {
		label	: '<spring:message code="jira.worklog.label"	text="Worklog" javaScriptEscape="true"/>',
		title	: '<spring:message code="jira.worklog.imported" text="The number of JIRA issue worklog entries, that were imported, updated or deleted in CodeBeamer" javaScriptEscape="true"/>'
	},

	links		: {
		label	: '<spring:message code="jira.links.label"	  text="Links" javaScriptEscape="true"/>',
		title	: '<spring:message code="jira.links.imported" text="The number of JIRA issue links, that were imported, updated or deleted in CodeBeamer" javaScriptEscape="true"/>'
	}
});


var jiraImportHistoryDialog = $.extend(true, {}, remoteImportHistoryDialog, {
	label		: '<spring:message code="jira.tracker.sync.history.label"   text="History..." javaScriptEscape="true" />',
	title		: '<spring:message code="jira.tracker.sync.history.title"   text="JIRA Import History" javaScriptEscape="true" />',
	loading		: '<spring:message code="jira.tracker.sync.history.loading" text="Loading JIRA Import History, please wait ..." javaScriptEscape="true" />',
	historyURL	: '<c:url value="/ajax/jira/synchronization/history.spr"/>'
});


var jiraSyncConfig = {
	issues		: {
		label	: '<spring:message code="jira.issues.label"     text="Issues" javaScriptEscape="true"/>',
		title	: '<spring:message code="jira.issues.tooltip"   text="The JIRA project and issue type to import" javaScriptEscape="true"/>'
	},
	history 	: {
		config   : jiraImportStatisticsConfig,
		dialog   : jiraImportHistoryDialog,
		settings : {
			config : $.extend({}, jiraImportSettingsConfig, {
				editable : false
			}),
			dialog : jiraSettingsDialogConfig,
		}
	},
	lastImport	: {
		label 	: '<spring:message code="jira.tracker.import.last.label"   text="Last Import" javaScriptEscape="true"/>',
		title 	: '<spring:message code="jira.tracker.import.last.tooltip" text="Date and time of the last import from JIRA" javaScriptEscape="true"/>',
		never	: '<spring:message code="jira.tracker.import.last.none"    text="Never" javaScriptEscape="true"/>'
	},
	lastExport	: {
		label 	: '<spring:message code="jira.tracker.export.last.label"   text="Last Import" javaScriptEscape="true"/>',
		title 	: '<spring:message code="jira.tracker.export.last.tooltip" text="Date and time of the last export to JIRA" javaScriptEscape="true"/>',
		never	: '<spring:message code="jira.tracker.export.last.none"    text="Never" javaScriptEscape="true"/>'
	},
	lastSync	: {
		label 	: '<spring:message code="jira.tracker.sync.last.label"   	text="Last Synchronization" javaScriptEscape="true"/>',
		title 	: '<spring:message code="jira.tracker.sync.last.tooltip"	text="Date and time of the last synchronization with JIRA" javaScriptEscape="true"/>',
		never	: '<spring:message code="jira.tracker.sync.last.none"		text="Never" javaScriptEscape="true"/>'
	},
	nextImport	: {
		label	: '<spring:message code="jira.tracker.import.next.label" 	text="Next Import" javaScriptEscape="true" />',
		title	: '<spring:message code="jira.tracker.import.next.tooltip" 	text="Date and time of the next scheduled import from JIRA" javaScriptEscape="true" />',
		none	: '<spring:message code="jira.tracker.import.next.none"		text="Not scheduled" javaScriptEscape="true" />'
	},
	nextExport	: {
		label	: '<spring:message code="jira.tracker.export.next.label" 	text="Next Export" javaScriptEscape="true" />',
		title	: '<spring:message code="jira.tracker.export.next.tooltip"	text="Date and time of the next scheduled export to JIRA" javaScriptEscape="true" />',
		none	: '<spring:message code="jira.tracker.export.next.none"		text="Not scheduled" javaScriptEscape="true" />'
	},
	nextSync	: {
		label 	: '<spring:message code="jira.tracker.sync.next.label"		text="Next Synchronization" javaScriptEscape="true"/>',
		title 	: '<spring:message code="jira.tracker.sync.next.tooltip"	text="Date and time of the next scheduled synchronization with JIRA" javaScriptEscape="true"/>',
		none	: '<spring:message code="jira.tracker.sync.next.none"		text="Not scheduled" javaScriptEscape="true"/>',
		disabled: '<spring:message code="jira.tracker.sync.next.disabled"	text="Disabled" javaScriptEscape="true"/>'
	}
};


var jiraSyncDialogConfig = {
	importURL	: '<c:url value="/ajax/jira/synchronization.spr"/>',
	loading		: '<spring:message code="jira.tracker.sync.loading" 	text="Loading synchronization information ..." javaScriptEscape="true" />',
	disabled	: '<spring:message code="jira.tracker.sync.disabled" 	text="Synchronization of this tracker with Atlassian JIRA has been disabled!" javaScriptEscape="true" />',
	synchronize : {
		label	: '<spring:message code="jira.tracker.sync.button" 		text="Synchronize" javaScriptEscape="true" />',
		title	: '<spring:message code="jira.tracker.sync.label" 		text="Synchronize with JIRA" javaScriptEscape="true" />',
		running	: '<spring:message code="jira.tracker.sync.running"		text="Synchronizing with Atlassian JIRA ..." javaScriptEscape="true" />'
	},
	"import"	: {
		label	: '<spring:message code="jira.tracker.import.button" 	text="Import" javaScriptEscape="true" />',
		title	: '<spring:message code="jira.tracker.import.label" 	text="Import from JIRA" javaScriptEscape="true" />',
		running	: '<spring:message code="jira.tracker.import.running"	text="Importing from Atlassian JIRA ..." javaScriptEscape="true" />'
	},
	"export"	: {
		label	: '<spring:message code="jira.tracker.export.button" 	text="Export" javaScriptEscape="true" />',
		title	: '<spring:message code="jira.tracker.export.label" 	text="Export to JIRA" javaScriptEscape="true" />',
		running	: '<spring:message code="jira.tracker.export.running"	text="Exporting to Atlassian JIRA ..." javaScriptEscape="true" />'
	},
	result 		: jiraImportStatisticsConfig,
	settings	: {
		none	: '<spring:message code="jira.tracker.sync.none" 		text="This tracker has not been configured for an Import from JIRA yet!" javaScriptEscape="true" />',
		confirm	: '<spring:message code="jira.tracker.sync.confirm" 	text="No JIRA project and issue type has been associated with this tracker yet. Do you want to configure one now ?" javaScriptEscape="true" />',
		config  : jiraImportSettingsConfig,
		dialog  : jiraSettingsDialogConfig
	}
};


function syncWithJIRA(trackerId) {
	var popup = $('#JiraSyncPopup');
	if (popup.length == 0) {
		popup = $('<div>', { id : 'JiraSyncPopup', "class" : 'editorPopup', style : 'display: None;' });
		$(document.documentElement).append(popup);
	} else {
		popup.empty();
	}

	popup.showJiraSyncDialog(trackerId, jiraSyncConfig, jiraSyncDialogConfig);

	return false;
}

</script>